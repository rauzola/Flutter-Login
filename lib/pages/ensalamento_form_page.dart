import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ensalamento.dart';

class EnsalamentoFormPage extends StatefulWidget {
  final Ensalamento? ensalamento;

  const EnsalamentoFormPage({Key? key, this.ensalamento}) : super(key: key);

  @override
  State<EnsalamentoFormPage> createState() => _EnsalamentoFormPageState();
}

class _EnsalamentoFormPageState extends State<EnsalamentoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final supabase = Supabase.instance.client;

  late DateTime _data;
  late TextEditingController _horarioController;
  int? _turmaId;
  int? _salaId;
  int? _professorId;

  List<Map<String, dynamic>> _turmas = [];
  List<Map<String, dynamic>> _salas = [];
  List<Map<String, dynamic>> _professores = [];

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _data = widget.ensalamento?.data ?? DateTime.now();
    _horarioController = TextEditingController(
      text: widget.ensalamento?.horario ?? '',
    );

    _turmaId = widget.ensalamento?.turmaId;
    _salaId = widget.ensalamento?.salaId;
    _professorId = widget.ensalamento?.professorId;

    _loadForeignData();
  }
Future<void> _loadForeignData() async {
  try {
    final turmas = await supabase.from('turma').select('id, nome'); // 'nome' ou 'name'
    final salas = await supabase.from('sala').select('id, nome');
    final professores = await supabase.from('professor').select('id, name');

    setState(() {
      _turmas = List<Map<String, dynamic>>.from(turmas);
      _salas = List<Map<String, dynamic>>.from(salas);
      _professores = List<Map<String, dynamic>>.from(professores);
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro ao carregar dados: $e')),
    );
  }
}

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _data) {
      setState(() {
        _data = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_turmaId == null || _salaId == null || _professorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione turma, sala e professor')),
      );
      return;
    }

    setState(() => _saving = true);

    final ensalamento = Ensalamento(
      id: widget.ensalamento?.id,
      data: _data,
      horario: _horarioController.text.trim(),
      turmaId: _turmaId!, // força non-null
      salaId: _salaId!,
      professorId: _professorId!,
    );

    try {
      if (ensalamento.id == null) {
        final response = await supabase
            .from('ensalamento')
            .insert(ensalamento.toMap());
        // response é a lista de registros inseridos
        Navigator.pop(context, true);
      } else {
        final response = await supabase
            .from('ensalamento')
            .update(ensalamento.toMap())
            .eq('id', ensalamento.id!);
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.ensalamento != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Ensalamento' : 'Novo Ensalamento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child:
            _turmas.isEmpty || _salas.isEmpty || _professores.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      ListTile(
                        title: const Text('Data'),
                        subtitle: Text('${_data.toLocal()}'.split(' ')[0]),
                        trailing: IconButton(
                          icon: const Icon(Icons.calendar_today),
                          onPressed: _selectDate,
                        ),
                      ),
                      TextFormField(
                        controller: _horarioController,
                        decoration: const InputDecoration(
                          labelText: 'Horário (ex: 19:00)',
                        ),
                        validator:
                            (v) =>
                                v == null || v.isEmpty
                                    ? 'Informe o horário'
                                    : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _turmaId,
                        decoration: const InputDecoration(labelText: 'Turma'),
                        items:
                            _turmas.map((turma) {
                              return DropdownMenuItem(
                                value: turma['id'] as int,
                                child: Text(turma['nome'] ?? ''),
                              );
                            }).toList(),
                        onChanged: (v) => setState(() => _turmaId = v),
                        validator:
                            (v) => v == null ? 'Selecione a turma' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _salaId,
                        decoration: const InputDecoration(labelText: 'Sala'),
                        items:
                            _salas.map((sala) {
                              return DropdownMenuItem(
                                value: sala['id'] as int,
                                child: Text(sala['nome'] ?? ''),
                              );
                            }).toList(),
                        onChanged: (v) => setState(() => _salaId = v),
                        validator: (v) => v == null ? 'Selecione a sala' : null,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _professorId,
                        decoration: const InputDecoration(
                          labelText: 'Professor',
                        ),
                        items:
                            _professores.map((prof) {
                              return DropdownMenuItem(
                                value: prof['id'] as int,
                                child: Text(prof['name'] ?? ''),
                              );
                            }).toList(),
                        onChanged: (v) => setState(() => _professorId = v),
                        validator:
                            (v) => v == null ? 'Selecione o professor' : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child:
                            _saving
                                ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                                : Text(isEditing ? 'Atualizar' : 'Salvar'),
                      ),
                    ],
                  ),
                ),
      ),
    );
  }
}
