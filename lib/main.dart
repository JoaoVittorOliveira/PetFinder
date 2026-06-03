import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:petfinder/controllers/pet_controller.dart';
import 'package:petfinder/views/home_view.dart';
import 'package:petfinder/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DatabaseService.instance.initialize(
    'https://lnvoyeegvsyuoinunvhe.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxudm95ZWVndnN5dW9pbnVudmhlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk4MTU1OTEsImV4cCI6MjA5NTM5MTU5MX0.iKD1TTnZqg5deT26A0Qf7Gj6y8JQxEMn_Cv5oYGjNQY',
  );

  await initializeDateFormatting('pt_BR', null);

  /* 
  // Inicializa o databaseFactory para desktop (Windows/Linux/macOS)
  if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
    databaseFactory = databaseFactoryFfi;
  }
  */

  // await AuthController.instance.init();
  await PetController.instance.init();

  runApp(const PetFinderApp());
}

class PetFinderApp extends StatelessWidget {
  const PetFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final isLoggedIn = AuthController.instance.currentUser.value != null;

    return MaterialApp(
      title: 'PetFinder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
      ),
      home: const HomeView(),
    );
  }
}
