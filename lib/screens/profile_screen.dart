import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'support_screen.dart'; // IMPORTANTE: Importe a tela de ajuda
import '../user_data.dart';
import '../services/database_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;
  final DatabaseService _dbService = DatabaseService();

  // Lista de Avatares Seguros
  final List<String> _avatars = [
    "https://cdn-icons-png.flaticon.com/512/4140/4140048.png", // Raposa
    "https://cdn-icons-png.flaticon.com/512/4140/4140037.png", // Coruja
    "https://cdn-icons-png.flaticon.com/512/4140/4140047.png", // Leão
    "https://cdn-icons-png.flaticon.com/512/4140/4140051.png", // Gato
    "https://cdn-icons-png.flaticon.com/512/4140/4140061.png", // Urso
    "https://cdn-icons-png.flaticon.com/512/4322/4322991.png", // Humano 1
    "https://cdn-icons-png.flaticon.com/512/4322/4322992.png", // Humano 2
    "https://cdn-icons-png.flaticon.com/512/924/924915.png",   // Robô
  ];

  Future<void> _refreshUser() async {
    await user?.reload();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  Widget _buildProfileImage(String? url, double radius) {
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFF8B5A2B),
        child: Text(user?.displayName?[0].toUpperCase() ?? "M", style: TextStyle(fontSize: radius * 0.8, color: Colors.white)),
      );
    }
    
    return ClipOval(
      child: Image.network(
        url,
        width: radius * 2,
        height: radius * 2,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: radius * 2,
            height: radius * 2,
            color: const Color(0xFF8B5A2B),
            alignment: Alignment.center,
            child: Text(
              user?.displayName?[0].toUpperCase() ?? "M", 
              style: TextStyle(fontSize: radius * 0.8, color: Colors.white)
            ),
          );
        },
      ),
    );
  }

  void _showAvatarSelectionDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 350,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Text("Escolha seu Avatar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4A4A4A))),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: _avatars.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () async {
                      Navigator.pop(context);
                      await _dbService.updateAvatar(_avatars[index]);
                      await _refreshUser();
                      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Avatar atualizado!")));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: ClipOval(
                        child: Image.network(_avatars[index]),
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showEditNameDialog() {
    final nameController = TextEditingController(text: user?.displayName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Nome"),
        content: TextField(controller: nameController, decoration: const InputDecoration(labelText: "Nome Completo")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancelar")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5A2B)),
            onPressed: () async {
              await user?.updateDisplayName(nameController.text);
              await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({'name': nameController.text});
              await _refreshUser();
              if (mounted) Navigator.pop(context);
            },
            child: const Text("Salvar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.only(top: 60, bottom: 30),
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5))],
                  ),
                  child: Column(
                    children: [
                      // AVATAR COM EDIÇÃO
                      Stack(
                        children: [
                          _buildProfileImage(user?.photoURL, 50),
                          Positioned(
                            bottom: 0, right: 0,
                            child: GestureDetector(
                              onTap: _showAvatarSelectionDialog,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: Color(0xFF8B5A2B), shape: BoxShape.circle),
                                child: const Icon(Icons.edit, color: Colors.white, size: 18),
                              ),
                            ),
                          )
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(user?.displayName ?? "Membro", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
                          IconButton(icon: const Icon(Icons.edit_outlined, size: 18), onPressed: _showEditNameDialog)
                        ],
                      ),
                      Text(user?.email ?? "", style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 10),
                      ValueListenableBuilder<int>(
                        valueListenable: UserData.totalXP,
                        builder: (context, xp, child) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(color: const Color(0xFF8B5A2B).withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                            child: Text("$xp XP", style: const TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.w900, fontSize: 14)),
                          );
                        },
                      ),
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
                if (canPop)
                  Positioned(top: 40, left: 10, child: IconButton(icon: const Icon(Icons.arrow_back, color: Color(0xFF8B5A2B)), onPressed: () => Navigator.pop(context))),
              ],
            ),
            
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Minhas Conquistas", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4A4A4A))),
                  const SizedBox(height: 15),
                  SizedBox(
                    height: 90,
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
                  
                  _menuItem(Icons.settings, "Configurações", () {}),
                  _menuItem(Icons.notifications, "Notificações", () {}),
                  
                  // --- BOTÃO DE AJUDA CONECTADO AQUI ---
                  _menuItem(Icons.help_outline, "Ajuda e Suporte", () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportScreen()));
                  }),
                  
                  const SizedBox(height: 20),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Sair da Conta", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
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
    return Column(children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF8B5A2B))),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
    ]);
  }

  Widget _badge(IconData icon, String label, bool earned) {
    return Container(
      width: 70, margin: const EdgeInsets.only(right: 15),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: earned ? const Color(0xFF8B5A2B).withOpacity(0.1) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: earned ? Colors.transparent : Colors.grey.shade200)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(icon, color: earned ? const Color(0xFF8B5A2B) : Colors.grey.shade300), const SizedBox(height: 5), Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: earned ? const Color(0xFF8B5A2B) : Colors.grey))]),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4A4A4A)), 
        title: Text(title, style: const TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.w500)), 
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap, // Agora o onTap funciona
      ),
    );
  }
}