import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/book_model.dart';
import '../providers/book_provider.dart';

// Function to show the edit dialog
Future<void> showEditBookDialog(BuildContext context, String bookId) {
  return showDialog(
    context: context,
    builder: (context) => EditBookDialog(bookId: bookId),
  );
}

class EditBookDialog extends StatefulWidget {
  final String bookId;

  const EditBookDialog({super.key, required this.bookId});

  @override
  State<EditBookDialog> createState() => _EditBookDialogState();
}

class _EditBookDialogState extends State<EditBookDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _authorController;
  late TextEditingController _genreController;
  late TextEditingController _imageUrlController;
  late TextEditingController _totalPagesController;
  late TextEditingController _currentPageController;
  late TextEditingController _notesController;
  bool _isLoading = false;

  // Status dropdown
  String _selectedStatus = 'not-started';

  // Rating for completed books
  int _rating = 0;
  int _hoverRating = 0;

  // Tab controller for URL/Upload tabs
  late TabController _tabController;

  // For Upload tab
  File? _uploadedImage;
  final ImagePicker _picker = ImagePicker();

  // For URL preview
  bool _showUrlPreview = false;
  bool _urlImageError = false;

  // Book data
  Book? _book;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _authorController = TextEditingController();
    _genreController = TextEditingController();
    _imageUrlController = TextEditingController();
    _totalPagesController = TextEditingController();
    _currentPageController = TextEditingController();
    _notesController = TextEditingController();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to tab changes to update height
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Load book data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BookProvider>(context, listen: false);
      _book = provider.getBookById(widget.bookId);

      if (_book != null) {
        _titleController.text = _book!.title;
        _authorController.text = _book!.author;
        _genreController.text = _book!.genre ?? '';
        _totalPagesController.text = _book!.totalPages.toString();
        _currentPageController.text = _book!.currentPage.toString();
        _selectedStatus = _book!.status;
        _rating = _book!.rating ?? 0; // Load rating from book
        _notesController.text = _book!.notes ?? ''; // Load notes from book

        // Handle image
        if (_book!.imageUrl.startsWith('http')) {
          _imageUrlController.text = _book!.imageUrl;
          _showUrlPreview = true;
          _tabController.index = 0; // URL tab
        } else if (_book!.imageUrl.isNotEmpty) {
          _uploadedImage = File(_book!.imageUrl);
          _tabController.index = 1; // Upload tab
        }

        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _genreController.dispose();
    _imageUrlController.dispose();
    _totalPagesController.dispose();
    _currentPageController.dispose();
    _notesController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          _uploadedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error memilih gambar: $e')));
    }
  }

  void _checkUrlImage() {
    if (_imageUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan URL gambar terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _showUrlPreview = true;
      _urlImageError = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Preview gambar ditampilkan!')),
    );
  }

  Future<void> _updateBook() async {
    if (!_formKey.currentState!.validate()) return;
    if (_book == null) return;

    setState(() => _isLoading = true);

    // Determine which image to use
    String? finalImageUrl;
    if (_tabController.index == 0) {
      // URL tab
      finalImageUrl = _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim();
    } else {
      // Upload tab
      if (_uploadedImage != null) {
        finalImageUrl = _uploadedImage!.path; // Store local file path
      }
    }

    final updatedBook = _book!.copyWith(
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      genre: _genreController.text.trim().isEmpty
          ? null
          : _genreController.text.trim(),
      imageUrl: finalImageUrl ?? _book!.imageUrl,
      totalPages: int.parse(_totalPagesController.text),
      currentPage: int.parse(_currentPageController.text),
      status: _selectedStatus,
      rating: _selectedStatus == 'completed' ? _rating : null,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      updatedAt: DateTime.now(),
    );

    await Provider.of<BookProvider>(
      context,
      listen: false,
    ).updateBook(widget.bookId, updatedBook);

    if (!mounted) return;

    setState(() => _isLoading = false);

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Buku berhasil diperbarui')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (_book == null) {
      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF231832) : Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 383, maxHeight: 926),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: Colors.black.withValues(alpha: 0.1),
            width: 1.333,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dialog Header
            Padding(
              padding: const EdgeInsets.fromLTRB(11, 21, 11, 23),
              child: Stack(
                children: [
                  // Centered content
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Edit Buku',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A0A0A),
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Perbarui informasi buku',
                          style: TextStyle(
                            fontSize: 14,
                            color: const Color(0xFF717182),
                            height: 1.43,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Close button positioned at top right
                  Positioned(
                    top: -4,
                    right: -4,
                    child: IconButton(
                      icon: Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.black.withValues(alpha: 0.7),
                      ),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Book Title
                      _buildInputField(
                        label: 'Judul Buku',
                        hint: 'Masukkan judul buku',
                        controller: _titleController,
                        isDark: isDark,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Judul buku wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Author
                      _buildInputField(
                        label: 'Penulis',
                        hint: 'Masukkan nama penulis',
                        controller: _authorController,
                        isDark: isDark,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama penulis wajib diisi';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // Genre
                      _buildInputField(
                        label: 'Genre',
                        hint: 'Fiksi, Non-Fiksi, Biografi, dll',
                        controller: _genreController,
                        isDark: isDark,
                      ),

                      const SizedBox(height: 16),

                      // Cover Book Tab Section
                      _buildCoverBookSection(isDark),

                      const SizedBox(height: 16),

                      // Status Dropdown
                      _buildStatusDropdown(isDark),

                      const SizedBox(height: 16),

                      // Total Pages + Current Page (side by side)
                      _buildPagesRow(isDark),

                      const SizedBox(height: 16),

                      // Rating (only show if status is completed)
                      if (_selectedStatus == 'completed')
                        _buildRatingSection(isDark),

                      if (_selectedStatus == 'completed')
                        const SizedBox(height: 16),

                      // Notes
                      _buildNotesField(isDark),

                      const SizedBox(height: 24),

                      // Update Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateBook,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: const Color(0xFF9810FA),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Perbarui',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Cancel Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.white,
                            side: const BorderSide(
                              color: Color(0xFF0A0A0A),
                              width: 1.333,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Color(0xFF0A0A0A),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get dynamic height for TabBarView
  double _getTabHeight() {
    if (_tabController.index == 0) {
      // URL Tab: smaller height when no preview, larger when showing preview
      return _showUrlPreview ? 240.0 : 60.0;
    } else {
      // Upload Tab: fixed height for file picker area
      return _uploadedImage != null ? 180.0 : 120.0;
    }
  }

  Widget _buildCoverBookSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cover Buku',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF0A0A0A),
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFFECECF0),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.transparent, width: 1.333),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: const Color(0xFF0A0A0A),
            unselectedLabelColor: const Color(0xFF0A0A0A),
            labelStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
            ),
            tabs: const [
              Tab(text: 'URL'),
              Tab(text: 'Upload'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: SizedBox(
            height: _getTabHeight(),
            child: TabBarView(
              controller: _tabController,
              children: [_buildUrlTab(isDark), _buildUploadTab(isDark)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUrlTab(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _imageUrlController,
                style: const TextStyle(fontSize: 16, color: Color(0xFF0A0A0A)),
                decoration: InputDecoration(
                  hintText: 'https://example.com/cover.jpg',
                  hintStyle: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF717182),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3F3F5),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                      width: 1.333,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                      width: 1.333,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xFF9810FA),
                      width: 1.333,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _checkUrlImage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9810FA),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Cek Gambar',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
        if (_showUrlPreview && !_urlImageError) ...[
          const SizedBox(height: 12),
          Container(
            width: 160,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                _imageUrlController.text.trim(),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) {
                      setState(() {
                        _urlImageError = true;
                      });
                    }
                  });
                  return Icon(
                    Icons.error,
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.3),
                  );
                },
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUploadTab(bool isDark) {
    return Column(
      children: [
        ElevatedButton.icon(
          onPressed: _pickImage,
          icon: const Icon(Icons.upload_file, size: 18),
          label: const Text(
            'Pilih Gambar',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9810FA),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (_uploadedImage != null) ...[
          const SizedBox(height: 12),
          Stack(
            children: [
              Container(
                width: 120,
                height: 85,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(_uploadedImage!, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: -8,
                right: -8,
                child: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _uploadedImage = null;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildStatusDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF0A0A0A),
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _selectedStatus,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF3F3F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 1.333,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 1.333,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF9810FA),
                width: 1.333,
              ),
            ),
          ),
          dropdownColor: isDark ? const Color(0xFF231832) : Colors.white,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? Colors.white.withValues(alpha: 0.9)
                : const Color(0xFF0A0A0A),
          ),
          items: const [
            DropdownMenuItem(value: 'not-started', child: Text('Belum Dibaca')),
            DropdownMenuItem(value: 'reading', child: Text('Sedang Dibaca')),
            DropdownMenuItem(value: 'completed', child: Text('Selesai')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedStatus = value!;
              // Reset rating if status is not completed
              if (_selectedStatus != 'completed') {
                _rating = 0;
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildPagesRow(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildInputField(
            label: 'Total Halaman',
            hint: '300',
            controller: _totalPagesController,
            isDark: isDark,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Total halaman wajib diisi';
              }
              final pages = int.tryParse(value);
              if (pages == null || pages <= 0) {
                return 'Masukkan angka yang valid';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInputField(
            label: 'Halaman Saat Ini',
            hint: '0',
            controller: _currentPageController,
            isDark: isDark,
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Halaman saat ini wajib diisi';
              }
              final currentPage = int.tryParse(value);
              final totalPages = int.tryParse(_totalPagesController.text);
              if (currentPage == null || currentPage < 0) {
                return 'Masukkan angka yang valid';
              }
              if (totalPages != null && currentPage > totalPages) {
                return 'Tidak boleh lebih dari total';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rating Buku',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF0A0A0A),
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            ...List.generate(5, (index) {
              final starValue = index + 1;
              return MouseRegion(
                onEnter: (_) => setState(() => _hoverRating = starValue),
                onExit: (_) => setState(() => _hoverRating = 0),
                child: GestureDetector(
                  onTap: () => setState(() => _rating = starValue),
                  child: Icon(
                    (_hoverRating >= starValue || _rating >= starValue)
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 32,
                  ),
                ),
              );
            }),
            const SizedBox(width: 16),
            const Text(
              '',
              style: TextStyle(fontSize: 14, color: Color(0xFF0A0A0A)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Catatan',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF0A0A0A),
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _notesController,
          maxLines: 4,
          style: const TextStyle(fontSize: 16, color: Color(0xFF0A0A0A)),
          decoration: InputDecoration(
            hintText: 'Tambahkan catatan atau review...',
            hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF717182)),
            filled: true,
            fillColor: const Color(0xFFF3F3F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.3)
                    : const Color(0xFF9810FA),
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE7000B), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE7000B), width: 1),
            ),
            errorStyle: const TextStyle(fontSize: 12, color: Color(0xFFE7000B)),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isDark,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF0A0A0A),
            height: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 16, color: Color(0xFF0A0A0A)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF717182)),
            filled: true,
            fillColor: const Color(0xFFF3F3F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 4,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 1.333,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Colors.transparent,
                width: 1.333,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF9810FA),
                width: 1.333,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFE7000B),
                width: 1.333,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFFE7000B),
                width: 1.333,
              ),
            ),
            errorStyle: const TextStyle(fontSize: 12, color: Color(0xFFE7000B)),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
