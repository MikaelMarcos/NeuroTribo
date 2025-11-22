import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../user_data.dart';
import '../sound_manager.dart';
import '../services/database_service.dart'; // Importe o serviço

// --- TELA DE LISTA DE DESAFIOS ---
class ChallengesScreen extends StatelessWidget {
  const ChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        iconTheme: const IconThemeData(color: Color(0xFF8B5A2B)),
        title: const Text("Desafios", style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold)),
        actions: [
          // MOSTRA O XP TOTAL NO TOPO DA TELA
          ValueListenableBuilder(
            valueListenable: UserData.totalXP, 
            builder: (context, value, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5A2B).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12)
                    ),
                    child: Text("$value XP", style: const TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.w900)),
                  ),
                ),
              );
            }
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // CARD DE DESTAQUE
          GestureDetector(
            onTap: () {
              SoundManager.playClick();
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const ChallengeDetailScreen(title: "7 Dias de Foco Extremo")
              ));
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5A2B), Color(0xFF6D451F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF8B5A2B).withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("DESAFIO ATUAL", style: TextStyle(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
                        child: const Text("Dia 2/7", style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text("7 Dias de Foco Extremo", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  const Text("Elimine distrações e dobre sua produtividade.", style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(value: 0.3, backgroundColor: Colors.white24, color: Colors.white, minHeight: 6, borderRadius: BorderRadius.circular(10)),
                  const SizedBox(height: 8),
                  const Text("Ganhe +1 XP por tarefa concluída", style: TextStyle(color: Colors.yellowAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 30),
          const Text("Disponíveis para Iniciar", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4A4A4A))),
          const SizedBox(height: 15),
          
          _buildChallengeCard(context, "14 Dias Sem Sabotagem", "Controle emocional", 14, false),
          _buildChallengeCard(context, "30 Dias de Hábitos", "Construção de rotina", 30, true),
          _buildChallengeCard(context, "Ambiente Produtivo", "Organização", 5, false),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(BuildContext context, String title, String subtitle, int days, bool locked) {
    return GestureDetector(
      onTap: locked ? null : () {
        SoundManager.playClick();
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => ChallengeDetailScreen(title: title)
        ));
      },
      child: Container(
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
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: locked ? Colors.grey : const Color(0xFF333333))),
                  Text("$subtitle • $days dias", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
            if (!locked)
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF8B5A2B))
          ],
        ),
      ),
    );
  }
}

// --- TELA DE DETALHE DO DESAFIO ---
class ChallengeDetailScreen extends StatefulWidget {
  final String title;
  const ChallengeDetailScreen({super.key, required this.title});

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  List<Map<String, dynamic>> dailyTasks = [
    {"title": "Meditação de 10min", "done": false},
    {"title": "Beber 2L de água", "done": false},
    {"title": "Ler 10 páginas", "done": false},
    {"title": "Sem redes sociais pela manhã", "done": false},
    {"title": "Dormir antes das 23h", "done": false},
  ];

  // Calcula quantos checks foram marcados
  int get xpToCollect => dailyTasks.where((t) => t['done']).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF8B5A2B)),
        title: Text(widget.title, style: const TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEATMAP
            const Text("Sua Consistência", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF4A4A4A))),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_getMonthName(DateTime.now().month), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey)),
                      const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 15),
                  _buildGithubHeatmap(),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // CHECKLIST DO DIA
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tarefas de Hoje", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF4A4A4A))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: const Color(0xFF8B5A2B).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text("XP a recolher: +$xpToCollect", style: const TextStyle(color: Color(0xFF8B5A2B), fontWeight: FontWeight.bold)),
                )
              ],
            ),
            const SizedBox(height: 15),
            
            ...dailyTasks.map((task) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: task['done'] ? const Color(0xFF8B5A2B) : Colors.transparent, width: 1.5),
                ),
                child: CheckboxListTile(
                  activeColor: const Color(0xFF8B5A2B),
                  value: task['done'],
                  title: Text(
                    task['title'], 
                    style: TextStyle(
                      decoration: task['done'] ? TextDecoration.lineThrough : null,
                      color: task['done'] ? const Color(0xFF8B5A2B) : const Color(0xFF4A4A4A),
                      fontWeight: task['done'] ? FontWeight.bold : FontWeight.normal
                    )
                  ),
                  onChanged: (bool? value) {
                    if (value == true) {
                      SoundManager.playCheck(); // SOM DE CHECK!
                    } else {
                      SoundManager.playClick(); // Som suave ao desmarcar
                    }
                    setState(() {
                      task['done'] = value!;
                    });
                  },
                ),
              );
            }).toList(),

            const SizedBox(height: 20),
            
            // BOTÃO CONCLUIR DIA (COM SOMA DE XP E SOM DE VITÓRIA)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  // 1. Toca o som
                  SoundManager.playSuccess(); 
                  
                  // 2. Salva no Firebase e Atualiza XP local
                  await DatabaseService().completeDay(xpToCollect);

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Dia salvo! +$xpToCollect XP garantidos na nuvem!"), 
                        backgroundColor: Colors.green
                      )
                    );
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5A2B),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("CONCLUIR DIA", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildGithubHeatmap() {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    
    final List<int> activityData = List.generate(daysInMonth, (index) {
      return (index % 3 == 0) ? 2 : (index % 4 == 0) ? 0 : 1;
    });

    return Center(
      child: SizedBox(
        width: 240, 
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: daysInMonth,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: 4,
            mainAxisSpacing: 4,
            childAspectRatio: 1.0,
          ),
          itemBuilder: (context, index) {
            int level = activityData[index];
            Color color;
            if (level == 0) color = Colors.grey.shade200;
            else if (level == 1) color = const Color(0xFFD7CCC8);
            else color = const Color(0xFF8B5A2B);

            bool isToday = (index + 1) == now.day;

            return Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
                border: isToday ? Border.all(color: Colors.black54, width: 2) : null,
              ),
              child: Center(
                child: Text(
                  "${index + 1}",
                  style: TextStyle(fontSize: 8, color: level == 2 ? Colors.white : Colors.black38, fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"];
    return months[month - 1];
  }
}