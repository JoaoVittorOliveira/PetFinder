import 'package:flutter/material.dart';
import 'package:petfinder/views/register_pet_view.dart';
import '../widgets/home_view/home_header.dart';
import '../widgets/home_view/highlights_carousel.dart';
import '../widgets/home_view/pet_filters.dart';
import '../widgets/home_view/pet_grid.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

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
            MaterialPageRoute(builder: (context) => const RegisterPetView()),
          );
        },
        backgroundColor: Colors.deepOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
