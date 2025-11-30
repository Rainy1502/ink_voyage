import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// Function to show the publish book dialog
Future<void> showPublishBookDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) => const PublishBookDialog(),
  );
}

class PublishBookDialog extends StatefulWidget {
  const PublishBookDialog({super.key});

  @override
  State<PublishBookDialog> createState() => _PublishBookDialogState();
}

class _PublishBookDialogState extends State<PublishBookDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _totalPagesController = TextEditingController();
  final _coverUrlController = TextEditingController();
  final _contentPreviewController = TextEditingController();

  String? _selectedGenre;
  bool _isSubmitting = false;

  final List<String> _genres = [
    'Fiksi',
    'Non-Fiksi',
    'Romance',
    'Mystery',
    'Thriller',
    'Sci-Fi',
    'Fantasy',
    'Horror',
    'Biography',
    'Self-Help',
    'History',
    'Philosophy',
    'Poetry',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _totalPagesController.dispose();
    _coverUrlController.dispose();
    _contentPreviewController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final auth = firebase_auth.FirebaseAuth.instance;
      final userId = auth.currentUser?.uid;

      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Get user data to include author name
      final userDoc = await firestore.collection('users').doc(userId).get();
      final userName = userDoc.data()?['name'] ?? 'Unknown Author';

      // Default cover URL if not provided
      final coverUrl = _coverUrlController.text.trim().isEmpty
          ? 'https://via.placeholder.com/300x450/9810FA/FFFFFF?text=Book+Cover'
          : _coverUrlController.text.trim();

      // Create published book document with pending status
      final bookData = {
        'title': _titleController.text.trim(),
        'author': userName,
        'authorId': userId,
        'description': _descriptionController.text.trim(),
        'genre': _selectedGenre,
        'totalPages': int.parse(_totalPagesController.text.trim()),
        'coverUrl': coverUrl,
        'contentPreview': _contentPreviewController.text.trim(),
        'status':
            'pending', // Changed from 'published' to 'pending' for moderator approval
        'submittedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'views': 0,
        'readers': 0,
        'rating': 0.0,
        'ratingsCount': 0,
      };

      // Add to published_books collection
      await firestore.collection('published_books').add(bookData);

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Buku berhasil disubmit! Menunggu persetujuan moderator.',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mempublikasikan buku: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 12),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 657),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 27, 13, 16),
              child: Row(
                children: [
                  // Icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9D5FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFDAB2FF),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.book,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Title and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Publish New Book',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tambahkan buku baru ke perpustakaan Anda',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: const Color(0xFF717182),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Close button
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Form content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul Buku
                      _buildLabel('Judul Buku', required: true),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _titleController,
                        hint: 'Masukkan judul buku',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Judul buku wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Deskripsi
                      _buildLabel('Deskripsi', required: true),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _descriptionController,
                        hint: 'Tuliskan sinopsis atau deskripsi buku',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Deskripsi wajib diisi';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Genre & Total Halaman
                      Row(
                        children: [
                          // Genre
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Genre', required: true),
                                const SizedBox(height: 8),
                                DropdownButtonFormField<String>(
                                  initialValue: _selectedGenre,
                                  decoration: InputDecoration(
                                    hintText: 'Pilih genre',
                                    hintStyle: const TextStyle(
                                      color: Color(0xFF717182),
                                      fontSize: 14,
                                    ),
                                    filled: true,
                                    fillColor: const Color(0xFFF3F3F5),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: _genres.map((genre) {
                                    return DropdownMenuItem(
                                      value: genre,
                                      child: Text(genre),
                                    );
                                  }).toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGenre = value;
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Pilih genre';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Total Halaman
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Total Halaman', required: true),
                                const SizedBox(height: 8),
                                _buildTextField(
                                  controller: _totalPagesController,
                                  hint: 'e.g., 250',
                                  keyboardType: TextInputType.number,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Wajib diisi';
                                    }
                                    final pages = int.tryParse(value);
                                    if (pages == null || pages <= 0) {
                                      return 'Harus angka valid';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Cover Image URL
                      _buildLabel('Cover Image URL (Optional)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _coverUrlController,
                        hint: 'https://example.com/cover.jpg',
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Jika kosong, akan menggunakan cover default',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color(0xFF6A7282),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Content Preview
                      _buildLabel('Content Preview (Optional)'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        controller: _contentPreviewController,
                        hint:
                            'Kutipan atau preview dari buku Anda (untuk menarik pembaca)',
                        maxLines: 3,
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),

            // Footer buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(13, 0, 13, 27),
              child: Column(
                children: [
                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : const Text(
                              'Submit',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Cancel button
                  SizedBox(
                    width: double.infinity,
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: Colors.black.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Batal',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Row(
      children: [
        Text(text, style: const TextStyle(fontSize: 14, color: Colors.black)),
        if (required) ...[
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(fontSize: 14, color: Color(0xFFFB2C36)),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF717182), fontSize: 16),
        filled: true,
        fillColor: const Color(0xFFF3F3F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: maxLines > 1 ? 8 : 10,
        ),
      ),
    );
  }
}
