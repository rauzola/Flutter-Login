class Sala {
  final int? id;
  final String nome;
  final int? capacidade;
  final String? tipo;

  Sala({
    this.id,
    required this.nome,
    this.capacidade,
    this.tipo,
  });

  factory Sala.fromMap(Map<String, dynamic> map) {
    return Sala(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      capacidade: map['capacidade'] as int?,
      tipo: map['tipo'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'capacidade': capacidade,
      'tipo': tipo,
    };
  }
}
