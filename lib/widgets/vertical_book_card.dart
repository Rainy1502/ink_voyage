import 'dart:io';
import 'package:flutter/material.dart';
import '../models/book_model.dart';

class VerticalBookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onFollow;
  final VoidCallback onAdd;
  final VoidCallback onTap;

  const VerticalBookCard({
    super.key,
    required this.book,
    required this.onFollow,
    required this.onAdd,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.zero,
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.06),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Cover
            SizedBox(
              width: 120,
              height: 170,
              // use a square/boxy cover (no rounded corners)
              child: ClipRect(child: _buildCover(context)),
            ),
            const SizedBox(height: 12),
            Text(
              book.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              'by ${book.author}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (book.genre != null && book.genre!.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  book.genre!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            // Description
            if (book.notes != null && book.notes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Text(
                  book.notes!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            const SizedBox(height: 10),
            // Stats row (example placeholders)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatItem(icon: Icons.remove_red_eye_outlined, label: '10'),
                const SizedBox(width: 12),
                _StatItem(icon: Icons.comment_outlined, label: '8'),
                const SizedBox(width: 12),
                _StatItem(
                  icon: Icons.star,
                  label: (book.rating?.toDouble() ?? 4.5).toString(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onFollow,
                    icon: const Icon(Icons.person_add_outlined),
                    label: const Text('Follow'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onAdd,
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.favorite_border),
                    label: const Text('Add'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCover(BuildContext context) {
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
        size: 36,
        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
