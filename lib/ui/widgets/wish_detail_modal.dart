import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/wish_model.dart';
import '../../utils/formatters.dart';
import '../styles/app_theme.dart';

class WishDetailModal extends StatelessWidget {
  final WishModel wish;

  const WishDetailModal({super.key, required this.wish});

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hasLink = wish.observation.startsWith('http');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.royalBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(Icons.card_giftcard, color: AppTheme.royalBlue, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wish.name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkBlue,
                      ),
                    ),
                    Text(
                      wish.category,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          const Text('Valor do Item:', style: TextStyle(color: Colors.grey)),
          Text(
            Formatters.currency(wish.value),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.royalBlue,
            ),
          ),

          const SizedBox(height: 24),

          if (wish.observation.isNotEmpty) ...[
            const Text('Observações / Link:', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: hasLink ? () => _launchURL(wish.observation) : null,
              child: Text(
                wish.observation,
                style: TextStyle(
                  fontSize: 16,
                  color: hasLink ? Colors.blue : AppTheme.darkBlue,
                  decoration: hasLink ? TextDecoration.underline : TextDecoration.none,
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ],
      ),
    );
  }
}