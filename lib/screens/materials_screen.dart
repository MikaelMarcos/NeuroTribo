import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; 
import '../sound_manager.dart'; // Importe os sons

class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  Future<void> _launchDownload(BuildContext context, String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link indisponível.")));
      return;
    }
    
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Não foi possível abrir $url';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro ao abrir: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F2EA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F2EA),
          elevation: 0,
          automaticallyImplyLeading: false,
          iconTheme: const IconThemeData(color: Color(0xFF8B5A2B)),
          title: const Text("Biblioteca", style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            isScrollable: true,
            labelColor: Color(0xFF8B5A2B),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF8B5A2B),
            tabs: [
              Tab(text: "Guias & PDFs"),
              Tab(text: "Exercícios"),
              Tab(text: "Áudios"),
              Tab(text: "E-books"),
              Tab(text: "Templates"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            MaterialsList(category: "Guias & PDFs"),
            MaterialsList(category: "Exercícios"),
            MaterialsList(category: "Áudios"),
            MaterialsList(category: "E-books"),
            MaterialsList(category: "Templates"),
          ],
        ),
      ),
    );
  }
}

class MaterialsList extends StatelessWidget {
  final String category;

  const MaterialsList({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('materials')
          .where('category', isEqualTo: category) 
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5A2B)));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_off_outlined, size: 40, color: Colors.grey.withOpacity(0.5)),
                const SizedBox(height: 10),
                Text("Nenhum material em '$category'", style: const TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        final materials = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: materials.length,
          itemBuilder: (context, index) {
            final data = materials[index].data() as Map<String, dynamic>;
            final bool isAudio = data['type'] == 'MP3' || data['type'] == 'AUDIO';

            return Container(
              margin: const EdgeInsets.only(bottom: 15),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F2EA),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        _getIconForType(data['type'] ?? 'DOC'),
                        color: const Color(0xFF8B5A2B),
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 15),
                  
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data['title'] ?? 'Sem título', 
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF333333))
                        ),
                        const SizedBox(height: 4),
                        Text(
                          data['description'] ?? '', 
                          style: const TextStyle(color: Colors.grey, fontSize: 12), 
                          maxLines: 2, 
                          overflow: TextOverflow.ellipsis
                        ),
                      ],
                    ),
                  ),
                  
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.favorite_border, color: Color(0xFF8B5A2B), size: 22),
                        onPressed: () {
                          SoundManager.playClick(); // Som ao favoritar
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Em breve: Favoritos!")));
                        }, 
                        constraints: const BoxConstraints(),
                        padding: const EdgeInsets.only(bottom: 8),
                      ),
                      IconButton(
                        icon: Icon(
                          isAudio ? Icons.play_circle_outline : Icons.download_rounded, 
                          color: Colors.grey, 
                          size: 22
                        ),
                        onPressed: () {
                          // SOM NO DOWNLOAD:
                          SoundManager.playClick(); 
                          
                          // Lógica para abrir o link
                          _launchUrl(context, data['url'] ?? '');
                        },
                        constraints: const BoxConstraints(),
                        padding: EdgeInsets.zero,
                      )
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link não configurado.")));
      return;
    }
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Erro';
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Não foi possível abrir o link.")));
    }
  }

  IconData _getIconForType(String type) {
    switch (type.toUpperCase()) {
      case 'PDF': return Icons.picture_as_pdf;
      case 'AUDIO': 
      case 'MP3': return Icons.headphones;
      case 'XLS': 
      case 'TEMPLATE': return Icons.table_chart;
      case 'EBOOK': return Icons.book;
      default: return Icons.description;
    }
  }
}