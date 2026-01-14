import 'package:flutter/material.dart';
import '../models/rich_doc.dart';
import '../theme/app_theme.dart';

class RichDocViewWidget extends StatelessWidget {
  final RichDoc? doc;

  const RichDocViewWidget({super.key, this.doc});

  @override
  Widget build(BuildContext context) {
    if (doc == null || doc!.blocks.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Text(
          'Chưa có ghi chú/ví dụ.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderPrimary, width: 2),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ghi chú & ví dụ',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.bgPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          ...doc!.blocks.map((block) => _buildBlock(block)),
        ],
      ),
    );
  }

  Widget _buildBlock(RichBlock block) {
    if (block is ParagraphBlock) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          block.text,
          style: TextStyle(
            fontSize: block.fontSize ?? 13,
            color: AppColors.bgPrimary,
            fontWeight: block.bold ? FontWeight.bold : FontWeight.normal,
            fontStyle: block.italic ? FontStyle.italic : FontStyle.normal,
            height: 1.5,
          ),
        ),
      );
    }

    if (block is ImageBlock) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                block.uri,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 180,
                    color: AppColors.bgTertiary,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.broken_image,
                      color: AppColors.textMuted,
                      size: 48,
                    ),
                  );
                },
              ),
            ),
            if (block.caption != null) ...[
              const SizedBox(height: 6),
              Text(
                block.caption!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      );
    }

    if (block is AudioBlock) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.accentPrimary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.play_arrow, color: AppColors.bgPrimary, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'Nghe audio',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.bgPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (block.caption != null) ...[
              const SizedBox(height: 6),
              Text(
                block.caption!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
