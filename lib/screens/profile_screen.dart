import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import '../user_data.dart'; // Importa o gerenciador de XP

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user = FirebaseAuth.instance.currentUser;

  // Função para recarregar os dados do usuário após edição
  Future<void> _refreshUser() async {
    await user?.reload();
    setState(() {
      user = FirebaseAuth.instance.currentUser;
    });
  }

  // Função para abrir o diálogo de edição
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: user?.displayName);
    final photoController = TextEditingController(text: user?.photoURL);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Editar Perfil"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Nome Completo",
                prefixIcon: Icon(Icons.person, color: Color(0xFF8B5A2B)),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: photoController,
              decoration: const InputDecoration(
                labelText: "URL da Foto",
                hintText: "Cole o link da imagem aqui",
                prefixIcon: Icon(Icons.link, color: Color(0xFF8B5A2B)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5A2B)),
            onPressed: () async {
              try {
                // 1. Atualiza no Firebase Auth (Login)
                await user?.updateDisplayName(nameController.text);
                if (photoController.text.isNotEmpty) {
                  await user?.updatePhotoURL(photoController.text);
                }

                // 2. Atualiza no Banco de Dados (Firestore)
                await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
                  'name': nameController.text,
                  'photoUrl': photoController.text.isNotEmpty ? photoController.text : null,
                });

                // 3. Atualiza a tela
                await _refreshUser();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Perfil atualizado!"), backgroundColor: Colors.green)
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Erro: $e"), backgroundColor: Colors.red)
                );
              }
            },
            child: const Text("Salvar", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Verifica se pode voltar (se veio de outra tela)
    final bool canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                // FUNDO BRANCO DO HEADER
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
                      // AVATAR (Com botão de editar)
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: const Color(0xFF8B5A2B),
                            backgroundImage: user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
                            child: user?.photoURL == null 
                                ? Text(user?.displayName?[0].toUpperCase() ?? "M", style: const TextStyle(fontSize: 40, color: Colors.white))
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _showEditProfileDialog,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF8B5A2B),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, color: Colors.white, size: 18),
                              ),
                            ),
                          )
                        ],
                      ),
                      
                      const SizedBox(height: 15),
                      
                      // NOME E EMAIL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            user?.displayName ?? "Membro NeuroTribo", 
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                            onPressed: _showEditProfileDialog,
                          )
                        ],
                      ),
                      Text(user?.email ?? "", style: const TextStyle(color: Colors.grey)),
                      
                      const SizedBox(height: 10),
                      
                      // XP
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
                      
                      // ESTATÍSTICAS
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
                
                // BOTÃO VOLTAR (SÓ APARECE SE PUDER VOLTAR)
                if (canPop)
                  Positioned(
                    top: 40, left: 10,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF8B5A2B)), 
                      onPressed: () => Navigator.pop(context)
                    ),
                  ),
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
                        _badge(Icons.rocket_launch, "Imparável", false),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  _menuItem(Icons.settings, "Configurações"),
                  _menuItem(Icons.notifications, "Notificações"),
                  _menuItem(Icons.help_outline, "Ajuda e Suporte"),
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
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: earned ? const Color(0xFF8B5A2B).withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: earned ? Colors.transparent : Colors.grey.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: earned ? const Color(0xFF8B5A2B) : Colors.grey.shade300, size: 28),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: earned ? const Color(0xFF8B5A2B) : Colors.grey)),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF4A4A4A)),
        title: Text(title, style: const TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.w500)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}