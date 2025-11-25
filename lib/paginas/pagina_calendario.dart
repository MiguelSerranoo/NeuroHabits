import 'package:flutter/material.dart';

class CalendarioSemanal extends StatefulWidget {
  final Function(DateTime) onDiaSeleccionado;

  const CalendarioSemanal({super.key, required this.onDiaSeleccionado});

  @override
  State<CalendarioSemanal> createState() => _CalendarioSemanalState();
}

class _CalendarioSemanalState extends State<CalendarioSemanal> {
  PageController controller = PageController(initialPage: 1000);
  DateTime seleccionado = DateTime.now();
  DateTime diareal = DateTime.now();
  String mesActual = "";

  @override
  void initState() {
    super.initState();
    mesActual = obtenerNombreMes(DateTime.now());
  }

  String obtenerNombreMes(DateTime fecha) {
    List<String> meses = [
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

    return meses[fecha.month - 1];
  }

  List<DateTime> obtenerDiasSemana(DateTime fecha) {
    int diaSemana = fecha.weekday;
    DateTime lunes = fecha.subtract(Duration(days: diaSemana - 1));
    return List.generate(7, (i) => lunes.add(Duration(days: i)));
  }

  bool estaEnSemanaActual(DateTime fecha) {
    DateTime hoy = DateTime.now();
    DateTime lunesActual = hoy.subtract(Duration(days: hoy.weekday - 1));
    DateTime domingoActual = lunesActual.add(const Duration(days: 6));

    return fecha.isAfter(lunesActual.subtract(const Duration(days: 1))) &&
        fecha.isBefore(domingoActual.add(const Duration(days: 1)));
  }

  static Map<int, String> diasSemana = {
    1: 'L',
    2: 'M',
    3: 'X',
    4: 'J',
    5: 'V',
    6: 'S',
    7: 'D',
  };
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.15,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            mesActual,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 5),

          Expanded(
            child: PageView.builder(
              controller: controller,
              scrollDirection: Axis.horizontal,
              onPageChanged: (index) {
                setState(() {
                  DateTime nuevaSemana = DateTime.now().add(
                    Duration(days: (index - 1000) * 7),
                  );

                  mesActual = obtenerNombreMes(nuevaSemana);
                });
              },
              itemBuilder: (context, index) {
                DateTime semana = DateTime.now().add(
                  Duration(days: (index - 1000) * 7),
                );
                List<DateTime> dias = obtenerDiasSemana(semana);

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: dias.map((dia) {
                    String nombre = diasSemana[dia.weekday]!;
                    bool esHoy = false;

                    if (estaEnSemanaActual(dia)) {
                      DateTime hoy = DateTime.now();
                      esHoy =
                          dia.day == hoy.day &&
                          dia.month == hoy.month &&
                          dia.year == hoy.year;
                    }

                    bool esSeleccionado =
                        dia.year == seleccionado.year &&
                        dia.month == seleccionado.month &&
                        dia.day == seleccionado.day;

                    return GestureDetector(
                      onTap: () {
                        setState(() => seleccionado = dia);
                        widget.onDiaSeleccionado(dia);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            nombre.toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: esSeleccionado
                                  ? const Color.fromARGB(255, 154, 33, 202)
                                  : esHoy
                                  ? const Color.fromARGB(255, 199, 118, 231)
                                  : Colors.grey.shade300,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${dia.day}',
                              style: TextStyle(
                                color: esHoy || esSeleccionado
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
