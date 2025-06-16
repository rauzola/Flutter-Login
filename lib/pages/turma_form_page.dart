// pages/turma_form_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/turma.dart';

class TurmaFormPage extends StatefulWidget {
  final Turma? turma;

  const TurmaFormPage({super.key, this.turma});

  @override
  State<TurmaFormPage> createState() => _TurmaFormPageState();
}

class _TurmaFormPageState extends State<TurmaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseClient supabase = Supabase.instance.client;

  late TextEditingController nomeController;
  late TextEditingController cursoController;
  late TextEditingController periodoController;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.turma?.nome ?? '');
    cursoController = TextEditingController(text: widget.turma?.curso ?? '');
    periodoController = TextEditingController(text: widget.turma?.periodo ?? '');
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final turma = Turma(
      id: widget.turma?.id,
      nome: nomeController.text.trim(),
      curso: cursoController.text.trim(),
      periodo: periodoController.text.trim(),
    );

    try {
      if (turma.id != null) {
        await supabase.from('turma').update(turma.toMap()).eq('id', turma.id!);
      } else {
        await supabase.from('turma').insert(turma.toMap());
      }
      if (mounted) Navigator.pop(context, true);
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.turma != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Editar Turma' : 'Nova Turma')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: cursoController,
                decoration: const InputDecoration(labelText: 'Curso'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: periodoController,
                decoration: const InputDecoration(labelText: 'Período'),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _salvar,
                child: Text(isEditing ? 'Atualizar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}