// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telalogin/pages/professor_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  // Telas do BottomNavigationBar
  final List<Widget> _pages = const [
    _Dashboard(), // você cria embaixo
    _Perfil(), // idem
    _Configuracoes(), // idem
  ];

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _signOut,
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config.'),
        ],
      ),
      drawer: Drawer(
        // opcional, se quiser um menu lateral
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
              accountName: Text(user?.email ?? ''),
              accountEmail: Text(user?.id ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Sobre'),
              onTap: () {
                /* navegue para uma tela de Sobre */
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Professores'),
              onTap: () {
                Navigator.pop(context); // fecha o drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfessorListPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/* ====== Páginas internas (placeholders) ====== */

class _Dashboard extends StatelessWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Bem‑vindo ao dashboard!'));
  }
}

class _Perfil extends StatelessWidget {
  const _Perfil();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Dados do usuário'));
  }
}

class _Configuracoes extends StatelessWidget {
  const _Configuracoes();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Configurações do app'));
  }
}
