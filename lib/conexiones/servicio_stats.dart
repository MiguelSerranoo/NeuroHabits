import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neurohabits_app/paginas/modelo_stats.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatService {
  static final _db = FirebaseFirestore.instance;
  DateTime diahoy = DateTime.now();

  // GUARDA LOS STATS INICIALES DEL USUARIO
  static Future<void> guardarStatsIniciales(List<String> stats) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    // Sustituir por tu sistema de auth

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

  static Future<void> subirExp(String stat, int cantidad) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final ref = _db
        .collection("usuarios")
        .doc(userId)
        .collection("stats")
        .doc(stat.toLowerCase());

    final snap = await ref.get();

    if (!snap.exists) return;

    StatModel model = StatModel.fromMap(snap.data()!);

    model.exp += cantidad;
    // Subir de nivel automáticamente
    while (model.exp >= model.expNecesaria) {
      model.exp -= model.expNecesaria; // resto exp sobrante
      model.nivel += 1; // sube nivel
      model.expNecesaria = (model.expNecesaria * 1.2).round();
    }

    await ref.set(model.toMap());
  }

  // =========================================================
  //   🔥 BAJAR EXP (NUNCA BAJA DE 0)
  // =========================================================
  static Future<void> bajarExp(String stat, int cantidad) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final ref = _db
        .collection("usuarios")
        .doc(userId)
        .collection("stats")
        .doc(stat.toLowerCase());

    final snap = await ref.get();

    if (!snap.exists) return;

    StatModel model = StatModel.fromMap(snap.data()!);

    model.exp -= cantidad;

    if (model.exp < 0) model.exp = 0;

    await ref.set(model.toMap());
  }
}
