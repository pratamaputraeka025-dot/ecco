// lib/widgets/review_card.dart
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/app_theme.dart';

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 18,
                backgroundColor: AppTheme.accent.withOpacity(0.1),
                backgroundImage: review.buyerAvatar != null && review.buyerAvatar!.isNotEmpty
                    ? NetworkImage(review.buyerAvatar!)
                    : null,
                child: review.buyerAvatar == null || review.buyerAvatar!.isEmpty
                    ? Text(
                        review.buyerName?.substring(0, 1).toUpperCase() ?? '?',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accent,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.buyerName ?? 'Pembeli',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        ...List.generate(5, (i) => Icon(
                          i < review.rating ? Icons.star : Icons.star_border,
                          color: AppTheme.gold,
                          size: 14,
                        )),
                        const SizedBox(width: 8),
                        Text(
                          review.ratingLabel,
                          style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                _formatDate(review.createdAt),
                style: const TextStyle(fontSize: 10, color: AppTheme.textMuted),
              ),
            ],
          ),
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: const TextStyle(fontSize: 13, height: 1.4),
            ),
          ],
          if (review.isVerifiedPurchase) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.verified, size: 12, color: AppTheme.success),
                const SizedBox(width: 4),
                const Text(
                  'Pembelian Terverifikasi',
                  style: TextStyle(fontSize: 10, color: AppTheme.success),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}