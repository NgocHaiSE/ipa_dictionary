import 'language.dart';

/// Dictionary entry with translations in multiple languages
class Entry {
  final int id;
  final Map<LanguageCode, String> translations;
  final Map<LanguageCode, String>? lemmaAudios;
  final String? notes;

  Entry({
    required this.id,
    required this.translations,
    this.lemmaAudios,
    this.notes,
  });

  /// Create entry from database row
  factory Entry.fromDb({
    required int id,
    required Map<LanguageCode, String> translations,
    Map<LanguageCode, String>? lemmaAudios,
    String? notes,
  }) {
    return Entry(
      id: id,
      translations: translations,
      lemmaAudios: lemmaAudios,
      notes: notes,
    );
  }

  /// Copy with modifications
  Entry copyWith({
    int? id,
    Map<LanguageCode, String>? translations,
    Map<LanguageCode, String>? lemmaAudios,
    String? notes,
  }) {
    return Entry(
      id: id ?? this.id,
      translations: translations ?? Map.from(this.translations),
      lemmaAudios: lemmaAudios ?? (this.lemmaAudios != null ? Map.from(this.lemmaAudios!) : null),
      notes: notes ?? this.notes,
    );
  }

  /// Get translation for a specific language
  String? getTranslation(LanguageCode code) => translations[code];

  /// Get audio URI for a specific language
  String? getAudio(LanguageCode code) => lemmaAudios?[code];
}
