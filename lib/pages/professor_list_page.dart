import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/professor.dart';
import 'professor_form_page.dart';

class ProfessorListPage extends StatefulWidget {
  const ProfessorListPage({Key? key}) : super(key: key);

  @override
  _ProfessorListPageState createState() => _ProfessorListPageState();
}

class _ProfessorListPageState extends State<ProfessorListPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  List<Professor> _professores = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfessores();
  }

  Future<void> _fetchProfessores() async {
    setState(() => _loading = true);
    try {
      final List<dynamic> rows = await supabase
          .from('professor')
          .select()
          .order('id'); // já devolve List

      _professores =
          rows
              .map((e) => Professor.fromMap(e as Map<String, dynamic>))
              .toList();
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar professores: ${e.message}')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _deleteProfessor(int id) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const Center(child: CircularProgressIndicator()),
  );

  try {
    await supabase.from('professor').delete().eq('id', id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Professor removido')),
      );
      await _fetchProfessores();
    }
  } on PostgrestException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao remover: ${e.message}')),
    );
  } finally {
    if (mounted) Navigator.of(context).pop(); // fecha o loading
  }
}
  void _navigateToForm([Professor? professor]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfessorFormPage(professor: professor),
      ),
    );
    if (result == true) {
      await _fetchProfessores(); // importante ser await
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Professores')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: _professores.length,
                itemBuilder: (context, index) {
                  final prof = _professores[index];
                  return ListTile(
                    title: Text(prof.name),
                    subtitle: Text('${prof.email} - ${prof.area}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _navigateToForm(prof),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed:
                              () => showDialog(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      title: const Text('Confirmar exclusão'),
                                      content: Text('Excluir ${prof.name}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cancelar'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            _deleteProfessor(prof.id!);
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
        tooltip: 'Adicionar professor',
      ),
    );
  }
}
