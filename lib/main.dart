
import 'package:fixypro/Login/password.dart';
import 'package:fixypro/Login/email.dart';
import 'package:fixypro/Login/create_account.dart';
import 'package:fixypro/Login/login.dart';
import 'package:fixypro/proveedor/navigation/navigation.dart';
import 'package:fixypro/proveedor/screens/hiring_order.dart';
import 'package:fixypro/proveedor/navigation/profile.dart';
import 'package:fixypro/users/navigation/homeUsers.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FixyProApp());
}

class FixyProApp extends StatelessWidget {
  const FixyProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const Login(),
        '/email': (context) => const Email(),
        '/homeUsers': (context) => const HomeUsers(),
        '/create_account': (context) => const CreateAccount(),
        '/password': (context) => const Password(),
        '/home': (context) =>
            const Navigation(), // Usa Navigation en lugar de HomeScreen
        '/hiring_order': (context) => const HiringOrder(),
        '/profile': (context) => const Profile(),
      },
    );
  }
}
