import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/favorites_service.dart';

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
  static const amber = Color(0xFFF59E0B);
  static const green = Color(0xFF22C55E);
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Map<String, dynamic>> favorites = [];

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await FavoritesService.loadFavorites();
    setState(() => favorites = data);
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 600;
    final bg = isDark ? _T.bgDark : _T.bgLight;
    final surface = isDark ? _T.surfaceDark : _T.surfaceLight;
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
                        'Favourites',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _T.amber.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: _T.amber.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: _T.amber, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              '${favorites.length} saved',
                              style: const TextStyle(
                                color: _T.amber,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: favorites.isEmpty
                      ? _EmptyState(textPrimary: textPrimary, textSecondary: textSecondary)
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
                          itemCount: favorites.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, index) {
                            final item = favorites[index];
                            return _FavCard(
                              isDark: isDark,
                              surface: surface,
                              border: border,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              index: index,
                              question: item['question'] ?? '',
                              answer: item['answer'] ?? '',
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

class _FavCard extends StatefulWidget {
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final int index;
  final String question;
  final String answer;

  const _FavCard({
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.index,
    required this.question,
    required this.answer,
  });

  @override
  State<_FavCard> createState() => _FavCardState();
}

class _FavCardState extends State<_FavCard>
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

  void _copy() async {
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
          GestureDetector(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: _T.amber.withOpacity(widget.isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Icon(Icons.star_rounded, color: _T.amber, size: 14),
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
                    color: _T.green.withOpacity(0.06),
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
                            onTap: _copy,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: _T.purple.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                                    size: 12,
                                    color: _T.purple,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _copied ? 'Copied!' : 'Copy',
                                    style: const TextStyle(
                                      color: _T.purple,
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

class _EmptyState extends StatelessWidget {
  final Color textPrimary;
  final Color textSecondary;
  const _EmptyState({required this.textPrimary, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _T.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.star_outline_rounded, size: 38, color: _T.amber),
          ),
          const SizedBox(height: 16),
          Text(
            'No favourites yet',
            style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Star questions you want to\nrevisit and they\'ll appear here.',
            textAlign: TextAlign.center,
            style: TextStyle(color: textSecondary, fontSize: 14, height: 1.5),
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