import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/pet.dart';
import 'image_upload_service.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._internal();
  DatabaseService._internal();

  late final SupabaseClient _supabase;

  // Inicializa a conexão com Supabase
  Future<void> initialize(String url, String anonKey) async {
    await Supabase.initialize(url: url, anonKey: anonKey);
    _supabase = Supabase.instance.client;
  }

  SupabaseClient get supabase => _supabase;

  // --- MÉTODOS DE PETS ---

  /// Salva um novo pet no Supabase
  Future<Pet?> savePet(Pet pet) async {
    try {
      final response = await _supabase
          .from('Pet')
          .insert(pet.toMap())
          .select()
          .single();

      return Pet.fromMap(response as Map<String, dynamic>);
    } catch (e) {
      print('Erro ao salvar pet: $e');
      return null;
    }
  }

  /// Carrega todos os pets do Supabase
  Future<List<Pet>> loadPets() async {
    try {
      final response = await _supabase
          .from('Pet')
          .select()
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((data) => Pet.fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao carregar pets: $e');
      return [];
    }
  }

  /// Atualiza um pet existente
  Future<bool> updatePet(Pet pet) async {
    try {
      await _supabase.from('Pet').update(pet.toMap()).eq('id', pet.id);
      return true;
    } catch (e) {
      print('Erro ao atualizar pet: $e');
      return false;
    }
  }

  /// Deleta um pet e suas imagens associadas
  Future<bool> deletePet(String petId) async {
    try {
      // Primeiro, busca o pet para obter as imagens
      final petResponse = await _supabase
          .from('Pet')
          .select('image_urls')
          .eq('id', petId)
          .single();

      final imageUrls = List<String>.from(petResponse['image_urls'] ?? []);

      // Deleta as imagens do Supabase Storage
      if (imageUrls.isNotEmpty) {
        await ImageUploadService.instance.deleteImages(imageUrls);
      }

      // Deleta o pet do banco
      await _supabase.from('Pet').delete().eq('id', petId);
      return true;
    } catch (e) {
      print('Erro ao deletar pet: $e');
      return false;
    }
  }

  /// Busca pets por tipo
  Future<List<Pet>> searchPetsByType(String type) async {
    try {
      final response = await _supabase
          .from('Pet')
          .select()
          .eq('type', type)
          .order('created_at', ascending: false);

      if (response.isEmpty) {
        return [];
      }

      return (response as List<dynamic>)
          .map((data) => Pet.fromMap(data as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Erro ao buscar pets por tipo: $e');
      return [];
    }
  }

  /// Marca um pet como encontrado
  Future<bool> markPetAsFound(String petId) async {
    try {
      await _supabase
          .from('Pet')
          .update({
            'isFound': true,
            'updatedAt': DateTime.now().toIso8601String(),
          })
          .eq('id', petId);
      return true;
    } catch (e) {
      print('Erro ao marcar pet como encontrado: $e');
      return false;
    }
  }

  /// Limpa todos os pets (use com cuidado!)
  Future<bool> clearAllPets() async {
    try {
      await _supabase.from('Pet').delete().neq('id', '');
      return true;
    } catch (e) {
      print('Erro ao limpar todos os pets: $e');
      return false;
    }
  }

  /// Retorna um stream de pets em tempo real (opcional, para atualizações ao vivo)
  Stream<List<Pet>> getPetsStream() {
    return _supabase
        .from('Pet')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map(
          (data) => (data as List<dynamic>)
              .map((item) => Pet.fromMap(item as Map<String, dynamic>))
              .toList(),
        )
        .handleError((error) {
          print('Erro no stream de pets: $error');
        });
  }
}
