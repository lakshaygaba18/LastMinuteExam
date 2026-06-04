
import 'package:flutter/material.dart';
import 'viva_screen.dart';
import 'subjective_menu_screen.dart';
import 'cheat_sheet_screen.dart';

class ModeSelectionScreen extends StatelessWidget {
  final Map data;
  const ModeSelectionScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth >= 600;

    final bg = isDark ? const Color(0xFF0A0A0F) : const Color(0xFFF5F4F0);
    final surface = isDark ? const Color(0xFF13131A) : Colors.white;
    final border = isDark ? const Color(0xFF1E1E2A) : const Color(0xFFE8E8E4);
    final textPrimary = isDark ? Colors.white : const Color(0xFF0F0F14);
    final textSecondary = isDark ? const Color(0xFF8888A0) : const Color(0xFF6B6B7A);

    final modes = [
      {
        "title": "Objective",
        "subtitle": "Fast one-line viva answers",
        "badge": "VIVA",
        "emoji": "🎙",
        "colors": [const Color(0xFF2563EB), const Color(0xFF06B6D4)],
        "bgColor": const Color(0xFF2563EB).withOpacity(0.12),
        "borderColor": const Color(0xFF2563EB).withOpacity(0.3),
        "screen": VivaScreen(data: data),
      },
      {
        "title": "Subjective",
        "subtitle": "1, 3, 5 and 10 mark answers",
        "badge": "1–10M",
        "emoji": "✏️",
        "colors": [const Color(0xFF7C3AED), const Color(0xFFEC4899)],
        "bgColor": const Color(0xFF7C3AED).withOpacity(0.12),
        "borderColor": const Color(0xFF7C3AED).withOpacity(0.3),
        "screen": SubjectiveMenuScreen(data: data),
      },
      {
        "title": "Cheat Sheet",
        "subtitle": "Key facts, formulas & tips",
        "badge": "QUICK",
        "emoji": "⚡",
        "colors": [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
        "bgColor": const Color(0xFFF59E0B).withOpacity(0.12),
        "borderColor": const Color(0xFFF59E0B).withOpacity(0.3),
        "screen": CheatSheetScreen(data: data),
      },
    ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 700.0 : double.infinity),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: isWide ? 40 : 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border),
                          ),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 16),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.3)),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text("●", style: TextStyle(color: Color(0xFF22C55E), fontSize: 8)),
                            SizedBox(width: 5),
                            Text(
                              "READY",
                              style: TextStyle(
                                color: Color(0xFF22C55E),
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Text(
                    "✦ STUDY MODE",
                    style: TextStyle(
                      color: const Color(0xFF7C3AED),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Pick your\nstudy mode",
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: isWide ? 40 : 34,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Your document is ready — choose how to study",
                    style: TextStyle(color: textSecondary, fontSize: 14),
                  ),

                  const SizedBox(height: 28),

                  if (isWide)
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: _ModeCard(isDark: isDark, mode: modes[0], surface: surface, border: border, textPrimary: textPrimary, textSecondary: textSecondary, context: context)),
                            const SizedBox(width: 12),
                            Expanded(child: _ModeCard(isDark: isDark, mode: modes[1], surface: surface, border: border, textPrimary: textPrimary, textSecondary: textSecondary, context: context)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _ModeCard(isDark: isDark, mode: modes[2], surface: surface, border: border, textPrimary: textPrimary, textSecondary: textSecondary, context: context, isWide: true),
                      ],
                    )
                  else
                    Column(
                      children: modes.map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ModeCard(isDark: isDark, mode: m, surface: surface, border: border, textPrimary: textPrimary, textSecondary: textSecondary, context: context),
                      )).toList(),
                    ),

                  const Spacer(),

                  Center(
                    child: Text(
                      "Generated from your uploaded document",
                      style: TextStyle(color: textSecondary, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final bool isDark;
  final Map mode;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final BuildContext context;
  final bool isWide;

  const _ModeCard({
    required this.isDark,
    required this.mode,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.context,
    this.isWide = false,
  });

  @override
  Widget build(BuildContext ctx) {
    final colors = mode["colors"] as List<Color>;
    final bgColor = mode["bgColor"] as Color;
    final borderColor = mode["borderColor"] as Color;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => mode["screen"] as Widget)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isDark ? bgColor.withOpacity(0.5) : bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: isWide
            ? Row(
                children: [
                  _iconBox(colors),
                  const SizedBox(width: 16),
                  Expanded(child: _textContent()),
                  Icon(Icons.arrow_forward_ios_rounded, color: textSecondary, size: 14),
                ],
              )
            : Row(
                children: [
                  _iconBox(colors),
                  const SizedBox(width: 14),
                  Expanded(child: _textContent()),
                  Icon(Icons.arrow_forward_ios_rounded, color: textSecondary, size: 14),
                ],
              ),
      ),
    );
  }

  Widget _iconBox(List<Color> colors) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Center(
        child: Text(mode["emoji"] as String, style: const TextStyle(fontSize: 22)),
      ),
    );
  }

  Widget _textContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              mode["title"] as String,
              style: TextStyle(
                color: textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: (mode["colors"] as List<Color>).first.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                mode["badge"] as String,
                style: TextStyle(
                  color: (mode["colors"] as List<Color>).first,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.05,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          mode["subtitle"] as String,
          style: TextStyle(color: textSecondary, fontSize: 12, height: 1.3),
        ),
      ],
    );
  }
}
