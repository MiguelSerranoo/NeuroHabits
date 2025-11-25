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

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: refreshController,
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.09),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              FutureBuilder<Map<String, dynamic>>(
                future: cargarPersonaje(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final personaje = snapshot.data!;
                  final avatar = personaje["avatar"] ?? "";
                  final nombre = personaje["nombre"] ?? "Sin nombre";

                  return Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.asset(
                          "assets/avatares/$avatar",
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(width: 20),

              Expanded(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: cargarStats(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final stats = snapshot.data!;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: stats.map((stat) {
                        final nombre = stat["nombre"];
                        final nivel = stat["nivel"];
                        final exp = stat["exp"];
                        final expNecesaria = stat["expNecesaria"];

                        final progreso = exp / expNecesaria;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "$nombre — Nivel $nivel",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),

                              Container(
                                height: 8,
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

                              Text(
                                "$exp / $expNecesaria EXP",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
