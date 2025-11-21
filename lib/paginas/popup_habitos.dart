import 'package:flutter/material.dart';

void mostrarPopupHabito(BuildContext context, Map<String, dynamic> h) {
  showDialog(
    context: context,
    builder: (context) {
      List dias = h["diasSemana"] ?? [];
      String diasTexto = dias.isNotEmpty ? dias.join(", ") : "Ninguno";

      bool repetirSiempre = h["repetirSiempre"] ?? true;
      String? fechaFin = h["fechaFin"];

      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: const Color(0xFF222222),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TÍTULO
              Text(
                h["nombre"] ?? "Hábito",
                style: const TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              _info("Stat", h["stat"]),
              _info("Días repetición", diasTexto),
              _info("Hora", h["hora"] ?? "--:--"),
              _info("Notificación", (h["notificacion"] ?? false) ? "Sí" : "No"),
              _info(
                "Repetición",
                repetirSiempre
                    ? "Para siempre"
                    : "Hasta el ${fechaFin ?? '--'}",
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cerrar",
                    style: TextStyle(color: Colors.purpleAccent),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// WIDGET para una fila de texto bonita
Widget _info(String titulo, String? valor) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Text(
          "$titulo: ",
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: Text(valor ?? "", style: const TextStyle(color: Colors.white)),
        ),
      ],
    ),
  );
}
