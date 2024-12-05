import 'package:flutter/material.dart';

class TicketsSupplierScreen extends StatefulWidget {
  const TicketsSupplierScreen({Key? key}) : super(key: key);

  @override
  _TicketsSupplierScreenState createState() => _TicketsSupplierScreenState();
}

class _TicketsSupplierScreenState extends State<TicketsSupplierScreen> {
  bool isRepairsSelected = true;

  @override
  Widget build(BuildContext context) {
    // Colores personalizados
    const Color unselectedButtonColor = Color(0xFF063852); // Azul oscuro
    const Color selectedButtonColor = Color(0xFFFFC107); // Amarillo
    const Color containerBackgroundColor =
        Color(0xFF063852); // Fondo azul contenedor

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
              // Simular eliminación del token
              await Future.delayed(Duration(milliseconds: 500));
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 10), // Espaciado superior
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(5), // Ajuste de margen interno
            decoration: BoxDecoration(
              color: containerBackgroundColor, // Fondo azul oscuro
              borderRadius: BorderRadius.circular(12), // Bordes redondeados
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isRepairsSelected = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: isRepairsSelected
                            ? selectedButtonColor // Amarillo si está seleccionado
                            : containerBackgroundColor, // Azul oscuro si no seleccionado
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.build,
                            color:
                                isRepairsSelected ? Colors.black : Colors.white,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Reparaciones realizadas',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isRepairsSelected
                                  ? Colors.black
                                  : Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isRepairsSelected = false;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      decoration: BoxDecoration(
                        color: isRepairsSelected
                            ? containerBackgroundColor // Azul oscuro si no seleccionado
                            : selectedButtonColor, // Amarillo si está seleccionado
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color:
                                isRepairsSelected ? Colors.white : Colors.black,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Solicitudes de Reparación',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isRepairsSelected
                                  ? Colors.white
                                  : Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // Espaciado entre los botones y la lista
          Expanded(
            child: isRepairsSelected
                ? ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20),
                        child: ListTile(
                          title: const Text('Problema'),
                          subtitle: const Text('Fecha'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: const Text(
                              'Completado',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 5, horizontal: 20),
                        child: ListTile(
                          title: const Text('Solicitud'),
                          subtitle: const Text('Fecha'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              index == 2 ? 'Pendiente' : 'Aprobada',
                              style: const TextStyle(color: Colors.black),
                            ),
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
