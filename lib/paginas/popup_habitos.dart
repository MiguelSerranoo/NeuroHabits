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
      String hora = h["hora"] ?? "--:--";

      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF2A2A2A), Color(0xFF1A1A1A)],
            ),
            borderRadius: BorderRadius.circular(20),
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
              // Header compacto con icono, nombre y hora
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getColorStat(
                      h["stat"],
                    ).map((c) => c.withOpacity(0.3)).toList(),
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    // Icono
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _getColorStat(
                            h["stat"],
                          ).map((c) => c.withOpacity(0.3)).toList(),
                        ),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _getColorStat(h["stat"])[0].withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getIconoStat(h["stat"]),
                        color: _getColorStat(h["stat"])[0],
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Nombre y stat
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            h["nombre"] ?? "Hábito",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _getColorStat(
                                h["stat"],
                              )[0].withOpacity(0.3),
                              borderRadius: BorderRadius.circular(4),
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
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Hora destacada
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            color: Colors.white.withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            hora,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // Contenido scrolleable
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Descripción si existe
                      if (descripcion.isNotEmpty) ...[
                        _buildSeccionCompacta(
                          icono: Icons.description_outlined,
                          titulo: "Descripción",
                          child: Text(
                            descripcion,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              height: 1.3,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      // Días de la semana - más compactos
                      _buildSeccionCompacta(
                        icono: Icons.calendar_month,
                        titulo: "Días",
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: ["L", "M", "X", "J", "V", "S", "D"].map((
                            dia,
                          ) {
                            bool activo = dias.contains(dia);
                            return Container(
                              width: 30,
                              height: 30,
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
                                  width: activo ? 1.5 : 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  dia,
                                  style: TextStyle(
                                    color: activo
                                        ? Colors.white
                                        : Colors.white30,
                                    fontWeight: activo
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Duración y notificación en una fila
                      Row(
                        children: [
                          // Duración
                          Expanded(
                            child: _buildInfoCompacta(
                              icono: repetirSiempre
                                  ? Icons.all_inclusive
                                  : Icons.event,
                              texto: repetirSiempre
                                  ? "Indefinido"
                                  : fechaFin != null
                                  ? _formatearFechaCorta(fechaFin)
                                  : "Sin fecha",
                              color: Colors.purpleAccent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Notificación
                          Expanded(
                            child: _buildInfoCompacta(
                              icono: (h["notificacion"] ?? false)
                                  ? Icons.notifications_active
                                  : Icons.notifications_off,
                              texto: (h["notificacion"] ?? false)
                                  ? "Activada"
                                  : "Desactivada",
                              color: (h["notificacion"] ?? false)
                                  ? Colors.greenAccent
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Botón cerrar compacto
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purpleAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Cerrar",
                      style: TextStyle(
                        fontSize: 15,
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

// Widget compacto para secciones
Widget _buildSeccionCompacta({
  required IconData icono,
  required String titulo,
  required Widget child,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icono, color: Colors.purpleAccent, size: 14),
          const SizedBox(width: 6),
          Text(
            titulo,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      child,
    ],
  );
}

// Widget para info compacta (duración y notificación)
Widget _buildInfoCompacta({
  required IconData icono,
  required String texto,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3), width: 1),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icono, color: color, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            texto,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    ),
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
    "Agilidad": [const Color(0xFF00D2FF), const Color(0x3A7BD5)],
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

String _formatearFechaCorta(String fecha) {
  try {
    final dt = DateTime.parse(fecha);
    return "${dt.day}/${dt.month}/${dt.year}";
  } catch (_) {
    return fecha;
  }
}
