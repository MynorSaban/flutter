import 'package:flutter/material.dart';
import 'package:plantilla_movil_mintrab/core/network/auth_service.dart';
import 'package:plantilla_movil_mintrab/core/storage/secure_storage.dart';
import 'package:plantilla_movil_mintrab/presentation/layout/main_layout.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _auth = AuthService();

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return MainLayout(
      title: 'Inicio',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logout,
        icon: const Icon(Icons.logout),
        label: const Text('Cerrar sesion'),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: SecureStorage.instance.getUserInfo(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final info = snapshot.data;
          if (info == null) {
            return const Center(child: Text('No hay datos de sesion'));
          }

          final nombre = info['name'] as String? ?? '';
          final email = info['email'] as String? ?? '';
          final username = info['preferred_username'] as String? ?? '';
          final roles = (info['resource_access']?['pam-client']?['roles']
                  as List<dynamic>?)
              ?.join(', ') ?? '';

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: colors.primaryContainer,
                child: Text(
                  nombre.isNotEmpty ? nombre[0] : '?',
                  style: TextStyle(
                    fontSize: 28,
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _InfoRow(label: 'Nombre', value: nombre),
              _InfoRow(label: 'Usuario', value: username),
              _InfoRow(label: 'Correo', value: email),
              _InfoRow(label: 'Rol', value: roles),
              const SizedBox(height: 24),
           
            ],
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
