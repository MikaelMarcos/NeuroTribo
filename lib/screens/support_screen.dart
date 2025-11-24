import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Para abrir WhatsApp/Email

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  // Função para abrir links externos (WhatsApp, Email)
  Future<void> _launchLink(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Não foi possível abrir $url';
      }
    } catch (e) {
      print("Erro ao abrir link: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF8B5A2B)),
        title: const Text("Ajuda e Suporte", style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Como podemos te ajudar?",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
            ),
            const SizedBox(height: 10),
            const Text(
              "Selecione uma opção abaixo ou entre em contato direto com a nossa equipe.",
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
            
            const SizedBox(height: 30),
            
            // BOTÕES DE CONTATO DIRETO
            Row(
              children: [
                Expanded(
                  child: _contactCard(
                    icon: Icons.email_outlined,
                    title: "E-mail",
                    subtitle: "Fale com a gente",
                    onTap: () => _launchLink("mailto:suporte@neurotribo.com?subject=Ajuda NeuroTribo"),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _contactCard(
                    icon: Icons.chat_bubble_outline, // Ícone genérico para WhatsApp
                    title: "WhatsApp",
                    subtitle: "Suporte rápido",
                    // Troque pelo seu link real do WhatsApp (ex: wa.me/5511999999999)
                    onTap: () => _launchLink("https://wa.me/"), 
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text("Perguntas Frequentes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
            const SizedBox(height: 15),

            // FAQ - LISTA DE PERGUNTAS
            _faqTile("Como recuperar minha senha?", "Na tela de login, clique em 'Esqueceu a senha'. Enviaremos um link para o seu e-mail cadastrado."),
            _faqTile("Como funciona o sistema de XP?", "Você ganha XP ao completar desafios diários (1 XP por item) e ao assistir aulas (10 XP por aula)."),
            _faqTile("Posso assistir offline?", "Ainda não. Você precisa de internet para carregar os vídeos e sincronizar seu progresso."),
            _faqTile("Como cancelo minha conta?", "Envie um e-mail para suporte@neurotribo.com solicitando a exclusão dos seus dados."),
            
            const SizedBox(height: 30),
            
            Center(
              child: Text(
                "NeuroTribo v1.0.0",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _contactCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFF5F2EA), shape: BoxShape.circle),
              child: Icon(icon, color: const Color(0xFF8B5A2B), size: 24),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _faqTile(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(question, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF4A4A4A))),
        iconColor: const Color(0xFF8B5A2B),
        collapsedIconColor: Colors.grey,
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(answer, style: const TextStyle(fontSize: 13, color: Color(0xFF666666), height: 1.4)),
        ],
      ),
    );
  }
}