import 'package:flutter/material.dart';
import 'package:farmlytics/services/language_service.dart';

class TranslatedText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool useCache;

  const TranslatedText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.useCache = true,
  });

  @override
  Widget build(BuildContext context) {
    // Check if translation is already cached
    final cachedTranslation = LanguageService.getCachedTranslation(text);
    if (cachedTranslation != null) {
      return Text(
        cachedTranslation,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    // If not cached, use FutureBuilder but don't show original text
    return FutureBuilder<String>(
      future: useCache
          ? LanguageService.translateWithCache(text)
          : LanguageService.translateDatabaseContent(text),
      builder: (context, snapshot) {
        // Show loading indicator or empty space while translating
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: style?.fontSize ?? 14,
            child: const Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            ),
          );
        }

        return Text(
          snapshot.data ?? text,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

class TranslatedCropName extends StatelessWidget {
  final String cropName;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedCropName(
    this.cropName, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // Check if translation is already cached
    final cachedTranslation = LanguageService.getCachedTranslation(cropName);
    if (cachedTranslation != null) {
      return Text(
        cachedTranslation,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    // If not cached, use FutureBuilder
    return FutureBuilder<String>(
      future: LanguageService.translateCrop(cropName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: style?.fontSize ?? 14,
            child: const Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            ),
          );
        }

        return Text(
          snapshot.data ?? cropName,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

class TranslatedDiseaseName extends StatelessWidget {
  final String diseaseName;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedDiseaseName(
    this.diseaseName, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // Check if translation is already cached
    final cachedTranslation = LanguageService.getCachedTranslation(diseaseName);
    if (cachedTranslation != null) {
      return Text(
        cachedTranslation,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    // If not cached, use FutureBuilder
    return FutureBuilder<String>(
      future: LanguageService.translateDisease(diseaseName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: style?.fontSize ?? 14,
            child: const Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            ),
          );
        }

        return Text(
          snapshot.data ?? diseaseName,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}

class TranslatedProgramName extends StatelessWidget {
  final String programName;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const TranslatedProgramName(
    this.programName, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    // Check if translation is already cached
    final cachedTranslation = LanguageService.getCachedTranslation(programName);
    if (cachedTranslation != null) {
      return Text(
        cachedTranslation,
        style: style,
        textAlign: textAlign,
        maxLines: maxLines,
        overflow: overflow,
      );
    }

    // If not cached, use FutureBuilder
    return FutureBuilder<String>(
      future: LanguageService.translateProgram(programName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: style?.fontSize ?? 14,
            child: const Center(
              child: SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 1.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                ),
              ),
            ),
          );
        }

        return Text(
          snapshot.data ?? programName,
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }
}
