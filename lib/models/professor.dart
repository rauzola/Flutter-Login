class Professor {
  final int? id;
  final String name;
  final String email;
  final String area;

  Professor({
    this.id,
    required this.name,
    required this.email,
    required this.area,
  });

  factory Professor.fromMap(Map<String, dynamic> map) {
    return Professor(
      id: map['id'] as int?,
      name: map['name'] as String,
      email: map['email'] as String,
      area: map['area'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'area': area,
    };
  }
}
