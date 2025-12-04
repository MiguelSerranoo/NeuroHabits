import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServicioHabitos {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static String letraDia(int weekday) {
    const mapa = {1: "L", 2: "M", 3: "X", 4: "J", 5: "V", 6: "S", 7: "D"};
    return mapa[weekday]!;
  }

  static Future<List<Map<String, dynamic>>> obtenerHabitosDelDia(
    DateTime diaSeleccionado,
  ) async {
    String diaLetra = letraDia(diaSeleccionado.weekday);
    List<Map<String, dynamic>> resultado = [];
    final userId = FirebaseAuth.instance.currentUser!.uid;

    QuerySnapshot snap = await _db
        .collection("usuarios")
        .doc(userId)
        .collection("habitos")
        .get();

    for (var doc in snap.docs) {
      Map<String, dynamic> h = doc.data() as Map<String, dynamic>;

      // IMPORTANTE: Añadir el ID del documento
      h["id"] = doc.id;

      List diasSemana = h["dias"] ?? [];
      bool repetirSiempre = h["repetirSiempre"] ?? true;
      String? fechaFin = h["fechaFin"];

      if (!diasSemana.contains(diaLetra)) {
        continue;
      }

      if (!repetirSiempre && fechaFin != null) {
        try {
          DateTime limite = DateTime.parse(fechaFin);
          if (diaSeleccionado.isAfter(limite)) {
            continue;
          }
        } catch (_) {}
      }

      resultado.add(h);
    }

    return resultado;
  }

  // Método para actualizar un hábito
  static Future<void> actualizarHabito(
    String habitoId,
    Map<String, dynamic> datos,
  ) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    await _db
        .collection("usuarios")
        .doc(userId)
        .collection("habitos")
        .doc(habitoId)
        .update(datos);
  }

  // Método para borrar un hábito
  static Future<void> borrarHabito(String habitoId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    await _db
        .collection("usuarios")
        .doc(userId)
        .collection("habitos")
        .doc(habitoId)
        .delete();
  }

  // Método para obtener un hábito específico
  static Future<Map<String, dynamic>?> obtenerHabito(String habitoId) async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final doc = await _db
        .collection("usuarios")
        .doc(userId)
        .collection("habitos")
        .doc(habitoId)
        .get();

    if (!doc.exists) return null;

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data["id"] = doc.id;

    return data;
  }
}
