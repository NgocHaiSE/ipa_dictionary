import '../models/entry.dart';
import '../models/language.dart';

/// Base dictionary entries preloaded with the app
final List<Entry> BASE_ENTRIES = [
  Entry(
    id: 1,
    translations: {LanguageCode.vi: 'xin chào', LanguageCode.tay: 'xo tuộng'},
  ),
  Entry(
    id: 2,
    translations: {LanguageCode.vi: 'cảm ơn', LanguageCode.tay: 'pjom bái'},
  ),
  Entry(
    id: 3,
    translations: {LanguageCode.vi: 'tạm biệt', LanguageCode.tay: 'pay chèo'},
  ),
  Entry(
    id: 4,
    translations: {LanguageCode.vi: 'tôi', LanguageCode.tay: 'cấu'},
  ),
  Entry(
    id: 5,
    translations: {LanguageCode.vi: 'bạn', LanguageCode.tay: 'mừng'},
  ),
  Entry(
    id: 6,
    translations: {LanguageCode.vi: 'yêu', LanguageCode.tay: 'háy'},
  ),
  Entry(
    id: 7,
    translations: {LanguageCode.vi: 'nước', LanguageCode.tay: 'nặm'},
  ),
  Entry(
    id: 8,
    translations: {LanguageCode.vi: 'cơm', LanguageCode.tay: 'khảu'},
  ),
  Entry(
    id: 9,
    translations: {LanguageCode.vi: 'nhà', LanguageCode.tay: 'rườn'},
  ),
  Entry(
    id: 10,
    translations: {LanguageCode.vi: 'đẹp', LanguageCode.tay: 'đẹp'},
  ),
  // Dao language entries
  Entry(
    id: 101,
    translations: {LanguageCode.vi: 'xin chào', LanguageCode.dao: 'hào nằng'},
  ),
  Entry(
    id: 102,
    translations: {LanguageCode.vi: 'cảm ơn', LanguageCode.dao: 'nản cúng'},
  ),
  // Mong language entries
  Entry(
    id: 201,
    translations: {LanguageCode.vi: 'xin chào', LanguageCode.mong: 'nyob zoo'},
  ),
  Entry(
    id: 202,
    translations: {LanguageCode.vi: 'cảm ơn', LanguageCode.mong: 'ua tsaug'},
  ),
  // Nung language entries
  Entry(
    id: 301,
    translations: {LanguageCode.vi: 'xin chào', LanguageCode.nung: 'khảu nèn'},
  ),
  Entry(
    id: 302,
    translations: {LanguageCode.vi: 'cảm ơn', LanguageCode.nung: 'khúp khơi'},
  ),
];
