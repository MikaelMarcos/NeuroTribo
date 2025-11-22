import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'home_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = credential.user;
      if (user != null && !user.emailVerified) {
        await FirebaseAuth.instance.signOut();
        _showError('Verifique seu e-mail antes de entrar.', color: Colors.orange);
      } else {
        _goToHome();
      }

    } on FirebaseAuthException catch (e) {
      _showError('Login falhou. Verifique e-mail e senha.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      _goToHome();

    } catch (e) {
      _showError('Erro ao entrar com Google.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToHome() {
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  void _showError(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 30 : 16, vertical: 10),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 400 : 350, minHeight: screenSize.height * 0.8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/images/logo_neurotribo.png', height: 70, fit: BoxFit.contain),
                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: const Color(0xFF8B5A2B).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('Bem-vindo(a)', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A))),
                        const SizedBox(height: 20),

                        // EMAIL
                        TextFormField(
                          controller: _emailController,
                          decoration: _inputDecoration('E-mail', Icons.email_outlined),
                          validator: (v) => !v!.contains('@') ? 'Email inválido' : null,
                          textInputAction: TextInputAction.next, // Vai para a senha
                        ),
                        const SizedBox(height: 12),

                        // SENHA
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: _inputDecoration('Senha', Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF8B5A2B), size: 18),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                          validator: (v) => v!.isEmpty ? 'Digite a senha' : null,
                          // CONFIGURAÇÃO DO ENTER:
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (value) {
                            _login(); // Chama o login ao dar Enter
                          },
                        ),

                        const SizedBox(height: 20),

                        // BOTÃO ENTRAR
                        SizedBox(
                          height: 42,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5A2B), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading 
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white))
                              : const Text('ENTRAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Não tem conta? ", style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
                              },
                              child: const Text("Criar agora", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF8B5A2B))),
                            ),
                          ],
                        ),

                        const SizedBox(height: 15),
                        const Divider(),
                        const SizedBox(height: 15),

                        SizedBox(
                          height: 42,
                          child: OutlinedButton.icon(
                            icon: const FaIcon(FontAwesomeIcons.google, color: Color(0xFFDB4437), size: 16),
                            label: const Text('Entrar com Google', style: TextStyle(color: Color(0xFF4A4A4A), fontWeight: FontWeight.w600, fontSize: 13)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFDDDDDD)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isLoading ? null : _loginWithGoogle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF999999), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF8B5A2B), size: 18),
      filled: true,
      fillColor: const Color(0xFFF9F9F9),
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEEEEEE))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF8B5A2B), width: 1.5)),
    );
  }
}