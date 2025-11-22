import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:neurohabits_app/conexiones/servicio_auth.dart';

class CheckPersonajePage extends StatefulWidget {
  const CheckPersonajePage({super.key});

  @override
  State<CheckPersonajePage> createState() => _CheckPersonajePageState();
}

class _CheckPersonajePageState extends State<CheckPersonajePage> {
  @override
  void initState() {
    super.initState();
    _comprobarPersonaje();
  }

  Future<void> _comprobarPersonaje() async {
    final user = AuthService.usuario;
    if (user == null) {
      Navigator.pushReplacementNamed(context, '/InicioSesion');
      return;
    }

    final snap = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(user.uid)
        .collection('stats')
        .get();

    if (snap.docs.isEmpty) {
      // No tiene stats → Crear Personaje
      Navigator.pushReplacementNamed(context, '/CrearPersonaje');
    } else {
      // Ya tiene personaje → Pantalla principal
      Navigator.pushReplacementNamed(context, '/Principal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF121212),
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }
}
