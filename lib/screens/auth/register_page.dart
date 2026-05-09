import 'package:flutter/material.dart';
import 'package:taskflow_lc/screens/auth/widgets/auth_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les mots de passe ne correspondent pas')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      UserCredential user =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await user.user?.updateDisplayName(_fullNameController.text);

      if (!mounted) return;

      Navigator.pop(context); // 🔁 GO BACK TO LOGIN PAGE

    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Erreur inscription')),
      );
    }

    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    const indigo = Color(0xFF4F46E5);
    const indigoLight = Color(0xFFEEF2FF);
    const textPrimary = Color(0xFF111827);
    const textSecondary = Color(0xFF6B7280);
    const borderColor = Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // 🔥 LOGO (same style as login)
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: indigoLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.person_add_alt_1,
                        size: 36, color: indigo),
                  ),

                  const SizedBox(height: 24),

                  // TITLE
                  const Text(
                    'Créer un compte',
                    style: TextStyle(
                      fontSize: 26,
                      color: textSecondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Inscrivez-vous pour commencer',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 👤 FULL NAME
                  AuthTextField(
                    controller: _fullNameController,
                    hint: 'Nom complet',
                    label: 'Nom complet',
                    prefixIcon: Icons.person_outline,
                    validator: (v) =>
                        (v == null || v.isEmpty) ? 'Champ requis' : null,
                  ),

                  const SizedBox(height: 16),

                  // 📧 EMAIL
                  AuthTextField(
                    controller: _emailController,
                    hint: 'email@gmail.com',
                    label: 'Votre email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: (v) =>
                        (v == null || !v.contains('@')) ? 'Email invalide' : null,
                  ),

                  const SizedBox(height: 16),

                  // 🔒 PASSWORD
                  AuthTextField(
                    controller: _passwordController,
                    hint: '*******',
                    label: 'Mot de passe',
                    isPasswordd: true,
                    prefixIcon: Icons.lock_outlined,
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Minimum 6 caractères'
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // 🔒 CONFIRM PASSWORD
                  AuthTextField(
                    controller: _confirmPasswordController,
                    hint: '*******',
                    label: 'Confirmer mot de passe',
                    isPasswordd: true,
                    prefixIcon: Icons.lock_outline,
                    validator: (v) => (v == null || v.length < 6)
                        ? 'Minimum 6 caractères'
                        : null,
                  ),

                  const SizedBox(height: 20),

                  // 🔥 REGISTER BUTTON
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      child: _loading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Créer un compte',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 🔁 BACK TO LOGIN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Déjà un compte ?',
                        style: TextStyle(color: textSecondary, fontSize: 14),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () => Navigator.pop(context), // ✅ clean back
                        child: const Text(
                          'Se connecter',
                          style: TextStyle(
                            color: indigo,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}