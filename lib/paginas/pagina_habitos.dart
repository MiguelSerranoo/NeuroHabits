import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ListaHabitos extends StatelessWidget {
  final List<Map<String, dynamic>> habitos;
  final Function(Map<String, dynamic>)? onTap;

  const ListaHabitos({super.key, required this.habitos, this.onTap});

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
        return HabitCard(data: habitos[index], onTap: onTap);
      },
    );
  }
}

class HabitCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>)? onTap;

  const HabitCard({super.key, required this.data, this.onTap});

  String diasSemanaEnTexto(List dias) {
    if (dias.isEmpty) return "";
    return dias.join(", "); // "L, M, X"
  }

  @override
  Widget build(BuildContext context) {
    String nombre = data["nombre"] ?? "Sin nombre";
    String stat = data["stat"] ?? "General";
    bool repetirSiempre = data["repetirSiempre"] ?? true;
    String? fechaFin = data["fechaFin"];
    String hora = data["hora"] ?? "";
    bool notificacion = data["notificacion"] ?? false;
    String fechaFinFormateada = "---";
    if (!repetirSiempre && fechaFin != null) {
      DateTime fecha = DateTime.parse(fechaFin);
      fechaFinFormateada = DateFormat('dd/MM/yyyy').format(fecha);
    }

    return GestureDetector(
      onTap: onTap != null ? () => onTap!(data) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NOMBRE + ICONO
            Row(
              children: [
                Expanded(
                  child: Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // STAT
            Text(
              "Stat: $stat",
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),

            const SizedBox(height: 6),

            // FECHA FIN O SE REPITE SIEMPRE
            Text(
              repetirSiempre
                  ? "∞ Se repite para siempre"
                  : "Hasta el $fechaFinFormateada",
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),

            const SizedBox(height: 6),

            // HORA
            Text(
              "Hora: $hora",
              style: TextStyle(color: Colors.white.withOpacity(0.9)),
            ),

            const SizedBox(height: 6),

            // NOTIFICACIÓN
            Row(
              children: [
                Icon(
                  notificacion
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  color: notificacion ? Colors.greenAccent : Colors.redAccent,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Text(
                  notificacion ? "Con notificación" : "Sin notificación",
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
