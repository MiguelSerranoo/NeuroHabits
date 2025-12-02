import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// CLASE PARA CARGAR Y MOSTRAR LA COMPARACIÓN
class ComparacionHelper {
  static Future<void> mostrarComparacion(
    BuildContext context,
    String miUid,
    String otroUid,
  ) async {
    try {
      // Mostrar loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Cargar datos de ambos usuarios
      final misDatos = await _cargarDatosUsuario(miUid);
      final otrosDatos = await _cargarDatosUsuario(otroUid);

      // Cerrar loading
      if (context.mounted) Navigator.pop(context);

      // Verificar que existan los datos
      if (misDatos == null) {
        _mostrarError(context, "No se encontró tu personaje");
        return;
      }
      if (otrosDatos == null) {
        _mostrarError(context, "No se encontró el personaje del otro usuario");
        return;
      }

      // Mostrar popup de comparación
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => ComparacionPopup(
            miPersonaje: misDatos['personaje'],
            misStats: misDatos['stats'],
            otroPersonaje: otrosDatos['personaje'],
            statsOtro: otrosDatos['stats'],
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Cerrar loading si está abierto
        _mostrarError(context, "Error al cargar datos: $e");
      }
    }
  }

  static Future<Map<String, dynamic>?> _cargarDatosUsuario(String uid) async {
    try {
      final db = FirebaseFirestore.instance;

      // Cargar perfil del personaje
      final perfilDoc = await db
          .collection("usuarios")
          .doc(uid)
          .collection("personaje")
          .doc("perfil")
          .get();

      if (!perfilDoc.exists) return null;

      // Cargar stats
      final statsSnapshot = await db
          .collection("usuarios")
          .doc(uid)
          .collection("stats")
          .get();

      final stats = statsSnapshot.docs
          .map(
            (doc) => {
              "nombre": doc.data()["nombre"] ?? doc.id,
              "nivel": doc.data()["nivel"] ?? 0,
              "exp": doc.data()["exp"] ?? 0,
              "expNecesaria": doc.data()["expNecesaria"] ?? 0,
            },
          )
          .toList();

      return {'personaje': perfilDoc.data()!, 'stats': stats};
    } catch (e) {
      print("Error cargando datos de usuario $uid: $e");
      return null;
    }
  }

