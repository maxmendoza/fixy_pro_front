import 'package:fixypro/users/screens/ProveedorDetailsScreen.dart';
import 'package:flutter/material.dart';

class ProveedoresScreen extends StatefulWidget {
  const ProveedoresScreen({super.key});

  @override
  State<ProveedoresScreen> createState() => _ProveedoresScreenState();
}

class _ProveedoresScreenState extends State<ProveedoresScreen> {
  final List<Map<String, String>> proveedores = [
    {
      'nombre': 'Juan Pérez',
      'descripcion': 'Especialista en carpintería',
      'imagen': 'assets/images/descarga (3).jpg',
    },
    {
      'nombre': 'María García',
      'descripcion': 'Experta en jardinería',
      'imagen': 'assets/images/descarga (3).jpg',
    },
    {
      'nombre': 'Carlos López',
      'descripcion': 'Plomería profesional',
      'imagen': 'assets/images/descarga (3).jpg',
    },
    {
      'nombre': 'Ana Torres',
      'descripcion': 'Servicio de pintura',
      'imagen': 'assets/images/descarga (3).jpg',
    },
  ];

  String query = '';
  List<Map<String, String>> filteredProveedores = [];
  bool isAscending = true;

  @override
  void initState() {
    super.initState();
    filteredProveedores = List.from(proveedores);
  }

  void updateQuery(String newQuery) {
    setState(() {
      query = newQuery;
      _applyFilters();
    });
  }

  void _applyFilters() {
    filteredProveedores = proveedores
        .where((prov) =>
            prov['nombre']!.toLowerCase().contains(query.toLowerCase()) ||
            prov['descripcion']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (isAscending) {
      filteredProveedores.sort((a, b) => a['nombre']!.compareTo(b['nombre']!));
    } else {
      filteredProveedores.sort((a, b) => b['nombre']!.compareTo(a['nombre']!));
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
        title: const Text("Proveedores"),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar proveedores',
                border: OutlineInputBorder(),
              ),
              onChanged: updateQuery,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(
                    isAscending ? Icons.arrow_upward : Icons.arrow_downward),
                tooltip: isAscending ? 'Ordenar Z-A' : 'Ordenar A-Z',
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
              itemCount: filteredProveedores.length,
              itemBuilder: (context, index) {
                final proveedor = filteredProveedores[index];
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
                          proveedor['imagen']!,
                          height: size.height * 0.2,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: size.height * 0.2,
                              width: double.infinity,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error, color: Colors.red),
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
                              proveedor['nombre']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: isLargeScreen ? 18 : 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              proveedor['descripcion']!,
                              style: const TextStyle(color: Colors.grey),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(
                          onPressed: () {
                            // Al presionar, se navega a la pantalla de detalles del proveedor
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProveedorDetailsScreen(
                                  proveedorNombre: proveedor['nombre']!,
                                  servicios: [
                                    {'descripcion': proveedor['descripcion']!},
                                  ],
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                          child: const Text(
                            "Ver más detalles",
                            style: TextStyle(fontSize: 12, color: Colors.white),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "Historial"),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
          BottomNavigationBarItem(
              icon: Icon(Icons.notifications), label: "Alertas"),
          BottomNavigationBarItem(icon: Icon(Icons.work), label: "Solicitudes"),
        ],
        selectedItemColor: Colors.orange,
      ),
    );
  }
}
