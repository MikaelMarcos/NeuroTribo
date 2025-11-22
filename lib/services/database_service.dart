import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user_data.dart';

class DatabaseService {
  final User? user = FirebaseAuth.instance.currentUser;

  // Coleções
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');

  // --- 1. USUÁRIO & XP ---

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
      });
      UserData.totalXP.value = 0;
    } else {
      final data = snapshot.data() as Map<String, dynamic>;
      UserData.totalXP.value = data['xp'] ?? 0;
    }
  }

  Future<void> completeDay(int xpGained) async {
    if (user == null) return;
    final docRef = usersCollection.doc(user!.uid);
    final snapshot = await docRef.get();
    int currentXP = (snapshot.data() as Map<String, dynamic>)['xp'] ?? 0;
    int finalXP = currentXP + xpGained;

    await docRef.update({
      'xp': finalXP,
      'activity.${DateTime.now().year}.${DateTime.now().month}.${DateTime.now().day}': true,
    });
    UserData.totalXP.value = finalXP;
  }

  // --- 2. COMUNIDADE (POSTS) ---

  // Ler posts em tempo real (ordenados por data)
  Stream<QuerySnapshot> getPostsStream() {
    return postsCollection.orderBy('timestamp', descending: true).snapshots();
  }

  // Criar novo post
  Future<void> addPost(String content) async {
    if (user == null) return;

    await postsCollection.add({
      'userId': user!.uid,
      'userName': user!.displayName ?? 'Membro da Tribo',
      'userPhoto': user!.photoURL, // Pode ser null
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [], // Lista de IDs de quem curtiu
    });

    // Ganha XP por interagir!
    completeDay(5); 
  }

  // Curtir / Descurtir
  Future<void> toggleLike(String postId, List<dynamic> likes) async {
    if (user == null) return;

    if (likes.contains(user!.uid)) {
      // Remove like
      await postsCollection.doc(postId).update({
        'likes': FieldValue.arrayRemove([user!.uid])
      });
    } else {
      // Adiciona like
      await postsCollection.doc(postId).update({
        'likes': FieldValue.arrayUnion([user!.uid])
      });
    }
  }
}