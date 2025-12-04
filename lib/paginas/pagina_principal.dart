import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:neurohabits_app/paginas/pagina_calendario.dart';
import 'package:neurohabits_app/paginas/pagina_habitos.dart';
import 'package:neurohabits_app/conexiones/servicio_habitos.dart';
import 'package:neurohabits_app/paginas/popup_habitos.dart';
import 'package:neurohabits_app/paginas/pagina_personajerresumen.dart';
import 'package:neurohabits_app/conexiones/Controlador.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PantallaInicio extends StatefulWidget {
  const PantallaInicio({super.key, required this.title});

  final String title;

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  DateTime hoy = DateTime.now();
  final DateTime now = DateTime.now();
  final RefreshController refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _configurarBarraEstado();
  }

  void _configurarBarraEstado() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

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

  void refrescar() {
    setState(() {});
  }

  Future<Map<String, dynamic>> _calcularProgresoHoy() async {
    try {
      final habitos = await ServicioHabitos.obtenerHabitosDelDia(hoy);

      int total = habitos.length;
      int completados = 0;

      if (total == 0) {
        return {'total': 0, 'completados': 0, 'porcentaje': 0};
      }

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        return {'total': total, 'completados': 0, 'porcentaje': 0};
      }

      final claveHoy =
          "${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}";

      for (var habito in habitos) {
        final habitoId = habito["id"];
        if (habitoId != null) {
          try {
            final doc = await FirebaseFirestore.instance
                .collection("usuarios")
                .doc(userId)
                .collection("habitos")
                .doc(habitoId)
                .collection("historial")
                .doc(claveHoy)
                .get();

            if (doc.exists && (doc.data()?["completado"] ?? false)) {
              completados++;
            }
          } catch (e) {
            // Si hay error, continuar con el siguiente
          }
        }
      }

      final porcentaje = ((completados / total) * 100).round();

      return {
        'total': total,
        'completados': completados,
        'porcentaje': porcentaje,
      };
    } catch (e) {
      return {'total': 0, 'completados': 0, 'porcentaje': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    final String diaTexto = diasSemana[now.weekday]!;
    final String mesTexto = meses[now.month]!;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          top: false, // Para que la barra de estado se superponga
          child: Column(
            children: [
              // Espacio para la barra de estado
              Container(
                height: MediaQuery.of(context).padding.top,
                color: Colors.black,
              ),

              // Header mejorado con gradiente sutil
              Container(
                height: MediaQuery.of(context).size.height * 0.12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.purple.withOpacity(0.1), Colors.black],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Fecha con círculo de progreso
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
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
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white.withOpacity(0.7),
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          // Círculo de progreso
                          AnimatedBuilder(
                            animation: refreshController,
                            builder: (context, _) {
                              return FutureBuilder<Map<String, dynamic>>(
                                key: ValueKey(
                                  'progreso_${hoy.toIso8601String()}',
                                ),
                                future: _calcularProgresoHoy(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox(
                                      width: 50,
                                      height: 50,
                                    );
                                  }

                                  final progreso =
                                      snapshot.data!['porcentaje'] / 100;

                                  return SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          value: progreso,
                                          strokeWidth: 4,
                                          backgroundColor: Colors.white
                                              .withOpacity(0.1),
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                progreso == 1.0
                                                    ? Colors.greenAccent
                                                    : Colors.purpleAccent,
                                              ),
                                        ),
                                        Text(
                                          "${snapshot.data!['porcentaje']}%",
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),

                      // Botones con efectos mejorados
                      Row(
                        children: [
                          // Botón Ranking
                          _buildHeaderButton(
                            icon: Icons.leaderboard,
                            onTap: () =>
                                Navigator.pushNamed(context, '/Ranking'),
                            gradient: LinearGradient(
                              colors: [
                                Colors.orangeAccent.withOpacity(0.3),
                                Colors.redAccent.withOpacity(0.3),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Botón Perfil
                          _buildHeaderButton(
                            icon: Icons.person,
                            onTap: () =>
                                Navigator.pushNamed(context, '/Perfil'),
                            gradient: LinearGradient(
                              colors: [
                                Colors.purpleAccent.withOpacity(0.3),
                                Colors.blueAccent.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Perfil compacto con sombra sutil
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    "/Principal",
                  ), // Navegar al perfil completo
                  child: PerfilCompacto(
                    onRefresh: refrescar,
                    refreshController: refreshController,
                  ),
                ),
              ),

              // Calendario con separador sutil
              Container(
                height: MediaQuery.of(context).size.height * 0.13,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withOpacity(0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: CalendarioSemanal(
                  onDiaSeleccionado: (dia) {
                    setState(() => hoy = dia);
                  },
                ),
              ),

              // Lista de hábitos con mejoras visuales
              Expanded(
                child: AnimatedBuilder(
                  animation: refreshController,
                  builder: (context, _) {
                    return Container(
                      width: MediaQuery.of(context).size.width,
                      padding: const EdgeInsets.only(top: 8),
                      child: Stack(
                        children: [
                          // Lista de hábitos
                          Positioned.fill(
                            child: FutureBuilder(
                              future: ServicioHabitos.obtenerHabitosDelDia(hoy),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        CircularProgressIndicator(
                                          color: Colors.purpleAccent,
                                          strokeWidth: 3,
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          "Cargando hábitos...",
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.6,
                                            ),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
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
                                  habitos: List<Map<String, dynamic>>.from(
                                    habitos,
                                  ),
                                  onTap: (habito) {
                                    mostrarPopupHabito(context, habito);
                                  },
                                  refreshController: refreshController,
                                  diaSeleccionado: hoy,
                                );
                              },
                            ),
                          ),

                          // Botón flotante mejorado
                          Positioned(
                            right: 20,
                            bottom: 20,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/CrearHabitos');
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF9C27B0),
                                      Color(0xFF673AB7),
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purpleAccent.withOpacity(
                                        0.4,
                                      ),
                                      blurRadius: 15,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.add,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper para los botones del header
  Widget _buildHeaderButton({
    required IconData icon,
    required VoidCallback onTap,
    required LinearGradient gradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: gradient,
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
