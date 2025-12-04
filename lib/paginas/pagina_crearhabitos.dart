import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:neurohabits_app/conexiones/Controlador.dart';

class CrearHabito extends StatefulWidget {
  final VoidCallback onSaved;
  final RefreshController refreshController;

  const CrearHabito({
    super.key,
    required this.onSaved,
    required this.refreshController,
  });

  @override
  State<CrearHabito> createState() => _CrearHabitoState();
}

class _CrearHabitoState extends State<CrearHabito> {
  final user = FirebaseAuth.instance.currentUser;
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController descripcionController = TextEditingController();
  String? statSeleccionado;
  List<String> diasSeleccionados = [];
  bool repetirSiempre = false;
  DateTime? fechaFin;
  TimeOfDay? hora;
  bool notificacion = false;
  Color ColorHora = Colors.white;
  final RefreshController refreshController = RefreshController();

  final List<String> stats = [];

  // Variables para edición
  bool esEdicion = false;
  String? habitoId;
  Map<String, dynamic>? habitoOriginal;

  @override
  void initState() {
    super.initState();
    cargarStats();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Obtener argumentos si es edición
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null && args['esEdicion'] == true) {
      esEdicion = true;
      habitoOriginal = args['habito'];
      _cargarDatosHabito(habitoOriginal!);
    }
  }

  void _cargarDatosHabito(Map<String, dynamic> habito) {
    setState(() {
      habitoId = habito['id'];
      nombreController.text = habito['nombre'] ?? '';
      descripcionController.text = habito['descripcion'] ?? '';
      statSeleccionado = habito['stat'];
      diasSeleccionados = List<String>.from(habito['dias'] ?? []);
      repetirSiempre = habito['repetirSiempre'] ?? false;
      notificacion = habito['notificacion'] ?? false;

      if (habito['fechaFin'] != null &&
          habito['fechaFin'].toString().isNotEmpty) {
        try {
          fechaFin = DateTime.parse(habito['fechaFin']);
        } catch (_) {}
      }

      if (habito['hora'] != null) {
        try {
          final partes = habito['hora'].toString().split(':');
          if (partes.length == 2) {
            hora = TimeOfDay(
              hour: int.parse(partes[0]),
              minute: int.parse(partes[1]),
            );
          }
        } catch (_) {}
      }
    });
  }

  Future<void> cargarStats() async {
    final uid = user!.uid;
    final snapshot = await FirebaseFirestore.instance
        .collection("usuarios")
        .doc(uid)
        .collection("stats")
        .get();

    setState(() {
      stats.clear();
      for (var doc in snapshot.docs) {
        stats.add(doc['nombre']);
      }
    });
  }

  final List<String> diasSemana = ["L", "M", "X", "J", "V", "S", "D"];

  Future<void> _guardarHabito(RefreshController refreshController) async {
    final uid = user!.uid;

    if (hora == null) {
      setState(() => ColorHora = Colors.red);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debes seleccionar una hora"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (statSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debes seleccionar una habilidad"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (diasSeleccionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Debes seleccionar al menos un día"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final datosHabito = {
        "nombre": nombreController.text,
        "descripcion": descripcionController.text,
        "stat": statSeleccionado,
        "dias": diasSeleccionados,
        "repetirSiempre": repetirSiempre,
        "fechaFin": fechaFin?.toIso8601String(),
        "hora": "${hora!.hour}:${hora!.minute}",
        "notificacion": notificacion,
        "actualizado": DateTime.now().toIso8601String(),
      };

      if (esEdicion && habitoId != null) {
        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(uid)
            .collection("habitos")
            .doc(habitoId)
            .update(datosHabito);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Hábito actualizado correctamente"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        datosHabito["creado"] = DateTime.now().toIso8601String();
        datosHabito["hechoHoy"] = false;

        await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(uid)
            .collection("habitos")
            .add(datosHabito);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Hábito creado correctamente"),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      setState(() => ColorHora = Colors.white);
      widget.onSaved();
      refreshController.refrescar();

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  String _formatearHora(TimeOfDay hora) {
    return "${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}";
  }

  Future<void> _mostrarSelectorFecha() async {
    DateTime? resultado = await showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        DateTime fechaTemp =
            fechaFin ?? DateTime.now().add(const Duration(days: 7));

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: const Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Fecha fin del hábito",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purpleAccent.withOpacity(0.3),
                            Colors.blueAccent.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _obtenerNombreMes(fechaTemp.month),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "${fechaTemp.day}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${fechaTemp.year}",
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Selectores
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Día
                        Column(
                          children: [
                            const Text(
                              "Día",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setStateDialog(() {
                                  fechaTemp = fechaTemp.add(
                                    const Duration(days: 1),
                                  );
                                });
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                fechaTemp.day.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setStateDialog(() {
                                  fechaTemp = fechaTemp.subtract(
                                    const Duration(days: 1),
                                  );
                                });
                              },
                            ),
                          ],
                        ),

                        // Mes
                        Column(
                          children: [
                            const Text(
                              "Mes",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setStateDialog(() {
                                  fechaTemp = DateTime(
                                    fechaTemp.year,
                                    fechaTemp.month + 1,
                                    fechaTemp.day,
                                  );
                                });
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                fechaTemp.month.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setStateDialog(() {
                                  fechaTemp = DateTime(
                                    fechaTemp.year,
                                    fechaTemp.month - 1,
                                    fechaTemp.day,
                                  );
                                });
                              },
                            ),
                          ],
                        ),

                        // Año
                        Column(
                          children: [
                            const Text(
                              "Año",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setStateDialog(() {
                                  fechaTemp = DateTime(
                                    fechaTemp.year + 1,
                                    fechaTemp.month,
                                    fechaTemp.day,
                                  );
                                });
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                fechaTemp.year.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setStateDialog(() {
                                  fechaTemp = DateTime(
                                    fechaTemp.year - 1,
                                    fechaTemp.month,
                                    fechaTemp.day,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Fechas rápidas",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Row(
                          children: [
                            _buildQuickDate(
                              setStateDialog,
                              fechaTemp,
                              "1 semana",
                              7,
                              (d) => fechaTemp = d,
                            ),
                            const SizedBox(width: 8),
                            _buildQuickDate(
                              setStateDialog,
                              fechaTemp,
                              "2 semanas",
                              14,
                              (d) => fechaTemp = d,
                            ),
                            const SizedBox(width: 8),
                            _buildQuickDate(
                              setStateDialog,
                              fechaTemp,
                              "1 mes",
                              30,
                              (d) => fechaTemp = d,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildQuickDate(
                              setStateDialog,
                              fechaTemp,
                              "2 meses",
                              60,
                              (d) => fechaTemp = d,
                            ),
                            const SizedBox(width: 8),
                            _buildQuickDate(
                              setStateDialog,
                              fechaTemp,
                              "3 meses",
                              90,
                              (d) => fechaTemp = d,
                            ),
                            const SizedBox(width: 8),
                            _buildQuickDate(
                              setStateDialog,
                              fechaTemp,
                              "6 meses",
                              180,
                              (d) => fechaTemp = d,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Cancelar",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, fechaTemp);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purpleAccent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              "Aceptar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (resultado != null) {
      setState(() {
        fechaFin = resultado;
      });
    }
  }

  String _obtenerNombreMes(int mes) {
    const meses = [
      "",
      "Enero",
      "Febrero",
      "Marzo",
      "Abril",
      "Mayo",
      "Junio",
      "Julio",
      "Agosto",
      "Septiembre",
      "Octubre",
      "Noviembre",
      "Diciembre",
    ];
    return meses[mes];
  }

  Widget _buildQuickDate(
    StateSetter setStateDialog,
    DateTime fechaActual,
    String texto,
    int dias,
    Function(DateTime) onSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setStateDialog(() {
            onSelected(DateTime.now().add(Duration(days: dias)));
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ),
      ),
    );
  }

  Future<void> _mostrarSelectorHora() async {
    TimeOfDay? resultado = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        TimeOfDay horaTemp = hora ?? TimeOfDay.now();

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return Dialog(
              backgroundColor: const Color(0xFF2A2A2A),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Seleccionar hora",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 24,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.purpleAccent.withOpacity(0.3),
                            Colors.blueAccent.withOpacity(0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _formatearHora(horaTemp),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Hora
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setStateDialog(() {
                                  horaTemp = TimeOfDay(
                                    hour: horaTemp.hour < 23
                                        ? horaTemp.hour + 1
                                        : 0,
                                    minute: horaTemp.minute,
                                  );
                                });
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                horaTemp.hour.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setStateDialog(() {
                                  horaTemp = TimeOfDay(
                                    hour: horaTemp.hour > 0
                                        ? horaTemp.hour - 1
                                        : 23,
                                    minute: horaTemp.minute,
                                  );
                                });
                              },
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            ":",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Minutos
                        Column(
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_up,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setStateDialog(() {
                                  horaTemp = TimeOfDay(
                                    hour: horaTemp.hour,
                                    minute: horaTemp.minute < 55
                                        ? horaTemp.minute + 5
                                        : 0,
                                  );
                                });
                              },
                            ),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                horaTemp.minute.toString().padLeft(2, '0'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                              ),
                              onPressed: () {
                                setStateDialog(() {
                                  horaTemp = TimeOfDay(
                                    hour: horaTemp.hour,
                                    minute: horaTemp.minute >= 5
                                        ? horaTemp.minute - 5
                                        : 55,
                                  );
                                });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      "Horas comunes",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickTime(
                              setStateDialog,
                              horaTemp,
                              "07:00",
                              7,
                              0,
                              (t) => horaTemp = t,
                            ),
                            _buildQuickTime(
                              setStateDialog,
                              horaTemp,
                              "08:00",
                              8,
                              0,
                              (t) => horaTemp = t,
                            ),
                            _buildQuickTime(
                              setStateDialog,
                              horaTemp,
                              "09:00",
                              9,
                              0,
                              (t) => horaTemp = t,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildQuickTime(
                              setStateDialog,
                              horaTemp,
                              "12:00",
                              12,
                              0,
                              (t) => horaTemp = t,
                            ),
                            _buildQuickTime(
                              setStateDialog,
                              horaTemp,
                              "18:00",
                              18,
                              0,
                              (t) => horaTemp = t,
                            ),
                            _buildQuickTime(
                              setStateDialog,
                              horaTemp,
                              "20:00",
                              20,
                              0,
                              (t) => horaTemp = t,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "Cancelar",
                              style: TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, horaTemp);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.purpleAccent,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text(
                              "Aceptar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (resultado != null) {
      setState(() {
        hora = resultado;
        ColorHora = Colors.white;
      });
    }
  }

  Widget _buildQuickTime(
    StateSetter setStateDialog,
    TimeOfDay horaActual,
    String texto,
    int h,
    int m,
    Function(TimeOfDay) onSelected,
  ) {
    final seleccionado = horaActual.hour == h && horaActual.minute == m;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setStateDialog(() {
            onSelected(TimeOfDay(hour: h, minute: m));
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            color: seleccionado
                ? Colors.purpleAccent.withOpacity(0.3)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: seleccionado
                  ? Colors.purpleAccent
                  : Colors.white.withOpacity(0.3),
              width: seleccionado ? 2 : 1,
            ),
          ),
          child: Text(
            texto,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: seleccionado ? Colors.white : Colors.white70,
              fontSize: 14,
              fontWeight: seleccionado ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purpleAccent.withOpacity(0.3),
                    Colors.blueAccent.withOpacity(0.3),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                esEdicion ? Icons.edit : Icons.add_circle_outline,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              esEdicion ? "Editar Hábito" : "Nuevo Hábito",
              style: const TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre y descripción en una sola card
            _buildSeccionCard(
              titulo: "Información básica",
              icono: Icons.info_outline,
              child: Column(
                children: [
                  TextField(
                    controller: nombreController,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    decoration: InputDecoration(
                      labelText: "Nombre del hábito",
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                      ),
                      hintText: "Ej: Hacer ejercicio, Meditar...",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descripcionController,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: "Descripción (opcional)",
                      labelStyle: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                      hintText: "Añade detalles sobre este hábito...",
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Habilidad y Hora en la misma fila
            Row(
              children: [
                Expanded(
                  child: _buildSeccionCard(
                    titulo: "Habilidad",
                    icono: Icons.psychology_outlined,
                    compact: true,
                    child: DropdownButton2<String>(
                      isExpanded: true,
                      underline: const SizedBox(),
                      buttonStyleData: const ButtonStyleData(
                        height: 36,
                        padding: EdgeInsets.zero,
                      ),
                      dropdownStyleData: DropdownStyleData(
                        maxHeight: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      hint: Text(
                        "Selecciona",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 14,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      value: statSeleccionado,
                      items: stats.map((s) {
                        return DropdownMenuItem(
                          value: s,
                          child: Text(
                            s,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => statSeleccionado = v),
                      iconStyleData: const IconStyleData(
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSeccionCard(
                    titulo: "Hora",
                    icono: Icons.access_time,
                    obligatorio: true,
                    errorColor: ColorHora,
                    compact: true,
                    child: GestureDetector(
                      onTap: _mostrarSelectorHora,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hora != null
                                ? Colors.purpleAccent.withOpacity(0.5)
                                : Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              color: hora != null
                                  ? Colors.purpleAccent
                                  : Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hora == null ? "Hora" : _formatearHora(hora!),
                                style: TextStyle(
                                  color: hora != null
                                      ? Colors.white
                                      : Colors.white54,
                                  fontSize: 14,
                                  fontWeight: hora != null
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Días de la semana - TODOS EN UNA FILA
            _buildSeccionCard(
              titulo: "Días de repetición",
              icono: Icons.calendar_month,
              compact: true,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: diasSemana.map((dia) {
                    bool seleccionado = diasSeleccionados.contains(dia);
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            if (seleccionado) {
                              diasSeleccionados.remove(dia);
                            } else {
                              diasSeleccionados.add(dia);
                            }
                          });
                        },
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            gradient: seleccionado
                                ? LinearGradient(
                                    colors: [
                                      Colors.purpleAccent.withOpacity(0.6),
                                      Colors.blueAccent.withOpacity(0.6),
                                    ],
                                  )
                                : null,
                            color: seleccionado
                                ? null
                                : Colors.white.withOpacity(0.05),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: seleccionado
                                  ? Colors.purpleAccent
                                  : Colors.white.withOpacity(0.2),
                              width: seleccionado ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              dia,
                              style: TextStyle(
                                color: seleccionado
                                    ? Colors.white
                                    : Colors.white70,
                                fontWeight: seleccionado
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Duración
            _buildSeccionCard(
              titulo: "Duración",
              icono: Icons.event_repeat,
              compact: true,
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: SwitchListTile(
                      value: repetirSiempre,
                      onChanged: (v) => setState(() => repetirSiempre = v),
                      title: const Text(
                        "Repetir indefinidamente",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      activeColor: Colors.purpleAccent,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 0,
                      ),
                      dense: true,
                    ),
                  ),

                  if (!repetirSiempre) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _mostrarSelectorFecha,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: fechaFin != null
                                ? Colors.purpleAccent.withOpacity(0.5)
                                : Colors.white.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.event,
                              color: fechaFin != null
                                  ? Colors.purpleAccent
                                  : Colors.white70,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                fechaFin == null
                                    ? "Seleccionar fecha fin"
                                    : "${fechaFin!.day}/${fechaFin!.month}/${fechaFin!.year}",
                                style: TextStyle(
                                  color: fechaFin != null
                                      ? Colors.white
                                      : Colors.white54,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white.withOpacity(0.3),
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Notificación
            _buildSeccionCard(
              titulo: "Recordatorio",
              icono: Icons.notifications_outlined,
              compact: true,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SwitchListTile(
                  value: notificacion,
                  onChanged: (v) => setState(() => notificacion = v),
                  title: const Text(
                    "Recibir notificación",
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  subtitle: Text(
                    "Te avisaremos a la hora programada",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                    ),
                  ),
                  activeColor: Colors.purpleAccent,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 0,
                  ),
                  dense: true,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botón guardar
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purpleAccent.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () => _guardarHabito(refreshController),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      esEdicion
                          ? Icons.check_circle_outline
                          : Icons.add_circle_outline,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      esEdicion ? "Actualizar Hábito" : "Crear Hábito",
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
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

  Widget _buildSeccionCard({
    required String titulo,
    required IconData icono,
    required Widget child,
    bool obligatorio = false,
    Color? errorColor,
    bool compact = false,
  }) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
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
              Expanded(
                child: Text(
                  titulo,
                  style: TextStyle(
                    color: errorColor ?? Colors.white,
                    fontSize: compact ? 13 : 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (obligatorio)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    "Req",
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: compact ? 8 : 12),
          child,
        ],
      ),
    );
  }
}
