// pages/turma_list_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/turma.dart';
import 'turma_form_page.dart';

class TurmaListPage extends StatefulWidget {
  const TurmaListPage({super.key});

  @override
  State<TurmaListPage> createState() => _TurmaListPageState();
}

class _TurmaListPageState extends State<TurmaListPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Turma> _turmas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchTurmas();
  }

  Future<void> _fetchTurmas() async {
    setState(() => _loading = true);
    try {
      final data = await supabase.from('turma').select().order('id');
      _turmas = data.map<Turma>((e) => Turma.fromMap(e)).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao buscar turmas')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteTurma(int id) async {
    try {
      await supabase.from('turma').delete().eq('id', id);
      await _fetchTurmas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao excluir turma')),
      );
    }
  }

  void _navigateToForm([Turma? turma]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TurmaFormPage(turma: turma)),
    );
    if (result == true) await _fetchTurmas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Turmas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _turmas.length,
              itemBuilder: (context, index) {
                final turma = _turmas[index];
                return ListTile(
                  title: Text(turma.nome),
                  subtitle: Text('${turma.curso ?? ''} - ${turma.periodo ?? ''}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _navigateToForm(turma),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Excluir turma'),
                            content: Text('Excluir turma ${turma.nome}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _deleteTurma(turma.id!);
                                },
                                child: const Text('Excluir'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}