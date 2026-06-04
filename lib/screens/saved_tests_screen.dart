import 'package:flutter/material.dart';
import '../services/exam_storage_service.dart';
import 'mode_selection_screen.dart';

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
  static const teal = Color(0xFF0D9488);
  static const red = Color(0xFFEF4444);
}

class SavedTestsScreen extends StatefulWidget {
  const SavedTestsScreen({super.key});

  @override
  State<SavedTestsScreen> createState() => _SavedTestsScreenState();
}

class _SavedTestsScreenState extends State<SavedTestsScreen> {
  List<Map<String, dynamic>> exams = [];
  List<Map<String, dynamic>> filteredExams = [];
  String searchQuery = '';
  bool newestFirst = true;

  bool get isDark => Theme.of(context).brightness == Brightness.dark;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    final loaded = await ExamStorageService.loadExams();
    setState(() {
      exams = loaded;
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Map<String, dynamic>> temp = List.from(exams);
    if (searchQuery.isNotEmpty) {
      temp = temp.where((e) =>
          (e['title'] ?? '').toString().toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
    temp.sort((a, b) {
      final aDate = DateTime.tryParse(a['createdAt'] ?? '') ?? DateTime.now();
      final bDate = DateTime.tryParse(b['createdAt'] ?? '') ?? DateTime.now();
      return newestFirst ? bDate.compareTo(aDate) : aDate.compareTo(bDate);
    });
    filteredExams = temp;
  }

  Future<void> _deleteExam(int index) async {
    await ExamStorageService.deleteExam(index);
    await _loadExams();
  }

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return 'Saved exam';
    }
  }

  String _examStats(Map data) {
    int viva = 0, subj = 0, cheat = 0;
    try {
      final v = data['objective']?['viva'];
      if (v is List) viva = v.length;
      final s = data['subjective'];
      if (s is Map) for (final val in s.values) if (val is List) subj += val.length;
      final c = data['cheat_sheet'];
      if (c is List) cheat = c.length;
    } catch (_) {}
    return '$viva viva  •  $subj answers  •  $cheat tips';
  }

  List<Color> _cardGradient(int index) {
    final gradients = [
      [const Color(0xFF6C47FF), const Color(0xFF4F46E5)],
      [const Color(0xFF0D9488), const Color(0xFF0F766E)],
      [const Color(0xFFEC4899), const Color(0xFFBE185D)],
      [const Color(0xFFF59E0B), const Color(0xFFD97706)],
      [const Color(0xFF2563EB), const Color(0xFF1D4ED8)],
      [const Color(0xFF10B981), const Color(0xFF059669)],
    ];
    return gradients[index % gradients.length];
  }

  @override
  Widget build(BuildContext context) {
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
                        'Saved Exams',
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
                          color: _T.purple.withOpacity(isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(color: _T.purple.withOpacity(0.3)),
                        ),
                        child: Text(
                          '${exams.length} exams',
                          style: const TextStyle(
                            color: _T.purple,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Search + sort
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border),
                          ),
                          child: TextField(
                            onChanged: (v) => setState(() { searchQuery = v; _applyFilters(); }),
                            style: TextStyle(color: textPrimary, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Search exams...',
                              hintStyle: TextStyle(color: textSecondary, fontSize: 14),
                              prefixIcon: Icon(Icons.search_rounded, color: textSecondary, size: 18),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => setState(() { newestFirst = !newestFirst; _applyFilters(); }),
                        child: Container(
                          width: 46, height: 46,
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: border),
                          ),
                          child: Icon(
                            newestFirst ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                            color: textSecondary,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // List
                Expanded(
                  child: filteredExams.isEmpty
                      ? _EmptyState(isDark: isDark, textPrimary: textPrimary, textSecondary: textSecondary)
                      : ListView.separated(
                          padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
                          itemCount: filteredExams.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (_, index) {
                            final exam = filteredExams[index];
                            final data = Map<String, dynamic>.from(exam['data'] ?? {});
                            final gradient = _cardGradient(index);
                            return _ExamCard(
                              isDark: isDark,
                              surface: surface,
                              border: border,
                              textPrimary: textPrimary,
                              textSecondary: textSecondary,
                              title: exam['title'] ?? 'Generated Exam',
                              date: _formatDate(exam['createdAt'] ?? ''),
                              stats: _examStats(data),
                              gradient: gradient,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ModeSelectionScreen(data: data)),
                              ),
                              onDelete: () => _showDeleteDialog(context, index, isDark, textPrimary, textSecondary),
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

  void _showDeleteDialog(BuildContext context, int index, bool isDark, Color textPrimary, Color textSecondary) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF14141F) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Exam?', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w800)),
        content: Text(
          'This exam will be permanently removed.',
          style: TextStyle(color: textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteExam(index);
            },
            child: const Text('Delete', style: TextStyle(color: _T.red, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _ExamCard extends StatelessWidget {
  final bool isDark;
  final Color surface;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final String title;
  final String date;
  final String stats;
  final List<Color> gradient;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _ExamCard({
    required this.isDark,
    required this.surface,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.title,
    required this.date,
    required this.stats,
    required this.gradient,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(Icons.description_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    date,
                    style: TextStyle(color: textSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    stats,
                    style: TextStyle(color: textSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: _T.red.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.delete_outline_rounded, color: _T.red, size: 16),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios_rounded, color: textSecondary, size: 13),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isDark;
  final Color textPrimary;
  final Color textSecondary;

  const _EmptyState({
    required this.isDark,
    required this.textPrimary,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80, height: 80,
            decoration: BoxDecoration(
              color: _T.purple.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.folder_open_rounded, size: 38, color: _T.purple),
          ),
          const SizedBox(height: 16),
          Text(
            'No saved exams yet',
            style: TextStyle(color: textPrimary, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            'Generate your first exam and\nit will appear here automatically.',
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