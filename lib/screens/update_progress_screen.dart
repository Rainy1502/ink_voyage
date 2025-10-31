import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_input.dart';

class UpdateProgressScreen extends StatefulWidget {
  final String bookId;

  const UpdateProgressScreen({super.key, required this.bookId});

  @override
  State<UpdateProgressScreen> createState() => _UpdateProgressScreenState();
}

class _UpdateProgressScreenState extends State<UpdateProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _currentPageController;
  bool _isLoading = false;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _currentPageController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<BookProvider>(context, listen: false);
      final book = provider.getBookById(widget.bookId);

      if (book != null) {
        _currentPageController.text = book.currentPage.toString();
        setState(() {
          _totalPages = book.totalPages;
        });
      }
    });
  }

  @override
  void dispose() {
    _currentPageController.dispose();
    super.dispose();
  }

  Future<void> _updateProgress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final currentPage = int.parse(_currentPageController.text);
    final provider = Provider.of<BookProvider>(context, listen: false);
    final book = provider.getBookById(widget.bookId);

    // Check if book is completed
    if (book != null && currentPage >= book.totalPages) {
      setState(() => _isLoading = false);

      // Show dialog to get rating and notes
      final result = await showDialog<Map<String, dynamic>>(
        context: context,
        barrierDismissible: false,
        builder: (context) => _CompletionDialog(),
      );

      if (result == null) return; // User cancelled

      setState(() => _isLoading = true);

      // Update progress with rating and notes
      await provider.updateProgress(
        widget.bookId,
        currentPage,
        rating: result['rating'],
        notes: result['notes'],
      );
    } else {
      // Just update progress
      await provider.updateProgress(widget.bookId, currentPage);
    }

    if (!mounted) return;

    setState(() => _isLoading = false);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Progress updated successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<BookProvider>(context);
    final book = provider.getBookById(widget.bookId);

    if (book == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Update Progress')),
        body: const Center(child: Text('Book not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Update Progress')),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Info Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: 60,
                              height: 90,
                              color: theme.colorScheme.surfaceContainerHighest,
                              child: book.imageUrl.startsWith('http')
                                  ? Image.network(
                                      book.imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                            return Icon(
                                              Icons.book,
                                              color: theme.colorScheme.onSurface
                                                  .withValues(alpha: 0.3),
                                            );
                                          },
                                    )
                                  : Icon(
                                      Icons.book,
                                      color: theme.colorScheme.onSurface
                                          .withValues(alpha: 0.3),
                                    ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  book.author,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Current Progress
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Text(
                            'Current Progress',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            '${book.progressPercentage.toStringAsFixed(0)}%',
                            style: theme.textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${book.currentPage} / ${book.totalPages} pages',
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.6,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: book.progressPercentage / 100,
                            backgroundColor:
                                theme.colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.primary,
                            ),
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Update Input
                  CustomInput(
                    label: 'Current Page',
                    hint: 'Enter current page number',
                    controller: _currentPageController,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter current page';
                      }
                      final page = int.tryParse(value);
                      if (page == null || page < 0) {
                        return 'Please enter a valid page number';
                      }
                      if (page > book.totalPages) {
                        return 'Page cannot exceed ${book.totalPages}';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildQuickActionChip('+10 pages', 10),
                      _buildQuickActionChip('+25 pages', 25),
                      _buildQuickActionChip('+50 pages', 50),
                      _buildQuickActionChip('Finish', book.totalPages),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Update Button
                  CustomButton(
                    text: 'Update Progress',
                    onPressed: _updateProgress,
                    isLoading: _isLoading,
                    width: double.infinity,
                    icon: Icons.save,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionChip(String label, int pages) {
    final theme = Theme.of(context);
    return ActionChip(
      label: Text(label),
      onPressed: () {
        final currentPage = int.tryParse(_currentPageController.text) ?? 0;
        final newPage = (currentPage + pages).clamp(0, _totalPages);
        _currentPageController.text = newPage.toString();
      },
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}

// Completion Dialog Widget
class _CompletionDialog extends StatefulWidget {
  @override
  State<_CompletionDialog> createState() => _CompletionDialogState();
}

class _CompletionDialogState extends State<_CompletionDialog> {
  int _rating = 5;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        '🎉 Buku Selesai!',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Berikan rating dan catatan untuk buku ini:',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),

            // Rating Stars
            const Text(
              'Rating',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 36,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),

            const SizedBox(height: 16),

            // Notes Input
            const Text(
              'Catatan',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notesController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tulis catatan tentang buku ini...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: const Color(0xFFF3F3F5),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Batal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'rating': _rating,
              'notes': _notesController.text.trim(),
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF9810FA),
            foregroundColor: Colors.white,
          ),
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
