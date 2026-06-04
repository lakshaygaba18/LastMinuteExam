
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../services/exam_api_service.dart';
import '../services/exam_storage_service.dart';
import 'mode_selection_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  File? selectedFile;
  bool isLoading = false;
  String statusMessage = "No file selected yet";
  String? errorMessage;

  @override
  void dispose() {
    ExamApiService.cancelActiveRequest();
    super.dispose();
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx', 'pptx', 'txt'],
      );
      if (result != null && result.files.single.path != null) {
        setState(() {
          selectedFile = File(result.files.single.path!);
          statusMessage = "Ready to generate";
          errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => errorMessage = "Could not select file: $e");
    }
  }

  String fileName() {
    if (selectedFile == null) return "";
    return selectedFile!.path.split(Platform.pathSeparator).last;
  }

  String generateExamTitle(Map data, String fileName) {
    try {
      String name = fileName
          .replaceAll(RegExp(r'\.(pdf|docx|pptx|txt)$', caseSensitive: false), '')
          .replaceAll(RegExp(r'[_\-]+'), ' ')
          .trim();
      if (name.isNotEmpty) return name;
    } catch (_) {}
    return "Generated Exam";
  }

  Future<void> uploadToServer() async {
    if (selectedFile == null) {
      setState(() => statusMessage = "Please select a file first");
      return;
    }

    setState(() { isLoading = true; statusMessage = "Connecting to server..."; errorMessage = null; });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && isLoading) setState(() => statusMessage = "Server warming up, almost ready...");
    });
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && isLoading) setState(() => statusMessage = "AI is crafting your questions...");
    });
    Future.delayed(const Duration(seconds: 60), () {
      if (mounted && isLoading) setState(() => statusMessage = "Large document — almost done...");
    });

    try {
      final finalData = await ExamApiService.uploadFile(
        selectedFile!,
        onStatusUpdate: (msg) { if (mounted) setState(() => statusMessage = msg); },
      );

      await ExamStorageService.saveExam(finalData, generateExamTitle(finalData, fileName()));

      if (!mounted) return;
      setState(() { isLoading = false; statusMessage = "Done!"; });

      Navigator.push(context, MaterialPageRoute(builder: (_) => ModeSelectionScreen(data: finalData)));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        statusMessage = "Generation failed";
        errorMessage = e.toString().replaceFirst("Exception: ", "");
      });
    }
  }

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

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isWide ? 600.0 : double.infinity),
            child: SingleChildScrollView(
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
                          color: const Color(0xFF7C3AED).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.3)),
                        ),
                        child: const Text(
                          "✦ EXAM AI",
                          style: TextStyle(
                            color: Color(0xFF7C3AED),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Text(
                    "Upload your\nnotes",
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: isWide ? 42 : 36,
                      fontWeight: FontWeight.w900,
                      height: 1.1,
                      letterSpacing: -1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Turn notes into viva, answers & cheat sheet",
                    style: TextStyle(color: textSecondary, fontSize: 14, height: 1.5),
                  ),

                  const SizedBox(height: 28),

                  // Upload zone
                  GestureDetector(
                    onTap: isLoading ? null : pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: selectedFile != null
                              ? const Color(0xFF7C3AED).withOpacity(0.5)
                              : border,
                          width: selectedFile != null ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: isLoading
                                  ? const LinearGradient(colors: [Color(0xFF7C3AED), Color(0xFFEC4899)])
                                  : LinearGradient(
                                      colors: selectedFile != null
                                          ? [const Color(0xFF7C3AED), const Color(0xFF5b21b6)]
                                          : [const Color(0xFF2563EB), const Color(0xFF06B6D4)],
                                    ),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: Center(
                              child: isLoading
                                  ? const SizedBox(
                                      width: 28, height: 28,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                                    )
                                  : Icon(
                                      selectedFile != null
                                          ? Icons.check_circle_rounded
                                          : Icons.upload_file_rounded,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Text(
                            isLoading
                                ? "Generating..."
                                : selectedFile != null
                                    ? "File selected"
                                    : "Tap to select file",
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),

                          const SizedBox(height: 6),

                          if (selectedFile != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF7C3AED).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                fileName(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF7C3AED),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            )
                          else
                            Text(
                              "PDF, DOCX, PPTX or TXT",
                              style: TextStyle(color: textSecondary, fontSize: 13),
                            ),

                          const SizedBox(height: 14),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              statusMessage,
                              key: ValueKey(statusMessage),
                              textAlign: TextAlign.center,
                              style: TextStyle(color: textSecondary, fontSize: 13, height: 1.4),
                            ),
                          ),

                          if (isLoading) ...[
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(99),
                              child: const LinearProgressIndicator(
                                minHeight: 3,
                                color: Color(0xFF7C3AED),
                                backgroundColor: Colors.transparent,
                              ),
                            ),
                          ],

                          if (errorMessage != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red.withOpacity(0.3)),
                              ),
                              child: Text(
                                errorMessage!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (isWide)
                    Row(
                      children: [
                        Expanded(child: _buildBtn("Select File", Icons.folder_open_rounded, false, isLoading ? null : pickFile, textSecondary, surface, border)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildPrimaryBtn(isLoading, uploadToServer)),
                      ],
                    )
                  else ...[
                    _buildBtn("Select File", Icons.folder_open_rounded, false, isLoading ? null : pickFile, textSecondary, surface, border),
                    const SizedBox(height: 10),
                    _buildPrimaryBtn(isLoading, uploadToServer),
                  ],

                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryBtn(bool isLoading, VoidCallback? onTap) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLoading
                ? [Colors.grey.shade400, Colors.grey.shade500]
                : const [Color(0xFF7C3AED), Color(0xFF5b21b6)],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            isLoading ? "Please wait..." : "✦ Generate Exam",
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }

  Widget _buildBtn(String label, IconData icon, bool isPrimary, VoidCallback? onTap,
      Color textSecondary, Color surface, Color border) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: textSecondary, size: 18),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(color: textSecondary, fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
