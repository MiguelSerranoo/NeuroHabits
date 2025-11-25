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
  String? statSeleccionado;
  List<String> diasSeleccionados = [];
  bool repetirSiempre = false;
  DateTime? fechaFin;
  TimeOfDay? hora;
  bool notificacion = false;
  bool botonActivo = false;
  Color ColorHora = Colors.white;
  final RefreshController refreshController = RefreshController();

  final List<String> stats = [];
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
    if (hora != null) {
      await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .collection("habitos")
          .add({
            "nombre": nombreController.text,
            "stat": statSeleccionado,
            "dias": diasSeleccionados,
            "repetirSiempre": repetirSiempre,
            "fechaFin": fechaFin?.toIso8601String(),
            "hora": hora != null ? "${hora!.hour}:${hora!.minute}" : null,
            "notificacion": notificacion,
            "creado": DateTime.now().toIso8601String(),
            "hechoHoy": false,
          });
      setState(() => ColorHora = Colors.white);

      widget.onSaved();
      refreshController.refrescar();

      Navigator.pop(context);
    } else {
      setState(() => ColorHora = Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    cargarStats();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),

      appBar: AppBar(
        backgroundColor: Colors.black,

        leading: IconButton(
          color: Colors.white,
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Crear Hábito",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nombre del hábito",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            TextField(
              controller: nombreController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Ingresa el nombre del hábito",
                hintStyle: TextStyle(color: Colors.white54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white54),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              "Seleccionar Habilidad",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            DropdownButton2<String>(
              isExpanded: true,

              buttonStyleData: ButtonStyleData(
                height: 42,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade500, width: 0.8),
                ),
              ),

              dropdownStyleData: DropdownStyleData(
                maxHeight: 150,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade600, width: 0.8),
                ),
                offset: const Offset(0, -5),
              ),

              hint: const Text(
                "Selecciona una habilidad",
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),

              style: const TextStyle(color: Colors.white, fontSize: 15),

              value: statSeleccionado,

              items: stats.map((s) {
                return DropdownMenuItem(
                  value: s,
                  child: Text(
                    s,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                  ),
                );
              }).toList(),

              onChanged: (v) {
                setState(() => statSeleccionado = v);
              },

              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white70,
                  size: 20,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Repetir en los días:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Wrap(
              spacing: 4.0,
              children: diasSemana.map((dia) {
                bool seleccionado = diasSeleccionados.contains(dia);
                return ChoiceChip(
                  label: Text(dia),
                  selectedColor: const Color.fromARGB(255, 154, 33, 202),
                  selected: seleccionado,
                  shape: const CircleBorder(),
                  showCheckmark: false,
                  onSelected: (v) {
                    setState(() {
                      if (v) {
                        diasSeleccionados.add(dia);
                      } else {
                        diasSeleccionados.remove(dia);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              value: repetirSiempre,
              onChanged: (v) => setState(() => repetirSiempre = v),
              title: const Text(
                "Repetir siempre",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Visibility(
              visible: !repetirSiempre,
              child: Column(
                children: [
                  const Text(
                    "Fecha fin del hábito",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final f = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                        initialDate: DateTime.now(),
                      );
                      if (f != null) {
                        setState(() => fechaFin = f);
                      } else {
                        setState(
                          () => fechaFin = DateTime.now().subtract(
                            const Duration(days: 365),
                          ),
                        );
                      }
                    },
                    child: Text(
                      fechaFin == null
                          ? "Seleccionar fecha"
                          : fechaFin.toString(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            Text(
              "Hora (Obligatorio)",
              style: TextStyle(fontWeight: FontWeight.bold, color: ColorHora),
            ),
            TextButton(
              onPressed: () async {
                final h = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (h != null) setState(() => hora = h);
              },
              child: Text(
                hora == null ? "Seleccionar hora" : hora!.format(context),
              ),
            ),

            SwitchListTile(
              value: notificacion,
              onChanged: (v) => setState(() => notificacion = v),
              title: const Text(
                "Activar notificación",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _guardarHabito(refreshController);
                },
                child: const Text("Guardar Hábito"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
