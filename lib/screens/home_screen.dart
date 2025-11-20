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
      // AppBar flutuante e transparente sobre o conteúdo
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Degradê no topo para o ícone ficar visível
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
        ),
        // --- MUDANÇA 1: LOGO TRANSPARENTE ---
        title: Image.asset(
          'assets/images/logo_neurotribo_semfundo.png', 
          height: 50, // Aumentei um pouquinho para ficar legível sem o fundo
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white, size: 28),
            onPressed: () {
              // Ação de busca
            },
          ),
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
        padding: const EdgeInsets.only(bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO BANNER (Destaque da Semana com SUA FOTO)
            _buildHeroBanner(context),

            const SizedBox(height: 20),

            // 2. BARRA DE PROGRESSO
            _buildProgressSection(),

            const SizedBox(height: 25),

            // 3. ATALHOS RÁPIDOS (Aulas, Materiais, etc)
            _buildQuickShortcuts(context),

            const SizedBox(height: 30),

            // 4. ÚLTIMOS CONTEÚDOS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Últimos Lançamentos", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
                  Text("Ver tudo", style: TextStyle(fontSize: 12, color: const Color(0xFF8B5A2B).withOpacity(0.8), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 15),
            
            // Lista Horizontal de Vídeos Recentes
            SizedBox(
              height: 220,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(left: 20),
                children: [
                  _buildVideoCard(context, "Neuroplasticidade", "Aula 1", "https://assets.mixkit.co/videos/preview/mixkit-waves-in-the-water-1164-large.mp4"),
                  _buildVideoCard(context, "Dopamina Detox", "Aula 2", "https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4"),
                  _buildVideoCard(context, "Rotina Matinal", "Extra", "https://assets.mixkit.co/videos/preview/mixkit-stars-in-space-1610-large.mp4"),
                ],
              ),
            ),

            const SizedBox(height: 30),

             // Botão Sair (Discreto no final)
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                icon: const Icon(Icons.logout, color: Colors.grey, size: 18),
                label: const Text("Sair da conta", style: TextStyle(color: Colors.grey)),
              ),
            )
          ],
        ),
      ),
      // Barra de Navegação inferior estilo App
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF8B5A2B),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
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

  // --- WIDGETS DA HOME ---

  Widget _buildHeroBanner(BuildContext context) {
    return Stack(
      children: [
        // --- MUDANÇA 2: SUA IMAGEM DO ASSETS ---
        Container(
          height: 500,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF4A3B32), // Cor de fundo caso a imagem demore
            image: DecorationImage(
              // Aqui trocamos NetworkImage por AssetImage
              image: AssetImage("assets/images/neuroExemploDeAula1.png"), 
              fit: BoxFit.cover,
            ),
          ),
        ),
        // Overlay Escuro (Gradiente Netflix para leitura do texto)
        Container(
          height: 500,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.3),
                Colors.transparent,
                const Color(0xFFF5F2EA).withOpacity(0.1),
                const Color(0xFFF5F2EA), // Funde com a cor de fundo do app no final
              ],
              stops: const [0.0, 0.3, 0.7, 1.0],
            ),
          ),
        ),
        // Conteúdo do Banner
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5A2B),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text("SEMANA 1", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              const SizedBox(height: 15),
              const Text(
                "Neuroplasticidade",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF2A2A2A), // Cor escura para contraste no final do degrade
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Sua mente muda com ações consistentes.\nDescubra como reprogramar seu cérebro.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF555555), fontSize: 14),
              ),
              const SizedBox(height: 25),
              
              // Botões de Ação
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => const VideoDetailScreen(title: "Neuroplasticidade: O Início", videoUrl: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4")));
                    },
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    label: const Text("Continuar", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5A2B),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.add, color: Color(0xFF4A4A4A)),
                    label: const Text("Minha Lista", style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFAAAAAA), width: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              )
            ],
          ),
        )
      ],
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
            const CircularProgressIndicator(
              value: 0.4, // 40%
              color: Color(0xFF8B5A2B),
              backgroundColor: Color(0xFFEEEEEE),
            ),
            const SizedBox(width: 15),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Jornada Mensal", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B5A2B), fontSize: 12)),
                  SizedBox(height: 4),
                  Text("Você concluiu 40% da jornada.", style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
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
          _buildShortcutItem(context, Icons.menu_book_rounded, "Materiais", null),
          _buildShortcutItem(context, FontAwesomeIcons.bullseye, "Desafios", null),
          _buildShortcutItem(context, Icons.people_alt_rounded, "Tribo", null),
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
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: const Color(0xFF8B5A2B).withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: const Color(0xFF8B5A2B), size: 24),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF666666))),
        ],
      ),
    );
  }

  Widget _buildVideoCard(BuildContext context, String title, String subtitle, String videoUrl) {
    return GestureDetector(
      onTap: () {
         Navigator.push(context, MaterialPageRoute(builder: (context) => VideoDetailScreen(title: title, videoUrl: videoUrl)));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              height: 160, // Formato Vertical estilo Netflix Mobile
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF8B5A2B).withOpacity(0.2), // Placeholder
                image: const DecorationImage(
                  // Imagem aleatória abstrata
                  image: NetworkImage("https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=1964&auto=format&fit=crop"),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(child: Icon(Icons.play_circle_outline, color: Colors.white, size: 40)),
            ),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF333333)), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}


// --- TELA DE LISTA DE MÓDULOS (ORGANIZAÇÃO) ---
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
              // Vai para o player com o vídeo selecionado
              Navigator.push(context, MaterialPageRoute(builder: (context) => VideoDetailScreen(
                title: video['title']!, 
                videoUrl: "https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4") // URL Exemplo
              ));
            },
          )).toList(),
        ),
      ),
    );
  }
}


// --- TELA DE DETALHES DO VÍDEO (PLAYER + DESCRIÇÃO + DOWNLOAD) ---
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
            // PLAYER NO TOPO
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

            // CONTEÚDO ABAIXO DO PLAYER
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(widget.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
                    const SizedBox(height: 10),
                    
                    // Ações (Download / Marcar Concluído)
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

                    // Descrição
                    const Text("SOBRE ESTA AULA", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 10),
                    const Text(
                      "Nesta aula, vamos entender os fundamentos biológicos de como o cérebro se adapta a novos estímulos e como você pode usar isso a seu favor.",
                      style: TextStyle(color: Color(0xFF4A4A4A), height: 1.5),
                    ),

                    const SizedBox(height: 20),

                    // Bullet Points
                    const Text("PONTOS CHAVE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 10),
                    _buildBulletPoint("O que define a neuroplasticidade."),
                    _buildBulletPoint("A diferença entre plasticidade funcional e estrutural."),
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