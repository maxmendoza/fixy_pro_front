import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeUsers extends StatefulWidget {
  const HomeUsers({super.key});

  @override
  State<HomeUsers> createState() => _HomeUsersState();
}

class _HomeUsersState extends State<HomeUsers> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  CameraPosition? _initialPosition;
  final Set<Marker> _listMarkers = {};
  String _selectedLocation = 'Casa 1';
  final List<String> _locations = ['Casa 1', 'Casa 2', 'Casa 3'];

  @override
  void initState() {
    super.initState();
    _initializeMap();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Quitar la flecha de navegación
        title: const Text(
          "FixyPro",
          style: TextStyle(
            color: Colors.white, // Texto en blanco
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFE4A320), // Fondo naranja
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white, // Ícono en blanco
            ),
            onPressed: () {
              // Navegar al login
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color(0xFFE4A320), // Fondo naranja para la barra inferior
        child: Container(
          height: 50.0,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: _selectedLocation,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedLocation = newValue!;
                });
              },
              items: _locations.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              isExpanded: true,
              style: const TextStyle(
                color: Colors.black, // Color del texto del Dropdown
                fontSize: 16,
              ),
              dropdownColor:
                  const Color(0xFFFFF3E0), // Fondo del dropdown (tono suave)
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
          // Botón "Mis Ofertas" más grande
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: ElevatedButton(
              onPressed: () {
                // Navegar a la sección de ofertas
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF9F00), // Color naranja
                padding: const EdgeInsets.symmetric(
                    vertical: 20, horizontal: 20), // Aumenta el padding
                minimumSize:
                    const Size(double.infinity, 70), // Aumenta la altura
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15), // Bordes más grandes
                ),
              ),
              child: const Text(
                'Mis Ofertas',
                style: TextStyle(
                  fontSize: 22, // Tamaño de fuente más grande
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
