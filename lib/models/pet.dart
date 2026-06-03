// lib/models/pet.dart

class Pet {
  final int id;
  final String userId; // ID do usuário que cadastrou o pet
  final String name;
  final String type; // 'cao', 'gato' ou 'outro'
  final String location;
  final String description;
  final String contact;
  final List<String>
  imageUrls; // URLs das imagens armazenadas no Supabase Storage
  final DateTime createdAt;
  final bool isFound;

  Pet({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.location,
    required this.description,
    required this.contact,
    required this.imageUrls,
    required this.createdAt,
    this.isFound = false,
  });

  Pet copyWith({
    bool? isFound,
    List<String>? imageUrls,
    String? name,
    String? type,
    String? location,
    String? description,
    String? contact,
  }) {
    return Pet(
      id: id,
      userId: userId,
      name: name ?? this.name,
      type: type ?? this.type,
      location: location ?? this.location,
      description: description ?? this.description,
      contact: contact ?? this.contact,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt,
      isFound: isFound ?? this.isFound,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'name': name,
      'type': type,
      'location': location,
      'description': description,
      'contact': contact,
      'image_urls':
          imageUrls, // Supabase converte List para jsonb automaticamente
      'created_at': createdAt.toIso8601String(),
      'isFound': isFound,
    };
  }

  factory Pet.fromMap(Map<String, dynamic> map) {
    // Trata tanto List quanto null para image_urls
    final imageUrlsData = map['image_urls'];
    List<String> imageUrls = [];

    if (imageUrlsData != null) {
      if (imageUrlsData is List) {
        imageUrls = List<String>.from(imageUrlsData.map((e) => e.toString()));
      } else if (imageUrlsData is String) {
        imageUrls = [imageUrlsData];
      }
    }

    return Pet(
      id: map['id'] ?? 0,
      userId: map['user_id'] ?? '2',
      name: map['name'] ?? '',
      type: map['type'] ?? 'outro',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      contact: map['contact'] ?? '',
      imageUrls: imageUrls,
      // CONVERTE STRING DE VOLTA PARA DATETIME
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      isFound: map['isFound'] == 1,
    );
  }
}
