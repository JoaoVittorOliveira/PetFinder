import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // formatar datas
import 'package:petfinder/controllers/auth_controller.dart';
import '../models/pet.dart';

class PetDetailsView extends StatelessWidget {
  final Pet pet;

  const PetDetailsView({super.key, required this.pet});

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
    final String formattedDate = formatter.format(pet.datePosted);

    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco conforme pedido
      body: CustomScrollView(
        slivers: [
          // 1. A IMAGEM (Top half - 50%)
          SliverAppBar(
            expandedHeight: imageHeight,
            pinned: true, // Mantém a barra visível ao rolar
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
              background: pet.dummyImageUrl.isNotEmpty
                  ? Image.network(pet.dummyImageUrl, fit: BoxFit.cover)
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
                height: 30, // Altura do arredondamento
                decoration: const BoxDecoration(
                  color: Colors.white, // Mesma cor do fundo da tela
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(30), // Bordas arredondadas modernas
                  ),
                ),
                width: double.infinity,
              ),
            ),
          ),

          // 2. O CONTEÚDO (Restante da tela)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                100,
              ), // Espaço inferior para o botão fixo
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER: Nome e Tag ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        pet.name.isNotEmpty ? pet.name : 'Sem nome',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
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
                    pet.location,
                  ),

                  const SizedBox(height: 16),

                  // --- DETALHES/DESCRIÇÃO ---
                  const Text(
                    'Descrição:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pet.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5, // Melhora a leitura
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- CONTATO ---
                  const Text(
                    'Quem publicou:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Builder(
                    builder: (context) {
                      final author = AuthController.instance.getUserById(
                        pet.userId,
                      );

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepOrange.withOpacity(0.1),
                          child: const Icon(
                            Icons.person,
                            color: Colors.deepOrange,
                          ),
                        ),
                        title: Text(
                          author?.name ?? 'Usuário do PetFinder',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(author?.phone ?? pet.contact),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Botão fixo no rodapé para contato rápido
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.4,
          height: 55,
          child: FloatingActionButton.extended(
            onPressed: () {
              // TODO: Implementar lógica de abrir WhatsApp
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulando abrir WhatsApp...')),
              );
            },
            backgroundColor: const Color(0xFF1B7A3E), // Verde mais escuro
            icon: Icon(
              Icons.wechat,
              size: MediaQuery.of(context).size.width * 0.026,
              color: Colors.white,
            ),
            label: Text(
              'Entrar em contato via WhatsApp',
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
      ),
    );
  }

  // Widget auxiliar para as linhas de informação (Localização)
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
