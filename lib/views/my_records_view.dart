/* 
import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/pet.dart';
import 'login_view.dart';

class MyRecordsView extends StatelessWidget {
  const MyRecordsView({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthController.instance.currentUser.value;
    // Opcional: Pegue apenas o primeiro nome
    final firstName = currentUser?.name.split(' ').first ?? 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: Text('Registros de $firstName'), // NOVO NOME NA BARRA
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            tooltip: 'Sair',
            onPressed: () async {
              await AuthController.instance.logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginView()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      // Mudamos para escutar o allPetsNotifier para ver os encontrados também
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
                    child: Image.network(
                      pet.dummyImage,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  title: Text(
                    pet.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(pet.datePosted.toString().substring(0, 10)),
                  trailing: pet.isFound
                      ? const Chip(
                          label: Text(
                            'Encontrado!',
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        )
                      : TextButton.icon(
                          onPressed: () =>
                              PetController.instance.markAsFound(pet.id),
                          icon: const Icon(
                            Icons.check_circle,
                            color: Colors.deepOrange,
                          ),
                          label: const Text(
                            'Encontrei',
                            style: TextStyle(color: Colors.deepOrange),
                          ),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
*/
