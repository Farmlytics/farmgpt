// Example usage of automatic translation for database content

import 'package:flutter/material.dart';
import 'package:farmlytics/services/language_service.dart';
import 'package:farmlytics/widgets/translated_text.dart';

class TranslationUsageExample extends StatelessWidget {
  const TranslationUsageExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translation Examples')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Example 1: Using TranslatedText widget for any database content
            const Text('Example 1: TranslatedText Widget'),
            const SizedBox(height: 8),
            TranslatedText(
              'Rice',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Example 2: Using specific translation widgets
            const Text('Example 2: Specific Translation Widgets'),
            const SizedBox(height: 8),
            TranslatedCropName('Wheat', style: const TextStyle(fontSize: 16)),
            TranslatedDiseaseName('Rust', style: const TextStyle(fontSize: 16)),
            TranslatedProgramName(
              'PM Kisan',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Example 3: Programmatic translation
            const Text('Example 3: Programmatic Translation'),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: LanguageService.translateDatabaseContent('Maize'),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Translating...');
                }
                return Text(
                  snapshot.data ?? 'Maize',
                  style: const TextStyle(fontSize: 16),
                );
              },
            ),
            const SizedBox(height: 16),

            // Example 4: Batch translation
            const Text('Example 4: Batch Translation'),
            const SizedBox(height: 8),
            FutureBuilder<List<String>>(
              future: LanguageService.translateBatch([
                'Tomato',
                'Onion',
                'Chili',
              ]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Translating batch...');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (snapshot.data ?? ['Tomato', 'Onion', 'Chili'])
                      .map(
                        (item) =>
                            Text(item, style: const TextStyle(fontSize: 14)),
                      )
                      .toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Example of how to use in your existing code:

class CropListExample extends StatelessWidget {
  final List<String> cropNames; // From database

  const CropListExample({super.key, required this.cropNames});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: cropNames.length,
      itemBuilder: (context, index) {
        final cropName = cropNames[index];

        // Option 1: Use TranslatedCropName widget (recommended)
        return ListTile(
          title: TranslatedCropName(cropName),
          subtitle: Text('Crop ${index + 1}'),
        );

        // Option 2: Use FutureBuilder for more control
        // return FutureBuilder<String>(
        //   future: LanguageService.translateCrop(cropName),
        //   builder: (context, snapshot) {
        //     return ListTile(
        //       title: Text(snapshot.data ?? cropName),
        //       subtitle: Text('Crop ${index + 1}'),
        //     );
        //   },
        // );
      },
    );
  }
}

// Example of how to translate disease data:
class DiseaseCardExample extends StatelessWidget {
  final String diseaseName;
  final String description;

  const DiseaseCardExample({
    super.key,
    required this.diseaseName,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Disease name will be automatically translated
            TranslatedDiseaseName(
              diseaseName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Description will be automatically translated
            TranslatedText(description, style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
