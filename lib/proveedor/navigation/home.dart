import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';

class HomeScrean extends StatefulWidget {
  const HomeScrean({super.key});

  @override
  State<HomeScrean> createState() => _HomeState();
}

class _HomeState extends State<HomeScrean> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  CameraPosition? _initialPosition;
  final Set<Marker> _listMarkers = {};
  String? _selectedLocation;
  List<Map<String, dynamic>> _userLocations = [];
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl = 'http://127.0.0.1:8080';

  @override
  void initState() {
    super.initState();
    _configureDio();
    _initializeMap();
    _fetchUserLocations();
  }

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

  Future<void> _fetchUserLocations() async {
    try {
      final response = await _dio.get('$baseUrl/api/ubicaciones/usuario/8');
      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(response.data);
        setState(() {
          _userLocations = data;
          _selectedLocation = _userLocations.isNotEmpty
              ? _userLocations.first['direccion']
              : null;

          for (var location in _userLocations) {
            _listMarkers.add(
              Marker(
                markerId: MarkerId(location['direccion']),
                position: LatLng(location['latitud'], location['longitud']),
                infoWindow: InfoWindow(
                  title: location['direccion'],
                ),
              ),
            );
          }
        });
      }
    } on DioException catch (e) {
      debugPrint("Error al obtener ubicaciones: ${e.message}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar ubicaciones: ${e.message}'),
        ),
      );
    }
  }

  Future<void> _initializeMap() async {
    try {
      final position = await _determinePosition();
      setState(() {
        _initialPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 14.4746,
        );

        _listMarkers.add(
          Marker(
            markerId: const MarkerId("current_location"),
            position: LatLng(position.latitude, position.longitude),
            infoWindow: const InfoWindow(
              title: "Ubicación actual",
              snippet: "Aquí estás",
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueViolet),
          ),
        );
      });
    } catch (e) {
      debugPrint("Error al inicializar el mapa: $e");
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      throw 'Los servicios de ubicación están desactivados.';
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Permisos de ubicación denegados.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Permisos de ubicación denegados permanentemente.';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<void> _moveToSelectedLocation(String locationName) async {
    final location = _userLocations.firstWhere(
      (loc) => loc['direccion'] == locationName,
      orElse: () => {},
    );

    if (location != null) {
      final GoogleMapController mapController = await _controller.future;
      final LatLng position = LatLng(location['latitud'], location['longitud']);
      mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 16));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "FixyPro",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF063852),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    value: _selectedLocation,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedLocation = newValue;
                        if (newValue != null) {
                          _moveToSelectedLocation(newValue);
                        }
                      });
                    },
                    items: _userLocations
                        .map<DropdownMenuItem<String>>((location) {
                      return DropdownMenuItem<String>(
                        value: location['direccion'],
                        child: Text(location['direccion']),
                      );
                    }).toList(),
                    isExpanded: true,
                    hint: const Text("Selecciona una ubicación"),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _initialPosition == null
                ? const Center(child: CircularProgressIndicator())
                : GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _initialPosition!,
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    markers: _listMarkers,
                  ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/hiring_order');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                minimumSize: const Size(double.infinity, 70),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                'Publicar Problema',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
