import 'dart:io';
import 'package:flutter/material.dart';
import '../models/book_model.dart';

/// A compact version of the LargeBookCard used for horizontal carousels.
/// Keeps layout shallow and removes action buttons to avoid vertical overflow.
class CompactBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  const CompactBookCard({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = book.progressPercentage;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Small cover image
              SizedBox(
                width: 120,
                height: 160,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildCoverImage(context),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                book.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                book.author,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Compact progress indicator
              SizedBox(
                height: 8,
                width: 140,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    minHeight: 8,
                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    final url = book.imageUrl;
    if (url.startsWith('http')) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => _placeholder(context),
      );
    }
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => _placeholder(context),
      );
    }
    return Image.file(
      File(url),
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => _placeholder(context),
    );
  }

  Widget _placeholder(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Icon(
        Icons.book,
        size: 32,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
    );
  }
}
