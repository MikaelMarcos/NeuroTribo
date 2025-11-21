import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F2EA),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F2EA),
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFF8B5A2B)),
          title: const Text("Biblioteca", style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            labelColor: Color(0xFF8B5A2B),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF8B5A2B),
            tabs: [
              Tab(text: "Guias & PDFs"),
              Tab(text: "Áudios"),
              Tab(text: "Templates"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList([
              {"title": "Protocolo Anti-Ansiedade", "type": "PDF", "desc": "Guia prático de 5 passos."},
              {"title": "Neuroplasticidade Aplicada", "type": "E-BOOK", "desc": "Conceitos fundamentais."},
              {"title": "Checklist de Dopamina", "type": "PDF", "desc": "Identifique seus gatilhos."},
            ]),
            _buildList([
              {"title": "Reprogramação Matinal", "type": "MP3", "desc": "Áudio de 10min para foco."},
              {"title": "Técnica Grounding 5-4-3-2-1", "type": "MP3", "desc": "Para crises de ansiedade."},
            ], isAudio: true),
            _buildList([
              {"title": "Planner Semanal NeuroTribo", "type": "XLSX", "desc": "Editável no Excel/Sheets."},
              {"title": "Rastreador de Hábitos", "type": "PDF", "desc": "Imprima e cole na parede."},
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<Map<String, String>> items, {bool isAudio = false}) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5A2B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isAudio ? Icons.headphones : Icons.description, 
                  color: const Color(0xFF8B5A2B)
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text(item['desc']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.download_rounded, color: Colors.grey),
                onPressed: () {}, // Lógica de download futura
              )
            ],
          ),
        );
      },
    );
  }
}