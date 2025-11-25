class StatModel {
  final String nombre;
  int nivel;
  int exp;
  int expNecesaria;

  StatModel({
    required this.nombre,
    this.nivel = 1,
    this.exp = 0,
    this.expNecesaria = 100,
  });

  void subirExperiencia(int cantidad) {
    exp += cantidad;

    while (exp >= expNecesaria) {
      exp -= expNecesaria;
      nivel++;
      expNecesaria = _calcularNuevaExperienciaNecesaria();
    }
  }

  void quitarExperiencia(int cantidad) {
    exp -= cantidad;

    while (exp < 0 && nivel > 1) {
      nivel--;
      expNecesaria = _calcularNuevaExperienciaNecesaria();
      exp += expNecesaria;
    }

    if (exp < 0) exp = 0;
  }

  int _calcularNuevaExperienciaNecesaria() {
    return (expNecesaria * 1.2).round();
  }

  Map<String, dynamic> toMap() {
    return {
      "nombre": nombre,
      "nivel": nivel,
      "exp": exp,
      "expNecesaria": expNecesaria,
    };
  }

  factory StatModel.fromMap(Map<String, dynamic> map) {
    return StatModel(
      nombre: map["nombre"],
      nivel: map["nivel"] ?? 1,
      exp: map["exp"] ?? 0,
      expNecesaria: map["expNecesaria"] ?? 100,
    );
  }
}
