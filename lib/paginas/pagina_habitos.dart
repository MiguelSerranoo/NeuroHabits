import 'package:flutter/material.dart';
import 'package:neurohabits_app/conexiones/servicio_stats.dart';
import 'package:neurohabits_app/conexiones/Controlador.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ListaHabitos extends StatelessWidget {
  final List<Map<String, dynamic>> habitos;
  final Function(Map<String, dynamic>)? onTap;
  final RefreshController refreshController;
  final DateTime diaSeleccionado;

  const ListaHabitos({
    super.key,
    required this.habitos,
    this.onTap,
    required this.refreshController,
    required this.diaSeleccionado,
  });

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
        final habito = habitos[index];
        // Key única que cambia con cada día y hábito
        final keyUnica =
            '${habito["id"]}_${diaSeleccionado.toIso8601String().split('T')[0]}';

        return HabitCard(
          key: ValueKey(keyUnica),
          data: habito,
          onTap: onTap,
          refreshController: refreshController,
          diaSeleccionado: diaSeleccionado,
        );
      },
    );
  }
}

class HabitCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>)? onTap;
  final RefreshController refreshController;
  final DateTime diaSeleccionado;

  const HabitCard({
    super.key,
    required this.data,
    this.onTap,
    required this.refreshController,
    required this.diaSeleccionado,
  });

  @override
  State<HabitCard> createState() => _HabitCardState();
}

class _HabitCardState extends State<HabitCard> {
  bool _cargando = false;
  bool _hechoHoy = false;

  @override
  void initState() {
    super.initState();
    _cargarEstadoDia();
  }

  @override
  void didUpdateWidget(HabitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Recargar cuando cambia el día seleccionado
    if (oldWidget.diaSeleccionado != widget.diaSeleccionado) {
      _cargarEstadoDia();
    }
  }

  String _obtenerClaveDay() {
    // Formato: YYYY-MM-DD
    final dia = widget.diaSeleccionado;
    return "${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}";
  }

  Future<void> _cargarEstadoDia() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final habitoId = widget.data["id"];
      final claveDay = _obtenerClaveDay();

      print("📅 Cargando estado para hábito: ${widget.data['nombre']}");
      print("   Día: $claveDay");

      final doc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(userId)
          .collection("habitos")
          .doc(habitoId)
          .collection("historial")
          .doc(claveDay)
          .get();

      print("   Documento existe: ${doc.exists}");

