import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_colors.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: const Icon(Icons.person, size: 50, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${user?.name ?? "User"}!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Email: ${user?.email ?? "N/A"}',
              style: const TextStyle(fontSize: 16, color: AppColors.muted),
            ),
            const SizedBox(height: 5),
            Text(
              'Role: ${user?.role ?? "learner"}',
              style: const TextStyle(fontSize: 16, color: AppColors.muted),
            ),
            const SizedBox(height: 40),
            const Text(
              'You have successfully logged in!',
              style: TextStyle(fontSize: 18, color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
