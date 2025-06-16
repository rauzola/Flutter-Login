import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sala.dart';
import 'sala_form_page.dart';

class SalaListPage extends StatefulWidget {
  const SalaListPage({super.key});

  @override
  State<SalaListPage> createState() => _SalaListPageState();
}

class _SalaListPageState extends State<SalaListPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Sala> _salas = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchSalas();
  }

  Future<void> _fetchSalas() async {
    setState(() => _loading = true);
    try {
      final List<dynamic> rows = await supabase
          .from('sala')
          .select()
          .order('id');
      _salas = rows.map((e) => Sala.fromMap(e)).toList();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao buscar salas')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteSala(int id) async {
    try {
      await supabase.from('sala').delete().eq('id', id!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sala removida')),
      );
      await _fetchSalas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover sala')),
      );
    }
  }

  void _navigateToForm([Sala? sala]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SalaFormPage(sala: sala)),
    );
    if (result == true) await _fetchSalas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Salas')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _salas.length,
              itemBuilder: (context, index) {
                final sala = _salas[index];
                return ListTile(
                  title: Text(sala.nome),
                  subtitle: Text(
                    'Capacidade: ${sala.capacidade ?? '-'} | Tipo: ${sala.tipo ?? '-'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _navigateToForm(sala),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Confirmar exclusão'),
                            content: Text('Excluir ${sala.nome}?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Cancelar'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(ctx);
                                  _deleteSala(sala.id!);
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
        tooltip: 'Adicionar sala',
      ),
    );
  }
}
