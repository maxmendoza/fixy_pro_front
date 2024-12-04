import 'package:flutter/material.dart';

class ProveedoresDetailsModal extends StatelessWidget {
  final Map<String, String> servicio;

  const ProveedoresDetailsModal({super.key, required this.servicio});

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    servicio['nombre'] ?? 'Servicio',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Image.asset(
                servicio['imagen'] ?? 'assets/images/descarga (3).jpg',
                fit: BoxFit.cover,
                height: 200,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.grey, size: 50),
                  );
                },
              ),
              const SizedBox(height: 10),
              const Text(
                "Descripción:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(servicio['descripcion'] ?? 'Sin descripción'),
              const SizedBox(height: 10),
              const Text(
                "Precio:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(servicio['precio'] ?? 'No disponible'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      // Acción para contratar
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    child: const Text(
                      "Contratar",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text(
                      "Cancelar",
                      style: TextStyle(fontSize: 12, color: Colors.white),
                    ),
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
