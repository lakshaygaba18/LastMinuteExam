import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class _T {
  static const purple = Color(0xFF6C47FF);
  static const pink   = Color(0xFFEC4899);
  static const amber  = Color(0xFFF59E0B);
  static const cyan   = Color(0xFF06B6D4);
  static const green  = Color(0xFF22C55E);

  static const bgLight            = Color(0xFFF5F5F7);
  static const surfaceLight       = Color(0xFFFFFFFF);
  static const textPrimaryLight   = Color(0xFF1A1A2E);
  static const textSecondaryLight = Color(0xFF6B6B80);
  static const borderLight        = Color(0xFFE4E4EC);

  static const bgDark             = Color(0xFF0A0A0F);
  static const surfaceDark        = Color(0xFF14141F);
  static const textPrimaryDark    = Color(0xFFFFFFFF);
  static const textSecondaryDark  = Color(0xFF9090A8);
  static const borderDark         = Color(0xFF2A2A3D);
}

class CheatSheetScreen extends StatelessWidget {
  final Map data;

  const CheatSheetScreen({super.key, required this.data});

  /// Extracts a display string from a cheat-sheet item.
  /// Priority: "summary" → joined "points" list → first point → fallback.
  static String _extractContent(Map item) {
    // 1. summary field
    final summary = (item['summary'] ?? '').toString().trim();
    if (summary.isNotEmpty) return summary;

    // 2. points list
    final raw = item['points'];
    if (raw is List && raw.isNotEmpty) {
      return raw
          .map((e) {
            if (e is Map) {
              return (e['point'] ?? e['text'] ?? e['content'] ?? e.values.first ?? '')
                  .toString()
                  .trim();
            }
            return e.toString().trim();
          })
          .where((s) => s.isNotEmpty)
          .join('\n');
    }

    // 3. plain string points
    if (raw is String && raw.trim().isNotEmpty) return raw.trim();

    return 'Refer to your notes for details.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark        = Theme.of(context).brightness == Brightness.dark;
    final List cheatSheet = data['cheat_sheet'] ?? [];

    final bg            = isDark ? _T.bgDark            : _T.bgLight;
    final surface       = isDark ? _T.surfaceDark        : _T.surfaceLight;
    final textPrimary   = isDark ? _T.textPrimaryDark    : _T.textPrimaryLight;
    final textSecondary = isDark ? _T.textSecondaryDark  : _T.textSecondaryLight;
    final border        = isDark ? _T.borderDark         : _T.borderLight;

    final w      = MediaQuery.of(context).size.width;
    final isWide = w >= 600;
    final hPad   = isWide ? 40.0 : 20.0;
    final maxW   = isWide ? 860.0 : double.infinity;

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW),
            child: Column(
              children: [
                // ── Top bar ──────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 0),
                  child: Row(
                    children: [
                      _BackButton(isDark: isDark, border: border),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Cheat Sheet',
                                style: TextStyle(
                                    color: textPrimary,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3)),
                            const SizedBox(height: 2),
                            Text('Last minute revision',
                                style: TextStyle(
                                    color: textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                      // Topic count badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: _T.amber
                              .withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                              color: _T.amber.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt_rounded,
                                color: _T.amber, size: 12),
                            const SizedBox(width: 4),
                            Text('${cheatSheet.length} topics',
                                style: const TextStyle(
                                    color: _T.amber,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Gradient banner ───────────────────────────────
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(22),
                      gradient: const LinearGradient(
                        colors: [_T.purple, _T.pink],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.bolt_rounded,
                            color: Colors.white, size: 34),
                        SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            'Revise the most important concepts before your exam.',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.4,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // ── List ─────────────────────────────────────────
                Expanded(
                  child: cheatSheet.isEmpty
                      ? _EmptyState(
                          textPrimary: textPrimary,
                          textSecondary: textSecondary)
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(
                              hPad, 4, hPad, 32),
                          itemCount: cheatSheet.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final item = cheatSheet[index];
                            final title = (item['title'] ??
                                    item['topic'] ??
                                    'Topic ${index + 1}')
                                .toString()
                                .trim();
                            final content = _extractContent(item);

                            return _CheatCard(
                              isDark: isDark,
                              surface: surface,
                              border: border,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              index: index,
                              title: title,
                              content: content,
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

// ─────────────────────────────────────────────────────────────────────────────
// CHEAT CARD — expandable, matches FavoritesScreen card style
// ─────────────────────────────────────────────────────────────────────────────
class _CheatCard extends StatefulWidget {
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final int index;
  final String title;
  final String content;

  const _CheatCard({
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.index,
    required this.title,
    required this.content,
  });

  @override
  State<_CheatCard> createState() => _CheatCardState();
}

class _CheatCardState extends State<_CheatCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  bool _copied   = false;
  late AnimationController _anim;
  late Animation<double> _expandAnim;

  static const _accents = [
    _T.purple, _T.pink, _T.amber, _T.cyan, _T.green,
  ];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 280));
    _expandAnim =
        CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
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
    await Clipboard.setData(ClipboardData(text: widget.content));
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final accent = _accents[widget.index % _accents.length];

    return Container(
      decoration: BoxDecoration(
        color: widget.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: widget.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ────────────────────────────────────────────
          GestureDetector(
            onTap: _toggle,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Number badge
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(
                          widget.isDark ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: accent.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(
                        '${widget.index + 1}',
                        style: TextStyle(
                            color: accent,
                            fontSize: 12,
                            fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                          color: widget.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          height: 1.4,
                          letterSpacing: -0.2),
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

          // ── Expandable answer — mirrors FavoritesScreen style ──
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(
              children: [
                // Divider
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
                    color: accent.withOpacity(
                        widget.isDark ? 0.08 : 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: accent.withOpacity(0.15)),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      // Label + Copy row
                      Row(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3),
                            decoration: BoxDecoration(
                              color:
                                  accent.withOpacity(0.15),
                              borderRadius:
                                  BorderRadius.circular(6),
                            ),
                            child: Text(
                              '★  KEY POINTS',
                              style: TextStyle(
                                  color: accent,
                                  fontSize: 9,
                                  fontWeight:
                                      FontWeight.w800,
                                  letterSpacing: 0.5),
                            ),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: _copy,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3),
                              decoration: BoxDecoration(
                                color: accent
                                    .withOpacity(0.1),
                                borderRadius:
                                    BorderRadius.circular(
                                        6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _copied
                                        ? Icons
                                            .check_rounded
                                        : Icons
                                            .copy_rounded,
                                    size: 12,
                                    color: accent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _copied
                                        ? 'Copied!'
                                        : 'Copy',
                                    style: TextStyle(
                                        color: accent,
                                        fontSize: 10,
                                        fontWeight:
                                            FontWeight
                                                .w700),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // Content — render bullet per line if multiline
                      ...widget.content
                          .split('\n')
                          .where((l) => l.trim().isNotEmpty)
                          .map((line) => Padding(
                                padding:
                                    const EdgeInsets.only(
                                        bottom: 8),
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                  children: [
                                    Text('• ',
                                        style: TextStyle(
                                            color: accent,
                                            fontWeight:
                                                FontWeight
                                                    .w900,
                                            fontSize: 14)),
                                    Expanded(
                                      child: Text(
                                        line.trim(),
                                        style: TextStyle(
                                            color: widget
                                                .textSecondary,
                                            fontSize: 14,
                                            height: 1.6),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
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

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY STATE
// ─────────────────────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final Color textPrimary;
  final Color textSecondary;
  const _EmptyState(
      {required this.textPrimary, required this.textSecondary});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _T.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.article_outlined,
                size: 38, color: _T.amber),
          ),
          const SizedBox(height: 16),
          Text('No cheat sheet available',
              style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('Generate a cheat sheet to\nsee key points here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: textSecondary, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BACK BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  final bool isDark;
  final Color border;
  const _BackButton({required this.isDark, required this.border});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2D) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 16,
          color: isDark
              ? Colors.white70
              : const Color(0xFF1A1A2E),
        ),
      ),
    );
  }
}
