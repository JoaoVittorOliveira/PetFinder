import 'package:flutter/material.dart';
import 'package:petfinder/controllers/pet_controller.dart';
import 'package:petfinder/models/pet.dart';
import 'highlight_card.dart';

class HighlightsCarousel extends StatelessWidget {
  const HighlightsCarousel({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Pet>>(
      valueListenable: PetController.instance.petsNotifier,
      builder: (context, allPets, child) {
        // Regra de negócio: Mostrar apenas os 5 mais recentes (Destaques)
        // Usamos .reversed para pegar os últimos cadastrados primeiro
        final highlightedPets = allPets.reversed.take(5).toList();

        // Se não houver pets, não renderiza o carrossel
        if (highlightedPets.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Perdidos Recentemente',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 180,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: highlightedPets.length,
                itemBuilder: (context, index) {
                  return HighlightCard(pet: highlightedPets[index]);
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}
