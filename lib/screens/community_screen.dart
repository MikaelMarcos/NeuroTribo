import 'package:flutter/material.dart';

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Color(0xFF8B5A2B)),
        title: const Text("Tribo Neuro", style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF8B5A2B),
        child: const Icon(Icons.edit),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          _buildPost("Rafaelly Psicóloga", "2h atrás", "Pessoal, lancei o novo módulo sobre Dopamina! O segredo não é cortar tudo, é gerenciar. Quem já assistiu?", true),
          _buildPost("Mikael Membro", "5h atrás", "Consegui completar o desafio de 7 dias de foco! A técnica Pomodoro ajudou muito.", false),
          _buildPost("Ana Clara", "1d atrás", "Alguém tem dicas para manter a rotina no fim de semana?", false),
        ],
      ),
    );
  }

  Widget _buildPost(String name, String time, String content, bool isAdmin) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: isAdmin ? const Color(0xFF8B5A2B) : Colors.grey.shade300,
                child: Text(name[0], style: TextStyle(color: isAdmin ? Colors.white : Colors.black)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (isAdmin) const Padding(
                        padding: EdgeInsets.only(left: 5),
                        child: Icon(Icons.verified, size: 14, color: Color(0xFF8B5A2B)),
                      )
                    ],
                  ),
                  Text(time, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(content, style: const TextStyle(color: Color(0xFF4A4A4A), height: 1.4)),
          const SizedBox(height: 15),
          const Row(
            children: [
              Icon(Icons.favorite_border, size: 20, color: Colors.grey),
              SizedBox(width: 5),
              Text("Curtir", style: TextStyle(color: Colors.grey, fontSize: 12)),
              SizedBox(width: 20),
              Icon(Icons.chat_bubble_outline, size: 20, color: Colors.grey),
              SizedBox(width: 5),
              Text("Comentar", style: TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}