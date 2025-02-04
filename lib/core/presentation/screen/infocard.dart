import 'package:flutter/material.dart';
export 'infocard.dart';
class InfoCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const InfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 450, // Set custom width
       // Set custom height
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data['id'] ?? 'ID',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                data['title'] ?? 'Title',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                data['description1'] ?? 'Description1 goes here...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                data['description2'] ?? 'Description2 goes here...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Text(
                data['description3'] ?? 'Description3 goes here...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: data['imagePath'] != null
                    ? Image.asset(
                        data['imagePath'],
                        width: double.infinity, // Match card width
                         // Adjust image height
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, size: 100),
                      )
                    : const Icon(Icons.image, size: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}