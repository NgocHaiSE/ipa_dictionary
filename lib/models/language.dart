/// Language codes supported by the dictionary
enum LanguageCode {
  vi,
  tay,
  mong,
  nung,
  dao,
  lolo,
  sanchi,
  sanchay,
  sandiu,
}

/// Metadata for each language
class LangMeta {
  final LanguageCode code;
  final String label;
  final String ttsLang;

  const LangMeta({
    required this.code,
    required this.label,
    required this.ttsLang,
  });
}

/// List of all supported languages
const List<LangMeta> LANGS = [
  LangMeta(code: LanguageCode.vi, label: 'Tiếng Việt', ttsLang: 'vi-VN'),
  LangMeta(code: LanguageCode.tay, label: 'Tiếng Tày', ttsLang: 'vi-VN'),
  LangMeta(code: LanguageCode.mong, label: 'Tiếng Mông', ttsLang: 'vi-VN'),
  LangMeta(code: LanguageCode.nung, label: 'Tiếng Nùng', ttsLang: 'vi-VN'),
  LangMeta(code: LanguageCode.dao, label: 'Tiếng Dao', ttsLang: 'vi-VN'),
  LangMeta(code: LanguageCode.lolo, label: 'Tiếng Lô Lô', ttsLang: 'vi-VN'),
  LangMeta(code: LanguageCode.sanchi, label: 'Tiếng Sán chỉ', ttsLang: 'vi-VN'),
  LangMeta(code: LanguageCode.sanchay, label: 'Tiếng Sán chay', ttsLang: 'vi-VN'),
  LangMeta(code: LanguageCode.sandiu, label: 'Tiếng Sán Dìu', ttsLang: 'vi-VN'),
];

/// Get metadata for a language code
LangMeta getLangMeta(LanguageCode code) {
  return LANGS.firstWhere((l) => l.code == code);
}

/// Dictionary pair - combinations of Vietnamese with other languages
class DictionaryPair {
  final String id;
  final String label;
  final LanguageCode source;
  final LanguageCode target;

  const DictionaryPair({
    required this.id,
    required this.label,
    required this.source,
    required this.target,
  });
}

/// Available dictionary pairs
const List<DictionaryPair> DICTIONARY_PAIRS = [
  DictionaryPair(id: 'vi-tay', label: 'Việt - Tày', source: LanguageCode.vi, target: LanguageCode.tay),
  DictionaryPair(id: 'vi-dao', label: 'Việt - Dao', source: LanguageCode.vi, target: LanguageCode.dao),
  DictionaryPair(id: 'vi-mong', label: 'Việt - Mông', source: LanguageCode.vi, target: LanguageCode.mong),
  DictionaryPair(id: 'vi-lolo', label: 'Việt - Lô Lô', source: LanguageCode.vi, target: LanguageCode.lolo),
  DictionaryPair(id: 'vi-sanchay', label: 'Việt - Sán Chay', source: LanguageCode.vi, target: LanguageCode.sanchay),
  DictionaryPair(id: 'vi-sandiu', label: 'Việt - Sán Dìu', source: LanguageCode.vi, target: LanguageCode.sandiu),
  DictionaryPair(id: 'vi-sanchi', label: 'Việt - Sán chỉ', source: LanguageCode.vi, target: LanguageCode.sanchi),
  DictionaryPair(id: 'vi-nung', label: 'Việt - Nùng', source: LanguageCode.vi, target: LanguageCode.nung),
];
