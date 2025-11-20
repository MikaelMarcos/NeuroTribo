import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login_screen.dart';

// --- TELA PRINCIPAL (HOME) ---
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final User? user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA), // Fundo Creme
      extendBodyBehindAppBar: true, // O conteúdo passa por trás da barra superior
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.8), // Mais escuro no topo para ler o menu
                Colors.transparent
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
        title: Image.asset(
          'assets/images/logo_neurotribo_semfundo.png', 
          height: 45,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: const Color(0xFF8B5A2B),
              radius: 16,
              child: Text(
                user?.displayName?.substring(0, 1).toUpperCase() ?? "M",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(), // Efeito elástico ao rolar
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO BANNER (Destaque Gigante)
            _buildHeroBanner(context),

            const SizedBox(height: 25),

            // 2. BARRA DE PROGRESSO
            _buildProgressSection(),

            const SizedBox(height: 30),

            // 3. ATALHOS RÁPIDOS
            _buildQuickShortcuts(context),

            const SizedBox(height: 35),

            // 4. ÚLTIMOS LANÇAMENTOS (CORRIGIDO O ERRO DE OVERFLOW AQUI)
            _buildSectionHeader("Últimos Lançamentos", () {}),
            const SizedBox(height: 15),
            _buildVideoCarousel(), // Agora com altura segura

            const SizedBox(height: 30),
            
            // 5. SEÇÃO EXTRA (Exemplo: Mais vistos)
            _buildSectionHeader("Continuar Assistindo", () {}),
            const SizedBox(height: 15),
            _buildVideoCarousel(isContinueWatching: true),

            const SizedBox(height: 40),
            _buildLogoutButton(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // --- WIDGETS DA HOME ---

  Widget _buildHeroBanner(BuildContext context) {
    return SizedBox(
      height: 550, // Altura imponente estilo Netflix
      child: Stack(
        children: [
          // Imagem de Fundo
          Positioned.fill(
            child: Image.asset(
              "assets/images/neuroExemploDeAula1.png",
              fit: BoxFit.cover,
            ),
          ),
          // Gradiente Inferior (Para o texto aparecer bem)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.8), // Escurece bem no final
                    const Color(0xFFF5F2EA), // Funde suavemente com o fundo do app
                  ],
                  stops: const [0.4, 0.6, 0.9, 1.0],
                ),
              ),
            ),
          ),
          // Conteúdo do Banner
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Badge "Semana 1"
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5A2B),
                    borderRadius: BorderRadius.circular(4),
                    boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 2))],
                  ),
                  child: const Text(
                    "SEMANA 1", 
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1),
                  ),
                ),
                const SizedBox(height: 15),
                
                // Título Principal
                const Text(
                  "NEUROPLASTICIDADE",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    shadows: [Shadow(color: Colors.black, blurRadius: 20, offset: Offset(0, 4))],
                  ),
                ),
                const SizedBox(height: 8),
                
                // Subtítulo
                const Text(
                  "Descubra como reprogramar seu cérebro com ações consistentes.",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 25),
                
                // Botões (Play e Minha Lista)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(
                          builder: (context) => const VideoDetailScreen(
                            title: "Neuroplasticidade: O Início", 
                            videoUrl: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"
                          )
                        ));
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text("Assistir", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5A2B),
                        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(width: 15),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Minha Lista", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white, width: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        backgroundColor: Colors.black26,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30), // Espaço extra no final do banner
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
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 50, height: 50,
                  child: CircularProgressIndicator(
                    value: 0.4,
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFF8B5A2B),
                    strokeWidth: 5,
                  ),
                ),
                const Text("40%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF8B5A2B))),
              ],
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Progresso da Jornada", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text("Você está indo muito bem!", style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold, fontSize: 15)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickShortcuts(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildShortcutItem(context, Icons.play_circle_fill, "Aulas", const ModulesListScreen()),
          _buildShortcutItem(context, Icons.book, "Materiais", null),
          _buildShortcutItem(context, FontAwesomeIcons.bullseye, "Desafios", null),
          _buildShortcutItem(context, Icons.groups, "Tribo", null),
        ],
      ),
    );
  }

  Widget _buildShortcutItem(BuildContext context, IconData icon, String label, Widget? destination) {
    return GestureDetector(
      onTap: () {
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (context) => destination));
        }
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF8B5A2B).withOpacity(0.15), blurRadius: 10, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: const Color(0xFF8B5A2B), size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF555555))),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF333333))),
          GestureDetector(
            onTap: onTap,
            child: const Text("Ver tudo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B5A2B))),
          ),
        ],
      ),
    );
  }

  // --- AQUI ESTAVA O PROBLEMA DO OVERFLOW (CORRIGIDO) ---
  Widget _buildVideoCarousel({bool isContinueWatching = false}) {
    return SizedBox(
      // AUMENTADO DE 220 PARA 260 PARA CABER TUDO SEM ERRO
      height: 260, 
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20, right: 10),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildVideoCard("Neuroplasticidade", "Aula 1 • Fundamentos", "https://assets.mixkit.co/videos/preview/mixkit-waves-in-the-water-1164-large.mp4"),
          _buildVideoCard("Detox de Dopamina", "Aula 2 • Prática", "https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4"),
          _buildVideoCard("Rotina Matinal", "Extra • Alta Performance", "https://assets.mixkit.co/videos/preview/mixkit-stars-in-space-1610-large.mp4"),
          _buildVideoCard("Sono Profundo", "Aula 3 • Recuperação", "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4"),
        ],
      ),
    );
  }

  Widget _buildVideoCard(String title, String subtitle, String videoUrl) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => VideoDetailScreen(title: title, videoUrl: videoUrl)));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // THUMBNAIL
            Container(
              height: 160, // Formato Vertical (Capa de Filme)
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
                image: const DecorationImage(
                  image: AssetImage("assets/images/neuroExemploDeAula1.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                  ),
                ),
                child: const Center(
                  child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 40),
                ),
              ),
            ),
            const SizedBox(height: 10),
            
            // INFORMAÇÕES
            Text(
              title, 
              maxLines: 1, 
              overflow: TextOverflow.ellipsis, // Corta com "..." se for grande demais
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF333333)),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle, 
              maxLines: 2, // Permite 2 linhas
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Color(0xFF888888), height: 1.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: TextButton.icon(
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
          if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        },
        icon: const Icon(Icons.logout_rounded, color: Colors.grey, size: 18),
        label: const Text("Sair da conta", style: TextStyle(color: Colors.grey, fontSize: 14)),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5))],
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF8B5A2B),
        unselectedItemColor: Colors.grey.shade400,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), label: 'Aulas'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events_outlined), label: 'Desafios'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Perfil'),
        ],
        onTap: (index) {
          if (index == 1) {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const ModulesListScreen()));
          }
        },
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