import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/pet.dart';
import 'pet_details_view.dart';

class MyRecordsView extends StatelessWidget {
  const MyRecordsView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthController.instance.currentUser.value;
    // Pega apenas o primeiro nome
    final firstName = currentUser?.name?.split(' ').first ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(title: Text('Registros de $firstName')),
      body: ValueListenableBuilder<List<Pet>>(
        valueListenable: PetController.instance.allPetsNotifier,
        builder: (context, allPets, child) {
          final myPets = allPets
              .where((pet) => pet.userId == currentUser?.id)
              .toList();

          if (myPets.isEmpty) {
            return const Center(
              child: Text('Você ainda não publicou nenhum pet.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: myPets.length,
            itemBuilder: (context, index) {
              final pet = myPets[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: pet.imageUrls.isNotEmpty
                        ? Image.network(
                            pet.imageUrls.first,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey[300],
                                child: const Icon(Icons.pets),
                              );
                            },
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.pets),
                          ),
                  ),
                  title: Text(
                    pet.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(pet.location),
                  trailing: pet.isFound
                      ? const Chip(
                          label: Text(
                            'Encontrado!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        )
                      : TextButton.icon(
                          onPressed: () => PetController.instance.markAsFound(
                            pet.id.toString(),
                          ),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.deepOrange,
                          ),
                          label: const Text(
                            'Encontrei',
                            style: TextStyle(color: Colors.deepOrange),
                          ),
                        ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PetDetailsView(pet: pet),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
