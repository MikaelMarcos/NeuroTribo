import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../user_data.dart';

class DatabaseService {
  final User? user = FirebaseAuth.instance.currentUser;

  // E-mail da administradora
  static const String adminEmail = "rafaelly@neurotribo.com"; 

  // Coleções
  final CollectionReference usersCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference postsCollection = FirebaseFirestore.instance.collection('posts');

  // --- 1. USUÁRIO & PERFIL ---

  // Inicializa e fica "ouvindo" mudanças no XP (Real-time)
  Future<void> initUserData() async {
    if (user == null) return;
    final docRef = usersCollection.doc(user!.uid);
    
    // 1. Tenta pegar os dados iniciais
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
      // Atualiza a tela imediatamente com o que tem no banco
      UserData.totalXP.value = data['xp'] ?? 0;
    }

    // 2. (Opcional mas recomendado) Cria um ouvinte para garantir sincronia
    // Se você mudar o XP no site do Firebase, muda no app na hora.
    docRef.snapshots().listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        UserData.totalXP.value = data['xp'] ?? 0;
      }
    });
  }

  // Atualizar avatar
  Future<void> updateAvatar(String url) async {
    if (user == null) return;
    await user?.updatePhotoURL(url);
    await usersCollection.doc(user!.uid).update({'photoUrl': url});
  }

  // --- LÓGICA DE XP CORRIGIDA (Atualização Otimista) ---
  Future<void> completeDay(int xpGained) async {
    if (user == null) return;
    
    // 1. ATUALIZAÇÃO OTIMISTA (Na tela AGORA)
    // Soma no visual antes mesmo de enviar para a internet
    UserData.addXP(xpGained); 

    final docRef = usersCollection.doc(user!.uid);

    try {
      // 2. ATUALIZAÇÃO NO BANCO (Em segundo plano)
      // Usamos FieldValue.increment para evitar erros de cálculo se a net cair
      await docRef.set({
        'xp': FieldValue.increment(xpGained), // Soma atômica segura
        'last_active': DateTime.now(),
        // Marca o dia no calendário (usando merge para não apagar o resto)
        'activity': {
          '${DateTime.now().year}': {
            '${DateTime.now().month}': {
              '${DateTime.now().day}': true
            }
          }
        }
      }, SetOptions(merge: true)); 
    } catch (e) {
      // Se der erro, desfaz a soma visual (opcional, mas boa prática)
      print("Erro ao salvar XP: $e");
      UserData.addXP(-xpGained); 
    }
  }

  // --- 2. COMUNIDADE ---

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

    // Salva o post
    await postsCollection.add({
      'userId': user!.uid,
      'userName': user!.displayName ?? 'Membro da Tribo',
      'userPhoto': user!.photoURL,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'likes': [],
    });

    // Soma +5 XP usando a nova função otimizada
    completeDay(5);
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