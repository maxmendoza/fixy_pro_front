import 'package:fixypro/users/screens/proveedoresDetailsModal.dart';
import 'package:flutter/material.dart';

class ProveedorDetailsScreen extends StatefulWidget {
  final String proveedorNombre;
  final List<Map<String, String>> servicios;

  const ProveedorDetailsScreen({
    super.key,
    required this.proveedorNombre,
    required this.servicios,
  });

  @override
  _ProveedorDetailsScreenState createState() => _ProveedorDetailsScreenState();
}

class _ProveedorDetailsScreenState extends State<ProveedorDetailsScreen> {
  late List<Map<String, String>> filteredServicios;
  bool isAscending = true;
  String query = "";

  @override
  void initState() {
    super.initState();
    filteredServicios = widget.servicios;
  }

  void _applyFilters() {
    filteredServicios = widget.servicios
        .where((servicio) =>
            servicio['nombre']!.toLowerCase().contains(query.toLowerCase()) ||
            servicio['descripcion']!
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();

    if (isAscending) {
      filteredServicios.sort((a, b) =>
          a['nombre']!.toLowerCase().compareTo(b['nombre']!.toLowerCase()));
    } else {
      filteredServicios.sort((a, b) =>
          b['nombre']!.toLowerCase().compareTo(a['nombre']!.toLowerCase()));
    }
  }

  void toggleSortOrder() {
    setState(() {
      isAscending = !isAscending;
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isLargeScreen = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        title: Text("Servicios de ${widget.proveedorNombre}"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) {
                setState(() {
                  query = value;
                  _applyFilters();
                });
              },
              decoration: const InputDecoration(
                labelText: "Buscar servicio",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Text("Ordenar por nombre:"),
                IconButton(
                  icon: Icon(
                      isAscending ? Icons.arrow_upward : Icons.arrow_downward),
                  onPressed: toggleSortOrder,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isLargeScreen ? 4 : 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.7,
                ),
                itemCount: filteredServicios.length,
                itemBuilder: (context, index) {
                  final servicio = filteredServicios[index];

                  final imagen =
                      servicio['imagen'] ?? 'assets/images/descarga (3).jpg';
                  final nombreProveedor =
                      servicio['proveedorNombre'] ?? 'Servicio';
                  final descripcion = servicio['descripcion'] ?? 'Descripción';

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10)),
                          child: Image.asset(
                            imagen,
                            height: size.height * 0.2,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: size.height * 0.2,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported,
                                    color: Colors.grey, size: 50),
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nombreProveedor,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                descripcion,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) =>
                                    ProveedoresDetailsModal(servicio: servicio),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: const Text(
                              "Más información",
                              style:
                                  TextStyle(fontSize: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
