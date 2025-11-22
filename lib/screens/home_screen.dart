import 'dart:async';
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
import '../services/database_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Inicializa o banco de dados ao abrir o app
    DatabaseService().initUserData();
  }

  final List<Widget> _screens = [
    const HomeContent(),      
    const MaterialsScreen(),  
    const ChallengesScreen(), 
    const CommunityScreen(),  
    const ProfileScreen(),    
  ];

  void _onItemTapped(int index) {
    // Removido som de navegação para ficar mais clean
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

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  final User? user = FirebaseAuth.instance.currentUser;
  
  int _currentHeroIndex = 0;
  Timer? _timer;
  List<Map<String, dynamic>> _heroSlides = [
    {
      "image": "assets/images/neuroExemploDeAula1.png",
      "title": "NEUROPLASTICIDADE",
      "desc": "Sua mente muda com ações consistentes.",
      "week": "SEMANA 1"
    }
  ];

  @override
  void initState() {
    super.initState();
    _startHeroTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startHeroTimer() {
    _timer = Timer.periodic(const Duration(seconds: 6), (Timer timer) {
      if (mounted) {
        setState(() {
          _currentHeroIndex = (_currentHeroIndex + 1) % _heroSlides.length;
        });
      }
    });
  }

  ImageProvider _getThumbnailProvider(String videoUrl) {
    if (videoUrl.contains("youtube.com") || videoUrl.contains("youtu.be")) {
      String? videoId;
      final RegExp regExp = RegExp(
        r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*',
        caseSensitive: false,
        multiLine: false,
      );
      final match = regExp.firstMatch(videoUrl);
      if (match != null && match.groupCount >= 7) {
        videoId = match.group(7);
      }

      if (videoId != null) {
        return NetworkImage("https://img.youtube.com/vi/$videoId/hqdefault.jpg");
      }
    }
    return const AssetImage("assets/images/neuroExemploDeAula1.png");
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
        title: Image.asset('assets/images/logo_neurotribo_semfundo.png', height: 45),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
              child: CircleAvatar(
                backgroundColor: const Color(0xFF8B5A2B),
                radius: 18,
                backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                child: user?.photoURL == null ? Text(user?.displayName?[0].toUpperCase() ?? "M", style: const TextStyle(color: Colors.white)) : null,
              ),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DatabaseService().getModulesStream(), 
        builder: (context, snapshotModules) {
          
          if (snapshotModules.hasData && snapshotModules.data!.docs.isNotEmpty) {
            List<Map<String, dynamic>> newSlides = [];
            for (var doc in snapshotModules.data!.docs) {
              var data = doc.data() as Map<String, dynamic>;
              newSlides.add({
                "image": "assets/images/neuroExemploDeAula1.png", 
                "title": (data['title'] as String).toUpperCase(),
                "desc": "Acesse agora o conteúdo exclusivo.",
                "week": "MÓDULO ${data['order'] ?? 1}"
              });
            }
            if (newSlides.length != _heroSlides.length && newSlides.isNotEmpty) {
               _heroSlides = newSlides;
            }
          }

          return StreamBuilder<DocumentSnapshot>(
            stream: DatabaseService().getUserStream(), 
            builder: (context, snapshotUser) {
              
              Map<String, dynamic> userData = {};
              if (snapshotUser.hasData && snapshotUser.data!.exists) {
                userData = snapshotUser.data!.data() as Map<String, dynamic>;
              }
              List completed = userData['completed_videos'] ?? [];
              List history = userData['watch_history'] ?? [];

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDynamicHeroBanner(context),

                    const SizedBox(height: 20),
                    _buildProgressSection(userData),
                    const SizedBox(height: 25),
                    
                    if (history.isNotEmpty) ...[
                      _buildSectionHeader("Continuar Assistindo"),
                      const SizedBox(height: 10),
                      _buildVideoCarousel(history, completed, isHistory: true),
                      const SizedBox(height: 30),
                    ],

                    _buildSectionHeader("Módulos e Aulas"),
                    const SizedBox(height: 15),
                    _buildVideoCarousel([
                      {"title": "Neuroplasticidade", "subtitle": "Aula 1", "url": "https://assets.mixkit.co/videos/preview/mixkit-waves-in-the-water-1164-large.mp4"},
                      {"title": "Dopamina Detox", "subtitle": "Aula 2", "url": "https://assets.mixkit.co/videos/preview/mixkit-tree-with-yellow-flowers-1173-large.mp4"},
                    ], completed, isHistory: false),
                    
                    const SizedBox(height: 30),
                  ],
                ),
              );
            }
          );
        }
      ),
    );
  }

  Widget _buildDynamicHeroBanner(BuildContext context) {
    var slide = _heroSlides[_currentHeroIndex];

    return SizedBox(
      height: 500,
      child: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 800),
            child: Container(
              key: ValueKey<int>(_currentHeroIndex), 
              decoration: BoxDecoration(
                color: const Color(0xFF4A3B32),
                image: DecorationImage(
                  image: AssetImage(slide['image']), 
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.2),
                  Colors.black.withOpacity(0.9), 
                  const Color(0xFFF5F2EA),
                ],
                stops: const [0.4, 0.6, 0.9, 1.0],
              ),
            ),
          ),
          Positioned(
            bottom: 20, left: 20, right: 20,
            child: Column(
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Container(
                    key: ValueKey<String>(slide['week']),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFF8B5A2B), borderRadius: BorderRadius.circular(4)),
                    child: Text(slide['week'], style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1)),
                  ),
                ),
                const SizedBox(height: 15),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: Text(
                    slide['title'],
                    key: ValueKey<String>(slide['title']),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, shadows: [Shadow(color: Colors.black, blurRadius: 20, offset: Offset(0, 4))]),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  slide['desc'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
                ),
                const SizedBox(height: 25),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                         Navigator.push(context, MaterialPageRoute(builder: (context) => const ModulesListScreen()));
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.white),
                      label: const Text("Assistir", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5A2B), padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                    ),
                    const SizedBox(width: 15),
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Adicionado à Minha Lista!")));
                      },
                      icon: const Icon(Icons.add, color: Colors.white),
                      label: const Text("Minha Lista", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white, width: 2), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), backgroundColor: Colors.black26),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _heroSlides.asMap().entries.map((entry) {
                    return Container(
                      width: 8.0, height: 8.0,
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _currentHeroIndex == entry.key ? const Color(0xFF8B5A2B) : Colors.white.withOpacity(0.4),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProgressSection(Map<String, dynamic> userData) {
    int currentXP = userData['xp'] ?? 0;
    double progress = (currentXP % 1000) / 1000.0; 
    if (progress == 0 && currentXP > 0) progress = 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(width: 50, height: 50, child: CircularProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, color: const Color(0xFF8B5A2B), strokeWidth: 5)),
                Text("${(progress * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF8B5A2B))),
              ],
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Nível Atual", style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text("$currentXP XP Totais", style: const TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold, fontSize: 15)),
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

  Widget _buildVideoCarousel(List items, List completedList, {bool isHistory = false}) {
    // Altura aumentada para evitar overflow dos textos
    return SizedBox(
      height: 280, 
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: items.length,
        itemBuilder: (context, index) {
          var item = items[index];
          String title = item['title'] ?? 'Aula';
          String subtitle = isHistory ? 'Continue assistindo' : (item['subtitle'] ?? 'Aula');
          String url = item['url'] ?? '';
          
          return _videoCard(context, title, subtitle, url, completedList.contains(url));
        },
      ),
    );
  }

  Widget _videoCard(BuildContext context, String title, String subtitle, String url, bool isCompleted) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => VideoDetailScreen(title: title, videoUrl: url)));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      // Usa a capa do YouTube se for link do YouTube
                      image: _getThumbnailProvider(url),
                      fit: BoxFit.cover,
                    ),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 4))],
                  ),
                  child: Container(
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, colors: [Colors.black.withOpacity(0.6), Colors.transparent])),
                    child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white70, size: 40)),
                  ),
                ),
                if (isCompleted)
                  Positioned(
                    top: 8, right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                      child: const Icon(Icons.check, size: 12, color: Colors.white),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 10),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF333333), height: 1.2)),
            const SizedBox(height: 4),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF888888))),
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
        stream: DatabaseService().getModulesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5A2B)));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Nenhum módulo encontrado.", style: TextStyle(color: Colors.grey)));
          }

          final modules = snapshot.data!.docs;

          return StreamBuilder<DocumentSnapshot>(
            stream: DatabaseService().getUserStream(),
            builder: (context, userSnapshot) {
              List completed = [];
              if (userSnapshot.hasData && userSnapshot.data!.exists) {
                completed = (userSnapshot.data!.data() as Map<String, dynamic>)['completed_videos'] ?? [];
              }

              return ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: modules.length,
                itemBuilder: (context, index) {
                  final moduleData = modules[index].data() as Map<String, dynamic>;
                  return _buildModuleTile(context, moduleData['title'] ?? 'Módulo', moduleData['lessons'] as List<dynamic>? ?? [], completed);
                },
              );
            }
          );
        },
      ),
    );
  }

  Widget _buildModuleTile(BuildContext context, String title, List<dynamic> lessons, List completedList) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
          iconColor: const Color(0xFF8B5A2B),
          collapsedIconColor: Colors.grey,
          children: lessons.map((lesson) {
            final lessonMap = lesson as Map<String, dynamic>;
            bool isDone = completedList.contains(lessonMap['videoUrl']);
            return ListTile(
              contentPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: isDone ? Colors.green.withOpacity(0.1) : const Color(0xFFF5F2EA), borderRadius: BorderRadius.circular(8)),
                child: Icon(isDone ? Icons.check : Icons.play_arrow, color: isDone ? Colors.green : const Color(0xFF8B5A2B), size: 20),
              ),
              title: Text(lessonMap['title'] ?? 'Aula', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, decoration: isDone ? TextDecoration.lineThrough : null, color: isDone ? Colors.grey : Colors.black)),
              subtitle: Text(lessonMap['duration'] ?? '0 min', style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

// --- TELA DE DETALHES DO VÍDEO (DESIGN PLATAFORMA DE CURSOS) ---
class VideoDetailScreen extends StatefulWidget {
  final String title;
  final String videoUrl;
  final String description;

  const VideoDetailScreen({super.key, required this.title, required this.videoUrl, this.description = "Assista a esta aula incrível."});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;
  YoutubePlayerController? _youtubeController;
  bool isYoutube = false;
  
  bool isCompleted = false;
  bool isFavorite = false;
  final DatabaseService _dbService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    _checkStatus();
    // Salva no histórico
    _dbService.addToHistory(widget.videoUrl, widget.title, "Continuar assistindo");
  }

  Future<void> _checkStatus() async {
    final snapshot = await _dbService.getUserStream().first;
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      List completedList = data['completed_videos'] ?? [];
      List favList = data['favorite_videos'] ?? [];
      if (mounted) {
        setState(() {
          isCompleted = completedList.contains(widget.videoUrl);
          isFavorite = favList.contains(widget.videoUrl);
        });
      }
    }
  }

  Future<void> _initializePlayer() async {
    if (widget.videoUrl.contains("youtube.com") || widget.videoUrl.contains("youtu.be")) {
      setState(() => isYoutube = true);
      String? videoId = _getYoutubeId(widget.videoUrl);
      if (videoId != null) {
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: videoId, 
          autoPlay: true, 
          params: const YoutubePlayerParams(
            showControls: true, 
            showFullscreenButton: true,
            enableCaption: false,
          ),
        );
      }
    } else {
      setState(() => isYoutube = false);
      try {
        _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl));
        await _videoPlayerController!.initialize();
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!, 
          autoPlay: true, 
          aspectRatio: 16/9, 
          materialProgressColors: ChewieProgressColors(
            playedColor: const Color(0xFF8B5A2B), 
            handleColor: const Color(0xFF8B5A2B), 
            backgroundColor: Colors.grey, 
            bufferedColor: Colors.white30
          ),
          placeholder: Container(
            color: Colors.black,
            child: const Center(child: CircularProgressIndicator(color: Color(0xFF8B5A2B))),
          ),
          autoInitialize: true,
        );
        setState(() {});
      } catch (e) { 
        print("Erro ao carregar vídeo: $e");
      }
    }
  }

  String? _getYoutubeId(String url) {
    final RegExp regExp = RegExp(r'^.*((youtu.be\/)|(v\/)|(\/u\/\w\/)|(embed\/)|(watch\?))\??v?=?([^#&?]*).*', caseSensitive: false, multiLine: false);
    final match = regExp.firstMatch(url);
    return (match != null && match.groupCount >= 7) ? match.group(7) : null;
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
          children: [
            // 1. PLAYER FIXO NO TOPO (16:9)
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Container(
                    color: Colors.black,
                    child: Center(
                      child: isYoutube
                          ? (_youtubeController != null 
                              ? YoutubePlayer(controller: _youtubeController!, aspectRatio: 16/9)
                              : const CircularProgressIndicator(color: Color(0xFF8B5A2B)))
                          : (_chewieController != null && _videoPlayerController != null && _videoPlayerController!.value.isInitialized 
                              ? Chewie(controller: _chewieController!)
                              : const CircularProgressIndicator(color: Color(0xFF8B5A2B))),
                    ),
                  ),
                ),
                Positioned(
                  top: 10, left: 10,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
                      child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            
            // 2. CONTEÚDO ROLÁVEL
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    Text(
                      widget.title, 
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF2D2D2D), height: 1.3)
                    ),
                    const SizedBox(height: 24),
                    
                    // Botões Grandes
                    Row(
                      children: [
                        // Botão Favorito (Outline)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              SoundManager.playClick();
                              if (isFavorite) {
                                await _dbService.removeFromFavorites(widget.videoUrl);
                              } else {
                                await _dbService.addToFavorites(widget.videoUrl);
                              }
                              setState(() => isFavorite = !isFavorite);
                            },
                            icon: Icon(
                              isFavorite ? Icons.favorite : Icons.favorite_border, 
                              color: isFavorite ? const Color(0xFFE57373) : const Color(0xFF8B5A2B)
                            ),
                            label: Text(
                              isFavorite ? "Favorito" : "Favoritar", 
                              style: TextStyle(
                                color: isFavorite ? const Color(0xFFE57373) : const Color(0xFF8B5A2B), 
                                fontWeight: FontWeight.bold
                              )
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              elevation: 2,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), 
                                side: BorderSide(color: isFavorite ? const Color(0xFFE57373).withOpacity(0.5) : const Color(0xFF8B5A2B))
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 15),
                        
                        // Botão Marcar Visto (Filled)
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              SoundManager.playSuccess();
                              bool newState = !isCompleted;
                              setState(() => isCompleted = newState);
                              await _dbService.toggleVideoCompletion(widget.videoUrl, newState);
                              if (newState) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Aula concluída! +10 XP"), backgroundColor: Colors.green));
                            },
                            icon: Icon(isCompleted ? Icons.check_circle : Icons.check_circle_outline, color: Colors.white),
                            label: Text(
                              isCompleted ? "Concluído" : "Marcar Visto", 
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isCompleted ? Colors.green[600] : const Color(0xFF8B5A2B),
                              elevation: 4,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 30),
                    Divider(color: Colors.grey.withOpacity(0.2), thickness: 1),
                    const SizedBox(height: 20),
                    
                    const Text("SOBRE ESTA AULA", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.0, color: Color(0xFF9E9E9E))),
                    const SizedBox(height: 12),
                    Text(widget.description, style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF555555))),
                    
                    const SizedBox(height: 30),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.lightbulb_outline, color: Color(0xFF8B5A2B), size: 20),
                              SizedBox(width: 8),
                              Text("PONTOS CHAVE", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF8B5A2B))),
                            ],
                          ),
                          const SizedBox(height: 15),
                          _buildBulletPoint("Assista com atenção plena."),
                          _buildBulletPoint("Faça anotações dos insights."),
                          _buildBulletPoint("Pratique o exercício proposto."),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),
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
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6.0),
            child: Icon(Icons.circle, size: 6, color: Color(0xFF8B5A2B)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(color: Color(0xFF4A4A4A), height: 1.4))),
        ],
      ),
    );
  }
}