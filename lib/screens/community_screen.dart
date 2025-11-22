import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago; // AGORA VAI FUNCIONAR
import '../services/database_service.dart';

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
    // Configura o timeago para português
    timeago.setLocaleMessages('pt_BR', timeago.PtBrMessages());
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return "Agora";
    DateTime date;
    if (timestamp is Timestamp) {
      date = timestamp.toDate();
    } else if (timestamp is DateTime) {
      date = timestamp;
    } else {
      return "Agora";
    }
    return timeago.format(date, locale: 'pt_BR');
  }

  void _showCreatePostDialog() {
    final TextEditingController _postController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              controller: _postController,
              maxLines: 4,
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
                onPressed: () async {
                  if (_postController.text.trim().isNotEmpty) {
                    Navigator.pop(context);
                    await _dbService.addPost(_postController.text.trim());
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Post enviado! +5 XP"), backgroundColor: Colors.green));
                    }
                  }
                },
                icon: const Icon(Icons.send, color: Colors.white),
                label: const Text("PUBLICAR", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5A2B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              ),
            )
          ],
        ),
      ),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5A2B)));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 60, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 10),
                  const Text("Ainda não há posts.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
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
                        CircleAvatar(
                          backgroundColor: const Color(0xFF8B5A2B),
                          radius: 20,
                          backgroundImage: data['userPhoto'] != null ? NetworkImage(data['userPhoto']) : null,
                          child: data['userPhoto'] == null ? Text((data['userName'] ?? 'M')[0].toUpperCase(), style: const TextStyle(color: Colors.white)) : null,
                        ),
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
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: () => _dbService.toggleLike(post.id, likes),
                          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, color: isLiked ? Colors.red : Colors.grey, size: 20),
                          label: Text("${likes.length}", style: TextStyle(color: isLiked ? Colors.red : Colors.grey, fontSize: 12)),
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