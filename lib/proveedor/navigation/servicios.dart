import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fixypro/proveedor/screens/serviciosDetailsModal.dart';

class ServiciosScreen extends StatefulWidget {
  const ServiciosScreen({super.key});

  @override
  _ServiciosScreenState createState() => _ServiciosScreenState();
}

class _ServiciosScreenState extends State<ServiciosScreen> {
  final List<Map<String, dynamic>> servicios = [
    {
      'titulo': 'Carpintería',
      'categoria': 'Hogar',
      'descripcion': 'Servicios de carpintería general.',
      'nombre': 'Carpintería básica',
      'precio_basico': '1000',
      'precio_completo': '2000',
      'imagen': 'assets/carpinteria.jpg',
      'suspendido': false,
    },
    {
      'titulo': 'Electricidad',
      'categoria': 'Hogar',
      'descripcion': 'Instalación y reparación eléctrica.',
      'nombre': 'Electricidad avanzada',
      'precio_basico': '1500',
      'precio_completo': '3000',
      'imagen': 'assets/electricidad.jpg',
      'suspendido': false,
    },
    {
      'titulo': 'Jardinería',
      'categoria': 'Exterior',
      'descripcion': 'Mantenimiento de jardines.',
      'nombre': 'Cuidado de jardines',
      'precio_basico': '800',
      'precio_completo': '1600',
      'imagen': 'assets/jardineria.jpg',
      'suspendido': false,
    },
  ];

  List<Map<String, dynamic>> filteredServicios = [];
  bool isAscending = true; // Controla el orden actual (A-Z o Z-A)
  String query = '';
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    filteredServicios = List.from(servicios);
  }

  void updateQuery(String newQuery) {
    setState(() {
      query = newQuery;
      _applyFilters();
    });
  }

  void _applyFilters() {
    filteredServicios = servicios
        .where((servicio) =>
            servicio['titulo'].toLowerCase().contains(query.toLowerCase()))
        .toList();

    // Ordenar según el estado actual (ascendente o descendente)
    if (isAscending) {
      filteredServicios.sort((a, b) => a['titulo'].compareTo(b['titulo']));
    } else {
      filteredServicios.sort((a, b) => b['titulo'].compareTo(a['titulo']));
    }
  }

  void toggleSortOrder() {
    setState(() {
      isAscending = !isAscending;
      _applyFilters();
    });
  }

  Future<void> _pickImage(int index) async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        servicios[index]['imagen'] = pickedFile.path;
      });
    }
  }

  void _showServiciosDetailsModal(
      BuildContext context, Map<String, dynamic> servicio, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ServiciosDetailsModal(
          servicio: servicio,
          onToggleSuspension: (bool suspend) {
            setState(() {
              servicios[index]['suspendido'] = suspend;
              _applyFilters();
            });
          },
          onImageChange: (String newImage) {
            setState(() {
              servicios[index]['imagen'] = newImage;
            });
          },
          onImagePick: () => _pickImage(index),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isLargeScreen = size.width > 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "FixyPro",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF063852),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: TextField(
              decoration: InputDecoration(
                  labelText: 'Buscar',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  )),
              onChanged: updateQuery,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.sort_by_alpha),
                tooltip: isAscending ? 'Ordenar Z-A' : 'Ordenar A-Z',
                onPressed: toggleSortOrder,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isLargeScreen ? 4 : 2,
                childAspectRatio: 0.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: filteredServicios.length,
              itemBuilder: (context, index) {
                final servicio = filteredServicios[index];
                final isSuspended = servicio['suspendido'];

                return GestureDetector(
                  onTap: () =>
                      _showServiciosDetailsModal(context, servicio, index),
                  child: Card(
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
                            servicio['imagen']!,
                            height: size.height * 0.2,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: size.height * 0.2,
                                width: double.infinity,
                                color: Colors.grey[300],
                                child:
                                    const Icon(Icons.error, color: Colors.red),
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
                                servicio['titulo']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: isLargeScreen ? 20 : 16,
                                  color:
                                      isSuspended ? Colors.grey : Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${servicio['categoria']} | \$${servicio['precio_basico']} - \$${servicio['precio_completo']}',
                                style: TextStyle(
                                  color:
                                      isSuspended ? Colors.grey : Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                servicio['descripcion']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSuspended
                                      ? Colors.grey
                                      : Colors.grey[700],
                                ),
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
                            onPressed: () => _showServiciosDetailsModal(
                                context, servicio, index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isSuspended
                                  ? Colors.grey
                                  : const Color(0xFF063852),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
