# PetFinder 🐾

Um aplicativo mobile desenvolvido em **Flutter** para ajudar na busca, registro e localização de animais de estimação perdidos ou encontrados.

## 📋 Informações do Projeto

- **Disciplina**: Programação para Dispositivos Móveis 2
- **Instituição**: UNITINS (Universidade Estadual do Tocantins)
- **Linguagem**: Dart/Flutter
- **Versão Flutter**: ^3.11.0

## 🎯 Funcionalidades

- ✅ **Autenticação de Usuários**: Login e registro de novos usuários
- ✅ **Registro de Pets**: Cadastro de animais perdidos ou encontrados (cães, gatos e outros)
- ✅ **Visualização em Carrossel**: Interface com carrossel interativo para visualizar destaques de pets
- ✅ **Sistema de Filtros**: Filtrar pets por tipo (cão, gato, outro)
- ✅ **Meus Registros**: Visualizar todos os pets cadastrados pelo usuário
- ✅ **Persistência Local**: Armazenamento de dados usando SQLite
- ✅ **Detalhes do Pet**: Visualizar informações completas de cada animal

## 🏗️ Arquitetura e Padrões

O projeto segue os padrões de projeto definidos pela orientadora:

### 1. **Carrossel (Carousel Pattern)**
- Localizado em: `lib/widgets/home_screen/highlights_carousel.dart`
- Exibe os pets em destaque de forma interativa
- Permite navegação horizontal entre os registros

### 2. **SQLite para Persistência**
- Localizado em: `lib/services/database_service.dart`
- Banco de dados local: `petfinder.db`
- **Tabelas criadas**:
  - `pets`: Armazena informações dos pets cadastrados
  - `session`: Armazena informações da sessão do usuário logado

### 3. **Padrão MVC (Model-View-Controller)**
- **Models** (`lib/models/`): Define a estrutura de dados (Pet)
- **Views** (`lib/screens/` e `lib/widgets/`): Componentes da UI
- **Controllers** (`lib/controllers/`):
  - `auth_controller.dart`: Gerencia autenticação
  - `pet_controller.dart`: Gerencia operações com pets

## 📁 Estrutura do Projeto

```
lib/
├── main.dart                      # Entrada da aplicação
├── models/
│   └── pet.dart                  # Modelo de dados para Pet
├── controllers/
│   ├── auth_controller.dart       # Lógica de autenticação
│   └── pet_controller.dart        # Lógica de gerenciamento de pets
├── services/
│   └── database_service.dart      # Serviço de banco de dados SQLite
├── screens/
│   ├── login_screen.dart          # Tela de login
│   ├── home_screen.dart           # Tela inicial (home)
│   ├── register_pet_screen.dart    # Tela para registrar novo pet
│   ├── my_records_screen.dart      # Tela com meus registros
│   └── pet_details_screen.dart     # Tela com detalhes do pet
└── widgets/
    ├── home_screen/               # Widgets da tela home
    │   ├── home_header.dart
    │   ├── highlights_carousel.dart # Carrossel principal
    │   ├── pet_filters.dart
    │   └── pet_grid.dart
    └── register_pet_screen/       # Widgets da tela de registro
```

## 🗄️ Banco de Dados (SQLite)

### Tabela `pets`
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| id | TEXT (PK) | Identificador único do pet |
| userId | TEXT | ID do usuário que cadastrou |
| name | TEXT | Nome do pet |
| type | TEXT | Tipo ('cao', 'gato', 'outro') |
| location | TEXT | Localização do pet |
| description | TEXT | Descrição/detalhes do pet |
| contact | TEXT | Contato do responsável |
| dummyImageUrl | TEXT | URL da imagem |
| datePosted | TEXT | Data do cadastro (ISO8601) |
| isFound | INTEGER | Status: 0 (perdido), 1 (encontrado) |

### Tabela `session`
| Coluna | Tipo | Descrição |
|--------|------|-----------|
| id | TEXT (PK) | ID da sessão |
| name | TEXT | Nome do usuário logado |

## 🚀 Como Replicar/Executar

### Pré-requisitos

