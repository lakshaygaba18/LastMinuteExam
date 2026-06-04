import 'package:flutter/material.dart';
import 'subjective_questions_screen.dart';

class _T {
  static const bgLight = Color(0xFFF5F5F7);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const textPrimaryLight = Color(0xFF1A1A2E);
  static const textSecondaryLight = Color(0xFF6B6B80);
  static const borderLight = Color(0xFFE4E4EC);
  static const bgDark = Color(0xFF0A0A0F);
  static const surfaceDark = Color(0xFF14141F);
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFF9090A8);
  static const borderDark = Color(0xFF2A2A3D);
  static const purple = Color(0xFF6C47FF);
  static const pink = Color(0xFFEC4899);
  static const teal = Color(0xFF0D9488);
  static const amber = Color(0xFFF59E0B);
  static const blue = Color(0xFF2563EB);
  static const green = Color(0xFF10B981);
}

class SubjectiveMenuScreen extends StatelessWidget {
  final Map data;
  const SubjectiveMenuScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 600;

    final bg = isDark ? _T.bgDark : _T.bgLight;
    final surface = isDark ? _T.surfaceDark : _T.surfaceLight;
    final textPrimary = isDark ? _T.textPrimaryDark : _T.textPrimaryLight;
    final textSecondary = isDark ? _T.textSecondaryDark : _T.textSecondaryLight;
    final border = isDark ? _T.borderDark : _T.borderLight;
    final hPad = isWide ? 40.0 : 20.0;
    final maxW = isWide ? 800.0 : double.infinity;

    final modes = [
      _ModeData(
        title: '1 Mark',
        subtitle: 'Quick definitions & facts',
        icon: Icons.flash_on_rounded,
        key: 'one_mark',
        accent: _T.blue,
        tag: 'FAST',
      ),
      _ModeData(
        title: '3 Mark',
        subtitle: 'Short notes & comparisons',
        icon: Icons.auto_awesome_rounded,
        key: 'three_mark',
        accent: _T.purple,
        tag: 'MEDIUM',
      ),
      _ModeData(
        title: '5 Mark',
        subtitle: 'Detailed exam-style answers',
        icon: Icons.description_rounded,
        key: 'five_mark',
        accent: _T.amber,
        tag: 'DETAILED',
      ),
      _ModeData(
        title: '10 Mark',
        subtitle: 'Long-form structured answers',
        icon: Icons.school_rounded,
        key: 'ten_mark',
        accent: _T.green,
        tag: 'LONG',
      ),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
                  child: Row(
                    children: [
                      _BackButton(isDark: isDark, border: border),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _T.purple.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: _T.purple.withOpacity(0.3)),
                        ),
                        child: const Text(
                          '✦ SUBJECTIVE',
                          style: TextStyle(
                            color: _T.purple,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose answer\nlength',
                        style: TextStyle(
                          fontSize: isWide ? 40 : 32,
                          fontWeight: FontWeight.w900,
                          color: textPrimary,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Practice according to exam marks and answer depth.',
                        style: TextStyle(fontSize: 14, color: textSecondary, height: 1.5),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Cards
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: isWide
                        ? GridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 3,
                            children: modes.map((m) => _MenuCard(
                              isDark: isDark,
                              surface: surface,
                              border: border,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              mode: m,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubjectiveQuestionsScreen(
                                    title: '${m.title} Q&A',
                                    questions: data['subjective']?[m.key] ?? [],
                                    accentColor: m.accent,
                                  ),
                                ),
                              ),
                            )).toList(),
                          )
                        : ListView.separated(
                            itemCount: modes.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (_, i) => _MenuCard(
                              isDark: isDark,
                              surface: surface,
                              border: border,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              mode: modes[i],
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => SubjectiveQuestionsScreen(
                                    title: '${modes[i].title} Q&A',
                                    questions: data['subjective']?[modes[i].key] ?? [],
                                    accentColor: modes[i].accent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeData {
  final String title;
  final String subtitle;
  final IconData icon;
  final String key;
  final Color accent;
  final String tag;
  const _ModeData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.key,
    required this.accent,
    required this.tag,
  });
}

class _MenuCard extends StatelessWidget {
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final _ModeData mode;
  final VoidCallback onTap;

  const _MenuCard({
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.mode,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 50, height: 50,
              decoration: BoxDecoration(
                color: mode.accent.withOpacity(isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(mode.icon, color: mode.accent, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        mode.title,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: mode.accent.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          mode.tag,
                          style: TextStyle(
                            color: mode.accent,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mode.subtitle,
                    style: TextStyle(color: textSecondary, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: textSecondary, size: 14),
          ],
        ),
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  final bool isDark;
  final Color border;
  const _BackButton({required this.isDark, required this.border});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: isDark ? Colors.white70 : const Color(0xFF1A1A2E),
        ),
      ),
    );
  }
}