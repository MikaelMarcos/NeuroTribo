import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login_screen.dart';
import 'materials_screen.dart';
import 'challenges_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';
import '../sound_manager.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  // Lista das telas para a navegação do rodapé
  final List<Widget> _screens = [
    const HomeContent(),      // 0: Início
    const MaterialsScreen(),  // 1: Materiais
    const ChallengesScreen(), // 2: Desafios
    const CommunityScreen(),  // 3: Tribo
    const ProfileScreen(),    // 4: Perfil
  ];

  void _onItemTapped(int index) {
    SoundManager.playClick(); // Som de navegação
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      // Exibe a tela correspondente ao índice selecionado
      body: _screens[_selectedIndex],
      
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF8B5A2B),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed, // Importante para 5 itens
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Início'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'Materiais'),
            BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.bullseye), label: 'Desafios'),
            BottomNavigationBarItem(icon: Icon(Icons.groups), label: 'Tribo'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          ],
        ),
      ),
    );
  }
}

// Conteúdo da Home (Separado para organização)
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
        ),
        title: Image.asset('assets/images/logo_neurotribo_semfundo.png', height: 45),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF8B5A2B),
              radius: 18,
              child: Text(
                user?.displayName?.substring(0, 1).toUpperCase() ?? "M",
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeroBanner(context),
            const SizedBox(height: 20),
            _buildProgressSection(),
            const SizedBox(height: 25),
            _buildSectionHeader("Últimos Lançamentos"),
            const SizedBox(height: 15),
            _buildVideoCarousel(), 
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          Positioned.fill(child: Image.asset("assets/images/neuroExemploDeAula1.png", fit: BoxFit.cover)),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, const Color(0xFFF5F2EA)],
                stops: const [0.6, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: const Color(0xFF8B5A2B), borderRadius: BorderRadius.circular(20)),
                  child: const Text("SEMANA 1", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                const Text("NEUROPLASTICIDADE", textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF333333), fontSize: 30, fontWeight: FontWeight.w900)),
                const Text("Sua mente muda com ações consistentes.", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  label: const Text("Continuar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5A2B)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProgressSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            const CircularProgressIndicator(value: 0.4, color: Color(0xFF8B5A2B), backgroundColor: Color(0xFFEEEEEE)),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Progresso Mensal", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B5A2B))),
                  Text("Você concluiu 40% da jornada.", style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF333333))),
    );
  }

  Widget _buildVideoCarousel() {
    return SizedBox(
      height: 260,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        children: [
          _videoCard("Neuroplasticidade", "Aula 1", "https://assets.mixkit.co/videos/preview/mixkit-waves-in-the-water-1164-large.mp4"),
          _videoCard("Dopamina Detox", "Aula 2", "https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4"),
          _videoCard("Rotina Matinal", "Extra", "https://assets.mixkit.co/videos/preview/mixkit-stars-in-space-1610-large.mp4"),
        ],
      ),
    );
  }

  Widget _videoCard(String title, String subtitle, String url) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: const DecorationImage(image: AssetImage("assets/images/neuroExemploDeAula1.png"), fit: BoxFit.cover),
            ),
            child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 40)),
          ),
          const SizedBox(height: 8),
          Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        ],
      ),
    );
  }
}