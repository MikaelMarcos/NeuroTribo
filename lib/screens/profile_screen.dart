import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 60, bottom: 30),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: const Color(0xFF8B5A2B),
                    child: Text(user?.displayName?[0].toUpperCase() ?? "M", style: const TextStyle(fontSize: 40, color: Colors.white)),
                  ),
                  const SizedBox(height: 15),
                  Text(user?.displayName ?? "Membro NeuroTribo", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(user?.email ?? "", style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _stat("12", "Dias seguidos"),
                      Container(height: 30, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 20)),
                      _stat("4", "Módulos"),
                      Container(height: 30, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 20)),
                      _stat("8", "Conquistas"),
                    ],
                  )
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Minhas Conquistas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _badge(Icons.bolt, "Iniciante", true),
                        _badge(Icons.timer, "Focado", true),
                        _badge(Icons.book, "Leitor", false),
                        _badge(Icons.star, "VIP", false),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  _menuItem(Icons.settings, "Configurações"),
                  _menuItem(Icons.help_outline, "Ajuda e Suporte"),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Sair da Conta", style: TextStyle(color: Colors.red)),
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
                      if (context.mounted) {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
                      }
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF8B5A2B))),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _badge(IconData icon, String label, bool earned) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        color: earned ? const Color(0xFF8B5A2B).withOpacity(0.1) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: earned ? const Color(0xFF8B5A2B) : Colors.grey),
          const SizedBox(height: 5),
          Text(label, style: TextStyle(fontSize: 10, color: earned ? const Color(0xFF8B5A2B) : Colors.grey)),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4A4A4A)),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: () {},
    );
  }
}