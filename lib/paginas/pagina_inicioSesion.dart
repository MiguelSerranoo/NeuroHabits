import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:neurohabits_app/conexiones/servicio_auth.dart';

class InicioSesion extends StatefulWidget {
  const InicioSesion({super.key});

  @override
  State<InicioSesion> createState() => _InicioSesionState();
}

class _InicioSesionState extends State<InicioSesion>
    with SingleTickerProviderStateMixin {
  bool mostrarLogin = false;
  bool mostrarRegistro = false;
  bool mostrarLogin2 = false;
  bool _cargando = false;
  bool _obscurePassword = true;
  bool _obscurePasswordRepeat = true;

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passCtrl = TextEditingController();
  final TextEditingController _passRepeatCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(mensaje, style: const TextStyle(fontSize: 15)),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _mostrarExito(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(mensaje, style: const TextStyle(fontSize: 15)),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _cargando = true);

    try {
      final user = await AuthService.loginEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      if (user != null) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/CheckPersonaje');
        }
      }
    } catch (e) {
      String mensajeError = 'Error al iniciar sesión';

      if (e.toString().contains('user-not-found')) {
        mensajeError = 'No existe una cuenta con este correo';
      } else if (e.toString().contains('wrong-password')) {
        mensajeError = 'Contraseña incorrecta';
      } else if (e.toString().contains('invalid-email')) {
        mensajeError = 'Correo electrónico inválido';
      } else if (e.toString().contains('user-disabled')) {
        mensajeError = 'Esta cuenta ha sido deshabilitada';
      } else if (e.toString().contains('too-many-requests')) {
        mensajeError = 'Demasiados intentos. Intenta más tarde';
      } else if (e.toString().contains('network-request-failed')) {
        mensajeError = 'Sin conexión a internet';
      } else if (e.toString().contains('invalid-credential')) {
        mensajeError = 'Correo o contraseña incorrectos';
      }

      _mostrarError(mensajeError);
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _registro() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validar que las contraseñas coincidan
    if (_passCtrl.text.trim() != _passRepeatCtrl.text.trim()) {
      _mostrarError('Las contraseñas no coinciden');
      return;
    }

    setState(() => _cargando = true);

    try {
      final user = await AuthService.registrarEmail(
        _emailCtrl.text.trim(),
        _passCtrl.text.trim(),
      );

      if (user != null) {
        _mostrarExito('¡Cuenta creada con éxito!');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/CrearPersonaje');
        }
      }
    } catch (e) {
      String mensajeError = 'Error al crear la cuenta';

      if (e.toString().contains('email-already-in-use')) {
        mensajeError = 'Ya existe una cuenta con este correo';
      } else if (e.toString().contains('weak-password')) {
        mensajeError = 'La contraseña es demasiado débil (mínimo 6 caracteres)';
      } else if (e.toString().contains('invalid-email')) {
        mensajeError = 'Correo electrónico inválido';
      } else if (e.toString().contains('network-request-failed')) {
        mensajeError = 'Sin conexión a internet';
      }

      _mostrarError(mensajeError);
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _loginGoogle() async {
    setState(() {
      mostrarLogin = false;
      _cargando = true;
    });

    try {
      final user = await AuthService.loginConGoogle();
      if (user != null) {
        _mostrarExito('¡Bienvenido!');
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/CheckPersonaje');
        }
      } else {
        _mostrarError('Inicio de sesión cancelado');
      }
    } catch (e) {
      String mensajeError = 'Error al iniciar sesión con Google';

      if (e.toString().contains('network-request-failed')) {
        mensajeError = 'Sin conexión a internet';
      }

      _mostrarError(mensajeError);
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  void _loginIniciosesion() {
    setState(() {
      mostrarLogin = true;
      mostrarRegistro = false;
      mostrarLogin2 = true;
      _emailCtrl.clear();
      _passCtrl.clear();
      _passRepeatCtrl.clear();
    });
  }

  void _loginRegistro() {
    setState(() {
      mostrarRegistro = true;
      mostrarLogin2 = false;
      _emailCtrl.clear();
      _passCtrl.clear();
      _passRepeatCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Contenido principal
          Column(
            children: [
              AnnotatedRegion<SystemUiOverlayStyle>(
                value: const SystemUiOverlayStyle(
                  statusBarColor: Colors.black,
                  statusBarIconBrightness: Brightness.light,
                  statusBarBrightness: Brightness.dark,
                ),
                child: Container(
                  height: MediaQuery.of(context).padding.top,
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),

                        // Logo/Título
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

                        const SizedBox(height: 40),

                        // Formulario
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: Column(
                            children: [
                              // Email
                              if (mostrarLogin)
                                TextFormField(
                                  controller: _emailCtrl,
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Correo electrónico',
                                    labelStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF9C27B0),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.05),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingresa tu correo';
                                    }
                                    if (!value.contains('@')) {
                                      return 'Ingresa un correo válido';
                                    }
                                    return null;
                                  },
                                ),

                              if (mostrarLogin) const SizedBox(height: 16),

                              // Contraseña
                              if (mostrarLogin)
                                TextFormField(
                                  controller: _passCtrl,
                                  obscureText: _obscurePassword,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Contraseña',
                                    labelStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF9C27B0),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.05),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Ingresa tu contraseña';
                                    }
                                    if (value.length < 6) {
                                      return 'Mínimo 6 caracteres';
                                    }
                                    return null;
                                  },
                                ),

                              if (mostrarRegistro) const SizedBox(height: 16),

                              // Repetir contraseña
                              if (mostrarRegistro)
                                TextFormField(
                                  controller: _passRepeatCtrl,
                                  obscureText: _obscurePasswordRepeat,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  decoration: InputDecoration(
                                    labelText: 'Repetir contraseña',
                                    labelStyle: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePasswordRepeat
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePasswordRepeat =
                                              !_obscurePasswordRepeat;
                                        });
                                      },
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF9C27B0),
                                        width: 2,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(
                                        color: Colors.red,
                                        width: 2,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.05),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Repite tu contraseña';
                                    }
                                    if (value != _passCtrl.text) {
                                      return 'Las contraseñas no coinciden';
                                    }
                                    return null;
                                  },
                                ),

                              const SizedBox(height: 24),

                              // Botón de acción principal
                              if (mostrarLogin2)
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _cargando ? null : _login,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9C27B0),
                                      disabledBackgroundColor:
                                          Colors.grey.shade800,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Iniciar Sesión',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                              if (mostrarRegistro)
                                SizedBox(
                                  width: double.infinity,
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: _cargando ? null : _registro,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF9C27B0),
                                      disabledBackgroundColor:
                                          Colors.grey.shade800,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Registrarse',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 16),

                              // Cambiar entre login y registro
                              if (mostrarLogin2)
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: '¿No tienes cuenta? ',
                                      ),
                                      TextSpan(
                                        text: 'Regístrate aquí',
                                        style: const TextStyle(
                                          color: Color(0xFF9C27B0),
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = _loginRegistro,
                                      ),
                                    ],
                                  ),
                                ),

                              if (mostrarRegistro)
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: '¿Ya tienes cuenta? ',
                                      ),
                                      TextSpan(
                                        text: 'Inicia sesión aquí',
                                        style: const TextStyle(
                                          color: Color(0xFF9C27B0),
                                          fontWeight: FontWeight.bold,
                                          decoration: TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = _loginIniciosesion,
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),

              // Botones inferiores
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _botonInferior('Google', _loginGoogle, Icons.login),
                  const SizedBox(height: 10),
                  _botonInferior(
                    'Iniciar Sesión',
                    _loginIniciosesion,
                    Icons.email,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ],
          ),

          // Indicador de carga
          if (_cargando)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF9C27B0),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Cargando...',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _botonInferior(String texto, VoidCallback onPressed, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      height: 56,
      child: OutlinedButton(
        onPressed: _cargando ? null : onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.black,
          side: BorderSide(
            color: _cargando
                ? Colors.grey.shade800
                : const Color.fromARGB(255, 68, 66, 66),
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: _cargando ? Colors.grey : Colors.white, size: 20),
            const SizedBox(width: 12),
            Text(
              texto.toUpperCase(),
              style: TextStyle(
                color: _cargando ? Colors.grey : Colors.white,
                fontSize: 16,
                fontFamily: 'Roboto',
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _passRepeatCtrl.dispose();
    super.dispose();
  }
}
