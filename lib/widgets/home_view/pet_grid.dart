import 'package:flutter/material.dart';
import 'package:petfinder/controllers/pet_controller.dart';
import 'package:petfinder/models/pet.dart';
import 'pet_card.dart';

class PetGrid extends StatelessWidget {
  const PetGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Pet>>(
      valueListenable: PetController.instance.petsNotifier,
      builder: (context, pets, child) {
        if (pets.isEmpty) {
          return const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum pet perdido por aqui ainda...',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16.0,
              crossAxisSpacing: 16.0,
              childAspectRatio: 0.75,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              // No grid, mostramos todos (também invertidos para os novos virem primeiro)
              final pet = pets.reversed.toList()[index];
              return PetCard(pet: pet);
            }, childCount: pets.length),
          ),
        );
      },
    );
  }
}
