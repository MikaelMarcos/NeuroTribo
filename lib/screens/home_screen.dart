import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
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

  final List<Widget> _screens = [
    const HomeContent(),
    const MaterialsScreen(),
    const ChallengesScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    SoundManager.playClick();
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
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
          type: BottomNavigationBarType.fixed,
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
            _buildVideoCarousel(context),
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
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const ModulesListScreen()));
                  }, 
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

  Widget _buildVideoCarousel(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        children: [
          _videoCard(context, "Neuroplasticidade", "Aula 1", "https://assets.mixkit.co/videos/preview/mixkit-waves-in-the-water-1164-large.mp4"),
          _videoCard(context, "Dopamina Detox", "Aula 2", "https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4"),
          _videoCard(context, "Rotina Matinal", "Extra", "https://assets.mixkit.co/videos/preview/mixkit-stars-in-space-1610-large.mp4"),
        ],
      ),
    );
  }

  Widget _videoCard(BuildContext context, String title, String subtitle, String url) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => VideoDetailScreen(title: title, videoUrl: url)
        ));
      },
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('modules').orderBy('order').snapshots(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5A2B)));
          }

          if (snapshot.hasError) {
            return Center(child: Text("Erro ao carregar: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 50, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Nenhum módulo encontrado.", style: TextStyle(color: Colors.grey)),
                  Text("Adicione 'modules' no Firestore.", style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            );
          }

          final modules = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final moduleData = modules[index].data() as Map<String, dynamic>;
              final title = moduleData['title'] ?? 'Módulo sem título';
              final lessons = moduleData['lessons'] as List<dynamic>? ?? [];

              return _buildModuleTile(context, title, lessons);
            },
          );
        },
      ),
    );
  }

  Widget _buildModuleTile(BuildContext context, String title, List<dynamic> lessons) {
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
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
          iconColor: const Color(0xFF8B5A2B),
          collapsedIconColor: Colors.grey,
          children: lessons.map((lesson) {
            final lessonMap = lesson as Map<String, dynamic>;
            return ListTile(
              contentPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: const Color(0xFFF5F2EA), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.play_arrow, color: Color(0xFF8B5A2B), size: 20),
              ),
              title: Text(lessonMap['title'] ?? 'Aula', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              subtitle: Text(lessonMap['duration'] ?? '0 min', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              trailing: const Icon(Icons.check_circle_outline, color: Colors.grey, size: 20),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => VideoDetailScreen(
                  title: lessonMap['title'] ?? 'Aula', 
                  videoUrl: lessonMap['videoUrl'] ?? "",
                  description: lessonMap['description'] ?? "Sem descrição.",
                )));
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class VideoDetailScreen extends StatefulWidget {
  final String title;
  final String videoUrl;
  final String description;

  const VideoDetailScreen({
    super.key, 
    required this.title, 
    required this.videoUrl,
    this.description = "Assista a esta aula incrível para expandir seus conhecimentos.",
  });

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;

  bool isYoutube = false;
  bool isDone = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    if (widget.videoUrl.contains("youtube.com") || widget.videoUrl.contains("youtu.be")) {
      setState(() {
        isYoutube = true;
      });

      String? videoId = _getYoutubeId(widget.videoUrl);

      if (videoId != null) {
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: true,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
          ),
        );
      }
    } else {
      setState(() {
        isYoutube = false;
      });
      
      try {
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
        await _videoPlayerController!.initialize();

        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
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
      } catch (e) {
        print("Erro MP4: $e");
      }
    }
  }

  String? _getYoutubeId(String url) {
    final RegExp regExp = RegExp(
      r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*',
      caseSensitive: false,
      multiLine: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 7) {
      return match.group(7);
    }
    return null;
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    _youtubeController?.close();
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
                    child: isYoutube
                        ? (_youtubeController != null
                            ? YoutubePlayer(controller: _youtubeController!)
                            : const CircularProgressIndicator(color: Color(0xFF8B5A2B)))
                        : (_chewieController != null && _videoPlayerController != null && _videoPlayerController!.value.isInitialized
                            ? Chewie(controller: _chewieController!)
                            : const CircularProgressIndicator(color: Color(0xFF8B5A2B))),
                  ),
                  Positioned(
                    top: 10, left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white, shadows: [Shadow(blurRadius: 10, color: Colors.black)]),
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
                    
                    Text(
                      widget.description,
                      style: const TextStyle(color: Color(0xFF4A4A4A), height: 1.5),
                    ),
                    
                    const SizedBox(height: 20),
                    const Text("PONTOS CHAVE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                    const SizedBox(height: 10),
                    _buildBulletPoint("Assista com atenção."),
                    _buildBulletPoint("Faça anotações."),
                    _buildBulletPoint("Pratique o que aprendeu."),
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