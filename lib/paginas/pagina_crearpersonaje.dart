import 'package:flutter/material.dart';
import 'package:neurohabits_app/data/stats.dart';
import 'package:neurohabits_app/conexiones/servicio_stats.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CrearPersonajePage extends StatefulWidget {
  const CrearPersonajePage({super.key});

  @override
  State<CrearPersonajePage> createState() => _CrearPersonajePageState();
}

class _CrearPersonajePageState extends State<CrearPersonajePage> {
  List<String> seleccionados = [];
  final int minStats = 3;
  final int maxStats = 5;
  final TextEditingController nombreCtrl = TextEditingController();
  String? avatarSeleccionado;

  Future<void> guardarPersonaje() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .collection("personaje")
        .doc("perfil")
        .set({
          "nombre": nombreCtrl.text.trim(),
          "avatar": avatarSeleccionado,
          "creado": Timestamp.now(),
        });
    await StatService.guardarStatsIniciales(seleccionados);

    // Ir a pantalla principal
    Navigator.pushReplacementNamed(context, "/Principal");
  }

  final List<String> avatares = [
    "avatar1.png",
    "avatar2.png",
    "avatar3.png",
    "avatar4.png",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        title: const Text(
          "Crear Personaje",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nombre del personaje",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nombreCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Escribe un nombre...",
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 25),

            // AVATARES
            const Text(
              "Elige un avatar",
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const SizedBox(height: 10),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: avatares.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final img = avatares[index];
                final bool seleccionado = avatarSeleccionado == img;

                return GestureDetector(
                  onTap: () {
                    setState(() => avatarSeleccionado = img);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: seleccionado
                            ? Colors.purpleAccent
                            : Colors.transparent,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        "assets/avatares/$img",
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 25),
            Text(
              "Elige entre 3 y 5 stats para tu personaje",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            // LISTA DE STATS
            Expanded(
              child: ListView.builder(
                itemCount: statsDisponibles.length,
                itemBuilder: (context, index) {
                  final stat = statsDisponibles[index];
                  final estaSeleccionado = seleccionados.contains(stat);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (estaSeleccionado) {
                          seleccionados.remove(stat);
                        } else {
                          if (seleccionados.length < maxStats) {
                            seleccionados.add(stat);
                          }
                        }
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: estaSeleccionado
                            ? Colors.purple.withOpacity(0.6)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: estaSeleccionado
                              ? Colors.purpleAccent
                              : Colors.white54,
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              stat,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Icon(
                            estaSeleccionado
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            color: estaSeleccionado
                                ? Colors.greenAccent
                                : Colors.white70,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // BOTÓN GUARDAR
            Padding(
              padding: const EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed:
                    avatarSeleccionado != null &&
                        nombreCtrl.text.trim().isNotEmpty &&
                        seleccionados.length >= minStats
                    ? guardarPersonaje
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 55),
                  backgroundColor: Colors.purpleAccent,
                  disabledBackgroundColor: Colors.grey,
                ),
                child: const Text(
                  "Crear Personaje",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
