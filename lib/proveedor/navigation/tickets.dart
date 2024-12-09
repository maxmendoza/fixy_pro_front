import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TicketsSupplierScreen extends StatefulWidget {
  const TicketsSupplierScreen({Key? key}) : super(key: key);

  @override
  _TicketsSupplierScreenState createState() => _TicketsSupplierScreenState();
}

class _TicketsSupplierScreenState extends State<TicketsSupplierScreen> {
  String selectedState = 'ABIERTO'; // Estado seleccionado
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final String baseUrl = 'http://127.0.0.1:8080';
  Map<String, List<dynamic>> problemasPorEstado = {
    'ABIERTO': [],
    'EN_PROCESO': [],
    'RESUELTO': [],
    'CERRADO': [],
  };

  @override
  void initState() {
    super.initState();
    _configureDio(); // Configurar interceptores
    _fetchProblemas();
  }

  void _configureDio() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error en la solicitud: ${e.message}')),
          );
          handler.next(e);
        },
      ),
    );
  }

  Future<void> _fetchProblemas() async {
    try {
      final response = await _dio.get('$baseUrl/api/problemas');
      if (response.statusCode == 200) {
        final List<dynamic> problemas = response.data;
        setState(() {
          problemasPorEstado = {
            'ABIERTO':
                problemas.where((p) => p['estado'] == 'ABIERTO').toList(),
            'EN_PROCESO':
                problemas.where((p) => p['estado'] == 'EN_PROCESO').toList(),
            'RESUELTO':
                problemas.where((p) => p['estado'] == 'RESUELTO').toList(),
            'CERRADO':
                problemas.where((p) => p['estado'] == 'CERRADO').toList(),
          };
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar problemas: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color unselectedButtonColor = Color(0xFF063852); // Azul oscuro
    const Color selectedButtonColor = Color(0xFFFFC107); // Amarillo

    return Scaffold(
      backgroundColor: Colors.white,
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
              await _storage.delete(key: 'auth_token');
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          // Botones superiores
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: unselectedButtonColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStateButton(
                  'ABIERTO',
                  Icons.warning_amber_rounded,
                  selectedButtonColor,
                  unselectedButtonColor,
                ),
                _buildStateButton(
                  'EN_PROCESO',
                  Icons.timelapse,
                  selectedButtonColor,
                  unselectedButtonColor,
                ),
                _buildStateButton(
                  'RESUELTO',
                  Icons.check_circle_outline,
                  selectedButtonColor,
                  unselectedButtonColor,
                ),
                _buildStateButton(
                  'CERRADO',
                  Icons.cancel,
                  selectedButtonColor,
                  unselectedButtonColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Lista dinámica
          Expanded(
            child: _buildProblemaList(problemasPorEstado[selectedState] ?? []),
          ),
        ],
      ),
    );
  }

  Widget _buildStateButton(
    String state,
    IconData icon,
    Color selectedColor,
    Color unselectedColor,
  ) {
    final bool isSelected = selectedState == state;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedState = state;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : unselectedColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? Colors.black : Colors.white),
              const SizedBox(height: 5),
              Text(
                state,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProblemaList(List<dynamic> problemas) {
    if (problemas.isEmpty) {
      return const Center(
        child: Text(
          'No hay problemas en este estado.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: problemas.length,
      itemBuilder: (context, index) {
        final problema = problemas[index];
        Color pillColor;

        // Asignar color del pill según el estado
        switch (problema['estado']) {
          case 'ABIERTO':
            pillColor = Colors.yellowAccent.shade700;
            break;
          case 'EN_PROCESO':
            pillColor = Colors.orange.shade700;
            break;
          case 'RESUELTO':
            pillColor = Colors.green;
            break;
          case 'CERRADO':
            pillColor = Colors.red.shade700;
            break;
          default:
            pillColor = Colors.black;
        }

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
          child: ListTile(
            title: Text(problema['titulo'] ?? 'Problema sin título'),
            subtitle: Text(problema['descripcion'] ?? 'Sin descripción'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              decoration: BoxDecoration(
                color: pillColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                problema['estado'],
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        );
      },
    );
  }
}
