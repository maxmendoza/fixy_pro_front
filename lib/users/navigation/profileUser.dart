import 'package:flutter/material.dart';

class Profileuser extends StatefulWidget {
  const Profileuser({super.key});

  @override
  State<Profileuser> createState() => _EditProfileState();
}

class _EditProfileState extends State<Profileuser> {
  bool isEditingInfo = false;
  bool isEditingAddress = false;

  final TextEditingController nameController =
      TextEditingController(text: "Sheila");
  final TextEditingController lastNameController =
      TextEditingController(text: "Sanchez");
  final TextEditingController motherLastNameController =
      TextEditingController(text: "Flores");
  final TextEditingController phoneController =
      TextEditingController(text: "7773448592");
  final TextEditingController emailController =
      TextEditingController(text: "sheila@gmail.com");
  final TextEditingController passwordController =
      TextEditingController(text: "*********");

  final TextEditingController address1Controller = TextEditingController(
      text: "Calleja Maria del Carmen Tamez, 0 - Pembroke Pines, Gal / 65842");
  final TextEditingController address2Controller = TextEditingController(
      text: "Arrabal Samuel Galindo 57 - Sandy Springs, Nav / 63128");
  final TextEditingController address3Controller =
      TextEditingController(text: "Cuesta Virginia, 8 - Lakewood, Cat / 67064");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.grey[300],
                    child: const Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Sheila Camila Sanchez Flores",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Información Personal
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isEditingInfo
                    ? buildEditablePersonalInfo()
                    : buildNormalPersonalInfo(),
              ),
              const SizedBox(height: 20),

              // Direcciones
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isEditingAddress
                    ? buildEditableAddressInfo()
                    : buildNormalAddressInfo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildEditablePersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Información Personal",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        buildTextField("Nombre", nameController),
        const SizedBox(height: 10),
        buildTextField("Apellido Paterno", lastNameController),
        const SizedBox(height: 10),
        buildTextField("Apellido Materno", motherLastNameController),
        const SizedBox(height: 10),
        buildTextField("Teléfono", phoneController),
        const SizedBox(height: 10),
        buildTextField("Correo Electrónico", emailController, readOnly: true),
        const SizedBox(height: 10),
        buildTextField("Contraseña", passwordController),
        const SizedBox(height: 10),
        buildActionButtons(() {
          setState(() {
            isEditingInfo = false;
          });
        }),
      ],
    );
  }

  Widget buildNormalPersonalInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Información Personal",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text("Nombre: ${nameController.text}"),
        Text("Apellido Paterno: ${lastNameController.text}"),
        Text("Apellido Materno: ${motherLastNameController.text}"),
        Text("Teléfono: ${phoneController.text}"),
        Text("Correo Electrónico: ${emailController.text}"),
        Text("Contraseña: ${passwordController.text}"),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                isEditingInfo = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA726),
            ),
            child: const Text("Editar"),
          ),
        ),
      ],
    );
  }

  Widget buildEditableAddressInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Direcciones",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        buildTextField("Dirección Principal", address1Controller),
        const SizedBox(height: 10),
        buildTextField("Dirección #2", address2Controller),
        const SizedBox(height: 10),
        buildTextField("Dirección #3", address3Controller),
        const SizedBox(height: 10),
        buildActionButtons(() {
          setState(() {
            isEditingAddress = false;
          });
        }),
      ],
    );
  }

  Widget buildNormalAddressInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Direcciones",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text("Dirección Principal: ${address1Controller.text}"),
        Text("Dirección #2: ${address2Controller.text}"),
        Text("Dirección #3: ${address3Controller.text}"),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                isEditingAddress = true;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA726),
            ),
            child: const Text("Editar"),
          ),
        ),
      ],
    );
  }

  Widget buildTextField(String label, TextEditingController controller,
      {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildActionButtons(VoidCallback onAccept) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: onAccept,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3E8923),
          ),
          child: const Text("Aceptar"),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              isEditingAddress = false;
              isEditingInfo = false;
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFB90000),
          ),
          child: const Text("Cancelar"),
        ),
      ],
    );
  }
}
