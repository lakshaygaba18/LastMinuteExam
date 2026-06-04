
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const LoginScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  final nameCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    passwordCtrl.dispose();
    nameCtrl.dispose();
    super.dispose();
  }

  Future<void> handleSubmit() async {
    final email = emailCtrl.text.trim();
    final password = passwordCtrl.text.trim();
    final name = nameCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => errorMessage = "Please fill in all fields");
      return;
    }
    if (!isLogin && name.isEmpty) {
      setState(() => errorMessage = "Please enter your name");
      return;
    }

    setState(() { isLoading = true; errorMessage = null; });

    final error = isLogin
        ? await AuthService.login(email, password)
        : await AuthService.signUp(email, password, name);

    if (!mounted) return;

    if (error != null) {
      setState(() { isLoading = false; errorMessage = error; });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(
          isDarkMode: widget.isDarkMode,
          onToggleTheme: widget.onToggleTheme,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F4F0);
    final surface = isDark ? const Color(0xFF13131A) : Colors.white;
    final border = isDark ? const Color(0xFF1E1E2A) : const Color(0xFFE8E8E4);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F0F14);
    final textSecondary = isDark ? const Color(0xFF8888A0) : const Color(0xFF6B6B7A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text("⚡", style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Exam AI",
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Hero card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F0A1E) : const Color(0xFF1A0533),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF7C3AED).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.4)),
                          ),
                          child: const Text(
                            "✦ FOR STUDENTS",
                            style: TextStyle(color: Color(0xFFa78bfa), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.1),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isLogin
                              ? "Welcome\nback 👋"
                              : "Join thousands\nof students acing\nexams",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            height: 1.2,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Name field
                  if (!isLogin) ...[
                    _buildField(
                      controller: nameCtrl,
                      hint: "Your name",
                      icon: Icons.person_rounded,
                      isDark: isDark,
                      surface: surface,
                      border: border,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Email field
                  _buildField(
                    controller: emailCtrl,
                    hint: "Email address",
                    icon: Icons.email_rounded,
                    isDark: isDark,
                    surface: surface,
                    border: border,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 12),

                  // Password field
                  _buildField(
                    controller: passwordCtrl,
                    hint: "Password",
                    icon: Icons.lock_rounded,
                    isDark: isDark,
                    surface: surface,
                    border: border,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                    obscure: obscurePassword,
                    suffix: IconButton(
                      icon: Icon(
                        obscurePassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                        color: textSecondary,
                        size: 20,
                      ),
                      onPressed: () => setState(() => obscurePassword = !obscurePassword),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Submit button
                  GestureDetector(
                    onTap: isLoading ? null : handleSubmit,
                    child: Container(
                      width: double.infinity,
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF5b21b6)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                isLogin ? "Sign In →" : "Create Account →",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() { isLogin = !isLogin; errorMessage = null; }),
                      child: RichText(
                        text: TextSpan(
                          text: isLogin ? "Don't have an account? " : "Already have an account? ",
                          style: TextStyle(color: textSecondary, fontSize: 13),
                          children: [
                            TextSpan(
                              text: isLogin ? "Sign Up" : "Sign In",
                              style: const TextStyle(
                                color: Color(0xFF7C3AED),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    required Color surface,
    required Color border,
    required Color textPrimary,
    required Color textSecondary,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        style: TextStyle(color: textPrimary, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: textSecondary, fontSize: 14),
          prefixIcon: Icon(icon, color: textSecondary, size: 18),
          suffixIcon: suffix,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
