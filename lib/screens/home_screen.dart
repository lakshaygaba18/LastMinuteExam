
import 'dart:math';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/exam_storage_service.dart';
import 'login_screen.dart';
import 'mode_selection_screen.dart';
import 'saved_tests_screen.dart';
import 'upload_screen.dart';
import 'favorites_screen.dart';

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  List<Map<String, dynamic>> recentExams = [];
  late bool _localDark;

  @override
  void initState() {
    super.initState();
    _localDark = widget.isDarkMode;
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    loadRecentExams();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isDarkMode != widget.isDarkMode) {
      setState(() => _localDark = widget.isDarkMode);
    }
  }

  Future<void> loadRecentExams() async {
    final loaded = await ExamStorageService.loadExams();
    if (mounted) setState(() => recentExams = loaded.take(3).toList());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    // Design tokens
    final bg = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F4F0);
    final surface = isDark ? const Color(0xFF13131A) : Colors.white;
    final border = isDark ? const Color(0xFF1E1E2A) : const Color(0xFFE8E8E4);
    final primary = isDark ? const Color(0xFF7C3AED) : const Color(0xFF6C3FE8);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F0F14);
    final textSecondary = isDark ? const Color(0xFF8888A0) : const Color(0xFF6B6B7A);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 900.0 : double.infinity),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isWide ? 32 : 20,
                      vertical: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(context, isDark, surface, border, primary, textPrimary, textSecondary),
                        const SizedBox(height: 20),
                        _buildHeroBanner(context, isDark, primary, isWide),
                        const SizedBox(height: 20),
                        _buildStatsRow(isDark, surface, border, textPrimary, textSecondary),
                        const SizedBox(height: 24),
                        Text(
                          "Quick Access",
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildActionGrid(context, isDark, surface, border),
                        const SizedBox(height: 24),
                        if (recentExams.isNotEmpty) ...[
                          Row(
                            children: [
                              Text(
                                "Continue Revision",
                                style: TextStyle(
                                  color: textSecondary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () async {
                                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedTestsScreen()));
                                  loadRecentExams();
                                },
                                child: Text(
                                  "See all",
                                  style: TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ...recentExams.map((exam) => _buildRecentCard(
                            context, isDark, surface, border, textPrimary, textSecondary, primary, exam,
                          )),
                        ],
                        const SizedBox(height: 32),
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

  Widget _buildTopBar(BuildContext context, bool isDark, Color surface, Color border,
      Color primary, Color textPrimary, Color textSecondary) {
    final userName = AuthService.userName;
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Hey, ${userName.split(' ').first} 👋",
              style: TextStyle(color: textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 2),
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
        const Spacer(),
        // Theme toggle
        GestureDetector(
          onTap: () {
            setState(() => _localDark = !_localDark);
            widget.onToggleTheme();
          },
          child: Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Icon(
              _localDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              color: _localDark ? const Color(0xFFFBBF24) : const Color(0xFF6C3FE8),
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Logout / avatar
        GestureDetector(
          onTap: () async {
            await AuthService.logout();
            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => LoginScreen(
                  isDarkMode: widget.isDarkMode,
                  onToggleTheme: widget.onToggleTheme,
                ),
              ),
            );
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                AuthService.userName.isNotEmpty
                    ? AuthService.userName[0].toUpperCase()
                    : "U",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroBanner(BuildContext context, bool isDark, Color primary, bool isWide) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final glow = 0.15 + _pulseController.value * 0.1;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F0A1E) : const Color(0xFF1A0533),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: primary.withOpacity(0.3),
            ),
          ),
          child: Stack(
            children: [
              // Glow blob
              Positioned(
                top: -20,
                right: -20,
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFF7C3AED).withOpacity(glow),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("✦", style: TextStyle(color: Color(0xFFa78bfa), fontSize: 10)),
                        SizedBox(width: 4),
                        Text(
                          "AI POWERED",
                          style: TextStyle(
                            color: Color(0xFFa78bfa),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(text: "Turn panic into\n"),
                        TextSpan(
                          text: "preparation.",
                          style: TextStyle(color: Color(0xFFa78bfa)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Upload notes → instant viva, answers & cheat sheet",
                    style: TextStyle(
                      color: Color(0xFF8888A0),
                      fontSize: 12,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadScreen()));
                      loadRecentExams();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF5b21b6)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("✦ ", style: TextStyle(color: Colors.white, fontSize: 12)),
                          Text(
                            "Generate Now",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 14),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRow(bool isDark, Color surface, Color border, Color textPrimary, Color textSecondary) {
    final stats = [
      {"num": "Notable", "label": "Viva Q's"},
      {"num": "Concise", "label": "Answers"},
      {"num": "Revision", "label": "Cheat tips"},
    ];
    return Row(
      children: stats.map((s) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: s == stats.last ? 0 : 8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                Text(
                  s["num"]!,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  s["label"]!,
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActionGrid(BuildContext context, bool isDark, Color surface, Color border) {
    return Column(
      children: [
        // Primary button - full width
        _ActionCard(
          isDark: isDark,
          title: "Generate New Exam",
          subtitle: "PDF, DOCX, PPTX or TXT",
          emoji: "✦",
          colors: const [Color(0xFF7C3AED), Color(0xFF5b21b6)],
          isLarge: true,
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadScreen()));
            loadRecentExams();
          },
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _ActionCard(
                isDark: isDark,
                title: "Saved Exams",
                subtitle: "Your history",
                emoji: "📁",
                colors: const [Color(0xFF0f766e), Color(0xFF0d9488)],
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const SavedTestsScreen()));
                  loadRecentExams();
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _ActionCard(
                isDark: isDark,
                title: "Favourites",
                subtitle: "Bookmarked Q's",
                emoji: "★",
                colors: const [Color(0xFFbe185d), Color(0xFF9d174d)],
                onTap: () async {
                  await Navigator.push(context, MaterialPageRoute(builder: (_) => const FavoritesScreen()));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentCard(BuildContext context, bool isDark, Color surface, Color border,
      Color textPrimary, Color textSecondary, Color primary, Map exam) {
    final data = Map<String, dynamic>.from(exam["data"] ?? {});
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => ModeSelectionScreen(data: data)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.description_rounded, color: primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exam["title"] ?? "Generated Exam",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Tap to continue revision",
                    style: TextStyle(color: textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: textSecondary, size: 13),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final bool isDark;
  final String title;
  final String subtitle;
  final String emoji;
  final List<Color> colors;
  final VoidCallback onTap;
  final bool isLarge;

  const _ActionCard({
    required this.isDark,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.colors,
    required this.onTap,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isLarge ? 18 : 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: isLarge
            ? Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "$emoji $title",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white70, size: 18),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 20)),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
