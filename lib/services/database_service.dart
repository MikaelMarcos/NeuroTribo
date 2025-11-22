import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user_data.dart';

class DatabaseService {
  // Pega o usuário atual
  final User? user = FirebaseAuth.instance.currentUser;

  // Referência para a coleção de usuários
  final CollectionReference usersCollection = 
      FirebaseFirestore.instance.collection('users');

  // 1. Inicializar dados do usuário (Chamar no Login ou Home)
  Future<void> initUserData() async {
    if (user == null) return;

    final docRef = usersCollection.doc(user!.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      // Se é a primeira vez, cria o documento com 0 XP
      await docRef.set({
        'xp': 0,
        'name': user!.displayName,
        'email': user!.email,
        'last_active': DateTime.now(),
      });
      UserData.totalXP.value = 0;
    } else {
      // Se já existe, carrega o XP salvo
      final data = snapshot.data() as Map<String, dynamic>;
      UserData.totalXP.value = data['xp'] ?? 0;
    }
  }

  // 2. Salvar XP na nuvem
  Future<void> updateUserXP(int newXP) async {
    if (user == null) return;
    
    // Atualiza localmente para ser rápido
    UserData.totalXP.value = newXP;

    // Atualiza na nuvem em segundo plano
    await usersCollection.doc(user!.uid).update({
      'xp': newXP,
      'last_active': DateTime.now(),
    });
  }

  // 3. Salvar dia concluído (Para o Heatmap futuro)
  Future<void> completeDay(int xpGained) async {
    if (user == null) return;

    final docRef = usersCollection.doc(user!.uid);
    
    // Pega o XP atual e soma
    final snapshot = await docRef.get();
    int currentXP = (snapshot.data() as Map<String, dynamic>)['xp'] ?? 0;
    int finalXP = currentXP + xpGained;

    await docRef.update({
      'xp': finalXP,
      // Salva um registro que o dia de hoje foi concluído para o histórico
      'activity.${DateTime.now().year}.${DateTime.now().month}.${DateTime.now().day}': true,
    });

    // Atualiza a variável global visual
    UserData.totalXP.value = finalXP;
  }
}