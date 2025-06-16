// models/turma.dart
class Turma {
  final int? id;
  final String nome;
  final String? curso;
  final String? periodo;

  Turma({
    this.id,
    required this.nome,
    this.curso,
    this.periodo,
  });

  factory Turma.fromMap(Map<String, dynamic> map) => Turma(
        id: map['id'],
        nome: map['nome'],
        curso: map['curso'],
        periodo: map['periodo'],
      );

  Map<String, dynamic> toMap() => {
        'nome': nome,
        'curso': curso,
        'periodo': periodo,
      };
}