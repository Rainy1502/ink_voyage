import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/author_application_service.dart';
import '../models/author_application_model.dart';

class BecomeAuthorScreen extends StatefulWidget {
  const BecomeAuthorScreen({super.key});

  @override
  State<BecomeAuthorScreen> createState() => _BecomeAuthorScreenState();
}

class _BecomeAuthorScreenState extends State<BecomeAuthorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _motivationCtrl = TextEditingController();
  bool _submitting = false;
  final _applicationService = AuthorApplicationService();
  AuthorApplication? _existingApplication;

  @override
  void initState() {
    super.initState();
    _checkExistingApplication();
  }

  Future<void> _checkExistingApplication() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.currentUser != null) {
      final application = await _applicationService.getApplicationByUserId(
        auth.currentUser!.id,
      );
      if (mounted) {
        setState(() {
          _existingApplication = application;
        });
      }
    }
  }

  @override
  void dispose() {
    _bioCtrl.dispose();
    _expCtrl.dispose();
    _motivationCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    // Check if already has pending application
    if (_existingApplication != null &&
        _existingApplication!.status == 'pending') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anda sudah memiliki aplikasi yang sedang direview'),
        ),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    try {
      debugPrint('🚀 Starting author application submission...');
      final auth = Provider.of<AuthProvider>(context, listen: false);
      debugPrint('👤 BEFORE SUBMIT - User role: ${auth.currentUser?.role}');
      debugPrint(
        '👤 BEFORE SUBMIT - User status: ${auth.currentUser?.authorApplicationStatus}',
      );

      final success = await auth.becomeAuthor(
        bio: _bioCtrl.text.trim(),
        experience: _expCtrl.text.trim(),
        motivation: _motivationCtrl.text.trim(),
      );

      if (!mounted) return;
      setState(() => _submitting = false);

      if (success) {
        debugPrint('✅ Application submitted successfully');
        debugPrint('👤 AFTER SUBMIT - User role: ${auth.currentUser?.role}');
        debugPrint(
          '👤 AFTER SUBMIT - User status: ${auth.currentUser?.authorApplicationStatus}',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Pengajuan menjadi Author terkirim dan sedang direview',
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      } else {
        final message = auth.errorMessage ?? 'Gagal mengajukan menjadi author';
        debugPrint('❌ Application failed: $message');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('💥 EXCEPTION in _submit: $e');
      debugPrint('Stack trace: $stackTrace');
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // If has pending application, show status instead of form
    if (_existingApplication != null &&
        _existingApplication!.status == 'pending') {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Status Aplikasi'),
          backgroundColor: const Color(0xFF8200DB),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  border: Border.all(
                    color: const Color(0xFFBEDBFF),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.schedule,
                      size: 64,
                      color: Color(0xFF1447E6),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Aplikasi Sedang Direview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C398E),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Diajukan pada: ${_existingApplication!.appliedAtFormatted}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1447E6),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Moderator sedang meninjau aplikasi Anda untuk menjadi Author. Anda akan diberi notifikasi setelah direview.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1447E6),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menjadi Author'),
        backgroundColor: const Color(0xFF8200DB),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Show rejected status if previous application was rejected
              if (_existingApplication != null &&
                  _existingApplication!.status == 'rejected') ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    border: Border.all(
                      color: const Color(0xFFFECACA),
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Color(0xFFDC2626),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Aplikasi Sebelumnya Ditolak',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                            if (_existingApplication!.notes != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Alasan: ${_existingApplication!.notes}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFDC2626),
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            const Text(
                              'Anda dapat mengajukan kembali dengan memperbaiki aplikasi Anda.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF6EDFF),
                  border: Border.all(color: const Color(0xFFE9D4FF)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3FF),
                        border: Border.all(color: const Color(0xFFE9D4FF)),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Image.asset(
                          'assets/icons/star.png',
                          width: 28,
                          height: 28,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.auto_awesome,
                                color: Color(0xFF8200DB),
                                size: 28,
                              ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        'Sebagai Author, Anda akan dapat:\n• Mempublikasikan buku original Anda\n• Mendapatkan followers dan reader\n• Melihat analytics (views, ratings, readers)\n• Berinteraksi dengan reader melalui reviews',
                        style: const TextStyle(fontSize: 14, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Bio / Tentang Anda',
                  style: TextStyle(fontSize: 14, color: Color(0xFF101828)),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _bioCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ceritakan tentang diri Anda sebagai penulis...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9AA0A6),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F7F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // no counter text
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Isi bio Anda' : null,
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Pengalaman Menulis',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF101828),
                        ),
                      ),
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _expCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Jelaskan pengalaman menulis Anda (karya sebelumnya, publikasi, penghargaan, dll)...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9AA0A6),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F7F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Jelaskan pengalaman menulis Anda'
                    : null,
              ),

              const SizedBox(height: 12),

              Align(
                alignment: Alignment.centerLeft,
                child: RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Mengapa Ingin Menjadi Author?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF101828),
                        ),
                      ),
                      TextSpan(
                        text: ' *',
                        style: TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _motivationCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'Jelaskan motivasi dan tujuan Anda menjadi author di platform ini...',
                  hintStyle: const TextStyle(
                    color: Color(0xFF9AA0A6),
                    fontSize: 16,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F7F8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Jelaskan motivasi Anda'
                    : null,
              ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8200DB),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _submitting
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Jadi Author'),
              ),

              const SizedBox(height: 8),

              OutlinedButton(
                onPressed: _submitting
                    ? null
                    : () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Batal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
