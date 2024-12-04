import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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

  String? _userPhoto; // Foto del usuario (Base64)
  String _userName = ''; // Nombre del usuario
  bool _isEditingPersonal = false;
  bool _isLoading = true;

  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl = 'http://127.0.0.1:8080';

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
          _isLoading = false;
        });
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
