import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Pacote do Firebase
import 'package:google_fonts/google_fonts.dart';
import 'screens/login_screen.dart';
import 'firebase_options.dart'; // O arquivo novo que você gerou!

void main() async {
  // 1. Garante que o motor do Flutter esteja pronto
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa o Firebase com as opções do seu projeto (Android/Web)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 3. Roda o App
  runApp(const NeuroTriboApp());
}

class NeuroTriboApp extends StatelessWidget {
  const NeuroTriboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeuroTribo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // --- Identidade Visual NeuroTribo ---
        scaffoldBackgroundColor: const Color(0xFFF5F2EA), // Fundo Creme
        primaryColor: const Color(0xFF8B5A2B), // Marrom
        
        // Fontes bonitas do Google
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
        
        // Estilo padrão para TODOS os campos de texto (Input)
        // Assim você não precisa ficar repetindo código em cada tela
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFEEEEEE)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF8B5A2B), width: 1.5),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}