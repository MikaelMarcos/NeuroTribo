import 'package:flutter/material.dart';

class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF8B5A2B)),
        title: const Text("Desafios", style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // CARD DE DESTAQUE
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF8B5A2B), Color(0xFF6D451F)]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Desafio Atual", style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 5),
                const Text("7 Dias de Foco Extremo", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                LinearProgressIndicator(value: 0.3, backgroundColor: Colors.white24, color: Colors.white),
                const SizedBox(height: 8),
                const Text("Dia 2 de 7 concluído", style: TextStyle(color: Colors.white, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text("Disponíveis", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4A4A4A))),
          const SizedBox(height: 15),
          _buildChallengeCard("14 Dias Sem Sabotagem", "Controle emocional", 14, false),
          _buildChallengeCard("30 Dias de Hábitos", "Construção de rotina", 30, true),
          _buildChallengeCard("Ambiente Produtivo", "Organização", 5, false),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(String title, String subtitle, int days, bool locked) {
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
          CircleAvatar(
            backgroundColor: locked ? Colors.grey.shade200 : const Color(0xFFF5F2EA),
            child: Icon(locked ? Icons.lock : Icons.emoji_events, color: locked ? Colors.grey : const Color(0xFF8B5A2B)),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text("$subtitle • $days dias", style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (!locked)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5A2B),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                minimumSize: const Size(0, 30)
              ),
              child: const Text("Iniciar", style: TextStyle(fontSize: 12)),
            )
        ],
      ),
    );
  }
}