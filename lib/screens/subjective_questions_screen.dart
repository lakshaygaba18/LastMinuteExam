import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _T {
  static const bgLight = Color(0xFFF5F5F7);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surface2Light = Color(0xFFF0F0F5);
  static const textPrimaryLight = Color(0xFF1A1A2E);
  static const textSecondaryLight = Color(0xFF6B6B80);
  static const borderLight = Color(0xFFE4E4EC);
  static const bgDark = Color(0xFF0A0A0F);
  static const surfaceDark = Color(0xFF14141F);
  static const surface2Dark = Color(0xFF1E1E2D);
  static const textPrimaryDark = Color(0xFFFFFFFF);
  static const textSecondaryDark = Color(0xFF9090A8);
  static const borderDark = Color(0xFF2A2A3D);
  static const purple = Color(0xFF6C47FF);
  static const pink = Color(0xFFEC4899);
  static const green = Color(0xFF22C55E);
}

class SubjectiveQuestionsScreen extends StatelessWidget {
  final String title;
  final List questions;
  final Color accentColor;

  const SubjectiveQuestionsScreen({
    super.key,
    required this.title,
    required this.questions,
    this.accentColor = _T.purple,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 600;

    final bg = isDark ? _T.bgDark : _T.bgLight;
    final surface = isDark ? _T.surfaceDark : _T.surfaceLight;
    final surface2 = isDark ? _T.surface2Dark : _T.surface2Light;
    final textPrimary = isDark ? _T.textPrimaryDark : _T.textPrimaryLight;
    final textSecondary = isDark ? _T.textSecondaryDark : _T.textSecondaryLight;
    final border = isDark ? _T.borderDark : _T.borderLight;
    final hPad = isWide ? 40.0 : 20.0;
    final maxW = isWide ? 860.0 : double.infinity;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Column(
              children: [
                // Top bar
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
                  child: Row(
                    children: [
                      _BackButton(isDark: isDark, border: border),
                      const SizedBox(width: 14),
                      Text(
                        title,
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: accentColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${questions.length} Q\'s',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Questions list
                Expanded(
                  child: questions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.quiz_outlined, size: 52, color: textSecondary),
                              const SizedBox(height: 12),
                              Text(
                                'No questions found',
                                style: TextStyle(color: textSecondary, fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(hPad, 4, hPad, 32),
                          itemCount: questions.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 14),
                          itemBuilder: (context, index) {
                            final q = questions[index];
                            return _QuestionCard(
                              isDark: isDark,
                              surface: surface,
                              surface2: surface2,
                              border: border,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              accentColor: accentColor,
                              index: index,
                              question: q['question'] ?? '',
                              answer: q['answer'] ?? '',
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// QUESTION CARD — expandable
// ============================================================
class _QuestionCard extends StatefulWidget {
  final bool isDark;
  final Color surface;
  final Color surface2;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color accentColor;
  final int index;
  final String question;
  final String answer;

  const _QuestionCard({
    required this.isDark,
    required this.surface,
    required this.surface2,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.accentColor,
    required this.index,
    required this.question,
    required this.answer,
  });

  @override
  State<_QuestionCard> createState() => _QuestionCardState();
}

class _QuestionCardState extends State<_QuestionCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _copied = false;
  late AnimationController _anim;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _expandAnim = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _anim.forward() : _anim.reverse();
  }

  void _copyAnswer() async {
    await Clipboard.setData(ClipboardData(text: widget.answer));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question header — always visible
          GestureDetector(
            onTap: _toggle,
            child: Container(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Index badge
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withOpacity(widget.isDark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.question,
                      style: TextStyle(
                        color: widget.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 280),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.textSecondary,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Answer — animated expand
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.fromLTRB(18, 0, 18, 0),
                  height: 0.5,
                  color: widget.border,
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? _T.green.withOpacity(0.06)
                        : _T.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _T.green.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _T.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              '✓ ANSWER',
                              style: TextStyle(
                                color: _T.green,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _copyAnswer,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: widget.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                                    size: 12,
                                    color: widget.accentColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _copied ? 'Copied!' : 'Copy',
                                    style: TextStyle(
                                      color: widget.accentColor,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.answer,
                        style: TextStyle(
                          color: widget.textSecondary,
                          fontSize: 14,
                          height: 1.65,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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