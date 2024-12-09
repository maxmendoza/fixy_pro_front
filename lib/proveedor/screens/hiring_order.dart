import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class HiringOrder extends StatelessWidget {
  const HiringOrder({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OrdenContratacion(),
    );
  }
}

class OrdenContratacion extends StatefulWidget {
  const OrdenContratacion({super.key});

  @override
  State<OrdenContratacion> createState() => _OrdenContratacionState();
}

class _OrdenContratacionState extends State<OrdenContratacion> {
  final Dio _dio = Dio();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  Uint8List? webImage;
  File? selectedImage;
  String categoria = 'PLOMERIA';
  int? _selectedLocationId;
  List<Map<String, dynamic>> _userLocations = [];
  int? _userId; // ID del usuario en sesión
  final String baseUrl = 'http://127.0.0.1:8080';

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _configureDio();
    _fetchUserProfile(); // Obtener el ID del usuario en sesión
  }

  // Configurar interceptores de Dio
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

  // Obtener perfil del usuario para recuperar el ID dinámicamente
  Future<void> _fetchUserProfile() async {
    try {
      final response = await _dio.get('$baseUrl/user/profile');
      if (response.statusCode == 200) {
        setState(() {
          _userId = response.data['id']; // Asignar ID del usuario
        });
        _fetchUserLocations(); // Cargar ubicaciones una vez que tengamos el ID
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar perfil: ${e.message}')),
      );
    }
  }

  // Obtener ubicaciones del usuario
  Future<void> _fetchUserLocations() async {
    if (_userId == null) return;

    try {
      final response =
          await _dio.get('$baseUrl/api/ubicaciones/usuario/$_userId');
      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(response.data);
        setState(() {
          _userLocations = data;
          _selectedLocationId =
              _userLocations.isNotEmpty ? _userLocations.first['id'] : null;
        });
      }
    } on DioException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar ubicaciones: ${e.message}')),
      );
    }
  }

  // Seleccionar imagen
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (kIsWeb) {
        final bytes = await image.readAsBytes();
        setState(() {
          webImage = bytes;
        });
      } else {
        setState(() {
          selectedImage = File(image.path);
        });
      }
    }
  }

  // Crear problema
  Future<void> _crearProblema() async {
    if (_selectedLocationId == null ||
        _tituloController.text.isEmpty ||
        _descripcionController.text.isEmpty ||
        (kIsWeb && webImage == null) ||
        (!kIsWeb && selectedImage == null)) {
      _showAlertDialog(
          'Error', 'Por favor completa todos los campos requeridos.');
      return;
    }

    // Codificar la imagen en Base64
    String? base64Image;
    if (kIsWeb && webImage != null) {
      base64Image = base64Encode(webImage!);
    } else if (!kIsWeb && selectedImage != null) {
      base64Image = base64Encode(selectedImage!.readAsBytesSync());
    }

    final data = {
      "titulo": _tituloController.text,
      "descripcion": _descripcionController.text,
      "categoria": categoria.toUpperCase(),
      "fotografia": base64Image,
      "ubicacionId": _selectedLocationId,
    };

    try {
      final response = await _dio.post(
        '$baseUrl/api/problemas/post',
        data: data,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 200) {
        _showAlertDialog('Éxito', 'El problema ha sido creado exitosamente.');
        _limpiarFormulario();
      } else {
        _showAlertDialog('Error',
            'El servidor respondió con un código: ${response.statusCode}');
      }
    } catch (e) {
      _showAlertDialog('Error', 'Error al enviar la solicitud: $e');
    }
  }

  // Limpiar formulario después de crear problema
  void _limpiarFormulario() {
    setState(() {
      _tituloController.clear();
      _descripcionController.clear();
      webImage = null;
      selectedImage = null;
      categoria = 'PLOMERIA';
      _selectedLocationId =
          _userLocations.isNotEmpty ? _userLocations.first['id'] : null;
    });
  }

  // Mostrar alertas
  void _showAlertDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/home');
              },
              child: const Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("FixyPro"),
        backgroundColor: const Color(0xFF063852),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _tituloController,
              decoration: const InputDecoration(
                labelText: 'Título del problema',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                labelText: 'Descripción del problema',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            DropdownButton<int>(
              value: _selectedLocationId,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedLocationId = newValue;
                });
              },
              items: _userLocations.map<DropdownMenuItem<int>>((location) {
                return DropdownMenuItem<int>(
                  value: location['id'],
                  child: Text(location['direccion']),
                );
              }).toList(),
              isExpanded: true,
              hint: const Text("Selecciona una ubicación"),
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: categoria,
              onChanged: (String? newValue) {
                setState(() {
                  categoria = newValue!;
                });
              },
              items: ['CARPINTERIA', 'PLOMERIA', 'ELECTRICIDAD', 'ALBAÑILERIA']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              isExpanded: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
              ),
              child: const Text('Cargar Imagen'),
            ),
            if (kIsWeb && webImage != null)
              Center(
                child: Image.memory(
                  webImage!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            if (!kIsWeb && selectedImage != null)
              Center(
                child: Image.file(
                  selectedImage!,
                  width: 150,
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _crearProblema,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF42A5F5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text(
                'Publicar Problema',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
