import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ComparacionPage extends StatelessWidget {
  const ComparacionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF2A2A2A),
          title: const Text("Ranking"),
        ),
        body: const Center(
          child: Text(
            "Debes iniciar sesión",
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A2A2A),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Ranking de Jugadores",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _cargarTodosLosUsuarios(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.purple),
                  SizedBox(height: 16),
                  Text(
                    "Cargando jugadores...",
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Error: ${snapshot.error}",
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          final usuarios = snapshot.data ?? [];

          if (usuarios.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "No hay otros jugadores aún",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Sé el primero en crear tu personaje",
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: usuarios.length,
            itemBuilder: (context, index) {
              final usuario = usuarios[index];
              final esMiPersonaje = usuario['uid'] == user.uid;

              return _buildUsuarioCard(
                context,
                usuario,
                index + 1,
                esMiPersonaje,
                user.uid,
              );
            },
          );
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _cargarTodosLosUsuarios(
    String miUid,
  ) async {
    try {
      print("🔍 === INICIO DEBUG ===");
      print("🔍 Mi UID: $miUid");

      // Ver todas las colecciones
      final usuariosSnapshot = await FirebaseFirestore.instance
          .collection("usuarios")
          .get();

      print(
        "📊 Total de documentos en colección 'usuarios': ${usuariosSnapshot.docs.length}",
      );

      if (usuariosSnapshot.docs.isEmpty) {
        print("❌ ¡La colección 'usuarios' está VACÍA!");
        return [];
      }

      // Listar todos los UIDs encontrados
      print("📋 UIDs encontrados:");
      for (var doc in usuariosSnapshot.docs) {
        print("   - ${doc.id}");
      }

      List<Map<String, dynamic>> listaUsuarios = [];

      for (var userDoc in usuariosSnapshot.docs) {
        final uid = userDoc.id;
        print("\n👤 === Procesando usuario: $uid ===");

        // Ver qué subcolecciones tiene
        print("   🔍 Buscando personaje/perfil...");

        final perfilDoc = await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(uid)
            .collection("personaje")
            .doc("perfil")
            .get();

        print("   📄 Documento perfil existe: ${perfilDoc.exists}");

        if (perfilDoc.exists) {
          print("   ✅ Datos del perfil: ${perfilDoc.data()}");
        } else {
          print("   ❌ NO EXISTE el documento perfil");

          // Ver qué hay en la subcolección personaje
          final personajeSnap = await FirebaseFirestore.instance
              .collection("usuarios")
              .doc(uid)
              .collection("personaje")
              .get();

          print(
            "   📊 Documentos en subcolección 'personaje': ${personajeSnap.docs.length}",
          );
          for (var doc in personajeSnap.docs) {
            print("      - ${doc.id}");
          }
          continue;
        }

        // Cargar stats
        print("   🔍 Buscando stats...");
        final statsSnapshot = await FirebaseFirestore.instance
            .collection("usuarios")
            .doc(uid)
            .collection("stats")
            .get();

        print("   📈 Total stats encontradas: ${statsSnapshot.docs.length}");

        final stats = statsSnapshot.docs.map((doc) {
          print("      - Stat: ${doc.id} -> ${doc.data()}");
          return {
            "nombre": doc.data()["nombre"] ?? doc.id,
            "nivel": doc.data()["nivel"] ?? 0,
            "exp": doc.data()["exp"] ?? 0,
            "expNecesaria": doc.data()["expNecesaria"] ?? 0,
          };
        }).toList();

        int nivelPromedio = 0;
        if (stats.isNotEmpty) {
          final sumaNiveles = stats.fold<int>(
            0,
            (prev, stat) => prev + (stat["nivel"] as int),
          );
          nivelPromedio = (sumaNiveles / stats.length).round();
        }

        final perfil = perfilDoc.data()!;

        listaUsuarios.add({
          'uid': uid,
          'nombre': perfil['nombre'] ?? 'Desconocido',
          'avatar': perfil['avatar'] ?? '',
          'nivelPromedio': nivelPromedio,
          'stats': stats,
          'esMio': uid == miUid,
        });

        print("   ✅ Usuario añadido exitosamente");
      }

      print("\n🎉 === FIN DEBUG ===");
      print("🎉 Total usuarios válidos agregados: ${listaUsuarios.length}");

      listaUsuarios.sort(
        (a, b) => b['nivelPromedio'].compareTo(a['nivelPromedio']),
      );

      return listaUsuarios;
    } catch (e, stackTrace) {
      print("💥 ERROR CRÍTICO: $e");
      print("📍 Stack trace: $stackTrace");
      return [];
    }
  }

  Widget _buildUsuarioCard(
    BuildContext context,
    Map<String, dynamic> usuario,
    int posicion,
    bool esMio,
    String miUid,
  ) {
    final nombre = usuario['nombre'] as String;
    final avatar = usuario['avatar'] as String;
    final nivelPromedio = usuario['nivelPromedio'] as int;

    Color colorMedalla = Colors.grey;
    IconData? iconoMedalla;

    if (posicion == 1) {
      colorMedalla = Colors.amber;
      iconoMedalla = Icons.emoji_events;
    } else if (posicion == 2) {
      colorMedalla = Colors.grey.shade400;
      iconoMedalla = Icons.emoji_events;
    } else if (posicion == 3) {
      colorMedalla = Colors.brown.shade300;
      iconoMedalla = Icons.emoji_events;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: esMio
            ? LinearGradient(
                colors: [
                  Colors.purple.withOpacity(0.3),
                  Colors.blue.withOpacity(0.2),
                ],
              )
            : null,
        color: esMio ? null : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: esMio ? Colors.purple : Colors.white.withOpacity(0.1),
          width: esMio ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Posición
          SizedBox(
            width: 40,
            child: Column(
              children: [
                if (iconoMedalla != null)
                  Icon(iconoMedalla, color: colorMedalla, size: 28)
                else
                  Text(
                    "$posicion",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: esMio ? Colors.purple : Colors.white30,
                width: 2,
              ),
            ),
            child: ClipOval(
              child: avatar.isNotEmpty
                  ? Image.asset(
                      "assets/avatares/$avatar",
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey,
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade800,
                      child: Center(
                        child: Text(
                          nombre[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 16),

          // Nombre y nivel
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        nombre,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (esMio) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.purple,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          "TÚ",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "Nivel promedio: $nivelPromedio",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Botón comparar
          if (!esMio)
            IconButton(
              onPressed: () {
                _mostrarComparacion(context, miUid, usuario['uid'], usuario);
              },
              icon: const Icon(Icons.compare_arrows),
              color: Colors.purple,
              iconSize: 28,
            ),
        ],
      ),
    );
  }

  void _mostrarComparacion(
    BuildContext context,
    String miUid,
    String otroUid,
    Map<String, dynamic> otroUsuario,
  ) async {
    // Mostrar loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          const Center(child: CircularProgressIndicator(color: Colors.purple)),
    );

    try {
      // Cargar mis datos
      final misDatos = await _cargarDatosUsuario(miUid);

      // Cerrar loading
      if (context.mounted) Navigator.pop(context);

      if (misDatos == null) {
        _mostrarError(context, "No se encontró tu personaje");
        return;
      }

      // Usar los datos ya cargados del otro usuario
      final otrosDatos = {
        'personaje': {
          'nombre': otroUsuario['nombre'],
          'avatar': otroUsuario['avatar'],
        },
        'stats': otroUsuario['stats'],
      };

      // Mostrar popup de comparación
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => ComparacionPopup(
            miPersonaje: misDatos['personaje'],
            misStats: List<Map<String, dynamic>>.from(misDatos['stats']),
            otroPersonaje: otrosDatos['personaje'],
            statsOtro: List<Map<String, dynamic>>.from(otrosDatos['stats']),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        _mostrarError(context, "Error: $e");
      }
    }
  }

  Future<Map<String, dynamic>?> _cargarDatosUsuario(String uid) async {
    try {
      final perfilDoc = await FirebaseFirestore.instance
          .collection("usuarios")
          .doc(uid)
          .collection("personaje")
          .doc("perfil")
          .get();

      if (!perfilDoc.exists) return null;

      final statsSnapshot = await FirebaseFirestore.instance
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
      print("Error cargando datos: $e");
      return null;
    }
  }

  void _mostrarError(BuildContext context, String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text("Error", style: TextStyle(color: Colors.redAccent)),
        content: Text(mensaje, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.purple)),
          ),
        ],
      ),
    );
  }
}

// POPUP DE COMPARACIÓN
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
                        return _buildStatRow(hab, mias[hab], suyas[hab]);
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
    final avatar = personaje["avatar"] ?? "";

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentColor.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accentColor.withOpacity(0.3),
            ),
            child: ClipOval(
              child: avatar.isNotEmpty
                  ? Image.asset(
                      "assets/avatares/$avatar",
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          nombre[0].toUpperCase(),
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        nombre[0].toUpperCase(),
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
