import 'package:flutter/material.dart';
import 'package:neurohabits_app/conexiones/servicio_stats.dart';
import 'package:neurohabits_app/conexiones/Controlador.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListaHabitos extends StatelessWidget {
  final List<Map<String, dynamic>> habitos;
  final Function(Map<String, dynamic>)? onTap;
  final RefreshController refreshController;

  const ListaHabitos({
    super.key,
    required this.habitos,
    this.onTap,
    required this.refreshController,
  });

  void valiidarHabitos() {}

  @override
  Widget build(BuildContext context) {
    if (habitos.isEmpty) {
      return const Center(
        child: Text(
          "No hay hábitos para este día",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: habitos.length,
      itemBuilder: (context, index) {
        return HabitCard(
          data: habitos[index],
          onTap: onTap,
          refreshController: refreshController,
        );
      },
    );
  }
}

class HabitCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>)? onTap;
  final VoidCallback? onRefresh;
  final RefreshController refreshController;

  const HabitCard({
    super.key,
    required this.data,
    this.onTap,
    this.onRefresh,
    required this.refreshController,
  });

  String diasSemanaEnTexto(List dias) {
    if (dias.isEmpty) return "";
    return dias.join(", ");
  }

  void cargarExp(
    bool hecho,
    String stat,
    RefreshController refreshController,
  ) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    if (hecho) {
      await StatService.subirExp(stat, 10);
    } else {
      await StatService.bajarExp(stat, 10);
    }
    // bool nuevoValor = !(data["hechoHoy"] ?? false);

    // // await FirebaseFirestore.instance
    //     .collection("usuarios")
    //     .doc(userId)
    //     .collection("habitos")
    //     .doc(data["id"])
    //     .update({"hechoHoy": nuevoValor});

    refreshController.refrescar();
  }

  @override
  Widget build(BuildContext context) {
    String nombre = data["nombre"] ?? "Sin nombre";
    String stat = data["stat"] ?? "General";
    String hora = data["hora"] ?? "";
    String iconStat = "assets/iconos/${stat.toLowerCase()}.png";
    bool hecho = false;
    return AnimatedBuilder(
      animation: refreshController,
      builder: (context, _) {
        return GestureDetector(
          onTap: onTap != null ? () => onTap!(data) : null,
          child: Container(
            padding: const EdgeInsets.all(14),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    hecho = !hecho;
                    cargarExp(hecho, stat, refreshController);
                  },
                  child: Container(
                    width: 28,
                    height: 28,
                    margin: const EdgeInsets.only(right: 14, bottom: 14),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: (data["hechoHoy"] ?? false)
                          ? Colors.greenAccent
                          : Colors.transparent,
                      border: Border.all(
                        color: (data["hechoHoy"] ?? false)
                            ? Colors.greenAccent
                            : Colors.white70,
                        width: 2.5,
                      ),
                    ),
                  ),
                ),

                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withOpacity(0.20),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      iconStat,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) {
                        return const Icon(
                          Icons.star,
                          color: Color.fromARGB(255, 223, 30, 30),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nombre,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        stat,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ),
                ),

                Column(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.white.withOpacity(0.8),
                      size: 20,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hora,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
