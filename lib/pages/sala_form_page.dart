import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/sala.dart';

class SalaFormPage extends StatefulWidget {
  final Sala? sala;

  const SalaFormPage({super.key, this.sala});

  @override
  State<SalaFormPage> createState() => _SalaFormPageState();
}

class _SalaFormPageState extends State<SalaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final SupabaseClient supabase = Supabase.instance.client;

  late TextEditingController nomeController;
  late TextEditingController capacidadeController;
  late TextEditingController tipoController;

  @override
  void initState() {
    super.initState();
    nomeController = TextEditingController(text: widget.sala?.nome ?? '');
    capacidadeController = TextEditingController(
      text: widget.sala?.capacidade?.toString() ?? '',
    );
    tipoController = TextEditingController(text: widget.sala?.tipo ?? '');
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    final sala = Sala(
      id: widget.sala?.id,
      nome: nomeController.text.trim(),
      capacidade: int.tryParse(capacidadeController.text.trim()),
      tipo: tipoController.text.trim(),
    );

    try {
      if (sala.id != null) {
        await supabase
            .from('sala')
            .update(sala.toMap())
            .eq('id', sala.id!);
      } else {
        await supabase.from('sala').insert(sala.toMap());
      }
      if (mounted) Navigator.pop(context, true);
    } on PostgrestException catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Erro: ${e.message}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.sala != null ? 'Editar Sala' : 'Nova Sala')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) =>
                    value!.isEmpty ? 'Informe o nome da sala' : null,
              ),
              TextFormField(
                controller: capacidadeController,
                decoration: const InputDecoration(labelText: 'Capacidade'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: tipoController,
                decoration: const InputDecoration(labelText: 'Tipo'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _salvar,
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
