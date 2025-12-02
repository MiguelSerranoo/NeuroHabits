import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:neurohabits_app/conexiones/Controlador.dart';

class PerfilCompacto extends StatelessWidget {
  final VoidCallback onRefresh;
  final RefreshController refreshController;

  const PerfilCompacto({
    super.key,
    required this.onRefresh,
    required this.refreshController,
  });

  Future<Map<String, dynamic>> cargarPersonaje() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .collection("personaje")
        .doc("perfil")
        .get();

    return doc.data() ?? {};
  }

  Future<List<Map<String, dynamic>>> cargarStats() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .collection("stats")
        .get();

    return snapshot.docs.map((d) => d.data()).toList();
  }

  Future<Map<String, dynamic>> cargarTodo() async {
    final personaje = await cargarPersonaje();
    final stats = await cargarStats();

    // Calcular media
    int mediaNivel = 0;
    if (stats.isNotEmpty) {
      final sumaNiveles = stats.fold<int>(0, (prev, stat) {
        final nivel = stat["nivel"];
        if (nivel == null) return prev;
        return prev + (nivel as num).toInt();
      });

      mediaNivel = (sumaNiveles / stats.length).round();
    }

    return {"personaje": personaje, "stats": stats, "mediaNivel": mediaNivel};
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: refreshController,
      builder: (context, _) {
        return FutureBuilder<Map<String, dynamic>>(
          future: cargarTodo(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final personaje = snapshot.data!["personaje"];
            final stats = snapshot.data!["stats"] as List<Map<String, dynamic>>;
            final mediaNivel = snapshot.data!["mediaNivel"] as int;

            final avatar = personaje["avatar"] ?? "";
            final nombre = personaje["nombre"] ?? "Sin nombre";

            // --- División en columnas ---
            final primeraColumna = stats.length > 3
                ? stats.sublist(0, 3)
                : stats;
            final segundaColumna = stats.length > 3 ? stats.sublist(3) : [];

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==== Avatar y Datos del personaje ====
                  Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          "assets/avatares/$avatar",
                          width: 85,
                          height: 85,
                          fit: BoxFit.cover,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // ✔ Nivel debajo del nombre
                      Text(
                        "Nivel: $mediaNivel",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 30),

                  // ==== Habilidades ====
                  Expanded(
                    child: Row(
                      children: [
                        // ---- Primera columna de habilidades ----
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: primeraColumna.map((stat) {
                              return _buildStat(stat);
                            }).toList(),
                          ),
                        ),

                        if (segundaColumna.isNotEmpty)
                          const SizedBox(
                            width: 18,
                          ), // separación entre columnas

                        if (segundaColumna.isNotEmpty)
                          // ---- Segunda columna ----
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: segundaColumna.map((stat) {
                                return _buildStat(stat);
                              }).toList(),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ==== Widget que dibuja cada habilidad ====
  Widget _buildStat(Map<String, dynamic> stat) {
    final nombre = stat["nombre"];
    final nivel = stat["nivel"];
    final exp = stat["exp"];
    final expNecesaria = stat["expNecesaria"];
    final progreso = exp / expNecesaria;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12), // un poco más grande
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título + nivel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                nombre,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                "Nv $nivel",
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 3),

          // Barra EXP
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(10),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progreso,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purpleAccent,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            "$exp / $expNecesaria EXP",
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
