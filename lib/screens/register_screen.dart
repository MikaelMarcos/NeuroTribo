import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();

  // --- Lógica de Cadastro ---
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // 1. Cria o usuário no Firebase
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // 2. Atualiza o nome do usuário (para aparecer "Olá, Mikael")
        await user.updateDisplayName(_nameController.text.trim());

        // 3. Envia o E-mail de Verificação
        await user.sendEmailVerification();

        if (mounted) {
          // 4. Mostra mensagem de sucesso
          _showSuccessDialog();
        }
      }
    } on FirebaseAuthException catch (e) {
      String msg = 'Erro ao cadastrar.';
      if (e.code == 'email-already-in-use') msg = 'Este e-mail já está em uso.';
      if (e.code == 'weak-password') msg = 'A senha é muito fraca.';
      if (e.code == 'invalid-email') msg = 'E-mail inválido.';
      _showSnackBar(msg, isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Obriga a clicar no botão
      builder: (context) => AlertDialog(
        title: const Text("Verifique seu E-mail"),
        content: Text(
          "Uma conta foi criada para ${_emailController.text}.\n\n"
          "Enviamos um link de confirmação para o seu e-mail. Por favor, clique no link antes de fazer login."
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Fecha dialogo
              Navigator.pop(context); // Volta para Login
            },
            child: const Text("Entendi, vou verificar", style: TextStyle(color: Color(0xFF8B5A2B))),
          )
        ],
      ),
    );
  }

  void _showSnackBar(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isDesktop = screenSize.width > 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2EA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF8B5A2B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 30 : 16, vertical: 10),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 400 : 350),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Título
                const Text(
                  'Crie sua conta',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Faça parte da NeuroTribo',
                  style: TextStyle(fontSize: 14, color: Color(0xFF888888)),
                ),
                
                const SizedBox(height: 25),

                // FORMULÁRIO
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: const Color(0xFF8B5A2B).withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // NOME
                        TextFormField(
                          controller: _nameController,
                          validator: (v) => v!.isEmpty ? 'Informe seu nome' : null,
                          decoration: _inputDecoration('Nome Completo', Icons.person_outline),
                        ),
                        const SizedBox(height: 12),

                        // EMAIL
                        TextFormField(
                          controller: _emailController,
                          validator: (v) => !v!.contains('@') ? 'E-mail inválido' : null,
                          decoration: _inputDecoration('E-mail', Icons.email_outlined),
                        ),
                        const SizedBox(height: 12),

                        // SENHA
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          validator: (v) => v!.length < 6 ? 'Mínimo 6 caracteres' : null,
                          decoration: _inputDecoration('Senha', Icons.lock_outline).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF8B5A2B), size: 18),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // CONFIRMAR SENHA
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: _obscureConfirmPassword,
                          validator: (v) {
                            if (v != _passwordController.text) return 'As senhas não coincidem';
                            return null;
                          },
                          decoration: _inputDecoration('Confirmar Senha', Icons.lock_reset).copyWith(
                            suffixIcon: IconButton(
                              icon: Icon(_obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFF8B5A2B), size: 18),
                              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // BOTÃO CADASTRAR
                        SizedBox(
                          width: double.infinity,
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5A2B),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: _isLoading ? null : _register,
                            child: _isLoading
                                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                : const Text('CRIAR CONTA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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