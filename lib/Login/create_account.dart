import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String? selectedRole;
  bool showIneField = false;
  Uint8List? webImage;
  File? selectedImage;

  final ImagePicker _picker = ImagePicker();
  final Dio _dio = Dio();

  // Controladores de texto
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _ineExpirationController =
      TextEditingController();

  // URL base del backend
  final String baseUrl = 'http://127.0.0.1:8080/auth/register';

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _ineExpirationController.dispose();
    super.dispose();
  }

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

  Future<void> _registerUser() async {
    // Validar campos
    String? validationMessage = _validateFields();
    if (validationMessage != null) {
      _showAlertDialog('Error de Validación', validationMessage);
      return;
    }

    String? base64Image;
    if (showIneField) {
      if (kIsWeb && webImage != null) {
        base64Image = base64Encode(webImage!);
      } else if (!kIsWeb && selectedImage != null) {
        base64Image = base64Encode(selectedImage!.readAsBytesSync());
      }
    }

    final Map<String, dynamic> data = {
      "name": _nameController.text,
      "firstSurname": _surnameController.text.split(' ').first,
      "secondSurname": _surnameController.text.split(' ').length > 1
          ? _surnameController.text.split(' ')[1]
          : '',
      "email": _emailController.text,
      "phone": _phoneController.text,
      "password": _passwordController.text,
      "role": selectedRole?.toUpperCase(),
      "photo": base64Image,
    };

    if (showIneField) {
      data["ineExpiration"] = _ineExpirationController.text;
    }

    try {
      final response = await _dio.post(
        baseUrl,
        data: data,
        options: Options(headers: {"Content-Type": "application/json"}),
      );

      if (response.statusCode == 201) {
        _showAlertDialog(
          'Registro Exitoso',
          response.data['message'] ??
              'Verifica tu correo para activar tu cuenta.',
          onOkPressed: () {
            Navigator.of(context).pop(); // Cierra el AlertDialog
            Navigator.of(context)
                .pushReplacementNamed('/login'); // Regresa al Login
          },
        );
      }
    } on DioException catch (e) {
      String errorMessage = e.response?.data['message'] ??
          'Ocurrió un error al registrar el usuario.';
      _showAlertDialog('Error', errorMessage);
    } catch (e) {
      _showAlertDialog('Exito',
          'Registro exitoso, verifica tu correo para activar tu cuenta',
          onOkPressed: () {
        Navigator.of(context).pop(); // Cierra el AlertDialog
        Navigator.of(context).pushReplacementNamed('/login');
      });
    }
  }

  String? _validateFields() {
    if (_nameController.text.isEmpty) {
      return 'Por favor ingrese su nombre.';
    }
    if (_surnameController.text.isEmpty) {
      return 'Por favor ingrese sus apellidos.';
    }
    if (_emailController.text.isEmpty ||
        !_validateEmail(_emailController.text)) {
      return 'Por favor ingrese un correo electrónico válido.';
    }
    if (_phoneController.text.isEmpty ||
        !_validatePhone(_phoneController.text)) {
      return 'Por favor ingrese un número de teléfono válido.';
    }
    if (_passwordController.text.isEmpty ||
        _passwordController.text.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres.';
    }
    if (selectedRole == null) {
      return 'Por favor seleccione su rol.';
    }
    if (showIneField &&
        (_ineExpirationController.text.isEmpty ||
            !_validateIneExpiration(_ineExpirationController.text))) {
      return 'Por favor ingrese un año de expiración válido para el INE.';
    }
    return null;
  }

  bool _validateEmail(String value) {
    final RegExp emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(value);
  }

  bool _validatePhone(String value) {
    final RegExp phoneRegExp = RegExp(r'^\d{10}$');
    return phoneRegExp.hasMatch(value);
  }

  bool _validateIneExpiration(String value) {
    final RegExp yearRegExp = RegExp(r'^\d{4}$');
    return yearRegExp.hasMatch(value);
  }

  void _showAlertDialog(String title, String message,
      {VoidCallback? onOkPressed}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (onOkPressed != null) {
                  onOkPressed();
                }
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
      backgroundColor: const Color(0xFFFDF4F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFF063852),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'Registro',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Nombres', _nameController),
                  const SizedBox(height: 16),
                  _buildTextField('Apellidos', _surnameController),
                  const SizedBox(height: 16),
                  _buildTextField('Correo Electrónico', _emailController),
                  const SizedBox(height: 16),
                  _buildTextField('Teléfono', _phoneController),
                  const SizedBox(height: 16),
                  _buildTextField('Contraseña', _passwordController,
                      obscureText: true),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Selecciona tu rol',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: selectedRole,
                    items: const [
                      DropdownMenuItem(
                        value: 'proveedor',
                        child: Text('Proveedor'),
                      ),
                      DropdownMenuItem(
                        value: 'cliente',
                        child: Text('Cliente'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedRole = value;
                        showIneField = value == 'proveedor';
                      });
                    },
                  ),
                  if (showIneField) ...[
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _pickImage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Seleccionar archivo'),
                    ),
                    const SizedBox(height: 16),
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
                    _buildTextField(
                        'Año de Expiración INE', _ineExpirationController),
                  ],
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Cancelar'),
                      ),
                      ElevatedButton(
                        onPressed: _registerUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                        ),
                        child: const Text('Registrar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            height: 40,
            color: const Color(0xFF063852),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