- **Flutter SDK**: Versão 3.11.0 ou superior
  - [Instalar Flutter](https://flutter.dev/docs/get-started/install)
- **Dart SDK**: Incluído no Flutter
- **IDE**: VS Code, Android Studio ou IntelliJ IDEA (recomendado)

### Passos para Configuração

1. **Clone o repositório**
   ```bash
   git clone <url-do-repositorio>
   cd petfinder
   ```

2. **Instale as dependências**
   ```bash
   flutter pub get
   ```

3. **Configure o banco de dados**
   - O SQLite é inicializado automaticamente na primeira execução
   - O arquivo `petfinder.db` é criado em:
     - **Android/iOS**: Diretório de documentos do app
     - **Windows/Linux/macOS**: Diretório padrão de banco de dados do sistema

4. **Execute a aplicação**
   ```bash
   # Para Android/iOS
   flutter run
   
   # Para Windows
   flutter run -d windows
   
   # Para Web (ainda em desenvolvimento)
   flutter run -d chrome
   ```

### Dependências Principais

```yaml
dependencies:
  flutter:              # Framework UI
  cupertino_icons:      # Ícones iOS style
  sqflite_common_ffi:   # SQLite para desktop (Windows/Linux/macOS)
  path:                 # Manipulação de caminhos de arquivo
  intl:                 # Internacionalização (pt_BR)
```

## 📱 Fluxo da Aplicação

### 1. **Inicialização**
   - Verifica se há usuário logado
   - Carrega dados de pets do banco de dados
   - Inicializa formatação de data em português (pt_BR)
   - Configura SQLite para plataformas desktop

### 2. **Login/Registro**
   - Usuário acessa `LoginScreen`
   - Cria nova conta ou faz login
   - Dados salvos em `session` table

### 3. **Tela Home**
   - Exibe **HighlightsCarousel** com destaques
   - Mostra **PetFilters** para filtrar por tipo
   - Lista pets em **PetGrid** 
   - Botão `+` (FAB) para registrar novo pet

### 4. **Registro de Pet**
   - Preenche formulário em `RegisterPetScreen`
   - Salva no banco de dados SQLite
   - Retorna à home

### 5. **Meus Registros**
   - Visualiza todos os pets cadastrados pelo usuário
   - Pode marcar como encontrado
   - Acessa detalhes completos

## 🔧 Como Funciona o Sistema

### **Autenticação**
```
LoginScreen → AuthController → DatabaseService (session table)
```
- Valida credenciais do usuário
- Mantém sessão ativa durante a navegação
- Usa estado reativo para atualizar UI

### **Registro e Busca de Pets**
```
RegisterPetScreen → PetController → DatabaseService (pets table)
```
- Cadastro de novo pet com validação
- Persiste dados localmente
- Busca e filtra pets pela tipo/localização

### **Carrossel de Destaques**
```
HomeScreen → HighlightsCarousel → PetController
```
- Exibe pets em scroll horizontal
- Permite interação deslizando
- Toca para ver detalhes completos

## 🎨 Personalizações e Padrões de Design

- **Tema**: Material Design 3 com cor primária `Colors.deepOrange`
- **Responsividade**: Usa `CustomScrollView` com `SliverToBoxAdapter`
- **Localização**: Formatação de datas em Português do Brasil (pt_BR)

## 📝 Modelo de Dados (Pet)

```dart
class Pet {
  final String id;              // Identificador único
  final String userId;          // Proprietário do registro
  final String name;            // Nome do pet
  final String type;            // 'cao', 'gato', 'outro'
  final String location;        // Localização
  final String description;     // Descrição detalhada
  final String contact;         // Contato para informações
  final String dummyImageUrl;   // URL da imagem
  final DateTime datePosted;    // Data do cadastro
  final bool isFound;           // Encontrado ou perdido
}
```

## 🐛 Troubleshooting

### Erro ao conectar ao banco de dados
- Verifique se a pasta de documentos do app existe
- Tente executar `flutter clean && flutter pub get`

### Carrossel não aparece
- Confirme que há pets cadastrados no banco
- Verifique logs com `flutter logs`

### Problema com formatação de data
- Confirme inicialização de locale em `main()`:
  ```dart
  await initializeDateFormatting('pt_BR', null);
  ```

## 📚 Referências e Recursos

- [Documentação Flutter](https://flutter.dev/docs)
- [SQLite Dart Package](https://pub.dev/packages/sqflite)
- [Material Design 3](https://m3.material.io/)

## 👤 Autor

Desenvolvido como projeto acadêmico para a disciplina de Programação para Dispositivos Móveis 2 - UNITINS.

## 📄 Licença

Este projeto foi desenvolvido para fins educacionais.

---

**Dúvidas ou sugestões?** Consulte a documentação oficial do Flutter ou abra uma issue no repositório.
