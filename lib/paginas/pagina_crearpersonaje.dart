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

    await FirebaseFirestore.instance.collection("usuarios").doc(uid).set({
      "existe": true,
      "creado": Timestamp.now(),
    });

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

    Navigator.pushReplacementNamed(context, "/Principal");
  }

  final List<String> avatares = [
    "avatar1.png",
    "avatar2.png",
    "avatar3.png",
    "avatar4.png",
  ];

  IconData _getIconoStat(String stat) {
    final iconos = {
      "Salud": Icons.favorite,
      "Fuerza": Icons.fitness_center,
      "Inteligencia": Icons.psychology,
      "Creatividad": Icons.palette,
      "Disciplina": Icons.military_tech,
      "Social": Icons.people,
      "Energía": Icons.bolt,
      "Agilidad": Icons.directions_run,
      "Resistencia": Icons.shield,
      "Carisma": Icons.stars,
      "Sabiduría": Icons.auto_stories,
      "Destreza": Icons.pan_tool,
      "Concentración": Icons.center_focus_strong,
      "Paciencia": Icons.self_improvement,
      "Liderazgo": Icons.emoji_events,
      "Empatía": Icons.volunteer_activism,
      "Velocidad": Icons.speed,
      "Memoria": Icons.description,
      "Adaptabilidad": Icons.swap_horiz,
      "Motivación": Icons.local_fire_department,
    };
    return iconos[stat] ?? Icons.star;
  }

  Color _getColorStat(String stat) {
    final colores = {
      "Salud": const Color(0xFFFF6B6B),
      "Fuerza": const Color(0xFFFF9F43),
      "Inteligencia": const Color(0xFF4ECDC4),
      "Creatividad": const Color(0xFFB8E986),
      "Disciplina": const Color(0xFF9B59B6),
      "Social": const Color(0xFFFECA57),
      "Energía": const Color(0xFFFFD93D),
      "Agilidad": const Color(0xFF00D2FF),
      "Resistencia": const Color(0xFF6C5CE7),
      "Carisma": const Color(0xFFFD79A8),
      "Sabiduría": const Color(0xFF74B9FF),
      "Destreza": const Color(0xFFA29BFE),
      "Concentración": const Color(0xFF00B894),
      "Paciencia": const Color(0xFF81ECEC),
      "Liderazgo": const Color(0xFFFAB1A0),
      "Empatía": const Color(0xFFFF7675),
      "Velocidad": const Color(0xFF55EFC4),
      "Memoria": const Color(0xFFDFE6E9),
      "Adaptabilidad": const Color(0xFFFECEA8),
      "Motivación": const Color(0xFFFF6348),
    };
    return colores[stat] ?? Colors.purpleAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nombre del personaje",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nombreCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Escribe un nombre...",
                hintStyle: TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.2)),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              "Elige un avatar",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Elige tus habilidades",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purpleAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.purpleAccent.withOpacity(0.5),
                    ),
                  ),
                  child: Text(
                    "${seleccionados.length}/$maxStats",
                    style: const TextStyle(
                      color: Colors.purpleAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Selecciona entre $minStats y $maxStats habilidades",
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),

            // Grid de habilidades
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: statsDisponibles.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1, // Cambiado de 1.5 a 1.1 para más altura
              ),
              itemBuilder: (context, index) {
                final stat = statsDisponibles[index];
                final estaSeleccionado = seleccionados.contains(stat);
                final descripcion = statDescripciones[stat] ?? "";

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
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: estaSeleccionado
                          ? LinearGradient(
                              colors: [
                                _getColorStat(stat).withOpacity(0.3),
                                _getColorStat(stat).withOpacity(0.1),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            )
                          : null,
                      color: estaSeleccionado
                          ? null
                          : Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: estaSeleccionado
                            ? _getColorStat(stat)
                            : Colors.white.withOpacity(0.2),
                        width: estaSeleccionado ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _getColorStat(stat).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getIconoStat(stat),
                                color: _getColorStat(stat),
                                size: 22,
                              ),
                            ),
                            const Spacer(),
                            if (estaSeleccionado)
                              Icon(
                                Icons.check_circle,
                                color: _getColorStat(stat),
                                size: 22,
                              )
                            else
                              Icon(
                                Icons.circle_outlined,
                                color: Colors.white.withOpacity(0.3),
                                size: 22,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stat,
                              style: TextStyle(
                                color: estaSeleccionado
                                    ? Colors.white
                                    : Colors.white70,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              descripcion,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 12,
                                height: 1.3,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Botón crear
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed:
                    avatarSeleccionado != null &&
                        nombreCtrl.text.trim().isNotEmpty &&
                        seleccionados.length >= minStats
                    ? guardarPersonaje
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purpleAccent,
                  disabledBackgroundColor: Colors.grey.shade800,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_circle_outline, color: Colors.white),
                    const SizedBox(width: 12),
                    Text(
                      "Crear Personaje",
                      style: TextStyle(
                        fontSize: 18,
                        color:
                            avatarSeleccionado != null &&
                                nombreCtrl.text.trim().isNotEmpty &&
                                seleccionados.length >= minStats
                            ? Colors.white
                            : Colors.white54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
