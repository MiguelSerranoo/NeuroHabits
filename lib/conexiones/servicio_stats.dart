import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neurohabits_app/paginas/modelo_stats.dart';

class StatService {
  static final _db = FirebaseFirestore.instance;

  // GUARDA LOS STATS INICIALES DEL USUARIO
  static Future<void> guardarStatsIniciales(List<String> stats) async {
    final userId = "TEMP_USER_ID"; // Sustituir por tu sistema de auth

    for (String stat in stats) {
      final statObj = StatModel(nombre: stat);

      await _db
          .collection("usuarios")
          .doc(userId)
          .collection("stats")
          .doc(stat.toLowerCase())
          .set(statObj.toMap());
    }
  }

  // OBTENER LOS STATS DEL USUARIO
  static Future<List<StatModel>> obtenerStatsUsuario() async {
    final userId = "TEMP_USER_ID";

    final snap = await _db
        .collection("usuarios")
        .doc(userId)
        .collection("stats")
        .get();

    return snap.docs.map((d) => StatModel.fromMap(d.data())).toList();
  }
}
