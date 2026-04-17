import 'package:flutter/material.dart';
import 'package:petfinder/screens/register_pet_screen.dart';
import '../widgets/home_screen/home_header.dart';
import '../widgets/home_screen/highlights_carousel.dart';
import '../widgets/home_screen/pet_filters.dart';
import '../widgets/home_screen/pet_grid.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: HomeHeader()),
            SliverToBoxAdapter(child: HighlightsCarousel()),
            SliverToBoxAdapter(child: PetFilters()),
            PetGrid(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterPetScreen()),
          );
        },
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
