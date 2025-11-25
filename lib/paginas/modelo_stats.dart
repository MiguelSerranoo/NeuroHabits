class StatModel {
  final String nombre; // ejemplo: "salud"
  int nivel; // nivel actual
  int exp; // xp acumulada
  int expNecesaria; // xp para subir de nivel

  StatModel({
    required this.nombre,
    this.nivel = 1,
    this.exp = 0,
    this.expNecesaria = 100,
  });

  // 👉 Añadir experiencia
  void subirExperiencia(int cantidad) {
    exp += cantidad;

    // Si supera el límite → subir nivel
    while (exp >= expNecesaria) {
      exp -= expNecesaria; // xp sobrante
      nivel++; // subir nivel
      expNecesaria = _calcularNuevaExperienciaNecesaria();
    }
  }

  // 👉 Quitar experiencia (por fallar hábitos)
  void quitarExperiencia(int cantidad) {
    exp -= cantidad;

    // Si baja de cero → bajar nivel
    while (exp < 0 && nivel > 1) {
      nivel--;
      expNecesaria = _calcularNuevaExperienciaNecesaria();
      exp += expNecesaria;
    }

    // evitar valores negativos
    if (exp < 0) exp = 0;
  }

  // Fórmula para subir experiencia necesaria por nivel
  int _calcularNuevaExperienciaNecesaria() {
    return (expNecesaria * 1.2).round(); // +20% por nivel
  }

  // Convertir a mapa para subir a Firestore
  Map<String, dynamic> toMap() {
    return {
      "nombre": nombre,
      "nivel": nivel,
      "exp": exp,
      "expNecesaria": expNecesaria,
    };
  }

  // Crear un stat desde Firestore
  factory StatModel.fromMap(Map<String, dynamic> map) {
    return StatModel(
      nombre: map["nombre"],
      nivel: map["nivel"] ?? 1,
      exp: map["exp"] ?? 0,
      expNecesaria: map["expNecesaria"] ?? 100,
    );
  }
}
