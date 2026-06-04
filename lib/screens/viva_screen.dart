import 'package:flutter/material.dart';
import '../services/favorites_service.dart';

class _T {
  static Color bg(bool d) => d ? const Color(0xFF0A0A0F) : const Color(0xFFF5F5F7);
  static Color surface(bool d) => d ? const Color(0xFF141420) : Colors.white;
  static Color border(bool d) => d ? const Color(0xFF1E1E2E) : const Color(0xFFE8E8ED);
  static Color text(bool d) => d ? Colors.white : const Color(0xFF0A0A0F);
  static Color sub(bool d) => d ? const Color(0xFF8B8B9E) : const Color(0xFF6B6B7B);
  static const purple = Color(0xFF7C3AED);
  static const purpleLight = Color(0xFFA78BFA);
  static const pink = Color(0xFFEC4899);
  static const green = Color(0xFF22C55E);
}

class VivaScreen extends StatefulWidget {
  final Map data;
  const VivaScreen({super.key, required this.data});

  @override
  State<VivaScreen> createState() => _VivaScreenState();
}

class _VivaScreenState extends State<VivaScreen> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  bool showAnswer = false;
  bool isFavorite = false;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool get _dark => Theme.of(context).brightness == Brightness.dark;

  List get vivaList =>
      widget.data['objective']?['viva'] ?? widget.data['viva'] ?? [];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _checkFav();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _checkFav() async {
    if (vivaList.isEmpty) return;
    final f = await FavoritesService.isFavorite({
      'question': vivaList[currentIndex]['question'],
      'answer': vivaList[currentIndex]['answer'],
    });
    if (mounted) setState(() => isFavorite = f);
  }

  void _next() {
    if (currentIndex < vivaList.length - 1) {
      _animController.reset();
      setState(() { currentIndex++; showAnswer = false; });
      _animController.forward();
      _checkFav();
    }
  }

  void _prev() {
    if (currentIndex > 0) {
      _animController.reset();
      setState(() { currentIndex--; showAnswer = false; });
      _animController.forward();
      _checkFav();
    }
  }

  Future<void> _toggleFav() async {
    final item = {'question': vivaList[currentIndex]['question'],
        'answer': vivaList[currentIndex]['answer']};
    await FavoritesService.toggleFavorite(item);
    _checkFav();
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final isWide = w >= 600;
    final maxW = isWide ? 680.0 : double.infinity;
    final hPad = isWide ? 40.0 : 20.0;

    if (vivaList.isEmpty) {
      return Scaffold(
        backgroundColor: _T.bg(_dark),
        appBar: AppBar(backgroundColor: Colors.transparent,
            iconTheme: IconThemeData(color: _T.text(_dark))),
        body: Center(child: Text('No viva questions found',
            style: TextStyle(color: _T.sub(_dark)))),
      );
    }

    final current = vivaList[currentIndex];
    final progress = (currentIndex + 1) / vivaList.length;

    return Scaffold(
      backgroundColor: _T.bg(_dark),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  // Top bar
                  Row(
                    children: [
                      _iconBtn(Icons.arrow_back_ios_new_rounded, () => Navigator.pop(context)),
                      const Spacer(),
                      Text('VIVA MODE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800,
                              color: _T.sub(_dark), letterSpacing: 0.8)),
                      const Spacer(),
                      GestureDetector(
                        onTap: _toggleFav,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
                            key: ValueKey(isFavorite),
                            color: isFavorite ? const Color(0xFFFBBF24) : _T.sub(_dark),
                            size: 26,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Progress
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Question ${currentIndex + 1} of ${vivaList.length}',
                              style: TextStyle(fontSize: 12, color: _T.sub(_dark), fontWeight: FontWeight.w600)),
                          Text('${(progress * 100).round()}%',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _T.purpleLight)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 4,
                          backgroundColor: _T.border(_dark),
                          valueColor: const AlwaysStoppedAnimation(Color(0xFF7C3AED)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Question card
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: _T.surface(_dark),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: _T.border(_dark)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _T.purple.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('✦  QUESTION ${(currentIndex + 1).toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                                    color: _T.purpleLight, letterSpacing: 0.5)),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            '${current['question'] ?? ''}',
                            style: TextStyle(
                              fontSize: isWide ? 20 : 18,
                              fontWeight: FontWeight.w800,
                              color: _T.text(_dark),
                              height: 1.4,
                              letterSpacing: -0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Reveal button
                  GestureDetector(
                    onTap: () => setState(() => showAnswer = !showAnswer),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: showAnswer
                            ? LinearGradient(colors: [
                                _T.surface(_dark),
                                _T.surface(_dark),
                              ])
                            : const LinearGradient(colors: [_T.purple, Color(0xFF5B21B6)]),
                        borderRadius: BorderRadius.circular(16),
                        border: showAnswer ? Border.all(color: _T.border(_dark)) : null,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            showAnswer ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: showAnswer ? _T.sub(_dark) : Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            showAnswer ? 'Hide Answer' : 'Reveal Answer',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: showAnswer ? _T.sub(_dark) : Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Answer
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: showAnswer
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    firstChild: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _T.green.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _T.green.withOpacity(0.2)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('✓  ANSWER',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
                                  color: _T.green, letterSpacing: 0.5)),
                          const SizedBox(height: 10),
                          Text(
                            '${current['answer'] ?? ''}',
                            style: TextStyle(
                              fontSize: 14,
                              color: _dark ? const Color(0xFFD1FAE5) : const Color(0xFF065F46),
                              height: 1.6,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    secondChild: const SizedBox(width: double.infinity),
                  ),

                  const Spacer(),

                  // Navigation
                  Row(
                    children: [
                      Expanded(child: _navBtn('← Previous', currentIndex == 0 ? null : _prev)),
                      const SizedBox(width: 12),
                      Expanded(child: _navBtn('Next →',
                          currentIndex == vivaList.length - 1 ? null : _next,
                          primary: true)),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          color: _T.surface(_dark),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _T.border(_dark)),
        ),
        child: Icon(icon, size: 16, color: _T.text(_dark)),
      ),
    );
  }

  Widget _navBtn(String label, VoidCallback? onTap, {bool primary = false}) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          gradient: primary && enabled
              ? const LinearGradient(colors: [_T.purple, Color(0xFF5B21B6)])
              : null,
          color: (!primary || !enabled) ? _T.surface(_dark) : null,
          borderRadius: BorderRadius.circular(14),
          border: (!primary || !enabled) ? Border.all(color: _T.border(_dark)) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: primary && enabled ? Colors.white : (enabled ? _T.text(_dark) : _T.sub(_dark)),
            ),
          ),
        ),
      ),
    );
  }
}