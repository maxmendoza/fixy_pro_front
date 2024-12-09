import 'package:flutter/material.dart';

class ServiciosDetailsModal extends StatefulWidget {
  final Map<String, dynamic> servicio;
  final void Function(bool) onToggleSuspension;
  final void Function(String) onImageChange;
  final Future<void> Function() onImagePick; // Función para seleccionar imagen

  const ServiciosDetailsModal({
    super.key,
    required this.servicio,
    required this.onToggleSuspension,
    required this.onImageChange,
    required this.onImagePick,
  });

  @override
  _ServiciosDetailsModalState createState() => _ServiciosDetailsModalState();
}

class _ServiciosDetailsModalState extends State<ServiciosDetailsModal> {
  bool isEditable = false;
  late String selectedImage;
  late TextEditingController categoriaController;
  late TextEditingController descripcionController;
  late TextEditingController nombreController;
  late TextEditingController precioBasicoController;
  late TextEditingController precioCompletoController;

  @override
  void initState() {
    super.initState();
    selectedImage = widget.servicio['imagen'];
    categoriaController =
        TextEditingController(text: widget.servicio['categoria']);
    descripcionController =
        TextEditingController(text: widget.servicio['descripcion']);
    nombreController = TextEditingController(text: widget.servicio['nombre']);
    precioBasicoController =
        TextEditingController(text: widget.servicio['precio_basico']);
    precioCompletoController =
        TextEditingController(text: widget.servicio['precio_completo']);
  }

  @override
  void dispose() {
    categoriaController.dispose();
    descripcionController.dispose();
    nombreController.dispose();
    precioBasicoController.dispose();
    precioCompletoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSuspended = widget.servicio['suspendido'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecera del Modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    widget.servicio['titulo']!,
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

              // Imagen principal (editable si está en modo edición)
              if (isEditable)
                ElevatedButton(
                  onPressed: widget
                      .onImagePick, // Llamamos a la función para seleccionar imagen
                  child: const Text("Cambiar Imagen"),
                )
              else
                Image.asset(
                  widget.servicio['imagen'],
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 200,
                ),

              const SizedBox(height: 20),

              // Campos de información
              _buildField("Categoría:", categoriaController, isEditable),
              _buildField("Descripción:", descripcionController, isEditable),
              _buildField("Nombre del servicio:", nombreController, isEditable),
              _buildField("Precio básico:", precioBasicoController, isEditable),
              _buildField(
                  "Precio completo:", precioCompletoController, isEditable),

              const SizedBox(height: 20),

              // Botones de acción
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón de Suspender/Activar
                  ElevatedButton(
                    onPressed: () {
                      // Mostrar el alert para confirmar la suspensión
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(isSuspended
                                ? '¿Seguro que quieres activar el servicio?'
                                : '¿Seguro que quieres suspender el servicio?'),
                            content: Text(isSuspended
                                ? 'Al activarlo, el servicio volverá a estar disponible.'
                                : 'Al suspenderlo, el servicio ya no estará disponible para los clientes.'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Confirmar y cambiar el estado
                                  widget.onToggleSuspension(!isSuspended);
                                  Navigator.pop(context); // Cerrar el dialog
                                  Navigator.pop(context); // Cerrar el modal
                                },
                                child: const Text("Aceptar"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          isSuspended ? Colors.green : Colors.orange,
                    ),
                    child: Text(isSuspended ? "Activar" : "Suspender"),
                  ),
                  if (isEditable) ...[
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditable = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text("Cancelar"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditable = false;
                        });
                        // Guardar los cambios aquí
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                      child: const Text("Guardar"),
                    ),
                  ] else
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isEditable = true;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                      ),
                      child: const Text("Editar"),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(
      String label, TextEditingController controller, bool isEditable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        enabled: isEditable,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
