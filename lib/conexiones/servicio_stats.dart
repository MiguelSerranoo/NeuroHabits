import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:neurohabits_app/paginas/modelo_stats.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StatService {
  static final _db = FirebaseFirestore.instance;
  DateTime diahoy = DateTime.now();

  static Future<void> guardarStatsIniciales(List<String> stats) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

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
    while (model.exp >= model.expNecesaria) {
      model.exp -= model.expNecesaria;
      model.nivel += 1;
      model.expNecesaria = (model.expNecesaria * 1.2).round();
    }

    await ref.set(model.toMap());
  }

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
