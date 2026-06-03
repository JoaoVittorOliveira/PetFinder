import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // formatar datas
import 'package:petfinder/controllers/auth_controller.dart';
import 'package:petfinder/controllers/pet_controller.dart';
import 'package:petfinder/views/edit_pet_view.dart';
import '../models/pet.dart';

class PetDetailsView extends StatefulWidget {
  final Pet pet;

  const PetDetailsView({super.key, required this.pet});

  @override
  State<PetDetailsView> createState() => _PetDetailsViewState();
}

class _PetDetailsViewState extends State<PetDetailsView> {
  late PageController _pageController;
  int _currentImageIndex = 0;
  late Pet _pet;

  @override
  void initState() {
    super.initState();
    _pet = widget.pet;
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _isOwner {
    final currentUser = AuthController.instance.currentUser.value;
    return currentUser != null && currentUser.id == _pet.userId;
  }

  Future<void> _editPet() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditPetView(pet: _pet)),
    );

    if (result is Pet) {
      setState(() => _pet = result);
    }
  }

  Future<void> _deletePet() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Pet'),
        content: const Text('Tem certeza que deseja deletar este registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await PetController.instance.deletePet(
        _pet.id.toString(),
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pet deletado com sucesso!')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao deletar o pet'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Calcula 50% da altura da tela para a imagem
    final screenHeight = MediaQuery.of(context).size.height;
    final imageHeight = screenHeight * 0.5;

    // Formatador de data simples (Ex: 25 de Outubro de 2023)
    final DateFormat formatter = DateFormat(
      'dd \'de\' MMMM \'de\' yyyy',
      'pt_BR',
    );
    final String formattedDate = formatter.format(_pet.createdAt);

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 1. O CARROSSEL DE IMAGENS (Top half - 50%)
          SliverAppBar(
            expandedHeight: imageHeight,
            pinned: true,
            backgroundColor: Colors.white,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.black.withOpacity(0.5),
                child: const BackButton(color: Colors.white),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: _pet.imageUrls.isNotEmpty
                  ? Container(
                      color: Colors.grey[300],
                      child: Stack(
                        children: [
                          // PageView com as imagens
                          PageView.builder(
                            controller: _pageController,
                            onPageChanged: (index) {
                              setState(() => _currentImageIndex = index);
                            },
                            itemCount: _pet.imageUrls.length,
                            itemBuilder: (context, index) {
                              return Image.network(
                                _pet.imageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.error,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          // Botão voltar imagem (esquerda)
                          if (_pet.imageUrls.length > 1)
                            Positioned(
                              left: 16,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    if (_currentImageIndex > 0) {
                                      _pageController.previousPage(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.chevron_left,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Botão próxima imagem (direita)
                          if (_pet.imageUrls.length > 1)
                            Positioned(
                              right: 16,
                              top: 0,
                              bottom: 0,
                              child: Center(
                                child: GestureDetector(
                                  onTap: () {
                                    if (_currentImageIndex <
                                        _pet.imageUrls.length - 1) {
                                      _pageController.nextPage(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        curve: Curves.easeInOut,
                                      );
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(8),
                                    child: const Icon(
                                      Icons.chevron_right,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          // Indicador de página
                          if (_pet.imageUrls.length > 1)
                            Positioned(
                              bottom: 16,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _pet.imageUrls.length,
                                  (index) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    child: Container(
                                      width: _currentImageIndex == index
                                          ? 12
                                          : 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: _currentImageIndex == index
                                            ? Colors.white
                                            : Colors.white.withOpacity(0.5),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.pets,
                        size: 100,
                        color: Colors.grey,
                      ),
                    ),
            ),
            // O efeito de sobreposição moderno é feito aqui, arredondando o fundo
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0),
              child: Container(
                height: 30,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                width: double.infinity,
              ),
            ),
          ),

          // 2. O CONTEÚDO (Restante da tela)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER: Nome e Tag ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          _pet.name.isNotEmpty ? _pet.name : 'Sem nome',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      // Tag de Perdido
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '🔴 PERDIDO',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // --- DATA DA POSTAGEM ---
                  Text(
                    'Postado em: $formattedDate',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  const SizedBox(height: 24),

                  // --- LOCALIZAÇÃO ---
                  _buildInfoRow(
                    Icons.location_on,
                    'Visto por último',
                    _pet.location,
                  ),

                  const SizedBox(height: 16),

                  // --- DETALHES/DESCRIÇÃO ---
                  const Text(
                    'Descrição:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _pet.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- CONTATO ---
                  const Text(
                    'Quem publicou:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepOrange.withOpacity(0.1),
                      child: const Icon(Icons.person, color: Colors.deepOrange),
                    ),
                    title: Text(
                      AuthController.instance.currentUser.value?.name ??
                          'Usuário do PetFinder',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(_pet.contact),
                  ),
                  const SizedBox(height: 16),

                  // --- BOTÕES DE AÇÃO (se for o dono) ---
                  if (_isOwner)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _editPet,
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar Pet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepOrange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _deletePet,
                          icon: const Icon(Icons.delete),
                          label: const Text('Deletar Pet'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Botão fixo no rodapé para contato rápido
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: !_isOwner
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.4,
                height: 55,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Simulando abrir WhatsApp...'),
                      ),
                    );
                  },
                  backgroundColor: const Color(0xFF1B7A3E),
                  icon: Icon(
                    Icons.wechat,
                    size: MediaQuery.of(context).size.width * 0.026,
                    color: Colors.white,
                  ),
                  label: Text(
                    'Entrar em contato',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width * 0.020,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  // Widget auxiliar para as linhas de informação
  Widget _buildInfoRow(IconData icon, String title, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.deepOrange, size: 20),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }
}
