import 'package:fixypro/proveedor/navigation/ofertas.dart';
import 'package:fixypro/proveedor/navigation/servicios.dart';
import 'package:fixypro/proveedor/navigation/tickets.dart';
import 'package:flutter/material.dart';
import 'home.dart';
import 'profile.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const Profile(),
    const TicketsSupplierScreen(),
    const HomeScrean(),
    const ServiciosScreen(),
    // Otra pantalla
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'Servicios',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF063852),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
