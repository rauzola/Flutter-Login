import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ensalamento.dart';
import 'ensalamento_form_page.dart';

class EnsalamentoListPage extends StatefulWidget {
  const EnsalamentoListPage({Key? key}) : super(key: key);

  @override
  State<EnsalamentoListPage> createState() => _EnsalamentoListPageState();
}

class _EnsalamentoListPageState extends State<EnsalamentoListPage> {
  final supabase = Supabase.instance.client;
  late Future<List<Ensalamento>> _futureEnsalamentos;

  @override
  void initState() {
    super.initState();
    _futureEnsalamentos = _fetchEnsalamentos();
  }

  Future<List<Ensalamento>> _fetchEnsalamentos() async {
    final response = await supabase
        .from('ensalamento')
        .select('id, data, horario, turma_id, sala_id, professor_id')
        .order('data', ascending: true)
        .order('horario', ascending: true);

    final dataList = response as List<dynamic>;

    return dataList
        .map((e) => Ensalamento.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureEnsalamentos = _fetchEnsalamentos();
    });
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar exclusão'),
            content: const Text('Deseja realmente excluir este ensalamento?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Excluir'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      final response = await supabase.from('ensalamento').delete().eq('id', id);

      if (response.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao excluir: ${response.error!.message}'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ensalamento excluído com sucesso')),
        );
        _refresh();
      }
    }
  }

  void _openForm([Ensalamento? ensalamento]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EnsalamentoFormPage(ensalamento: ensalamento),
      ),
    );

    if (result == true) {
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ensalamentos')),
      body: FutureBuilder<List<Ensalamento>>(
        future: _futureEnsalamentos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum ensalamento encontrado.'));
          }

          final ensalamentos = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              itemCount: ensalamentos.length,
              itemBuilder: (_, index) {
                final ensalamento = ensalamentos[index];
                return ListTile(
                  title: Text(
                    '${ensalamento.data.toLocal().toString().split(" ")[0]} - ${ensalamento.horario}',
                  ),
                  subtitle: Text(
                    'Turma: ${ensalamento.turmaId ?? '-'}  | Sala: ${ensalamento.salaId ?? '-'}  | Prof: ${ensalamento.professorId ?? '-'}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _openForm(ensalamento),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _delete(ensalamento.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
