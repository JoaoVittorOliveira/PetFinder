// lib/services/image_upload_service.dart

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ImageUploadService {
  static final ImageUploadService instance = ImageUploadService._internal();
  ImageUploadService._internal();

  final ImagePicker _picker = ImagePicker();
  late final SupabaseClient _supabase;

  void initialize(SupabaseClient supabaseClient) {
    _supabase = supabaseClient;
  }

  /// Seleciona múltiplas imagens da galeria
  Future<List<File>> selectImagesFromGallery() async {
    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage(
        imageQuality: 100, // Qualidade na seleção, compressão acontece depois
      );

      if (pickedFiles.isEmpty) {
        return [];
      }

      return pickedFiles.map((xfile) => File(xfile.path)).toList();
    } catch (e) {
      print('Erro ao selecionar imagens: $e');
      return [];
    }
  }

  /// Comprime e redimensiona uma imagem
  Future<File> compressImage(File imageFile) async {
    try {
      // Lê a imagem original
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return imageFile; // Retorna original se falhar ao decodificar
      }

      // Redimensiona para máximo 1024x1024 mantendo aspect ratio
      img.Image resized;
      if (image.width > 1024 || image.height > 1024) {
        resized = img.copyResize(
          image,
          width: image.width > image.height ? 1024 : null,
          height: image.height > image.width ? 1024 : null,
          interpolation: img.Interpolation.average,
        );
      } else {
        resized = image;
      }

      // Comprime para JPEG com qualidade 80
      final compressedBytes = img.encodeJpg(resized, quality: 80);

      // Salva em arquivo temporário
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File(
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}_compressed.jpg',
      );
      await compressedFile.writeAsBytes(compressedBytes);

      return compressedFile;
    } catch (e) {
      print('Erro ao comprimir imagem: $e');
      return imageFile; // Retorna original em caso de erro
    }
  }

  /// Faz upload de múltiplas imagens para Supabase Storage
  Future<List<String>> uploadImages(List<File> imageFiles, int petId) async {
    final uploadedUrls = <String>[];

    try {
      for (final imageFile in imageFiles) {
        // Comprime a imagem
        final compressedFile = await compressImage(imageFile);

        // Cria nome único para o arquivo
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${imageFile.path.split('/').last}';
        final uploadPath = 'pet-images/$petId/$fileName';

        // Faz upload para Supabase Storage
        await _supabase.storage
            .from('pet-images')
            .upload(uploadPath, compressedFile);

        // Obtém URL pública da imagem
        final publicUrl = _supabase.storage
            .from('pet-images')
            .getPublicUrl(uploadPath);

        uploadedUrls.add(publicUrl);

        // Remove arquivo comprimido temporário
        await compressedFile.delete();
      }

      // Remove imagens originais temporárias
      for (final imageFile in imageFiles) {
        if (await imageFile.exists()) {
          await imageFile.delete();
        }
      }

      return uploadedUrls;
    } catch (e) {
      print('Erro ao fazer upload de imagens: $e');
      return [];
    }
  }

  /// Deleta imagem do Supabase Storage pelo URL
  Future<bool> deleteImage(String imageUrl) async {
    try {
      // Extrai o caminho da URL
      // URL formato: https://.../storage/v1/object/public/pet-images/...
      final uri = Uri.parse(imageUrl);
      final pathParts = uri.pathSegments;

      // Encontra o índice de 'pet-images' e monta o caminho
      final petImagesIndex = pathParts.indexOf('pet-images');
      if (petImagesIndex == -1) return false;

      final uploadPath = pathParts.sublist(petImagesIndex).join('/');

      await _supabase.storage.from('pet-images').remove([uploadPath]);
      return true;
    } catch (e) {
      print('Erro ao deletar imagem: $e');
      return false;
    }
  }

  /// Deleta múltiplas imagens do Storage
  Future<void> deleteImages(List<String> imageUrls) async {
    for (final url in imageUrls) {
      await deleteImage(url);
    }
  }
}
