class StatModel {
  final String nombre; // ejemplo: "salud"
  int nivel; // nivel actual
  int experiencia; // xp acumulada
  int experienciaNecesaria; // xp para subir de nivel

  StatModel({
    required this.nombre,
    this.nivel = 1,
    this.experiencia = 0,
    this.experienciaNecesaria = 100,
  });

  // 👉 Añadir experiencia
  void subirExperiencia(int cantidad) {
    experiencia += cantidad;

    // Si supera el límite → subir nivel
    while (experiencia >= experienciaNecesaria) {
      experiencia -= experienciaNecesaria; // xp sobrante
      nivel++; // subir nivel
      experienciaNecesaria = _calcularNuevaExperienciaNecesaria();
    }
  }

  // 👉 Quitar experiencia (por fallar hábitos)
  void quitarExperiencia(int cantidad) {
    experiencia -= cantidad;

    // Si baja de cero → bajar nivel
    while (experiencia < 0 && nivel > 1) {
      nivel--;
      experienciaNecesaria = _calcularNuevaExperienciaNecesaria();
      experiencia += experienciaNecesaria;
    }

    // evitar valores negativos
    if (experiencia < 0) experiencia = 0;
  }

  // Fórmula para subir experiencia necesaria por nivel
  int _calcularNuevaExperienciaNecesaria() {
    return (experienciaNecesaria * 1.2).round(); // +20% por nivel
  }

  // Convertir a mapa para subir a Firestore
  Map<String, dynamic> toMap() {
    return {
      "nombre": nombre,
      "nivel": nivel,
      "exp": experiencia,
      "expNecesaria": experienciaNecesaria,
    };
  }

  // Crear un stat desde Firestore
  factory StatModel.fromMap(Map<String, dynamic> map) {
    return StatModel(
      nombre: map["nombre"],
      nivel: map["nivel"] ?? 1,
      experiencia: map["exp"] ?? 0,
      experienciaNecesaria: map["expNecesaria"] ?? 100,
    );
  }
}
