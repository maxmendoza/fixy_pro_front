import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class PublishProblemModal extends StatefulWidget {
  const PublishProblemModal({super.key});

  @override
  _PublishProblemModalState createState() => _PublishProblemModalState();
}

class _PublishProblemModalState extends State<PublishProblemModal> {
  File? _image1;
  File? _image2;
  String? _selectedAddress;

  final List<String> _addresses = [
    "Calle Principal 123",
    "Avenida Secundaria 456",
    "Boulevard Tercero 789",
    "Otra dirección"
  ];

  // Método para seleccionar una imagen
  Future<void> _pickImage(int imageNumber) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          if (imageNumber == 1) {
            _image1 = File(pickedFile.path);
          } else if (imageNumber == 2) {
            _image2 = File(pickedFile.path);
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar imagen: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Publicar problema",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // Campo del problema
              const TextField(
                decoration: InputDecoration(
                  labelText: "Problema",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              // Campo de descripción
              const TextField(
                decoration: InputDecoration(
                  labelText: "Descripción",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 15),
              // Menú desplegable para la dirección
              DropdownButtonFormField<String>(
                value: _selectedAddress,
                decoration: const InputDecoration(
                  labelText: "Dirección",
                  border: OutlineInputBorder(),
                ),
                items: _addresses.map((address) {
                  return DropdownMenuItem(
                    value: address,
                    child: Text(address),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAddress = value;
                  });
                },
              ),
              const SizedBox(height: 20),
              // Carga de imágenes
              Row(
                children: [
                  // Imagen principal
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickImage(1),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _image1 != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _image1!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image, size: 30, color: Colors.grey),
                                    Text("Subir imagen 1", style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Imagen secundaria
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _pickImage(2),
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: _image2 != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  _image2!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image, size: 30, color: Colors.grey),
                                    Text("Subir imagen 2", style: TextStyle(fontSize: 12)),
                                  ],
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Botones para publicar o cancelar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (_selectedAddress != null) {
                        // Lógica para publicar
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Seleccione una dirección antes de publicar.'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    child: const Text("Publicar",
                    style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text("Cancelar",
                    style: TextStyle(fontSize: 12, color: Colors.white)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
