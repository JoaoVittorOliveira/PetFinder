import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petfinder/controllers/auth_controller.dart';
import 'package:petfinder/controllers/pet_controller.dart';
import 'package:petfinder/services/image_upload_service.dart';
import 'package:petfinder/widgets/register_pet_view/custom_text_field.dart';
import '../models/pet.dart';

class RegisterPetView extends StatefulWidget {
  const RegisterPetView({super.key});

  @override
  State<RegisterPetView> createState() => _RegisterPetViewState();
}

class _RegisterPetViewState extends State<RegisterPetView> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedType = 'cao';
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];
  bool _isUploading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final images = await ImageUploadService.instance.selectImagesFromGallery();
    if (images.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _savePet() async {
    if (_formKey.currentState!.validate()) {
      // Se há imagens selecionadas mas não foram uploadadas ainda
      if (_selectedImages.isNotEmpty && _uploadedImageUrls.isEmpty) {
        setState(() => _isUploading = true);

        try {
          _uploadedImageUrls = await ImageUploadService.instance.uploadImages(
            _selectedImages,
            0, // petId temporário (será gerado pelo Supabase)
          );

          if (_uploadedImageUrls.isEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Erro ao fazer upload das imagens'),
                  backgroundColor: Colors.red,
                ),
              );
            }
            setState(() => _isUploading = false);
            return;
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao fazer upload: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
          setState(() => _isUploading = false);
          return;
        }
      }

      final newPet = Pet(
        id: 0, // O id será gerado automaticamente pelo Supabase
        userId: AuthController.instance.currentUser.value?.id ?? '2',
        name: _nameController.text.trim(),
        type: _selectedType,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        contact: _contactController.text.trim(),
        imageUrls: _uploadedImageUrls,
        createdAt: DateTime.now(),
      );

      // Chama o controller para adicionar o pet e persistir os dados
      PetController.instance.addPet(newPet);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet publicado com sucesso!')),
        );
        Navigator.pop(context);
      }

      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportar Pet Perdido'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Galeria de imagens selecionadas
              if (_selectedImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Imagens selecionadas:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(
                                          _selectedImages[index],
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removeImage(index),
                                      child: Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

              // Botão para adicionar mais fotos
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ElevatedButton.icon(
                  onPressed: _isUploading ? null : _pickImages,
                  icon: const Icon(Icons.add_a_photo),
                  label: const Text('Adicionar Foto'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),

              // Componentes de Texto
              CustomTextField(
                controller: _nameController,
                labelText: 'Nome do Pet (Opcional)',
              ),

              // Dropdown de tipo
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Espécie',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'cao', child: Text('Cachorro')),
                    DropdownMenuItem(value: 'gato', child: Text('Gato')),
                    DropdownMenuItem(value: 'outro', child: Text('Outro')),
                  ],
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
              ),

              CustomTextField(
                controller: _locationController,
                labelText: 'Localização (Bairro, Cidade)',
                suffixIcon: Icons.location_on,
                validator: (value) =>
                    value!.isEmpty ? 'Informe o local onde foi visto' : null,
              ),

              CustomTextField(
                controller: _descriptionController,
                labelText: 'Descrição (Cores, coleira, raça...)',
                maxLines: 3,
                validator: (value) =>
                    value!.isEmpty ? 'Dê alguns detalhes para ajudar' : null,
              ),

              CustomTextField(
                controller: _contactController,
                labelText: 'Seu Contato (WhatsApp)',
                prefixIcon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? 'Informe um meio de contato' : null,
              ),

              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _isUploading ? null : _savePet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Publicar Registro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
