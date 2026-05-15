import 'package:flutter/material.dart';
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
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyRecordsView(),
                    ),
                  );
                },
                icon: const Icon(
                  Icons.person,
                  color: Colors.deepOrange,
                  size: 28,
                ),
                tooltip: 'Meus Registros e Perfil',
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
