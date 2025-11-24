import 'package:flutter/material.dart';
import 'package:neurohabits_app/paginas/pagina_calendario.dart';
import 'package:neurohabits_app/paginas/pagina_habitos.dart';
import 'package:neurohabits_app/conexiones/servicio_habitos.dart';
import 'package:neurohabits_app/paginas/popup_habitos.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key, required this.title});

  final String title;

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  DateTime hoy = DateTime.now();
  final DateTime now = DateTime.now();
  static Map<int, String> diasSemana = {
    1: 'Lunes',
    2: 'Martes',
    3: 'Miércoles',
    4: 'Jueves',
    5: 'Viernes',
    6: 'Sábado',
    7: 'Domingo',
  };
  static Map<int, String> meses = {
    1: 'Enero',
    2: 'Febrero',
    3: 'Marzo',
    4: 'Abril',
    5: 'Mayo',
    6: 'Junio',
    7: 'Julio',
    8: 'Agosto',
    9: 'Septiembre',
    10: 'Octubre',
    11: 'Noviembre',
    12: 'Diciembre',
  };
  void _cargarHabitos() {
    // Lógica para cargar los hábitos desde la base de datos o cualquier otra fuente
  }

  @override
  Widget build(BuildContext context) {
    final String diaTexto = diasSemana[now.weekday]!;
    final String mesTexto = meses[now.month]!;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.12,

              // 🔹 Padding SOLO para la fila superior
              child: Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 🔹 Fecha
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diaTexto,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        Text(
                          "${now.day} $mesTexto ${now.year}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Color.fromARGB(255, 180, 180, 180),
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ],
                    ),

                    // 🔹 Avatar
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/Perfil');
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70, width: 2),
                          image: const DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/imagenes/avatar.png"),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              height: MediaQuery.of(context).size.height * 0.24,
              width: MediaQuery.of(context).size.width, // 100% real
              color: const Color.fromARGB(255, 255, 19, 19),
              margin: const EdgeInsets.symmetric(horizontal: 0),
              child: Stack(children: [
                  
                ],
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.111,
              width: MediaQuery.of(context).size.width, // 100% real
              child: CalendarioSemanal(
                onDiaSeleccionado: (dia) {
                  setState(() => hoy = dia);
                },
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.44,
              width: MediaQuery.of(context).size.width,

              child: Stack(
                children: [
                  Positioned.fill(
                    child: FutureBuilder(
                      future: ServicioHabitos.obtenerHabitosDelDia(hoy),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        List habitos = snapshot.data as List;
                        habitos.sort((a, b) {
                          String horaA = a["hora"] ?? "00:00";
                          String horaB = b["hora"] ?? "00:00";
                          return horaA.compareTo(horaB);
                        });
                        return ListaHabitos(
                          habitos: List<Map<String, dynamic>>.from(habitos),
                          onTap: (habito) {
                            mostrarPopupHabito(context, habito);
                          },
                        );
                      },
                    ),
                  ),
                  Positioned(
                    right: 20,
                    bottom: 20,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/CrearHabitos');
                        onsaved:
                        () {
                          _cargarHabitos();
                        };
                      },
                      child: Container(
                        width: 45,
                        height: 45,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white70, width: 2),
                          image: const DecorationImage(
                            fit: BoxFit.cover,
                            image: AssetImage("assets/imagenes/cruz.png"),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// DefaultTabController(
//       length: 2,
//       child: Scaffold(
//         extendBody: true,
//         backgroundColor: Colors.white,
//         bottomNavigationBar: BottomAppBar(
//           color: Colors.transparent,
//           elevation: 0,
//           child: menu(),
//         ),
//         body: const TabBarView(
//           children: [
//             Pagina1(),
//             Pagina2(),
//             /*
// 		Aquí es donde debes colocar tus diferentes páginas, cuyo número debe ser igual al de las pestañas (Tabs). Añade o quita pestañas según tus necesidades.
// 		*/
//           ],
//         ),
//       ),
//     );
//   }

//   Widget menu() {
//     return Container(
//       margin: EdgeInsets.only(right: 25, left: 25),
//       decoration: BoxDecoration(
//         borderRadius: BorderRadius.circular(40),
//         border: Border.all(width: 0.05, color: Color.fromARGB(255, 24, 83, 79)),
//         color: Colors.white.withOpacity(0.9),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.2),
//             spreadRadius: 2,
//             blurRadius: 5,
//             offset: Offset(0, 5),
//           ),
//         ],
//       ),
//       child: TabBar(
//         labelPadding: EdgeInsets.all(5),
//         labelColor: Color.fromARGB(255, 33, 46, 83),
//         dividerColor: Colors.transparent,
//         unselectedLabelColor: Color.fromARGB(255, 33, 46, 83).withOpacity(0.4),
//         indicatorSize: TabBarIndicatorSize.label,
//         indicatorPadding: EdgeInsets.only(bottom: 5.0),
//         indicatorColor: Color.fromARGB(255, 206, 106, 107),
//         tabs: const [
//           Tab(icon: Icon(Icons.home, size: 27)),
//           Tab(icon: Icon(Icons.school, size: 27)),
//         ],
//       ),
//     );
