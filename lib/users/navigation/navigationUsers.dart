import 'package:fixypro/users/navigation/ProveedoresScreen.dart';
import 'package:fixypro/users/navigation/homeUsers.dart';
import 'package:fixypro/users/navigation/problemas.dart';
import 'package:fixypro/users/navigation/profileUser.dart';
import 'package:fixypro/users/navigation/ticketsUsers.dart';
import 'package:flutter/material.dart';

class NavigationUsers extends StatefulWidget {
  const NavigationUsers({super.key});

  @override
  State<NavigationUsers> createState() => _NavigationState();
}

class _NavigationState extends State<NavigationUsers> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const Profileuser(),
    const TicketsUserScreen(),
    const HomeUsers(),
    const ProblemasScreen(),
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
        selectedItemColor: const Color(0xFFE4A320),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}
