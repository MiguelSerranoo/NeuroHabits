import 'package:flutter/material.dart';

void mostrarPopupHabito(BuildContext context, Map<String, dynamic> h) {
  showDialog(
    context: context,
    builder: (context) {
      List dias = h["dias"] ?? [];
      String diasTexto = dias.isNotEmpty ? dias.join(", ") : "Ninguno";

      bool repetirSiempre = h["repetirSiempre"] ?? true;
      String? fechaFin = h["fechaFin"];
      String descripcion = h["descripcion"] ?? "";

      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con icono y nombre
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getColorStat(
                      h["stat"],
                    ).map((c) => c.withOpacity(0.3)).toList(),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getColorStat(
                            h["stat"],
                          ).map((c) => c.withOpacity(0.3)).toList(),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getColorStat(h["stat"])[0].withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getIconoStat(h["stat"]),
                        color: _getColorStat(h["stat"])[0],
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h["nombre"] ?? "Hábito",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getColorStat(
                                h["stat"],
                              )[0].withOpacity(0.3),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: _getColorStat(
                                  h["stat"],
                                )[0].withOpacity(0.5),
                              ),
                            ),
                            child: Text(
                              h["stat"] ?? "General",
                              style: TextStyle(
                                color: _getColorStat(h["stat"])[0],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Contenido
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Descripción si existe
                    if (descripcion.isNotEmpty) ...[
                      _buildSeccion(
                        icono: Icons.description_outlined,
                        titulo: "Descripción",
                        child: Text(
                          descripcion,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // Hora
                    _buildSeccion(
                      icono: Icons.access_time,
                      titulo: "Hora programada",
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.purpleAccent.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.schedule,
                              color: Colors.purpleAccent,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              h["hora"] ?? "--:--",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Días de la semana
                    _buildSeccion(
                      icono: Icons.calendar_month,
                      titulo: "Días de repetición",
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ["L", "M", "X", "J", "V", "S", "D"].map((
                          dia,
                        ) {
                          bool activo = dias.contains(dia);
                          return Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: activo
                                  ? LinearGradient(
                                      colors: [
                                        Colors.purpleAccent.withOpacity(0.6),
                                        Colors.blueAccent.withOpacity(0.6),
                                      ],
                                    )
                                  : null,
                              color: activo
                                  ? null
                                  : Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: activo
                                    ? Colors.purpleAccent
                                    : Colors.white.withOpacity(0.2),
                                width: activo ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                dia,
                                style: TextStyle(
                                  color: activo ? Colors.white : Colors.white30,
                                  fontWeight: activo
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Duración
                    _buildSeccion(
                      icono: Icons.event_repeat,
                      titulo: "Duración",
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              repetirSiempre
                                  ? Icons.all_inclusive
                                  : Icons.event,
                              color: Colors.purpleAccent,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                repetirSiempre
                                    ? "Repetir indefinidamente"
                                    : fechaFin != null
                                    ? "Hasta el ${_formatearFecha(fechaFin)}"
                                    : "Sin fecha fin",
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Notificación
                    _buildSeccion(
                      icono: Icons.notifications_outlined,
                      titulo: "Recordatorio",
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              (h["notificacion"] ?? false)
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                              color: (h["notificacion"] ?? false)
                                  ? Colors.purpleAccent
                                  : Colors.grey,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              (h["notificacion"] ?? false)
                                  ? "Notificación activada"
                                  : "Sin notificación",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Botón cerrar
              Padding(
                padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Cerrar",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
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

Widget _buildSeccion({
  required IconData icono,
  required String titulo,
  required Widget child,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.purpleAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icono, color: Colors.purpleAccent, size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            titulo,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      child,
    ],
  );
}

IconData _getIconoStat(String? stat) {
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

List<Color> _getColorStat(String? stat) {
  final colores = {
    "Salud": [const Color(0xFFFF6B6B), const Color(0xFFEE5A6F)],
    "Fuerza": [const Color(0xFFFF9F43), const Color(0xFFFF8C00)],
    "Inteligencia": [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
    "Creatividad": [const Color(0xFFB8E986), const Color(0xFF6DD5ED)],
    "Disciplina": [const Color(0xFF9B59B6), const Color(0xFF8E44AD)],
    "Social": [const Color(0xFFFECA57), const Color(0xFFEE5A6F)],
    "Energía": [const Color(0xFFFFD93D), const Color(0xFFF39C12)],
    "Agilidad": [const Color(0xFF00D2FF), const Color(0xFF3A7BD5)],
    "Resistencia": [const Color(0xFF6C5CE7), const Color(0xFF5F27CD)],
    "Carisma": [const Color(0xFFFD79A8), const Color(0xFFE84393)],
    "Sabiduría": [const Color(0xFF74B9FF), const Color(0xFF0984E3)],
    "Destreza": [const Color(0xFFA29BFE), const Color(0xFF6C5CE7)],
    "Concentración": [const Color(0xFF00B894), const Color(0xFF00CEC9)],
    "Paciencia": [const Color(0xFF81ECEC), const Color(0xFF00B894)],
    "Liderazgo": [const Color(0xFFFAB1A0), const Color(0xFFFF7675)],
    "Empatía": [const Color(0xFFFF7675), const Color(0xFFD63031)],
    "Velocidad": [const Color(0xFF55EFC4), const Color(0xFF00B894)],
    "Memoria": [const Color(0xFFDFE6E9), const Color(0xFFB2BEC3)],
    "Adaptabilidad": [const Color(0xFFFECEA8), const Color(0xFFFF9F43)],
    "Motivación": [const Color(0xFFFF6348), const Color(0xFFE17055)],
  };
  return colores[stat] ?? [Colors.purpleAccent, Colors.purple];
}

String _formatearFecha(String fecha) {
  try {
    final dt = DateTime.parse(fecha);
    return "${dt.day}/${dt.month}/${dt.year}";
  } catch (_) {
    return fecha;
  }
}
