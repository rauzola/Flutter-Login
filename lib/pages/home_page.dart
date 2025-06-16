// lib/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:telalogin/pages/ensalamento_list_page.dart';
import 'package:telalogin/pages/professor_list_page.dart';
import 'package:telalogin/pages/sala_list_page.dart';
import 'package:telalogin/pages/turma_list_page.dart';
import 'package:telalogin/pages/calendar_dashboard.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final GlobalKey<CalendarDashboardState> calendarKey =
      GlobalKey<CalendarDashboardState>();

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [CalendarDashboard(key: calendarKey), const _Configuracoes()];
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ensala +'),
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
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Ensalamento'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Config.'),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              currentAccountPicture: CircleAvatar(
                backgroundImage: NetworkImage(
                  'https://avatars.githubusercontent.com/u/57502280?v=4',
                ),
              ),
              accountName: Text(user?.email ?? ''),
              accountEmail: Text(user?.id ?? ''),
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('Professores'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfessorListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.meeting_room),
              title: const Text('Salas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SalaListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.class_),
              title: const Text('Turmas'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TurmaListPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Ensalamento'),
              onTap: () async {
                Navigator.pop(context);
                final changed = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const EnsalamentoListPage(),
                  ),
                );
                if (changed == true) {
                  calendarKey.currentState?.loadEnsalamentos();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Configuracoes extends StatelessWidget {
  const _Configuracoes();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Configurações do app'));
  }
}

class Configuracoes extends StatelessWidget {
  const Configuracoes();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Configurações do app'));
  }
}
