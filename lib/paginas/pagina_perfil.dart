import 'package:flutter/material.dart';
import 'package:neurohabits_app/conexiones/servicio_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Perfil extends StatefulWidget {
  const Perfil({super.key});
  @override
  State<Perfil> createState() => _PerfilState();
}

class _PerfilState extends State<Perfil> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? personajeData;
  List<Map<String, dynamic>> statsData = [];
  Map<String, dynamic>? estadisticasHabitos;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _cargarDatos();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    setState(() => isLoading = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Cargar personaje
      final perfilDoc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(user.uid)
          .collection("personaje")
          .doc("perfil")
          .get();

      // Cargar stats
      final statsSnap = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(user.uid)
          .collection("stats")
          .get();

      // Cargar hábitos para estadísticas
      final habitosSnap = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(user.uid)
          .collection("habitos")
          .get();

      // Calcular estadísticas de hábitos
      int totalHabitos = habitosSnap.docs.length;
      int habitosCompletadosHoy = 0;

      final hoy = DateTime.now();
      final claveHoy =
          "${hoy.year}-${hoy.month.toString().padLeft(2, '0')}-${hoy.day.toString().padLeft(2, '0')}";

      for (var habito in habitosSnap.docs) {
        final historialDoc = await habito.reference
            .collection("historial")
            .doc(claveHoy)
            .get();

        if (historialDoc.exists &&
            (historialDoc.data()?["completado"] ?? false)) {
          habitosCompletadosHoy++;
        }
      }

      setState(() {
        personajeData = perfilDoc.data();
        statsData = statsSnap.docs.map((doc) => doc.data()).toList();
        estadisticasHabitos = {
          'total': totalHabitos,
          'completadosHoy': habitosCompletadosHoy,
          'porcentaje': totalHabitos > 0
              ? ((habitosCompletadosHoy / totalHabitos) * 100).round()
              : 0,
        };
        isLoading = false;
      });
    } catch (e) {
      print("Error cargando datos: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String? email = user?.email;
    final String nombre =
        personajeData?["nombre"] ?? user?.displayName ?? "Usuario";
    final String avatar = personajeData?["avatar"] ?? "";

    return Scaffold(
      backgroundColor: Colors.black,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent),
            )
          : CustomScrollView(
              slivers: [
                // AppBar con gradiente y avatar
                SliverAppBar(
                  expandedHeight: 330,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.black,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Gradiente de fondo
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.purple.withOpacity(0.4),
                                Colors.black,
                              ],
                            ),
                          ),
                        ),

                        // Contenido del header
                        SafeArea(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 70),
                              // Avatar con borde animado
                              Container(
                                width: 130,
                                height: 130,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.purpleAccent,
                                      Colors.blueAccent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purpleAccent.withOpacity(
                                        0.5,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Container(
                                  margin: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                  child: ClipOval(
                                    child: avatar.isNotEmpty
                                        ? Image.asset(
                                            "assets/avatares/$avatar",
                                            fit: BoxFit.cover,
                                          )
                                        : const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Colors.white,
                                          ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 16),

                              // Nombre
                              Text(
                                nombre,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 8),

                              // Email con icono
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email_outlined,
                                    color: Colors.white.withOpacity(0.6),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    email ?? "Sin correo",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(48),
                    child: Container(
                      color: Colors.black,
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.purpleAccent,
                        indicatorWeight: 3,
                        labelColor: Colors.purpleAccent,
                        unselectedLabelColor: Colors.white60,
                        tabs: const [
                          Tab(text: "Estadísticas"),
                          Tab(text: "Habilidades"),
                        ],
                      ),
                    ),
                  ),
                ),

                // Contenido de las tabs
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 400,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildEstadisticasTab(),
                        _buildHabilidadesTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildEstadisticasTab() {
    final stats = estadisticasHabitos ?? {};
    final nivelPromedio = statsData.isNotEmpty
        ? (statsData.fold<double>(
                    0.0,
                    (sum, stat) =>
                        sum + ((stat["nivel"] ?? 0) as num).toDouble(),
                  ) /
                  statsData.length)
              .round()
        : 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card de resumen - CENTRADO
          Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.purpleAccent.withOpacity(0.2),
                    Colors.blueAccent.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.purpleAccent.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    "Tu Progreso de Hoy",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Círculo de progreso
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: (stats['porcentaje'] ?? 0) / 100,
                          strokeWidth: 14,
                          backgroundColor: Colors.white.withOpacity(0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.greenAccent,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${stats['porcentaje'] ?? 0}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "${stats['completadosHoy']}/${stats['total']}",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "completados",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Botones de acción
          _buildActionButton(
            "Editar Perfil",
            Icons.edit,
            Colors.purpleAccent,
            () {
              // TODO: Implementar edición de perfil
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Función en desarrollo"),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          _buildActionButton(
            "Configuración",
            Icons.settings,
            Colors.blueAccent,
            () {
              // TODO: Implementar configuración
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Función en desarrollo"),
                  backgroundColor: Colors.orange,
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          _buildActionButton(
            "Cerrar Sesión",
            Icons.logout,
            Colors.redAccent,
            () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF2A2A2A),
                  title: const Text(
                    "¿Cerrar sesión?",
                    style: TextStyle(color: Colors.white),
                  ),
                  content: const Text(
                    "¿Estás seguro de que quieres cerrar sesión?",
                    style: TextStyle(color: Colors.white70),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text("Cancelar"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.redAccent,
                      ),
                      child: const Text("Cerrar sesión"),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await AuthService.logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, "/login");
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHabilidadesTab() {
    // Ordenar stats: primero por nivel (mayor a menor), luego por exp (mayor a menor)
    final statsSorted = List<Map<String, dynamic>>.from(statsData)
      ..sort((a, b) {
        final nivelA = a["nivel"] ?? 0;
        final nivelB = b["nivel"] ?? 0;

        // Si tienen diferente nivel, ordenar por nivel
        if (nivelA != nivelB) {
          return nivelB.compareTo(nivelA);
        }

        // Si tienen el mismo nivel, ordenar por exp
        final expA = a["exp"] ?? 0;
        final expB = b["exp"] ?? 0;
        return expB.compareTo(expA);
      });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(statsSorted.length, (index) {
          final stat = statsSorted[index];
          final nombre = stat["nombre"] ?? "Desconocido";
          final nivel = stat["nivel"] ?? 0;
          final exp = stat["exp"] ?? 0;
          final expNecesaria = stat["expNecesaria"] ?? 100;
          final progreso = exp / expNecesaria;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _getColorForStat(nombre).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getColorForStat(nombre).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconForStat(nombre),
                        color: _getColorForStat(nombre),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nombre,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _getDescripcionStat(nombre),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Nivel $nivel",
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Barra de progreso
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Progreso al siguiente nivel",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          "$exp / $expNecesaria EXP",
                          style: TextStyle(
                            color: _getColorForStat(nombre),
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progreso,
                        minHeight: 10,
                        backgroundColor: Colors.white.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          _getColorForStat(nombre),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

Widget _buildActionButton(
  String texto,
  IconData icono,
  Color color,
  VoidCallback onPressed,
) {
  return SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: color.withOpacity(0.5), width: 2),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icono, color: color),
          const SizedBox(width: 12),
          Text(
            texto,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );
}

Color _getColorForStat(String stat) {
  final colores = {
    "Salud": const Color(0xFFFF6B6B),
    "Fuerza": const Color(0xFFFF9F43),
    "Inteligencia": const Color(0xFF4ECDC4),
    "Creatividad": const Color(0xFFB8E986),
    "Disciplina": const Color(0xFF9B59B6),
    "Social": const Color(0xFFFECA57),
    "Energía": const Color(0xFFFFD93D),
    "Agilidad": const Color(0xFF00D2FF),
    "Resistencia": const Color(0xFF6C5CE7),
    "Carisma": const Color(0xFFFD79A8),
    "Sabiduría": const Color(0xFF74B9FF),
    "Destreza": const Color(0xFFA29BFE),
    "Concentración": const Color(0xFF00B894),
    "Paciencia": const Color(0xFF81ECEC),
    "Liderazgo": const Color(0xFFFAB1A0),
    "Empatía": const Color(0xFFFF7675),
    "Velocidad": const Color(0xFF55EFC4),
    "Memoria": const Color(0xFFDFE6E9),
    "Adaptabilidad": const Color(0xFFFECEA8),
    "Motivación": const Color(0xFFFF6348),
  };
  return colores[stat] ?? Colors.purpleAccent;
}

String _getDescripcionStat(String stat) {
  final descripciones = {
    "Salud": "Bienestar físico y mental general",
    "Fuerza": "Poder físico y capacidad muscular",
    "Inteligencia": "Capacidad cognitiva y razonamiento",
    "Creatividad": "Innovación, arte e imaginación",
    "Disciplina": "Autocontrol y constancia",
    "Social": "Interacción y conexión con otros",
    "Energía": "Vitalidad y vigor diario",
    "Agilidad": "Velocidad y reflejos rápidos",
    "Resistencia": "Aguante y durabilidad física",
    "Carisma": "Encanto y magnetismo personal",
    "Sabiduría": "Conocimiento y experiencia acumulada",
    "Destreza": "Habilidad manual y precisión",
    "Concentración": "Enfoque mental sostenido",
    "Paciencia": "Control emocional y calma",
    "Liderazgo": "Capacidad de guiar e inspirar",
    "Empatía": "Conexión emocional con otros",
    "Velocidad": "Rapidez de movimiento y acción",
    "Memoria": "Retención y recuerdo de información",
    "Adaptabilidad": "Flexibilidad ante el cambio",
    "Motivación": "Impulso interno y determinación",
  };
  return descripciones[stat] ?? "Habilidad especial";
}

IconData _getIconForStat(String stat) {
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
