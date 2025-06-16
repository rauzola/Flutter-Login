import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/professor.dart';

class ProfessorFormPage extends StatefulWidget {
  final Professor? professor;

  const ProfessorFormPage({Key? key, this.professor}) : super(key: key);

  @override
  _ProfessorFormPageState createState() => _ProfessorFormPageState();
}

class _ProfessorFormPageState extends State<ProfessorFormPage> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseClient supabase = Supabase.instance.client;

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _areaController;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.professor?.name ?? '');
    _emailController = TextEditingController(
      text: widget.professor?.email ?? '',
    );
    _areaController = TextEditingController(text: widget.professor?.area ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final professor = Professor(
      id: widget.professor?.id,
      name: _nameController.text,
      email: _emailController.text,
      area: _areaController.text,
    );

    if (professor.id == null) {
      // Criar
      final response = await supabase
          .from('professor')
          .insert(professor.toMap());
      if (response.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: ${response.error!.message}')),
        );
      } else {
        Navigator.pop(context, true);
      }
    } else {
      // Atualizar
      final response = await supabase
          .from('professor')
          .update(professor.toMap())
          .eq('id', professor.id!);
      if (response.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar: ${response.error!.message}'),
          ),
        );
      } else {
        Navigator.pop(context, true);
      }
    }

    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.professor != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Professor' : 'Novo Professor'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Informe o email' : null,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _areaController,
                decoration: const InputDecoration(labelText: 'Área'),
                validator:
                    (v) => v == null || v.isEmpty ? 'Informe a área' : null,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving ? null : _save,
                child:
                    _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(isEditing ? 'Atualizar' : 'Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
