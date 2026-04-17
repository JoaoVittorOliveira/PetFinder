import 'package:flutter/material.dart';
import 'package:petfinder/controllers/auth_controller.dart';
import 'package:petfinder/controllers/pet_controller.dart';
import 'package:petfinder/widgets/register_pet_screen/custom_text_field.dart';
import 'package:petfinder/widgets/register_pet_screen/image_upload_placeholder.dart';
import '../models/pet.dart';

class RegisterPetScreen extends StatefulWidget {
  const RegisterPetScreen({super.key});

  @override
  State<RegisterPetScreen> createState() => _RegisterPetScreenState();
}

class _RegisterPetScreenState extends State<RegisterPetScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _contactController = TextEditingController();

  String _selectedType = 'cao';

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  void _savePet() {
    if (_formKey.currentState!.validate()) {
      final newPet = Pet(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: AuthController.instance.currentUser.value!.id,
        name: _nameController.text.trim(),
        type: _selectedType,
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim(),
        contact: _contactController.text.trim(),

        datePosted: DateTime.now(),
        // acessar pelo banco de dados futuramente
        dummyImageUrl:
            'https://images.unsplash.com/photo-1543466835-00a7907e9de1?q=80&w=500',
      );

      // chama o controller para adicionar o pet e persistir os dados
      PetController.instance.addPet(newPet);

      // resultado visual e volta para a tela anterior
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pet publicado com sucesso!')),
        );
        Navigator.pop(context);
      }
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
              // Componente modularizado de Imagem
              ImageUploadPlaceholder(
                onTap: () {
                  // TODO: Lógica de abrir galeria/câmera
                },
              ),

              // Componentes modularizados de Texto
              CustomTextField(
                controller: _nameController,
                labelText: 'Nome do Pet (Opcional)',
              ),

              // O Dropdown ainda não foi abstraído pois é o único na tela,
              // mas poderia ser se tivéssemos mais selects.
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
                onPressed: _savePet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Publicar Registro'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
