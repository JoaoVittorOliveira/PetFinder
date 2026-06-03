import 'package:flutter/material.dart';
import '../models/pet.dart';
import '../services/database_service.dart';

class PetController {
  static final PetController instance = PetController._internal();
  PetController._internal();

  final DatabaseService _database = DatabaseService.instance;

  List<Pet> _allPets = [];

  final ValueNotifier<List<Pet>> petsNotifier = ValueNotifier<List<Pet>>([]);
  final ValueNotifier<List<Pet>> allPetsNotifier = ValueNotifier<List<Pet>>([]);
  final ValueNotifier<bool> isLoadingNotifier = ValueNotifier<bool>(false);

  // Controladores de estado dos filtros
  final ValueNotifier<String> selectedFilterNotifier = ValueNotifier<String>(
    'Todos',
  );
  String _currentSearchQuery = '';

  Future<void> init() async {
    isLoadingNotifier.value = true;
    try {
      _allPets = await _database.loadPets();
      allPetsNotifier.value = List.from(_allPets);
      _applyFilters();
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  Future<bool> addPet(Pet pet) async {
    isLoadingNotifier.value = true;
    try {
      final savedPet = await _database.savePet(pet);
      if (savedPet != null) {
        _allPets.add(savedPet);
        allPetsNotifier.value = List.from(_allPets);
        _applyFilters();
        return true;
      }
      return false;
    } finally {
      isLoadingNotifier.value = false;
    }
  }

  Future<bool> removePet(String petId) async {
    try {
      final success = await _database.deletePet(petId);
      if (success) {
        _allPets.removeWhere((p) => p.id == petId);
        allPetsNotifier.value = List.from(_allPets);
        _applyFilters();
      }
      return success;
    } catch (e) {
      print('Erro ao remover pet: $e');
      return false;
    }
  }

  Future<bool> markAsFound(String petId) async {
    try {
      final success = await _database.markPetAsFound(petId);
      if (success) {
        final index = _allPets.indexWhere((p) => p.id == petId);
        if (index != -1) {
          _allPets[index] = _allPets[index].copyWith(isFound: true);
          allPetsNotifier.value = List.from(_allPets);
          _applyFilters();
        }
      }
      return success;
    } catch (e) {
      print('Erro ao marcar pet como encontrado: $e');
      return false;
    }
  }

  /// Recarrega pets do Supabase (útil para sincronização)
  Future<void> refreshPets() async {
    await init();
  }

  // --- MÉTODOS DE BUSCA E FILTRO ---

  // Disparado quando o usuário digita no TextField
  void searchPets(String query) {
    _currentSearchQuery = query.toLowerCase().trim();
    _applyFilters();
  }

  // Disparado quando o usuário clica nos Chips (Cães, Gatos...)
  void filterByType(String type) {
    selectedFilterNotifier.value = type;
    _applyFilters();
  }

  // O motor que processa os dados antes de mandar pra tela
  void _applyFilters() {
    List<Pet> filteredList = List.from(
      _allPets,
    ); // Cria uma cópia da lista original

    // Esconde os pets que já foram encontrados
    filteredList = filteredList.where((pet) => !pet.isFound).toList();

    // 1. Aplica o filtro de Espécie
    if (selectedFilterNotifier.value != 'Todos') {
      // Mapeia o nome do botão (UI) para o tipo do modelo (Banco)
      String targetType = 'outro';
      if (selectedFilterNotifier.value == 'Cães') targetType = 'cao';
      if (selectedFilterNotifier.value == 'Gatos') targetType = 'gato';

      filteredList = filteredList
          .where((pet) => pet.type == targetType)
          .toList();
    }

    // 2. Aplica o filtro de Texto (Nome ou Localização)
    if (_currentSearchQuery.isNotEmpty) {
      filteredList = filteredList.where((pet) {
        final matchName = pet.name.toLowerCase().contains(_currentSearchQuery);
        final matchLocation = pet.location.toLowerCase().contains(
          _currentSearchQuery,
        );
        return matchName ||
            matchLocation; // Retorna se bater com o nome OU localização
      }).toList();
    }

    // Atualiza a tela com o resultado final
    petsNotifier.value = filteredList;
  }
}