      if (mounted) {
        final estado = doc.exists
            ? (doc.data()?["completado"] ?? false)
            : false;
        print("   Estado cargado: $estado");

        setState(() {
          _hechoHoy = estado;
        });
      }
    } catch (e) {
      print("❌ Error cargando estado del día: $e");
    }
  }

  Future<void> _toggleHabito() async {
    if (_cargando) return;

    setState(() => _cargando = true);

    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final habitoId = widget.data["id"];
      final claveDay = _obtenerClaveDay();
      final nuevoEstado = !_hechoHoy;
      final String stat = widget.data["stat"] ?? "General";

      print("🔄 Cambiando estado del hábito: $habitoId para el día $claveDay");
      print("   Estado actual: $_hechoHoy -> Nuevo: $nuevoEstado");

      // Guardar en historial del día específico
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(userId)
          .collection("habitos")
          .doc(habitoId)
          .collection("historial")
          .doc(claveDay)
          .set({
            "completado": nuevoEstado,
            "fecha": widget.diaSeleccionado.toIso8601String(),
            "timestamp": FieldValue.serverTimestamp(),
          });

      // Actualizar experiencia
      if (nuevoEstado) {
        print("   ✅ Sumando 10 EXP a $stat");
        await StatService.subirExp(stat, 10);
      } else {
        print("   ❌ Restando 10 EXP a $stat");
        await StatService.bajarExp(stat, 10);
      }

      // Actualizar estado local
      setState(() => _hechoHoy = nuevoEstado);

      // Refrescar la UI
      widget.refreshController.refrescar();

      print("   ✅ Hábito actualizado correctamente");
    } catch (e) {
      print("   ❌ Error al actualizar hábito: $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error al actualizar: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _editarHabito(BuildContext context) async {
    Navigator.pushNamed(
      context,
      '/CrearHabitos',
      arguments: {'habito': widget.data, 'esEdicion': true},
    ).then((_) {
      widget.refreshController.refrescar();
    });
  }

  Future<void> _borrarHabito(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          "¿Borrar hábito?",
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          "¿Estás seguro de que quieres eliminar '${widget.data["nombre"]}'?\n\nSe borrará todo el historial del hábito.",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("Borrar"),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        final userId = FirebaseAuth.instance.currentUser!.uid;
        final habitoId = widget.data["id"];

        // Borrar todos los documentos del historial primero
        final historialDocs = await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(userId)
            .collection("habitos")
            .doc(habitoId)
            .collection("historial")
            .get();

        for (var doc in historialDocs.docs) {
          await doc.reference.delete();
        }

        // Luego borrar el hábito principal
        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(userId)
            .collection("habitos")
            .doc(habitoId)
            .delete();

        widget.refreshController.refrescar();

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Hábito eliminado"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error al borrar: $e"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _mostrarOpciones(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF2A2A2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text(
                  "Editar hábito",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _editarHabito(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.orange),
                title: const Text(
                  "Ver historial",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _mostrarHistorial(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  "Borrar hábito",
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _borrarHabito(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.grey),
                title: const Text(
                  "Cancelar",
                  style: TextStyle(color: Colors.white70),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _mostrarHistorial(BuildContext context) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final habitoId = widget.data["id"];

      final historialDocs = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(userId)
          .collection("habitos")
          .doc(habitoId)
          .collection("historial")
          .where("completado", isEqualTo: true)
          .orderBy("timestamp", descending: true)
          .limit(30)
          .get();

      if (!context.mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF2A2A2A),
          title: Text(
            "Historial: ${widget.data['nombre']}",
            style: const TextStyle(color: Colors.white),
          ),
          content: historialDocs.docs.isEmpty
              ? const Text(
                  "Aún no has completado este hábito ningún día",
                  style: TextStyle(color: Colors.white70),
                )
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: historialDocs.docs.length,
                    itemBuilder: (context, index) {
                      final doc = historialDocs.docs[index];
                      final fecha = doc.data()["fecha"] as String?;

                      String fechaFormateada = doc.id;
                      if (fecha != null) {
                        try {
                          final dt = DateTime.parse(fecha);
                          fechaFormateada = "${dt.day}/${dt.month}/${dt.year}";
                        } catch (_) {}
                      }

                      return ListTile(
                        leading: const Icon(
                          Icons.check_circle,
                          color: Colors.greenAccent,
                        ),
                        title: Text(
                          fechaFormateada,
                          style: const TextStyle(color: Colors.white),
                        ),
                        dense: true,
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cerrar"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error al cargar historial: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    String nombre = widget.data["nombre"] ?? "Sin nombre";
    String stat = widget.data["stat"] ?? "General";
    String hora = widget.data["hora"] ?? "";
    String descripcion = widget.data["descripcion"] ?? "";

    return GestureDetector(
      onLongPress: () => _mostrarOpciones(context),
      onTap: widget.onTap != null ? () => widget.onTap!(widget.data) : null,
      child: Container(
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: _hechoHoy
              ? LinearGradient(
                  colors: [
                    Colors.greenAccent.withOpacity(0.1),
                    Colors.green.withOpacity(0.05),
                  ],
                )
              : null,
          color: _hechoHoy ? null : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hechoHoy
                ? Colors.greenAccent.withOpacity(0.4)
                : Colors.white.withOpacity(0.1),
            width: _hechoHoy ? 2 : 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Checkbox
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: _cargando ? null : _toggleHabito,
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _hechoHoy ? Colors.greenAccent : Colors.transparent,
                  border: Border.all(
                    color: _hechoHoy ? Colors.greenAccent : Colors.white70,
                    width: 2.5,
                  ),
                ),
                child: _cargando
                    ? Padding(
                        padding: const EdgeInsets.all(4),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _hechoHoy ? Colors.white : Colors.greenAccent,
                          ),
                        ),
                      )
                    : _hechoHoy
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : null,
              ),
            ),

            // Icono del stat
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: LinearGradient(
                  colors: _getColorStat(
                    stat,
                  ).map((c) => c.withOpacity(0.3)).toList(),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: _getColorStat(stat)[0].withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: Icon(
                _getIconoStat(stat),
                color: _getColorStat(stat)[0],
                size: 24,
              ),
            ),

            const SizedBox(width: 12),

            // Nombre, stat y descripción
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      decoration: _hechoHoy ? TextDecoration.lineThrough : null,
                      decorationColor: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getColorStat(stat)[0].withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _getColorStat(stat)[0].withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          stat,
                          style: TextStyle(
                            fontSize: 11,
                            color: _getColorStat(stat)[0],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (descripcion.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            descripcion,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.5),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Hora
            Column(
              children: [
                Icon(
                  Icons.access_time,
                  color: Colors.white.withOpacity(0.6),
                  size: 18,
                ),
                const SizedBox(height: 4),
                Text(
                  hora,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(width: 8),

            // Botón de opciones
            IconButton(
              icon: const Icon(Icons.more_vert),
              color: Colors.white54,
              iconSize: 20,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () => _mostrarOpciones(context),
            ),
          ],
        ),
      ),
    );
  }

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

  List<Color> _getColorStat(String stat) {
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
}
