import 'package:flutter/material.dart';

class ProblemDetailsModal extends StatelessWidget {
  const ProblemDetailsModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título del modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Mesa rota",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Carrusel de imágenes
              SizedBox(
                height: 200,
                child: PageView(
                  children: [
                    Image.asset(
                      'assets/images/descarga (3).jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey, size: 50),
                          ),
                        );
                      },
                    ),
                    Image.asset(
                      'assets/images/descarga (3).jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.image_not_supported,
                                color: Colors.grey, size: 50),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Información del problema
              const Text(
                "Categoría:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text("Carpintería"),
              const SizedBox(height: 8),
              const Text(
                "Descripción:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text("Se rompió la mesa de una esquina y se despegó la pata."),
              const SizedBox(height: 8),
              const Text(
                "Dirección:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text("Arrabal Samuel Galindo 57\nSandy Springs, Nav / 63128"),
              const SizedBox(height: 20),

              // Botones de acción ajustados al espacio disponible
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Acción para suspender
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                      child: const Text(
                        "Suspender",
                        style: TextStyle(fontSize: 8, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Acción para editar
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text(
                        "Editar",
                        style: TextStyle(fontSize: 12, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        "Cancelar",
                        style: TextStyle(fontSize: 9.9, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
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
