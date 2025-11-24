import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:neurohabits_app/conexiones/servicio_auth.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});
  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> {
  @override
  Widget build(BuildContext context) {
    // final User? user = FirebaseAuth.instance.currentUser;

    // final String? photoUrl = user?.photoURL;
    // final String? email = user?.email;
    // final String? nombre = user?.displayName ?? "Usuario";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text("Mi Perfil"),
        centerTitle: true,
        elevation: 0,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 40),

            // 🔹 Foto de perfil
            ClipOval(
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white70, width: 2),
                ),
                // child: photoUrl != null
                //     ? Image.network(photoUrl, fit: BoxFit.cover)
                //     : Image.asset("assets/images/avatar.jpg"),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Nombre
            Text(
              'nombre',
              // nombre ?? "Usuario",
              // style: const TextStyle(
              //   color: Colors.white,
              //   fontSize: 26,
              //   fontWeight: FontWeight.bold,
              // ),
            ),

            const SizedBox(height: 8),

            // 🔹 Email
            Text(
              'email',
              // email ?? "Sin correo",
              // style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),

            const SizedBox(height: 40),

            // 🔹 Botón editar perfil
            ElevatedButton(
              onPressed: () {
                // Aquí pondrás la edición de perfil
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple[700],
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Editar Perfil",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),

            const SizedBox(height: 20),

            // 🔹 Botón cerrar sesión
            OutlinedButton(
              onPressed: () async {
                await AuthService.logout();
                Navigator.pushReplacementNamed(context, "/login");
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.white70, width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                "Cerrar sesión",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
