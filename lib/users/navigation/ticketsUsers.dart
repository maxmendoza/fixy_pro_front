import 'package:flutter/material.dart';

class TicketsUserScreen extends StatefulWidget {
  const TicketsUserScreen({Key? key}) : super(key: key);

  @override
  _TicketsUserScreenState createState() => _TicketsUserScreenState();
}

class _TicketsUserScreenState extends State<TicketsUserScreen> {
  bool isOffersSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false, // Quitar la flecha de navegación
        title: const Text(
          "FixyPro",
          style: TextStyle(
            color: Colors.white, // Texto en blanco
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFE4A320), // Fondo naranja
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
              color: Colors.white, // Ícono en blanco
            ),
            onPressed: () {
              // Navegar al login
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
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF063852), // Fondo azul oscuro
              borderRadius: BorderRadius.circular(12), // Bordes redondeados
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isOffersSelected = true;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          left: 5), // Espacio del lado izquierdo
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isOffersSelected
                            ? const Color(
                                0xFFFFC107) // Amarillo si está seleccionado
                            : const Color(0xFF063852), // Azul oscuro si no
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
                                isOffersSelected ? Colors.black : Colors.white,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Ofertas realizadas',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isOffersSelected
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
                        isOffersSelected = false;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(
                          right: 5), // Espacio del lado derecho
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isOffersSelected
                            ? const Color(
                                0xFF063852) // Azul oscuro si no seleccionado
                            : const Color(
                                0xFFFFC107), // Amarillo si está seleccionado
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
                                isOffersSelected ? Colors.white : Colors.black,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Contratación de proveedor',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isOffersSelected
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
            child: isOffersSelected
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
                          title: const Text('Problema'),
                          subtitle: const Text('Fecha'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 10),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              index == 2 ? 'Aprobada' : 'Pendiente',
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
