import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: const Center(
        child: Text(
          'Tela de Cadastro - implemente aqui',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
