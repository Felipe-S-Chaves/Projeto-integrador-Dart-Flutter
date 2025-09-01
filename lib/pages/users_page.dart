import 'package:flutter/material.dart';

class UsersPage extends StatelessWidget {
  static const route = '/users';
  const UsersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuários')),
      body: const Center(child: Text('Lista de usuários em breve...')),
    );
  }
}
