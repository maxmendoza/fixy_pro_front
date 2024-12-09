import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<Profile> {
  final _nameController = TextEditingController();
  final _apellidoPaternoController = TextEditingController();
  final _apellidoMaternoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _emailController = TextEditingController();
  final _direccionController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();

  String? _userPhoto; // Foto del usuario (Base64)
  String _userName = ''; // Nombre del usuario
  bool _isEditingPersonal = false;
  bool _isLoading = true;

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl = 'http://127.0.0.1:8080';

  int? _userId; // Almacena el ID del usuario
  List<Map<String, dynamic>> _ubicaciones = []; // Lista de ubicaciones

  GoogleMapController? _mapController;
  LatLng _selectedLocation = LatLng(19.432608, -99.133209); // Ubicación inicial
  final String googleApiKey =
      "YOUR_GOOGLE_API_KEY"; // Cambia esto con tu API Key

  @override
  void initState() {
    super.initState();
    _configureDio();
    _fetchUserProfile();
  }

  // Configura Dio para incluir automáticamente el token
  void _configureDio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) {
          debugPrint('Error en la solicitud: ${e.response?.data}');
          handler.next(e);
        },
      ),
    );
  }

  // Obtiene el perfil del usuario desde el servidor
  Future<void> _fetchUserProfile() async {
    try {
      final response = await _dio.get('$baseUrl/user/profile');

      if (response.statusCode == 200) {
        final data = response.data;

        setState(() {
          _nameController.text = data['name'];
          _apellidoPaternoController.text = data['firstSurname'];
          _apellidoMaternoController.text = data['secondSurname'];
          _telefonoController.text = data['phone'];
          _emailController.text = data['email'];
          _userPhoto = data['photo']; // Foto en base64
          _userName = data['name'] ?? 'Usuario';
          _userId = data['id']; // Guarda el userId obtenido del perfil
          _isLoading = false;
        });

        // Llama a la función de ubicaciones después de obtener el perfil
        _fetchUserLocations();
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar perfil: ${e.message}')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Obtiene las ubicaciones del usuario desde el servidor
  Future<void> _fetchUserLocations() async {
    if (_userId == null) {
      return;
    }
    try {
      final response =
          await _dio.get('$baseUrl/api/ubicaciones/usuario/$_userId');

      if (response.statusCode == 200) {
        setState(() {
          _ubicaciones = List<Map<String, dynamic>>.from(response.data);
        });
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar ubicaciones: ${e.message}')),
      );
    }
  }

  // Añade una nueva ubicación
  Future<void> _addUserLocation(
      String direccion, double latitud, double longitud) async {
    if (_userId == null) {
      return;
    }
    try {
      final Map<String, dynamic> data = {
        "direccion": direccion,
        "latitud": latitud,
        "longitud": longitud,
      };

      final response = await _dio.post(
        '$baseUrl/api/ubicaciones/$_userId',
        data: data,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ubicación añadida correctamente')),
        );
        _fetchUserLocations(); // Refrescar las ubicaciones
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al añadir ubicación: ${e.message}')),
      );
    }
  }

  // Elimina una ubicación del usuario
  Future<void> _deleteUserLocation(int ubicacionId) async {
    try {
      final response =
          await _dio.delete('$baseUrl/api/ubicaciones/$ubicacionId');

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ubicación eliminada correctamente')),
        );
        _fetchUserLocations(); // Refrescar las ubicaciones
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar ubicación: ${e.message}')),
      );
    }
  }

  // Búsqueda de ubicación por nombre utilizando Google Places API
  Future<void> _fetchLocationFromAddress(String address) async {
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$googleApiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          setState(() {
            _selectedLocation = LatLng(location['lat'], location['lng']);
            _latitudController.text = location['lat'].toString();
            _longitudController.text = location['lng'].toString();
          });
          // Mover la cámara del mapa a la nueva ubicación
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(_selectedLocation),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ubicación no encontrada')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al buscar la ubicación')),
      );
    }
  }

  // Obtener sugerencias de direcciones mientras se escribe
  Future<List<String>> _getSuggestions(String query) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(query)}&key=$googleApiKey';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['predictions'] != null) {
          return List<String>.from(data['predictions']
              .map((prediction) => prediction['description']));
        }
      }
    } catch (e) {
      debugPrint('Error obteniendo sugerencias: $e');
    }
    return [];
  }

  // Mostrar diálogo para añadir una nueva ubicación
  void _showAddLocationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Añadir Ubicación"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TypeAheadField<String>(
                builder: (context, controller, focusNode) {
                  return TextField(
                    controller: _direccionController,
                    focusNode: focusNode,
                    decoration: const InputDecoration(labelText: "Dirección"),
                  );
                },
                suggestionsCallback: _getSuggestions,
                itemBuilder: (context, String suggestion) {
                  return ListTile(
                    title: Text(suggestion),
                  );
                },
                onSelected: (String suggestion) {
                  _direccionController.text = suggestion;
                  _fetchLocationFromAddress(suggestion);
                },
              ),
              const SizedBox(height: 10),
              Container(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 14.0,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onTap: (LatLng position) {
                    setState(() {
                      _selectedLocation = position;
                      _latitudController.text = position.latitude.toString();
                      _longitudController.text = position.longitude.toString();
                    });
                  },
                  markers: {
                    Marker(
                      markerId: const MarkerId('selected-location'),
                      position: _selectedLocation,
                    ),
                  },
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _latitudController,
                decoration: const InputDecoration(labelText: "Latitud"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _longitudController,
                decoration: const InputDecoration(labelText: "Longitud"),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                final direccion = _direccionController.text;
                final latitud = double.tryParse(_latitudController.text) ??
                    _selectedLocation.latitude;
                final longitud = double.tryParse(_longitudController.text) ??
                    _selectedLocation.longitude;

                if (direccion.isNotEmpty) {
                  _addUserLocation(direccion, latitud, longitud);
                  Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Por favor, complete todos los campos.')),
                  );
                }
              },
              child: const Text("Añadir"),
            ),
          ],
        );
      },
    );
  }

  // Actualiza el perfil del usuario en el servidor
  Future<void> _updateUserProfile() async {
    try {
      final Map<String, dynamic> data = {
        "name": _nameController.text,
        "firstSurname": _apellidoPaternoController.text,
        "secondSurname": _apellidoMaternoController.text,
        "phone": _telefonoController.text,
      };

      final response = await _dio.put(
        '$baseUrl/user/profile',
        data: data,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado correctamente')),
        );
        setState(() {
          _isEditingPersonal = false;
        });
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar perfil: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "FixyPro",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF063852),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await _storage.delete(key: 'auth_token'); // Elimina el token
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Burbuja con imagen y nombre de usuario
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: _userPhoto != null
                            ? MemoryImage(base64Decode(_userPhoto!))
                            : const AssetImage('assets/avatar.png')
                                as ImageProvider,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _userName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(padding: EdgeInsets.all(4)),
                      Text(
                        _apellidoPaternoController.text,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Información Personal',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          _buildEditableField(
                              "Nombre", _nameController, _isEditingPersonal),
                          const SizedBox(height: 10),
                          _buildEditableField("Apellido Paterno",
                              _apellidoPaternoController, _isEditingPersonal),
                          const SizedBox(height: 10),
                          _buildEditableField("Apellido Materno",
                              _apellidoMaternoController, _isEditingPersonal),
                          const SizedBox(height: 10),
                          _buildEditableField("Teléfono", _telefonoController,
                              _isEditingPersonal),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_isEditingPersonal) {
                                  _updateUserProfile();
                                } else {
                                  setState(() {
                                    _isEditingPersonal = true;
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isEditingPersonal
                                    ? Colors.green
                                    : const Color(0xFFFFA500),
                              ),
                              child: Text(
                                  _isEditingPersonal ? "Guardar" : "Editar"),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Card para las ubicaciones del usuario
                  Card(
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Ubicaciones',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ..._ubicaciones.map((ubicacion) => ListTile(
                                title: Text(ubicacion['direccion']),
                                subtitle: Text(
                                    'Lat: ${ubicacion['latitud']}, Lng: ${ubicacion['longitud']}'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    _deleteUserLocation(ubicacion['id']);
                                  },
                                ),
                              )),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _showAddLocationDialog(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text("Añadir Ubicación"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildEditableField(
      String label, TextEditingController controller, bool isEditable) {
    return TextFormField(
      controller: controller,
      readOnly: !isEditable,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }
}
