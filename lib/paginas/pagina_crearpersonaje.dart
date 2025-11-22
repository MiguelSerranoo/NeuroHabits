import 'package:flutter/material.dart';
import 'package:neurohabits_app/data/stats.dart';
import 'package:neurohabits_app/conexiones/servicio_stats.dart';

class CrearPersonajePage extends StatefulWidget {
  const CrearPersonajePage({super.key});

  @override
  State<CrearPersonajePage> createState() => _CrearPersonajePageState();
}

class _CrearPersonajePageState extends State<CrearPersonajePage> {
  List<String> seleccionados = [];
  final int minStats = 3;
  final int maxStats = 5;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Crear Personaje"),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              "Elige entre 3 y 5 stats para tu personaje",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),

          // LISTA DE STATS
          Expanded(
            child: ListView.builder(
              itemCount: statsDisponibles.length,
              itemBuilder: (context, index) {
                final stat = statsDisponibles[index];
                final estaSeleccionado = seleccionados.contains(stat);

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (estaSeleccionado) {
                        seleccionados.remove(stat);
                      } else {
                        if (seleccionados.length < maxStats) {
                          seleccionados.add(stat);
                        }
                      }
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: estaSeleccionado
                          ? Colors.purple.withOpacity(0.6)
                          : Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: estaSeleccionado
                            ? Colors.purpleAccent
                            : Colors.white54,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            stat,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        Icon(
                          estaSeleccionado
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: estaSeleccionado
                              ? Colors.greenAccent
                              : Colors.white70,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // BOTÓN GUARDAR
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: seleccionados.length < minStats
                  ? null
                  : () async {
                      await StatService.guardarStatsIniciales(seleccionados);

                      Navigator.pushReplacementNamed(context, "/Principal");
                    },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 55),
                backgroundColor: Colors.purpleAccent,
                disabledBackgroundColor: Colors.grey,
              ),
              child: const Text(
                "Guardar y continuar",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
