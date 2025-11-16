import 'package:flutter/material.dart';
import 'package:neurohabits_app/paginas/pagina_inicioSesion.dart';
import 'package:neurohabits_app/paginas/pagina_principal.dart';
import 'package:flutter/services.dart';
import 'package:neurohabits_app/paginas/pagina_perfil.dart';
import 'package:neurohabits_app/paginas/pagina_crearhabitos.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 🔹 Forzar modo oscuro globalmente
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroHabits',
      themeMode: ThemeMode.dark,

      home: const InicioSesion(),
      routes: {
        '/Principal': (context) => const PantallaInicio(title: 'Principal'),
        '/Perfil': (context) => const Perfil(),
        '/CrearHabitos': (context) => CrearHabito(onSaved: () {}),
      },
    );
  }
}
