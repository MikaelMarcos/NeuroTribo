import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user_data.dart';

class DatabaseService {
  final User? user = FirebaseAuth.instance.currentUser;
  static const String adminEmail = "rafaelly@neurotribo.com"; 

  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');
  final CollectionReference modulesCollection = FirebaseFirestore.instance.collection('modules');

  // --- 1. USUÁRIO & PERFIL ---

  Future<void> initUserData() async {
    if (user == null) return;
    final docRef = usersCollection.doc(user!.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      await docRef.set({
        'xp': 0,
        'name': user!.displayName ?? 'Membro',
        'email': user!.email,
        'photoUrl': user!.photoURL,
        'last_active': DateTime.now(),
        'completed_videos': [],
        'favorite_videos': [],
        'watch_history': [],
      });
      UserData.totalXP.value = 0;
    } else {
      final data = snapshot.data() as Map<String, dynamic>;
      UserData.totalXP.value = data['xp'] ?? 0;
    }
  }

  // --- 2. VÍDEOS E PROGRESSO (CORRIGIDO) ---

  Future<void> toggleVideoCompletion(String videoUrl, bool isCompleted) async {
    if (user == null) return;
    final docRef = usersCollection.doc(user!.uid);

    if (isCompleted) {
      await docRef.update({
        'completed_videos': FieldValue.arrayUnion([videoUrl]),
        'xp': FieldValue.increment(10) 
      });
      UserData.addXP(10);
    } else {
      await docRef.update({
        'completed_videos': FieldValue.arrayRemove([videoUrl]),
        'xp': FieldValue.increment(-10)
      });
      UserData.addXP(-10);
    }
  }

  Future<void> addToFavorites(String videoUrl) async {
    if (user == null) return;
    await usersCollection.doc(user!.uid).update({
      'favorite_videos': FieldValue.arrayUnion([videoUrl])
    });
  }

  Future<void> removeFromFavorites(String videoUrl) async {
    if (user == null) return;
    await usersCollection.doc(user!.uid).update({
      'favorite_videos': FieldValue.arrayRemove([videoUrl])
    });
  }

  // CORREÇÃO: Lógica inteligente de Histórico
  // Agora ele baixa a lista, remove duplicatas e salva a lista limpa.
  Future<void> addToHistory(String videoUrl, String title, String subtitle) async {
    if (user == null) return;
    
    final docRef = usersCollection.doc(user!.uid);
    
    try {
      // 1. Ler o histórico atual
      final snapshot = await docRef.get();
      if (!snapshot.exists) return;
      
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      List<dynamic> history = List.from(data['watch_history'] ?? []);

      // 2. Remover se esse vídeo JÁ estiver na lista (para não duplicar)
      history.removeWhere((item) => item['url'] == videoUrl);

      // 3. Adicionar no topo (índice 0) como o mais recente
      history.insert(0, {
        'url': videoUrl, 
        'title': title, 
        'subtitle': subtitle, 
        'timestamp': DateTime.now().toString()
      });

      // 4. Manter apenas os últimos 10 itens para não pesar o banco
      if (history.length > 10) {
        history = history.sublist(0, 10);
      }

      // 5. Salvar a lista limpa de volta
      await docRef.update({
        'watch_history': history
      });
      
    } catch (e) {
      print("Erro ao atualizar histórico: $e");
    }
  }

  Stream<DocumentSnapshot> getUserStream() {
    return usersCollection.doc(user!.uid).snapshots();
  }

  Stream<QuerySnapshot> getModulesStream() {
    return modulesCollection.orderBy('order').snapshots();
  }

  // --- 3. COMUNIDADE ---
  Stream<QuerySnapshot> getPostsStream() {
    return postsCollection.orderBy('timestamp', descending: true).snapshots();
  }

  Future<bool> hasPostedToday() async {
    if (user == null) return true; 
    if (user!.email == adminEmail) return false; 

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final query = await postsCollection
        .where('userId', isEqualTo: user!.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    return query.docs.isNotEmpty;
  }

  Future<void> addPost(String content) async {
    if (user == null) return;

    if (await hasPostedToday()) {
      throw "Você já fez seu post diário! Volte amanhã.";
    }

    await postsCollection.add({
      'userId': user!.uid,
      'userName': user!.displayName ?? 'Membro',
      'userPhoto': user!.photoURL,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
    });
    completeDay(5);
  }

  Future<void> toggleLike(String postId, List<dynamic> likes) async {
    if (user == null) return;
    if (likes.contains(user!.uid)) {
      await postsCollection.doc(postId).update({'likes': FieldValue.arrayRemove([user!.uid])});
    } else {
      await postsCollection.doc(postId).update({'likes': FieldValue.arrayUnion([user!.uid])});
    }
  }
  
  Future<void> updateAvatar(String url) async {
    if (user == null) return;
    await user?.updatePhotoURL(url);
    await usersCollection.doc(user!.uid).update({'photoUrl': url});
  }
  
  Future<void> completeDay(int xpGained) async {
    if (user == null) return;
    final docRef = usersCollection.doc(user!.uid);
    await docRef.set({
      'xp': FieldValue.increment(xpGained),
      'last_active': DateTime.now(),
      'activity': {'${DateTime.now().year}': {'${DateTime.now().month}': {'${DateTime.now().day}': true}}}
    }, SetOptions(merge: true));
    UserData.totalXP.value += xpGained;
  }
}