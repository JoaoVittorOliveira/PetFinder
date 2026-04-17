import 'package:flutter/material.dart';
import 'package:petfinder/controllers/pet_controller.dart';

class PetFilters extends StatelessWidget {
  const PetFilters({super.key});

  @override
  Widget build(BuildContext context) {
    final filters = ['Todos', 'Cães', 'Gatos', 'Outros'];

    // Envolvemos num ValueListenableBuilder para a UI atualizar quando o filtro mudar
    return ValueListenableBuilder<String>(
      valueListenable: PetController.instance.selectedFilterNotifier,
      builder: (context, selectedFilter, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: filters.map((filter) {
                bool isSelected =
                    filter == selectedFilter; // Verifica se este é o ativo

                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      // Se clicar, avisa o controller qual foi escolhido
                      if (selected) {
                        PetController.instance.filterByType(filter);
                      }
                    },
                    selectedColor: Colors.deepOrange.withValues(alpha: 0.2),
                    showCheckmark:
                        false, // Tira aquele "V" padrão do Material para ficar mais limpo
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.deepOrange : Colors.grey[700],
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected
                            ? Colors.deepOrange
                            : Colors.grey[300]!,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
