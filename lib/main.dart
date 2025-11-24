import 'package:flutter/material.dart';
import 'package:neurohabits_app/paginas/pagina_inicioSesion.dart';
import 'package:neurohabits_app/paginas/pagina_personaje.dart';
import 'package:neurohabits_app/paginas/pagina_principal.dart';
import 'package:flutter/services.dart';
import 'package:neurohabits_app/paginas/pagina_perfil.dart';
import 'package:neurohabits_app/paginas/pagina_crearhabitos.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:neurohabits_app/paginas/pagina_crearpersonaje.dart';
import 'package:neurohabits_app/paginas/pagina_checkPersonaje.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      debugShowCheckedModeBanner: false,
      // HOME según si hay usuario o no
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Cargando estado inicial
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // No hay usuario → ir a login
          if (!snapshot.hasData) {
            return const InicioSesion();
          }

          // Hay usuario → comprobar si tiene personaje
          return const CheckPersonajePage();
        },
      ),

      routes: {
        '/login': (context) => const InicioSesion(),
        '/CheckPersonaje': (context) => const CheckPersonajePage(),
        '/Principal': (context) => const PantallaInicio(title: 'Principal'),
        '/Perfil': (context) => const Perfil(),
        '/CrearHabitos': (context) => CrearHabito(onSaved: () {}),
        '/CrearPersonaje': (context) => const CrearPersonajePage(),
        '/PersonajeCompleto': (context) => const PaginaPersonaje(),
      },
    );
  }
}

// title: 'NeuroHabits',
//       themeMode: ThemeMode.dark,

//       home: const InicioSesion(),
