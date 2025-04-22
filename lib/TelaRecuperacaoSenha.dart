import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar Senha')),
      body: const Center(
        child: Text(
          'Tela de Recuperação de Senha - implemente aqui',
          style: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
