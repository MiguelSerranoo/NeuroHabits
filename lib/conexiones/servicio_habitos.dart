import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ServicioHabitos {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Convertimos weekday a letra tipo "L", "M", etc.
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

    // Obtener todos los hábitos
    QuerySnapshot snap = await _db
        .collection("usuarios")
        .doc(userId)
        .collection("habitos")
        .get();

    for (var doc in snap.docs) {
      Map<String, dynamic> h = doc.data() as Map<String, dynamic>;

      List diasSemana = h["dias"] ?? [];
      bool repetirSiempre = h["repetirSiempre"] ?? true;
      String? fechaFin = h["fechaFin"];

      // ----- 1) Validar día -----
      if (!diasSemana.contains(diaLetra)) {
        continue;
      }

      // ----- 2) Validar fecha fin -----
      if (!repetirSiempre && fechaFin != null) {
        try {
          DateTime limite = DateTime.parse(fechaFin);
          if (diaSeleccionado.isAfter(limite)) {
            continue;
          }
        } catch (_) {}
      }

      // Si pasa los filtros → agregar
      resultado.add(h);
    }

    return resultado;
  }
}
