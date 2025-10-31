import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../models/book_model.dart';
import '../providers/book_provider.dart';

// Function to show the dialog
Future<void> showAddBookDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) => const AddBookDialog(),
  );
}

class AddBookDialog extends StatefulWidget {
  const AddBookDialog({super.key});

  @override
  State<AddBookDialog> createState() => _AddBookDialogState();
}

class _AddBookDialogState extends State<AddBookDialog>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _genreController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _totalPagesController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isLoading = false;

  // Tab controller for URL/Upload tabs
  late TabController _tabController;

  // For Upload tab
  File? _uploadedImage;
  final ImagePicker _picker = ImagePicker();

  // For URL preview
  bool _showUrlPreview = false;
  bool _urlImageError = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Listen to tab changes to update height
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
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
        const SnackBar(content: Text('Masukkan URL gambar terlebih dahulu!')),
      );
      return;
    }

    if (!_imageUrlController.text.startsWith('http')) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('URL tidak valid!')));
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

  Future<void> _addBook() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if image is provided (either URL or Upload)
    if (_tabController.index == 0 && _imageUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('URL gambar wajib diisi!')));
      return;
    }

    if (_tabController.index == 1 && _uploadedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih gambar terlebih dahulu!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Determine which image to use
    String imageUrl;
    if (_tabController.index == 0) {
      // URL tab
      imageUrl = _imageUrlController.text.trim();
    } else {
      // Upload tab
      imageUrl = _uploadedImage!.path; // Store local file path
    }

    final newBook = Book(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      author: _authorController.text.trim(),
      imageUrl: imageUrl,
      totalPages: int.parse(_totalPagesController.text),
      genre: _genreController.text.trim().isEmpty
          ? null
          : _genreController.text.trim(),
      createdAt: DateTime.now(),
    );

    await Provider.of<BookProvider>(context, listen: false).addBook(newBook);

    if (!mounted) return;

    setState(() => _isLoading = false);

    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Buku berhasil ditambahkan')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
                      children: const [
                        Text(
                          'Tambah Buku Baru',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0A0A0A),
                            height: 1.0,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Masukkan detail buku yang ingin ditambahkan',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF717182),
                            height: 1.43,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  // Close button positioned at top right
                  Positioned(
                    top: -12,
                    right: -12,
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

                      // Total Pages
                      _buildInputField(
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

                      const SizedBox(height: 16),

                      // Notes
                      _buildNotesField(isDark),

                      const SizedBox(height: 24),

                      // Add Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _addBook,
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
                                  'Tambah Buku',
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
              border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
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
                    color: Colors.black.withValues(alpha: 0.3),
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
                    color: Colors.black.withValues(alpha: 0.1),
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
                    decoration: const BoxDecoration(
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