  static void _mostrarError(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text("Error", style: TextStyle(color: Colors.redAccent)),
        content: Text(mensaje, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}

// POPUP DE COMPARACIÓN MEJORADO
class ComparacionPopup extends StatelessWidget {
  final Map<String, dynamic> miPersonaje;
  final List<Map<String, dynamic>> misStats;
  final Map<String, dynamic> otroPersonaje;
  final List<Map<String, dynamic>> statsOtro;

  const ComparacionPopup({
    super.key,
    required this.miPersonaje,
    required this.misStats,
    required this.otroPersonaje,
    required this.statsOtro,
  });

  @override
  Widget build(BuildContext context) {
    // Crear mapas de habilidades con manejo seguro de datos
    final mias = <String, Map<String, dynamic>>{};
    for (var s in misStats) {
      final nombre = s["nombre"];
      if (nombre != null) {
        mias[nombre] = s;
      }
    }

    final suyas = <String, Map<String, dynamic>>{};
    for (var s in statsOtro) {
      final nombre = s["nombre"];
      if (nombre != null) {
        suyas[nombre] = s;
      }
    }

    // Obtener todas las habilidades únicas y ordenarlas
    final habilidades = {...mias.keys, ...suyas.keys}.toList()..sort();

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 700),
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
            _buildHeader(context),
            _buildPersonajesRow(),
            const Divider(color: Colors.white24, height: 1),
            Flexible(
              child: habilidades.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: habilidades.length,
                      itemBuilder: (context, index) {
                        final hab = habilidades[index];
                        final miStat = mias[hab];
                        final suStat = suyas[hab];
                        return _buildStatRow(hab, miStat, suStat);
                      },
                    ),
            ),
            _buildResumenGeneral(mias, suyas),
            _buildCloseButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.3),
            Colors.blue.withOpacity(0.3),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.compare_arrows, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Comparación de Personajes",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonajesRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _buildPersonajeCard(miPersonaje, Colors.blue, true)),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              "VS",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: _buildPersonajeCard(otroPersonaje, Colors.red, false),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonajeCard(
    Map<String, dynamic> personaje,
    Color accentColor,
    bool esMio,
  ) {
    final nombre = personaje["nombre"] ?? "Desconocido";
    final avatar = personaje["avatar"];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: accentColor.withOpacity(0.3),
            child: avatar != null && avatar.toString().isNotEmpty
                ? Text(avatar.toString(), style: const TextStyle(fontSize: 30))
                : Text(
                    nombre[0].toUpperCase(),
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            nombre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (esMio)
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Tú",
                style: TextStyle(color: Colors.greenAccent, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    String habilidad,
    Map<String, dynamic>? miStat,
    Map<String, dynamic>? suStat,
  ) {
    final miNivel = miStat?["nivel"] ?? 0;
    final suNivel = suStat?["nivel"] ?? 0;

    Color color = Colors.white70;
    IconData? icon;

    if (miNivel > 0 && suNivel > 0) {
      if (miNivel > suNivel) {
        color = Colors.greenAccent;
        icon = Icons.arrow_upward;
      } else if (miNivel < suNivel) {
        color = Colors.redAccent;
        icon = Icons.arrow_downward;
      } else {
        color = Colors.orangeAccent;
        icon = Icons.drag_handle;
      }
    }

    final diferencia = (miNivel - suNivel).abs();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  habilidad,
                  style: TextStyle(
                    color: color,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (miNivel > 0 && suNivel > 0 && diferencia > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "±$diferencia",
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildNivelBar("Tú", miNivel, Colors.blue)),
              const SizedBox(width: 16),
              Expanded(child: _buildNivelBar("Rival", suNivel, Colors.red)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNivelBar(String label, int nivel, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            Text(
              nivel.toString(),
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: nivel / 100,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildResumenGeneral(
    Map<String, Map<String, dynamic>> mias,
    Map<String, Map<String, dynamic>> suyas,
  ) {
    int ventajas = 0;
    int desventajas = 0;
    int empates = 0;

    for (var hab in {...mias.keys, ...suyas.keys}) {
      final miNivel = mias[hab]?["nivel"] ?? 0;
      final suNivel = suyas[hab]?["nivel"] ?? 0;

      if (miNivel > 0 && suNivel > 0) {
        if (miNivel > suNivel) {
          ventajas++;
        } else if (miNivel < suNivel) {
          desventajas++;
        } else {
          empates++;
        }
      }
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildResumenItem("Ventajas", ventajas, Colors.greenAccent),
          _buildResumenItem("Empates", empates, Colors.orangeAccent),
          _buildResumenItem("Desventajas", desventajas, Colors.redAccent),
        ],
      ),
    );
  }

  Widget _buildResumenItem(String label, int valor, Color color) {
    return Column(
      children: [
        Text(
          valor.toString(),
          style: TextStyle(
            color: color,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.white30),
            SizedBox(height: 16),
            Text(
              "No hay estadísticas para comparar",
              style: TextStyle(color: Colors.white60, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.1),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.white.withOpacity(0.2)),
            ),
          ),
          child: const Text(
            "Cerrar",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

// PÁGINA PARA USAR EN RUTAS
class ComparacionPage extends StatelessWidget {
  const ComparacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtener mi UID automáticamente de Firebase Auth
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return _buildErrorScreen(
        context,
        "No has iniciado sesión",
        "Debes iniciar sesión para comparar personajes",
        Icons.login,
      );
    }

    final miUid = user.uid;

    // Intentar obtener otroUid de los argumentos (opcional)
    String? otroUid;
    final route = ModalRoute.of(context);
    if (route?.settings.arguments != null) {
      try {
        final args = route!.settings.arguments as Map<String, dynamic>;
        otroUid = args['otroUid'] as String?;
      } catch (e) {
        // Si falla, buscaremos un usuario aleatorio
      }
    }

    // Si no hay otroUid, buscar uno automáticamente
    if (otroUid == null) {
      return _buildBuscandoUsuarioScreen(context, miUid);
    }

    return _buildComparacionScaffold(context, miUid, otroUid);
  }

  // Pantalla que busca automáticamente un usuario para comparar
  Widget _buildBuscandoUsuarioScreen(BuildContext context, String miUid) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text("Comparación de Personajes"),
      ),
      body: FutureBuilder<String?>(
        future: _buscarUsuarioAleatorio(miUid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.purple),
                  SizedBox(height: 16),
                  Text(
                    "Buscando un rival...",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorContent(
              context,
              "Error al buscar usuarios",
              snapshot.error.toString(),
              Icons.error_outline,
            );
          }

          final otroUid = snapshot.data;
          if (otroUid == null) {
            return _buildErrorContent(
              context,
              "No hay otros usuarios",
              "No se encontraron otros usuarios con personajes para comparar",
              Icons.person_off,
            );
          }

          // Redirigir a la comparación con el usuario encontrado
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
              context,
              '/comparacion',
              arguments: {'otroUid': otroUid},
            );
          });

          return const Center(
            child: CircularProgressIndicator(color: Colors.purple),
          );
        },
      ),
    );
  }

  // Buscar un usuario aleatorio diferente a mí
  Future<String?> _buscarUsuarioAleatorio(String miUid) async {
    try {
      print("🔍 Buscando usuarios en Firestore...");
      print("📱 Mi UID: $miUid");

      final snapshot = await FirebaseFirestore.instance
          .collection("usuarios")
          .get();

      print("📊 Total de usuarios encontrados: ${snapshot.docs.length}");

      // Filtrar usuarios que no sean yo
      final otrosUsuarios = snapshot.docs
          .where((doc) => doc.id != miUid)
          .toList();

      print("👥 Usuarios diferentes a mí: ${otrosUsuarios.length}");

      if (otrosUsuarios.isEmpty) {
        print("❌ No hay otros usuarios en la base de datos");
        return null;
      }

      // Verificar que tengan personaje creado
      for (var userDoc in otrosUsuarios) {
        print("🔎 Verificando usuario: ${userDoc.id}");

        try {
          final perfilDoc = await FirebaseFirestore.instance
              .collection("usuarios")
              .doc(userDoc.id)
              .collection("personaje")
              .doc("perfil")
              .get();

          print("   - Tiene perfil: ${perfilDoc.exists}");

          if (perfilDoc.exists) {
            final data = perfilDoc.data();
            print("   - Datos del perfil: $data");
            print("✅ Usuario encontrado para comparar: ${userDoc.id}");
            return userDoc.id;
          }
        } catch (e) {
          print("   - Error al verificar este usuario: $e");
          continue;
        }
      }

      print("❌ Ningún usuario tiene personaje/perfil creado");
      return null;
    } catch (e) {
      print("💥 Error general buscando usuario aleatorio: $e");
      return null;
    }
  }

  Widget _buildErrorScreen(
    BuildContext context,
    String title,
    String message,
    IconData icon,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text("Error"),
      ),
      body: _buildErrorContent(context, title, message, icon),
    );
  }

  Widget _buildErrorContent(
    BuildContext context,
    String title,
    String message,
    IconData icon,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: const Text("Volver"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparacionScaffold(
    BuildContext context,
    String miUid,
    String otroUid,
  ) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text("Comparación de Personajes"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future:
            Future.wait([
              ComparacionHelper._cargarDatosUsuario(miUid),
              ComparacionHelper._cargarDatosUsuario(otroUid),
            ]).then((results) {
              if (results[0] == null || results[1] == null) return null;
              return {'misDatos': results[0], 'otrosDatos': results[1]};
            }),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.purple),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Volver"),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No se encontraron los personajes",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Volver"),
                  ),
                ],
              ),
            );
          }

          final misDatos = data['misDatos'] as Map<String, dynamic>;
          final otrosDatos = data['otrosDatos'] as Map<String, dynamic>;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _buildComparacionContent(
                misDatos['personaje'],
                misDatos['stats'],
                otrosDatos['personaje'],
                otrosDatos['stats'],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComparacionContent(
    Map<String, dynamic> miPersonaje,
    List<Map<String, dynamic>> misStats,
    Map<String, dynamic> otroPersonaje,
    List<Map<String, dynamic>> statsOtro,
  ) {
    // Crear mapas de habilidades
    final mias = <String, Map<String, dynamic>>{};
    for (var s in misStats) {
      final nombre = s["nombre"];
      if (nombre != null) mias[nombre] = s;
    }

    final suyas = <String, Map<String, dynamic>>{};
    for (var s in statsOtro) {
      final nombre = s["nombre"];
      if (nombre != null) suyas[nombre] = s;
    }

    final habilidades = {...mias.keys, ...suyas.keys}.toList()..sort();

    return Column(
      children: [
        _buildPersonajesComparacion(miPersonaje, otroPersonaje),
        const SizedBox(height: 16),
        _buildResumenGeneral(mias, suyas),
        const SizedBox(height: 16),
        ...habilidades.map((hab) {
          final miStat = mias[hab];
          final suStat = suyas[hab];
          return _buildStatCard(hab, miStat, suStat);
        }).toList(),
      ],
    );
  }

  Widget _buildPersonajesComparacion(
    Map<String, dynamic> miPersonaje,
    Map<String, dynamic> otroPersonaje,
  ) {
    return Card(
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _buildPersonajeInfo(miPersonaje, Colors.blue, "Tú"),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "VS",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: _buildPersonajeInfo(otroPersonaje, Colors.red, "Rival"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonajeInfo(
    Map<String, dynamic> personaje,
    Color color,
    String label,
  ) {
    final nombre = personaje["nombre"] ?? "Desconocido";
    final avatar = personaje["avatar"];

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: color.withOpacity(0.3),
          child: avatar != null && avatar.toString().isNotEmpty
              ? Text(avatar.toString(), style: const TextStyle(fontSize: 40))
              : Text(
                  nombre[0].toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          nombre,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Container(
          margin: const EdgeInsets.only(top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, style: TextStyle(color: color, fontSize: 12)),
        ),
      ],
    );
  }

  Widget _buildResumenGeneral(
    Map<String, Map<String, dynamic>> mias,
    Map<String, Map<String, dynamic>> suyas,
  ) {
    int ventajas = 0;
    int desventajas = 0;
    int empates = 0;

    for (var hab in {...mias.keys, ...suyas.keys}) {
      final miNivel = mias[hab]?["nivel"] ?? 0;
      final suNivel = suyas[hab]?["nivel"] ?? 0;

      if (miNivel > 0 && suNivel > 0) {
        if (miNivel > suNivel) {
          ventajas++;
        } else if (miNivel < suNivel) {
          desventajas++;
        } else {
          empates++;
        }
      }
    }

    return Card(
      color: const Color(0xFF2A2A2A),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildResumenItem("Ventajas", ventajas, Colors.greenAccent),
            _buildResumenItem("Empates", empates, Colors.orangeAccent),
            _buildResumenItem("Desventajas", desventajas, Colors.redAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildResumenItem(String label, int valor, Color color) {
    return Column(
      children: [
        Text(
          valor.toString(),
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white60, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String habilidad,
    Map<String, dynamic>? miStat,
    Map<String, dynamic>? suStat,
  ) {
    final miNivel = miStat?["nivel"] ?? 0;
    final suNivel = suStat?["nivel"] ?? 0;

    Color color = Colors.white70;
    IconData? icon;

    if (miNivel > 0 && suNivel > 0) {
      if (miNivel > suNivel) {
        color = Colors.greenAccent;
        icon = Icons.arrow_upward;
      } else if (miNivel < suNivel) {
        color = Colors.redAccent;
        icon = Icons.arrow_downward;
      } else {
        color = Colors.orangeAccent;
        icon = Icons.drag_handle;
      }
    }

    final diferencia = (miNivel - suNivel).abs();

    return Card(
      color: const Color(0xFF2A2A2A),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: Text(
                    habilidad,
                    style: TextStyle(
                      color: color,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (miNivel > 0 && suNivel > 0 && diferencia > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "±$diferencia",
                      style: TextStyle(
                        color: color,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildNivelInfo("Tú", miNivel, Colors.blue)),
                const SizedBox(width: 16),
                Expanded(child: _buildNivelInfo("Rival", suNivel, Colors.red)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNivelInfo(String label, int nivel, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.white60, fontSize: 14),
            ),
            Text(
              nivel.toString(),
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: nivel / 100,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

// EJEMPLO DE USO EN RUTAS:
/*
// 1. En tu main.dart donde defines las rutas:
MaterialApp(
  routes: {
    '/comparacion': (context) => const ComparacionPage(),
    // ... otras rutas
  },
)

// 2. OPCIÓN A: Navegar SIN argumentos (busca un usuario aleatorio automáticamente):
Navigator.pushNamed(context, '/comparacion');

// 3. OPCIÓN B: Navegar con un usuario específico:
Navigator.pushNamed(
  context,
  '/comparacion',
  arguments: {
    'otroUid': 'uid-del-usuario-especifico',
  },
);

// EJEMPLO DE BOTÓN SIMPLE (sin pasar nada):
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(context, '/comparacion');
  },
  child: const Text("Buscar rival aleatorio"),
)

// EJEMPLO DE BOTÓN CON USUARIO ESPECÍFICO:
ElevatedButton(
  onPressed: () {
    Navigator.pushNamed(
      context,
      '/comparacion',
      arguments: {'otroUid': usuarioSeleccionado.uid},
    );
  },
  child: const Text("Comparar con este usuario"),
)
*/
