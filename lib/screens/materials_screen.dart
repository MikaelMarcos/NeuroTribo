import 'package:flutter/material.dart';

class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F2EA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F2EA),
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF8B5A2B)),
          automaticallyImplyLeading: false, // Remove botão de voltar pois está na tab bar
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
        body: TabBarView(
          children: [
            _buildMaterialList([
              {"title": "Protocolo Anti-Ansiedade", "type": "PDF", "desc": "Passo a passo para crises.", "img": "assets/images/neuroExemploDeAula1.png"},
              {"title": "Checklist de Dopamina", "type": "PDF", "desc": "Identifique seus gatilhos.", "img": "assets/images/neuroExemploDeAula1.png"},
            ]),
            _buildMaterialList([
              {"title": "Ficha de Autoavaliação", "type": "DOC", "desc": "Exercício semanal.", "img": "assets/images/neuroExemploDeAula1.png"},
              {"title": "Treino Cognitivo", "type": "DOC", "desc": "Melhore sua memória.", "img": "assets/images/neuroExemploDeAula1.png"},
            ]),
            _buildMaterialList([
              {"title": "Reprogramação Matinal", "type": "MP3", "desc": "Comece o dia focado.", "img": "assets/images/neuroExemploDeAula1.png"},
              {"title": "Técnica Grounding", "type": "MP3", "desc": "Áudio guiado.", "img": "assets/images/neuroExemploDeAula1.png"},
            ], isAudio: true),
            _buildMaterialList([
              {"title": "Construindo Rotinas", "type": "EBOOK", "desc": "Mini-livro completo.", "img": "assets/images/neuroExemploDeAula1.png"},
              {"title": "Ambiente Produtivo", "type": "EBOOK", "desc": "Design de ambiente.", "img": "assets/images/neuroExemploDeAula1.png"},
            ]),
            _buildMaterialList([
              {"title": "Planner Semanal", "type": "XLS", "desc": "Editável no Excel.", "img": "assets/images/neuroExemploDeAula1.png"},
              {"title": "Planner Financeiro", "type": "XLS", "desc": "Controle de gastos.", "img": "assets/images/neuroExemploDeAula1.png"},
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialList(List<Map<String, String>> items, {bool isAudio = false}) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
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
              // MINIATURA
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: AssetImage(item['img']!), // Placeholder
                    fit: BoxFit.cover,
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                    child: Text(item['type']!, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 15),
              
              // TEXTOS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF333333))),
                    const SizedBox(height: 4),
                    Text(item['desc']!, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 2, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              
              // BOTÕES DE AÇÃO
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite_border, color: Color(0xFF8B5A2B), size: 22),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Adicionado aos favoritos!")));
                    }, 
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.only(bottom: 8),
                  ),
                  IconButton(
                    icon: const Icon(Icons.download_rounded, color: Colors.grey, size: 22),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Iniciando download...")));
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
  }
}