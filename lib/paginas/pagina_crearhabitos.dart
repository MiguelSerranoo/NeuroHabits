import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CrearHabito extends StatefulWidget {
  final VoidCallback onSaved;
  const CrearHabito({super.key, required this.onSaved});

  @override
  State<CrearHabito> createState() => _CrearHabitoState();
}

class _CrearHabitoState extends State<CrearHabito> {
  final TextEditingController nombreController = TextEditingController();
  String? statSeleccionado;
  List<String> diasSeleccionados = [];
  bool repetirSiempre = false;
  DateTime? fechaFin;
  TimeOfDay? hora;
  bool notificacion = false;

  final List<String> stats = [
    "Salud",
    "Productividad",
    "Personal",
    "Estudio",
    "Ejercicio",
  ];

  final List<String> diasSemana = ["L", "M", "X", "J", "V", "S", "D"];

  Future<void> _guardarHabito() async {
    await FirebaseFirestore.instance.collection("habitos").add({
      "nombre": nombreController.text,
      "stat": statSeleccionado,
      "dias": diasSeleccionados,
      "repetirSiempre": repetirSiempre,
      "fechaFin": fechaFin?.toIso8601String(),
      "hora": hora != null ? "${hora!.hour}:${hora!.minute}" : null,
      "notificacion": notificacion,
      "creado": DateTime.now().toIso8601String(),
    });

    widget.onSaved();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Crear Hábito"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Nombre del hábito",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(controller: nombreController),
            const SizedBox(height: 20),

            const Text(
              "Seleccionar stat",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              hint: const Text("Selecciona un stat"),
              value: statSeleccionado,
              items: stats
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setState(() => statSeleccionado = v),
            ),
            const SizedBox(height: 20),

            const Text("Repetir en los días:"),
            Wrap(
              children: diasSemana.map((dia) {
                bool seleccionado = diasSeleccionados.contains(dia);
                return ChoiceChip(
                  label: Text(dia),
                  selected: seleccionado,
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
              title: const Text("Repetir siempre"),
            ),
            const SizedBox(height: 20),

            const Text("Fecha fin del hábito"),
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
                fechaFin == null ? "Seleccionar fecha" : fechaFin.toString(),
              ),
            ),
            const SizedBox(height: 20),

            const Text("Hora (opcional)"),
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
              title: const Text("Activar notificación"),
            ),

            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: _guardarHabito,
                child: const Text("Guardar Hábito"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
