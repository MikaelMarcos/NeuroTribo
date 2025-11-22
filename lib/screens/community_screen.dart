import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/database_service.dart';
import '../sound_manager.dart'; // Importe os sons

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final DatabaseService _dbService = DatabaseService();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Agora";
    DateTime date = (timestamp is Timestamp) ? timestamp.toDate() : DateTime.now();
    return timeago.format(date, locale: 'pt_BR');
  }

  Widget _buildAvatar(String? url, String name) {
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        backgroundColor: const Color(0xFF8B5A2B),
        child: Text(name[0].toUpperCase(), style: const TextStyle(color: Colors.white)),
      );
    }
    return CircleAvatar(
      backgroundColor: const Color(0xFF8B5A2B),
      backgroundImage: NetworkImage(url),
      onBackgroundImageError: (exception, stackTrace) {},
      child: null,
    );
  }

  void _showCreatePostDialog() {
    final TextEditingController postController = TextEditingController();
    bool isPosting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                top: 20, left: 20, right: 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Compartilhe com a Tribo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4A4A4A))),
                  const SizedBox(height: 15),
                  TextField(
                    controller: postController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: "Como está sendo sua jornada hoje?",
                      filled: true,
                      fillColor: const Color(0xFFF5F2EA),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: isPosting ? null : () async {
                        if (postController.text.trim().isNotEmpty) {
                          setModalState(() => isPosting = true);
                          try {
                            await _dbService.addPost(postController.text.trim());
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post enviado! +5 XP"), backgroundColor: Colors.green));
                            }
                          } catch (e) {
                            setModalState(() => isPosting = false);
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
                            }
                          }
                        }
                      },
                      icon: isPosting 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white)) 
                        : const Icon(Icons.send, color: Colors.white),
                      label: Text(isPosting ? "ENVIANDO..." : "PUBLICAR", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5A2B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                  )
                ],
              ),
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF8B5A2B)),
        automaticallyImplyLeading: false,
        title: const Text("Tribo Neuro", style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostDialog,
        backgroundColor: const Color(0xFF8B5A2B),
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text("Escrever", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _dbService.getPostsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5A2B)));
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey.withOpacity(0.5)), const SizedBox(height: 10), const Text("Ainda não há posts.", style: TextStyle(color: Colors.grey))]));
          }

          final posts = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final data = post.data() as Map<String, dynamic>;
              final List<dynamic> likes = data['likes'] ?? [];
              final bool isLiked = likes.contains(currentUser?.uid);

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildAvatar(data['userPhoto'], data['userName'] ?? 'M'),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['userName'] ?? 'Membro', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text(_formatTimestamp(data['timestamp']), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(data['content'] ?? '', style: const TextStyle(color: Color(0xFF333333), height: 1.4, fontSize: 14)),
                    const SizedBox(height: 15),
                    const Divider(height: 1),
                    
                    // BOTÕES DE AÇÃO
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () {
                            // SOM E AÇÃO DE LIKE
                            SoundManager.playClick(); 
                            _dbService.toggleLike(post.id, likes);
                          },
                          // ÍCONE E COR MUDAM SE TIVER LIKE
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border, 
                            color: isLiked ? Colors.red : Colors.grey, 
                            size: 20
                          ),
                          label: Text(
                            "${likes.length}", 
                            style: TextStyle(color: isLiked ? Colors.red : Colors.grey, fontSize: 12)
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}