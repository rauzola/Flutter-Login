class Ensalamento {
  final int? id;
  final DateTime data;
  final String horario;
  final int? turmaId;
  final int? salaId;
  final int? professorId;
  final DateTime? createdAt;

  Ensalamento({
    this.id,
    required this.data,
    required this.horario,
    this.turmaId,
    this.salaId,
    this.professorId,
    this.createdAt,
  });

  factory Ensalamento.fromMap(Map<String, dynamic> map) {
    return Ensalamento(
      id: map['id'] as int?,
      data: DateTime.parse(map['data'] as String),
      horario: map['horario'] as String,
      turmaId: map['turma_id'] as int?,
      salaId: map['sala_id'] as int?,
      professorId: map['professor_id'] as int?,
      createdAt: map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'data': data.toIso8601String().substring(0,10), // só a data yyyy-MM-dd
      'horario': horario,
      'turma_id': turmaId,
      'sala_id': salaId,
      'professor_id': professorId,
    };
  }
}
