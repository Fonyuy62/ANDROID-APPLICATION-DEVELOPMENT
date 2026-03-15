// ============================================================
// home_screen.dart — Main Application Screen
// Full Grade Calculator Desktop GUI
// ============================================================

import 'package:flutter/material.dart';
import '../models/calculator.dart';
import '../utils/app_theme.dart';
import '../utils/excel_service.dart';
import '../widgets/app_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ---- Delayed init (lazy) ----
  late final GradeCalculator _calculator;
  late final ExcelService _excelService;
  late final AnimationController _fadeController;
  late final Animation<double> _fadeAnimation;

  // ---- State ----
  List<StudentRecord> _students = [];
  bool _isUploading = false;
  bool _isDownloading = false;
  String? _uploadedFileName;
  String? _statusMessage;
  bool _statusIsError = false;

  @override
  void initState() {
    super.initState();
    // Delayed initialisation
    _calculator = GradeCalculator();
    _excelService = ExcelService();

    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnimation = CurvedAnimation(
        parent: _fadeController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // ---- Upload handler (lambda-style) ----
  Future<void> _handleUpload() async {
    setState(() {
      _isUploading = true;
      _statusMessage = null;
    });

    try {
      final records = await _excelService.pickAndReadFile(_calculator);

      if (records == null) {
        setState(() {
          _isUploading = false;
          _statusMessage = 'No file selected.';
          _statusIsError = false;
        });
        return;
      }

      if (records.isEmpty) {
        setState(() {
          _isUploading = false;
          _statusMessage = 'File has no student data. Check column headers.';
          _statusIsError = true;
        });
        return;
      }

      setState(() {
        _students = records;
        _isUploading = false;
        _statusMessage = '✓ Successfully loaded ${records.length} students.';
        _statusIsError = false;
      });

      _fadeController.forward(from: 0);
    } catch (e) {
      setState(() {
        _isUploading = false;
        _statusMessage = 'Error reading file: ${e.toString()}';
        _statusIsError = true;
      });
    }
  }

  // ---- Download handler ----
  Future<void> _handleDownload() async {
    if (_students.isEmpty) return;

    setState(() => _isDownloading = true);

    try {
      final path = await _excelService.downloadResults(_students, _calculator);

      setState(() {
        _isDownloading = false;
        _statusMessage = path != null
            ? '✓ File saved to: $path'
            : 'Download cancelled.';
        _statusIsError = false;
      });
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _statusMessage = 'Error saving file: ${e.toString()}';
        _statusIsError = true;
      });
    }
  }

  // ---- Clear state ----
  void _handleClear() => setState(() {
        _students = [];
        _uploadedFileName = null;
        _statusMessage = null;
        _fadeController.reset();
      });

  // ---- Build ----
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          _buildTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 32),
                  _buildUploadSection(),
                  if (_statusMessage != null) ...[
                    const SizedBox(height: 16),
                    _buildStatusBar(),
                  ],
                  if (_students.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryCards(),
                          const SizedBox(height: 32),
                          _buildResultsSection(),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Top AppBar ----
  Widget _buildTopBar() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(bottom: BorderSide(color: AppTheme.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          // Logo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Grade Calculator',
                  style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              Text(_calculator.calculatorName,
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 11)),
            ],
          ),
          const Spacer(),
          // Toolbar actions
          if (_students.isNotEmpty) ...[
            GlowButton(
              label: 'Download Results',
              icon: Icons.download_rounded,
              onPressed: _isDownloading ? null : _handleDownload,
              isLoading: _isDownloading,
              color: AppTheme.passGreen,
            ),
            const SizedBox(width: 12),
            GlowButton(
              label: 'Clear',
              icon: Icons.refresh_rounded,
              onPressed: _handleClear,
              color: AppTheme.border,
            ),
          ],
        ],
      ),
    );
  }

  // ---- Upload Area ----
  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upload Student File',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text(
          'Upload an Excel file containing student IDs, names, and exam marks.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 24),
        DropZone(onTap: _handleUpload, isLoading: _isUploading),
        const SizedBox(height: 16),
        _buildFormatGuide(),
      ],
    );
  }

  // ---- Format guide ----
  Widget _buildFormatGuide() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.accent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded,
              color: AppTheme.accentLight, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                children: [
                  TextSpan(text: 'Expected columns: '),
                  TextSpan(
                      text: 'Student ID',
                      style: TextStyle(
                          color: AppTheme.accentLight,
                          fontWeight: FontWeight.w600)),
                  TextSpan(text: ', '),
                  TextSpan(
                      text: 'Student Name',
                      style: TextStyle(
                          color: AppTheme.accentLight,
                          fontWeight: FontWeight.w600)),
                  TextSpan(text: ', '),
                  TextSpan(
                      text: 'Exam Mark',
                      style: TextStyle(
                          color: AppTheme.accentLight,
                          fontWeight: FontWeight.w600)),
                  TextSpan(
                      text:
                          '  •  Marks should be 0–100  •  First row must be headers'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Status bar ----
  Widget _buildStatusBar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: (_statusIsError ? AppTheme.failRed : AppTheme.passGreen)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
            color: (_statusIsError ? AppTheme.failRed : AppTheme.passGreen)
                .withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(
            _statusIsError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: _statusIsError ? AppTheme.failRed : AppTheme.passGreen,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _statusMessage!,
              style: TextStyle(
                color: _statusIsError ? AppTheme.failRed : AppTheme.passGreen,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---- Summary Cards ----
  Widget _buildSummaryCards() {
    // Lambda for percentage string
    final avgStr = '${_calculator.classAverage(_students).toStringAsFixed(1)}%';
    final passStr = _calculator.passCount(_students).toString();
    final failStr = _calculator.failCount(_students).toString();
    final highStr = '${_calculator.highestMark(_students).toStringAsFixed(1)}%';
    final lowStr = '${_calculator.lowestMark(_students).toStringAsFixed(1)}%';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Class Summary',
            style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            StatCard(
                label: 'TOTAL STUDENTS',
                value: _students.length.toString(),
                icon: Icons.people_alt_rounded),
            StatCard(
                label: 'CLASS AVERAGE',
                value: avgStr,
                icon: Icons.analytics_rounded,
                valueColor: AppTheme.accentLight),
            StatCard(
                label: 'PASS',
                value: passStr,
                icon: Icons.check_circle_rounded,
                valueColor: AppTheme.passGreen),
            StatCard(
                label: 'FAIL',
                value: failStr,
                icon: Icons.cancel_rounded,
                valueColor: AppTheme.failRed),
            StatCard(
                label: 'HIGHEST MARK',
                value: highStr,
                icon: Icons.trending_up_rounded,
                valueColor: AppTheme.gradeGold),
            StatCard(
                label: 'LOWEST MARK',
                value: lowStr,
                icon: Icons.trending_down_rounded,
                valueColor: AppTheme.textSecondary),
          ],
        ),
      ],
    );
  }

  // ---- Results Table ----
  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Student Results',
                style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const Spacer(),
            Text('${_students.length} records',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
        const SizedBox(height: 16),
        StudentsDataTable(students: _students),
      ],
    );
  }
}
