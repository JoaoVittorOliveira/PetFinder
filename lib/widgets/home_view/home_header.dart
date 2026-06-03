import 'package:flutter/material.dart';
import 'package:petfinder/controllers/auth_controller.dart';
import 'package:petfinder/controllers/pet_controller.dart';
import 'package:petfinder/views/my_records_view.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row do Título e Perfil
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PetFinder',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.person,
                  color: Colors.deepOrange,
                  size: 28,
                ),
                onSelected: (value) async {
                  if (value == 'logout') {
                    await AuthController.instance.signOut();
                  } else if (value == 'records') {
                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyRecordsView(),
                        ),
                      );
                    }
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'profile',
                    enabled: false,
                    child: ValueListenableBuilder<AppUser?>(
                      valueListenable: AuthController.instance.currentUser,
                      builder: (context, user, _) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.name ?? 'Usuário',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              user?.email ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'records',
                    child: Row(
                      children: [
                        Icon(Icons.list, size: 20),
                        SizedBox(width: 8),
                        Text('Meus Registros'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Sair', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Input de Busca
          TextField(
            onChanged: (value) {
              // Envia o texto digitado em tempo real para o Controller
              PetController.instance.searchPets(value);
            },
            decoration: InputDecoration(
              hintText: 'Buscar por nome ou bairro...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ],
      ),
    );
  }
}
