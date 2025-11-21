
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login_screen.dart';
import 'materials_screen.dart';
import 'challenges_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0; // Controla a barra inferior

  // Função para navegar na barra inferior
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ModulesListScreen()));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ChallengesScreen()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Image.asset(
          'assets/images/logo_neurotribo_semfundo.png', 
          height: 45,
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF8B5A2B),
                radius: 18,
                child: Text(
                  user?.displayName?.substring(0, 1).toUpperCase() ?? "M",
                  style: const TextStyle(color: Colors.white),
                ),
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
            _buildQuickShortcuts(context),
            const SizedBox(height: 30),
            _buildSectionHeader("Últimos Lançamentos"),
            const SizedBox(height: 15),
            // AQUI ESTAVA O ERRO: Aumentei para 260 e ajustei o card
            _buildVideoCarousel(), 
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF8B5A2B),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Início'),
            BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Aulas'),
            BottomNavigationBarItem(icon: Icon(FontAwesomeIcons.bullseye), label: 'Desafios'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS DA HOME (Mantidos e Ajustados) ---

  Widget _buildHeroBanner(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/images/neuroExemploDeAula1.png", fit: BoxFit.cover),
          ),
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
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ModulesListScreen())),
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

  Widget _buildQuickShortcuts(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _shortcut(context, Icons.play_circle_fill, "Aulas", const ModulesListScreen()),
        _shortcut(context, Icons.menu_book, "Materiais", const MaterialsScreen()),
        _shortcut(context, FontAwesomeIcons.bullseye, "Desafios", const ChallengesScreen()),
        _shortcut(context, Icons.groups, "Tribo", const CommunityScreen()),
      ],
    );
  }

  Widget _shortcut(BuildContext context, IconData icon, String label, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Column(
        children: [
          CircleAvatar(radius: 25, backgroundColor: Colors.white, child: Icon(icon, color: const Color(0xFF8B5A2B))),
          const SizedBox(height: 5),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF555555))),
        ],
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
      height: 260, // Altura segura para evitar overflow
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
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => VideoDetailScreen(title: title, videoUrl: url))),
      child: Container(
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
      ),
    );
  }
}

// --- TELA DE LISTA DE MÓDULOS ---
class ModulesListScreen extends StatelessWidget {
  const ModulesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF8B5A2B)),
        title: const Text("Módulos e Aulas", style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildModuleTile(context, "Módulo 1: Neuroplasticidade", [
            {"title": "O que é Neuroplasticidade", "duration": "10 min"},
            {"title": "Como aplicar no dia a dia", "duration": "15 min"},
            {"title": "Exercícios Práticos", "duration": "8 min"},
          ], isOpen: true),
          
          _buildModuleTile(context, "Módulo 2: Dopamina e Autocontrole", [
             {"title": "O ciclo da Dopamina", "duration": "12 min"},
             {"title": "Jejum de Dopamina", "duration": "20 min"},
          ]),
          
          _buildModuleTile(context, "Módulo 3: Ambiente e Produtividade", []),
          _buildModuleTile(context, "Módulo 4: Rotina e Sono", []),
        ],
      ),
    );
  }

  Widget _buildModuleTile(BuildContext context, String title, List<Map<String, String>> videos, {bool isOpen = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: isOpen,
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
          iconColor: const Color(0xFF8B5A2B),
          collapsedIconColor: Colors.grey,
          children: videos.map((video) => ListTile(
            contentPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: const Color(0xFFF5F2EA), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.play_arrow, color: Color(0xFF8B5A2B), size: 20),
            ),
            title: Text(video['title']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            subtitle: Text(video['duration']!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            trailing: const Icon(Icons.check_circle_outline, color: Colors.grey, size: 20),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => VideoDetailScreen(
                title: video['title']!, 
                videoUrl: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4")
              ));
            },
          )).toList(),
        ),
      ),
    );
  }
}

// --- TELA DE DETALHES DO VÍDEO ---
class VideoDetailScreen extends StatefulWidget {
  final String title;
  final String videoUrl;

  const VideoDetailScreen({super.key, required this.title, required this.videoUrl});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;
  bool isDone = false;

  @override
  void initState() {
    super.initState();
    initializePlayer();
  }

  Future<void> initializePlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      materialProgressColors: ChewieProgressColors(
        playedColor: const Color(0xFF8B5A2B),
        handleColor: const Color(0xFF8B5A2B),
        backgroundColor: Colors.grey,
        bufferedColor: Colors.white30,
      ),
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 250,
              color: Colors.black,
              child: Stack(
                children: [
                  Center(
                    child: _chewieController != null && _videoPlayerController.value.isInitialized
                        ? Chewie(controller: _chewieController!)
                        : const CircularProgressIndicator(color: Color(0xFF8B5A2B)),
                  ),
                  Positioned(
                    top: 10, left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                               ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Baixando material...")));
                            },
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: const Text("Baixar Material"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF8B5A2B),
                              elevation: 0,
                              side: const BorderSide(color: Color(0xFF8B5A2B)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              setState(() => isDone = !isDone);
                            },
                            icon: Icon(isDone ? Icons.check_circle : Icons.check_circle_outline, size: 18),
                            label: Text(isDone ? "Concluído" : "Marcar Visto"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDone ? Colors.green : const Color(0xFF8B5A2B),
                              foregroundColor: Colors.white,
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    const Divider(),
                    const SizedBox(height: 15),
                    const Text("SOBRE ESTA AULA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 10),
                    const Text(
                      "Nesta aula, vamos entender os fundamentos biológicos de como o cérebro se adapta a novos estímulos.",
                      style: TextStyle(color: Color(0xFF4A4A4A), height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    const Text("PONTOS CHAVE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 10),
                    _buildBulletPoint("O que define a neuroplasticidade."),
                    _buildBulletPoint("Diferença entre plasticidade funcional e estrutural."),
                    _buildBulletPoint("Exercícios práticos de atenção plena."),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF8B5A2B)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF4A4A4A)))),
        ],
      ),
    );
  }
}