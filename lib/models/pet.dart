// lib/models/pet.dart

class Pet {
  final int id;
  // final String userId; // ID do usuário que cadastrou o pet
  final String name;
  final String type; // 'cao', 'gato' ou 'outro'
  final String location;
  final String description;
  final String contact;
  final String dummyImage;
  final DateTime createdAt;
  final bool isFound;

  Pet({
    required this.id,
    // required this.userId,
    required this.name,
    required this.type,
    required this.location,
    required this.description,
    required this.contact,
    required this.dummyImage,
    required this.createdAt,
    this.isFound = false,
  });

  Pet copyWith({bool? isFound}) {
    return Pet(
      id: id,
      // userId: userId,
      name: name,
      type: type,
      location: location,
      description: description,
      contact: contact,
      dummyImage: dummyImage,
      createdAt: createdAt,
      isFound: isFound ?? this.isFound,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'location': location,
      'description': description,
      'contact': contact,
      'dummyImage': dummyImage,
      'created_at': createdAt.toIso8601String(),
      'isFound': isFound,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] ?? 0,
      // userId: map['userId'] ?? '2',
      name: map['name'] ?? '',
      type: map['type'] ?? 'outro',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      contact: map['contact'] ?? '',
      dummyImage: map['dummyImage'] ?? '',
      // CONVERTE STRING DE VOLTA PARA DATETIME
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      isFound: map['isFound'] == 1,
    );
  }
}
