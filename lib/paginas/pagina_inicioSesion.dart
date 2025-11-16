import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  State<InicioSesion> createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesion>
    with SingleTickerProviderStateMixin {
  bool mostrarLogin = false;
  bool mostrarRegistro = false;
  bool mostrarRegistro2 = false;

  void _login() {
    Future.microtask(() {
      Navigator.pushReplacementNamed(context, '/Principal');
    });
  }

  void _loginGoogle() {
    setState(() {
      mostrarLogin = false;
    });
  }

  void _loginApple() {
    setState(() {
      mostrarLogin = false;
    });
  }

  void _loginIniciosesion() {
    setState(() {
      mostrarLogin = true;
      mostrarRegistro2 = true;
      mostrarRegistro = false;
    });
  }

  void _loginRegistro() {
    setState(() {
      mostrarRegistro = true;
      mostrarRegistro2 = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          // ⚡ Barra de estado negra con iconos blancos
          AnnotatedRegion<SystemUiOverlayStyle>(
            value: const SystemUiOverlayStyle(
              statusBarColor: Colors.black, // fondo negro sólido
              statusBarIconBrightness:
                  Brightness.light, // iconos blancos Android
              statusBarBrightness: Brightness.dark, // iconos blancos iOS
            ),
            child: Container(
              height: MediaQuery.of(context).padding.top,
              color: Colors.black, // mismo color que la barra
            ),
          ),

          // ⚡ Resto de la UI
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: Form(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 🔹 Texto animado moderno "NeuroHabits"
                    ShaderMask(
                      shaderCallback: (Rect bounds) {
                        return const LinearGradient(
                          colors: [
                            Color(0xFF4A148C),
                            Color(0xFF7B1FA2),
                            Color(0xFF9C27B0),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds);
                      },
                      child: Text(
                        'NeuroHabits',
                        style: GoogleFonts.poppins(
                          fontSize: 46,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.6,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // 🔹 Campos de login (ocultos temporalmente)
                    Visibility(
                      visible: mostrarLogin,
                      child: Column(
                        children: [
                          const SizedBox(height: 30),
                          TextFormField(
                            style: const TextStyle(
                              color: Color.fromARGB(255, 131, 32, 148),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Correo ',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value!.isEmpty ? 'Introduce el Correo' : null,
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            obscureText: true,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 131, 32, 148),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) => value!.isEmpty
                                ? 'Introduce la contraseña'
                                : null,
                          ),

                          Visibility(
                            visible: mostrarRegistro,
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                TextFormField(
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 131, 32, 148),
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Nombre',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) => value!.isEmpty
                                      ? 'Introduce Nombre'
                                      : null,
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 131, 32, 148),
                                  ),
                                  decoration: const InputDecoration(
                                    labelText: 'Apellidos',
                                    border: OutlineInputBorder(),
                                  ),
                                  validator: (value) => value!.isEmpty
                                      ? 'Introduce los Apellidos'
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 15,
                              ),
                              side: const BorderSide(
                                color: Color.fromARGB(255, 68, 66, 66),
                                width: 1.5,
                              ),
                            ),
                            child: const Text(
                              'Iniciar Sesión',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Visibility(
                                visible: mostrarRegistro2,
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: '¿No tienes cuenta? ',
                                      ),
                                      TextSpan(
                                        text: 'Regístrate aquí',
                                        style: const TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            131,
                                            32,
                                            148,
                                          ),
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            _loginRegistro();
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: mostrarRegistro,
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: '¿Ya tienes cuenta? ',
                                      ),
                                      TextSpan(
                                        text: 'Inicia sesión aquí',
                                        style: const TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            131,
                                            32,
                                            148,
                                          ),
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            _loginIniciosesion();
                                          },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _botonInferior('Google', _loginGoogle),
                        const SizedBox(height: 10),
                        _botonInferior('Apple', _loginApple),
                        const SizedBox(height: 10),
                        _botonInferior('Iniciar Sesión', _loginIniciosesion),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _botonInferior(String texto, VoidCallback onPressed) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.black,
          side: const BorderSide(
            color: Color.fromARGB(255, 68, 66, 66),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          texto.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
      ),
    );
  }
}
