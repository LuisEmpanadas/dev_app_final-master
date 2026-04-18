import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _isRegisterMode = false;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();
    _requestStoragePermission();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      if (_isRegisterMode) {
        await _authService.register(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      } else {
        await _authService.login(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = _mapFirebaseError(e.code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Error inesperado. Intenta de nuevo.'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _requestStoragePermission() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;

    final status = await Permission.storage.status;
    if (status.isGranted) return;

    final result = await Permission.storage.request();
    if (result.isDenied || result.isPermanentlyDenied) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('Permiso de almacenamiento'),
            content: const Text(
              'La aplicación necesita acceso al almacenamiento del dispositivo para funcionar correctamente. Por favor, otorga el permiso.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cerrar'),
              ),
              if (result.isPermanentlyDenied)
                TextButton(
                  onPressed: () => openAppSettings(),
                  child: const Text('Abrir ajustes'),
                ),
            ],
          );
        },
      );
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No existe una cuenta con ese correo.';
      case 'wrong-password':
        return 'Contraseña incorrecta.';
      case 'invalid-credential':
        return 'Correo o contraseña inválidos.';
      case 'email-already-in-use':
        return 'Este correo ya está registrado.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'invalid-email':
        return 'El correo no tiene un formato válido.';
      case 'too-many-requests':
        return 'Demasiados intentos. Espera un momento.';
      default:
        return 'Error: $code';
    }
  }

  void _toggleMode() {
    setState(() => _isRegisterMode = !_isRegisterMode);
    _animController.reset();
    _animController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [scheme.primary, scheme.primaryContainer],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Card(
                      elevation: 12,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icono
                              Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  color: scheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.lock_outline_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _isRegisterMode ? 'Crear cuenta' : 'Bienvenido',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                _isRegisterMode
                                    ? 'Regístrate para continuar'
                                    : 'Inicia sesión para continuar',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey),
                              ),
                              const SizedBox(height: 32),

                              // Email
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Correo electrónico',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Ingresa tu correo';
                                  }
                                  if (!val.contains('@')) {
                                    return 'Correo no válido';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // Contraseña
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                    onPressed:
                                        () => setState(
                                          () =>
                                              _obscurePassword =
                                                  !_obscurePassword,
                                        ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Ingresa tu contraseña';
                                  }
                                  if (_isRegisterMode && val.length < 6) {
                                    return 'Mínimo 6 caracteres';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 28),

                              // Botón principal
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _submit,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: scheme.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child:
                                      _isLoading
                                          ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              color: Colors.white,
                                            ),
                                          )
                                          : Text(
                                            _isRegisterMode
                                                ? 'Registrarme'
                                                : 'Iniciar sesión',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Cambiar modo
                              TextButton(
                                onPressed: _toggleMode,
                                child: Text(
                                  _isRegisterMode
                                      ? '¿Ya tienes cuenta? Inicia sesión'
                                      : '¿No tienes cuenta? Regístrate',
                                  style: TextStyle(color: scheme.primary),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
