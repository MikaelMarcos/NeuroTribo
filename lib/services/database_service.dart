import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user_data.dart';

class DatabaseService {
  final User? user = FirebaseAuth.instance.currentUser;

  // E-mail da administradora (sem limites de post)
  static const String adminEmail = "rafaelly@neurotribo.com"; 

  // Coleções
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');

  // --- 1. USUÁRIO & PERFIL ---

  Future<void> initUserData() async {
    if (user == null) return;
    final docRef = usersCollection.doc(user!.uid);
    final snapshot = await docRef.get();

    if (!snapshot.exists) {
      // Cria usuário inicial
      await docRef.set({
        'xp': 0,
        'name': user!.displayName ?? 'Membro',
        'email': user!.email,
        'photoUrl': user!.photoURL,
        'last_active': DateTime.now(),
      });
      UserData.totalXP.value = 0;
    } else {
      final data = snapshot.data() as Map<String, dynamic>;
      UserData.totalXP.value = data['xp'] ?? 0;
      
      // Sincroniza a foto se ela foi alterada dentro do app (avatar)
      if (data['photoUrl'] != null && data['photoUrl'] != user!.photoURL) {
        await user!.updatePhotoURL(data['photoUrl']);
      }
    }
  }

  // Atualizar avatar (apenas salva o link da imagem escolhida)
  Future<void> updateAvatar(String url) async {
    if (user == null) return;
    await user?.updatePhotoURL(url); // Atualiza no Auth
    await usersCollection.doc(user!.uid).update({'photoUrl': url}); // Atualiza no Banco
  }

  Future<void> completeDay(int xpGained) async {
    if (user == null) return;
    final docRef = usersCollection.doc(user!.uid);
    
    final snapshot = await docRef.get();
    int currentXP = 0;
    if (snapshot.exists && snapshot.data() != null) {
      final data = snapshot.data() as Map<String, dynamic>;
      currentXP = data['xp'] ?? 0;
    }
    
    int finalXP = currentXP + xpGained;

    await docRef.update({
      'xp': finalXP,
      'activity.${DateTime.now().year}.${DateTime.now().month}.${DateTime.now().day}': true,
    });
    UserData.totalXP.value = finalXP;
  }

  // --- 2. COMUNIDADE (POSTS TEXTO) ---

  Stream<QuerySnapshot> getPostsStream() {
    return postsCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // Verifica se já postou hoje
  Future<bool> hasPostedToday() async {
    if (user == null) return true; 
    if (user!.email == adminEmail) return false; // Admin livre

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final query = await postsCollection
        .where('userId', isEqualTo: user!.uid)
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .get();

    return query.docs.isNotEmpty;
  }

  // Criar novo post (Apenas texto)
  Future<void> addPost(String content) async {
    if (user == null) return;

    if (await hasPostedToday()) {
      throw "Você já fez seu post diário! Volte amanhã ou comente nos posts dos outros.";
    }

    await postsCollection.add({
      'userId': user!.uid,
      'userName': user!.displayName ?? 'Membro da Tribo',
      'userPhoto': user!.photoURL,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
    });

    completeDay(5); // XP por postar
  }

  Future<void> toggleLike(String postId, List<dynamic> likes) async {
    if (user == null) return;

    if (likes.contains(user!.uid)) {
      await postsCollection.doc(postId).update({
        'likes': FieldValue.arrayRemove([user!.uid])
      });
    } else {
      await postsCollection.doc(postId).update({
        'likes': FieldValue.arrayUnion([user!.uid])
      });
    }
  }
}