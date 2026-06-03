import 'dart:io';
import 'package:flutter/material.dart';
import 'package:petfinder/controllers/pet_controller.dart';
import 'package:petfinder/services/image_upload_service.dart';
import 'package:petfinder/widgets/register_pet_view/custom_text_field.dart';
import '../models/pet.dart';

class EditPetView extends StatefulWidget {
  final Pet pet;

  const EditPetView({super.key, required this.pet});

  @override
  State<EditPetView> createState() => _EditPetViewState();
}

class _EditPetViewState extends State<EditPetView> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _contactController;

  late String _selectedType;
  List<File> _selectedImages = [];
  List<String> _uploadedImageUrls = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.pet.name);
    _locationController = TextEditingController(text: widget.pet.location);
    _descriptionController = TextEditingController(
      text: widget.pet.description,
    );
    _contactController = TextEditingController(text: widget.pet.contact);
    _selectedType = widget.pet.type;
    _uploadedImageUrls = List.from(widget.pet.imageUrls);
  }

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

  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(String imageUrl) {
    setState(() {
      _uploadedImageUrls.remove(imageUrl);
    });
  }

  Future<void> _updatePet() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isUploading = true);

      // Upload de novas imagens se houver
      if (_selectedImages.isNotEmpty) {
        try {
          final newUrls = await ImageUploadService.instance.uploadImages(
            _selectedImages,
            widget.pet.id,
          );

          if (newUrls.isNotEmpty) {
            _uploadedImageUrls.addAll(newUrls);
          } else {
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

      // Cria pet atualizado
      final updatedPet = widget.pet.copyWith(
        name: _nameController.text.trim(),
        type: _selectedType,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        contact: _contactController.text.trim(),
        imageUrls: _uploadedImageUrls,
      );

      // Atualiza no banco
      final success = await PetController.instance.updatePet(updatedPet);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet atualizado com sucesso!')),
          );
          Navigator.pop(context, updatedPet);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao atualizar o pet'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Pet'), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Imagens existentes
              if (_uploadedImageUrls.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Imagens atuais:',
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
                          itemCount: _uploadedImageUrls.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _uploadedImageUrls[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Container(
                                              width: 100,
                                              height: 100,
                                              color: Colors.grey[300],
                                              child: const Icon(Icons.error),
                                            );
                                          },
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        _removeExistingImage(
                                          _uploadedImageUrls[index],
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
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
              // Novas imagens selecionadas
              if (_selectedImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Novas imagens selecionadas:',
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
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.file(
                                      _selectedImages[index],
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 0,
                                    child: GestureDetector(
                                      onTap: () {
                                        _removeNewImage(index);
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        padding: const EdgeInsets.all(2),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
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
              ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Adicionar Foto'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _nameController,
                labelText: 'Nome do Pet',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite o nome';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                items: const [
                  DropdownMenuItem(value: 'cao', child: Text('Cachorro')),
                  DropdownMenuItem(value: 'gato', child: Text('Gato')),
                  DropdownMenuItem(value: 'outro', child: Text('Outro')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedType = value);
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _locationController,
                labelText: 'Última localização',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite a localização';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _descriptionController,
                labelText: 'Descrição',
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite a descrição';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _contactController,
                labelText: 'Contato (telefone/email)',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, digite o contato';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isUploading ? null : _updatePet,
                child: _isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar Alterações'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
