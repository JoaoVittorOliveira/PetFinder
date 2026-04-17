// lib/models/pet.dart

class Pet {
  final String id;
  final String userId; // ID do usuário que cadastrou o pet
  final String name;
  final String type; // 'cao', 'gato' ou 'outro'
  final String location;
  final String description;
  final String contact;
  final String dummyImageUrl;
  final DateTime datePosted;
  final bool isFound;

  Pet({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.location,
    required this.description,
    required this.contact,
    required this.dummyImageUrl,
    required this.datePosted,
    this.isFound = false,
  });

  Pet copyWith({bool? isFound}) {
    return Pet(
      id: id,
      userId: userId,
      name: name,
      type: type,
      location: location,
      description: description,
      contact: contact,
      dummyImageUrl: dummyImageUrl,
      datePosted: datePosted,
      isFound: isFound ?? this.isFound,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'location': location,
      'description': description,
      'contact': contact,
      'dummyImageUrl': dummyImageUrl,
      // CONVERTE DATETIME PARA STRING ISO8601
      'datePosted': datePosted.toIso8601String(),
      'isFound': isFound ? 1 : 0,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    return Pet(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '2',
      name: map['name'] ?? '',
      type: map['type'] ?? 'outro',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      contact: map['contact'] ?? '',
      dummyImageUrl: map['dummyImageUrl'] ?? '',
      // CONVERTE STRING DE VOLTA PARA DATETIME
      datePosted: DateTime.parse(
        map['datePosted'] ?? DateTime.now().toIso8601String(),
      ),
      isFound: map['isFound'] == 1,
    );
  }
}
