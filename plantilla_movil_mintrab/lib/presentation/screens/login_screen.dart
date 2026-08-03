import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:plantilla_movil_mintrab/core/network/auth_service.dart';
import 'package:plantilla_movil_mintrab/presentation/widgets/ui/button.dart';
import 'package:plantilla_movil_mintrab/presentation/widgets/ui/custom_alert_dialog.dart';
import 'package:plantilla_movil_mintrab/presentation/widgets/ui/custom_input_text.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _auth = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _auth.login(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final mensaje =
          e.response?.data?['error_description'] as String? ?? 'Error de conexion';
      CustomAlertDialog.show(
        context: context,
        type: AlertType.danger,
        title: mensaje,
        message: 'Hubo un error al iniciar sesión, verifica tus credenciales o intenta de nuevo mas tarde'
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 72, color: colors.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Iniciar sesión',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 32),
                  CustomInputText(
                    value: _usernameController,
                    label: 'Usuario (DPI)',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Ingresa tu usuario' : null,
                  ),
                  const SizedBox(height: 16),
                  CustomInputText(
                    value: _passwordController,
                    label: 'Contrasena',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Ingresa tu contrasena' : null,
                  ),
                  const SizedBox(height: 24),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Button(
                          label: 'Ingresar',
                          icon: Icons.login,
                          onPressed: _login,
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
