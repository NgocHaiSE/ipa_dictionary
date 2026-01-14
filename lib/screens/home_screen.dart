import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/entry.dart';
import '../models/language.dart';
import '../models/rich_doc.dart';
import '../theme/app_theme.dart';
import '../widgets/rich_doc_view.dart';

class HomeScreen extends StatefulWidget {
  final List<Entry> entries;
  final Map<String, RichDoc> docsMap;
  final LanguageCode sourceLang;
  final LanguageCode targetLang;
  final Function(LanguageCode) onChangeSourceLang;
  final Function(LanguageCode) onChangeTargetLang;
  final VoidCallback onNavigateCreate;
  final Function(int) onNavigateEdit;
  final Function(int) onNavigateDelete;
  final Function(List<Entry>, Map<String, RichDoc>?) onImportEntries;

  const HomeScreen({
    super.key,
    required this.entries,
    required this.docsMap,
    required this.sourceLang,
    required this.targetLang,
    required this.onChangeSourceLang,
    required this.onChangeTargetLang,
    required this.onNavigateCreate,
    required this.onNavigateEdit,
    required this.onNavigateDelete,
    required this.onImportEntries,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _query = '';
  int? _expandedEntryId;
  bool _isDisplaySwapped = false;
  final FlutterTts _tts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  int? _playingAudioId;

  LanguageCode get displaySourceLang =>
      _isDisplaySwapped ? widget.targetLang : widget.sourceLang;
  LanguageCode get displayTargetLang =>
      _isDisplaySwapped ? widget.sourceLang : widget.targetLang;

  List<Entry> get entriesWithBothLangs {
    return widget.entries.where((item) {
      final hasSrc = item.translations[widget.sourceLang]?.trim().isNotEmpty ?? false;
      final hasDst = item.translations[widget.targetLang]?.trim().isNotEmpty ?? false;
      return hasSrc && hasDst;
    }).toList();
  }

  List<Entry> get filteredEntries {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return entriesWithBothLangs;

    return entriesWithBothLangs.where((item) {
      final src = (item.translations[widget.sourceLang] ?? '').toLowerCase();
      final dst = (item.translations[widget.targetLang] ?? '').toLowerCase();
      return src.contains(q) || dst.contains(q);
    }).toList();
  }

  Future<void> _speak(Entry entry, String word, LanguageCode lang) async {
    final uri = entry.lemmaAudios?[lang];
    if (uri != null && uri.trim().isNotEmpty) {
      try {
        setState(() => _playingAudioId = entry.id);
        await _audioPlayer.play(UrlSource(uri));
        _audioPlayer.onPlayerComplete.listen((_) {
          setState(() => _playingAudioId = null);
        });
      } catch (e) {
        setState(() => _playingAudioId = null);
        _showError('Không thể phát audio: $uri');
      }
      return;
    }

    // Use TTS
    final meta = getLangMeta(lang);
    await _tts.setLanguage(meta.ttsLang);
    await _tts.speak(word);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text('Thông tin', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Đây là phần mềm từ điển đa ngôn ngữ, bản quyền thuộc về Trung đoàn 246, Sư đoàn 346, Quân khu 1.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  String _getDocKey(int entryId, LanguageCode lang) => '$entryId:${lang.name}';

  RichDoc? _getDocForEntry(int entryId, LanguageCode lang) {
    return widget.docsMap[_getDocKey(entryId, lang)];
  }

  @override
  Widget build(BuildContext context) {
    final sourceMeta = getLangMeta(widget.sourceLang);
    final targetMeta = getLangMeta(widget.targetLang);
    final displaySourceMeta = getLangMeta(displaySourceLang);
    final displayTargetMeta = getLangMeta(displayTargetLang);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Dictionary selector section
            _buildDictionarySelector(displaySourceMeta, displayTargetMeta),

            // Search bar
            _buildSearchBar(displaySourceMeta, displayTargetMeta),

            // Entry list
            Expanded(
              child: _buildEntryList(displaySourceMeta, displayTargetMeta),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          bottom: BorderSide(color: AppColors.accentPrimary, width: 2),
        ),
      ),
      child: Row(
        children: [
          // Logo placeholder
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.bgTertiary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.accentPrimary),
            ),
            child: const Center(
              child: Text(
                'E246',
                style: TextStyle(
                  color: AppColors.accentPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'ĐƠN VỊ E246',
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 2,
                    color: AppColors.accentPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Từ điển ngôn ngữ các dân tộc',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDictionarySelector(LangMeta displaySourceMeta, LangMeta displayTargetMeta) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Action buttons row
          Row(
            children: [
              // Info button
              _buildOutlinedButton('ⓘ Thông tin', _showInfo),
              const SizedBox(width: 8),
              // Import button
              _buildOutlinedButton('📥 Nhập file', () {
                // TODO: Implement Excel import
                _showError('Tính năng nhập file sẽ được hoàn thiện sau');
              }),
              const Spacer(),
              // Add button
              ElevatedButton(
                onPressed: widget.onNavigateCreate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPrimary,
                  foregroundColor: AppColors.bgPrimary,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '+ Thêm mục từ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Dictionary pair dropdown
          const Text(
            'Chọn từ điển',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgSecondary,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accentPrimary, width: 2),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: '${widget.sourceLang.name}-${widget.targetLang.name}',
                      isExpanded: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      dropdownColor: AppColors.bgSecondary,
                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                      items: DICTIONARY_PAIRS.map((pair) {
                        final label = _isDisplaySwapped
                            ? '${getLangMeta(pair.target).label} - ${getLangMeta(pair.source).label}'
                            : pair.label;
                        return DropdownMenuItem(
                          value: pair.id,
                          child: Text(label),
                        );
                      }).toList(),
                      onChanged: (pairId) {
                        final pair = DICTIONARY_PAIRS.firstWhere((p) => p.id == pairId);
                        widget.onChangeSourceLang(pair.source);
                        widget.onChangeTargetLang(pair.target);
                        setState(() => _isDisplaySwapped = false);
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Swap button
              GestureDetector(
                onTap: () => setState(() => _isDisplaySwapped = !_isDisplaySwapped),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _isDisplaySwapped
                        ? AppColors.accentPrimary
                        : AppColors.bgTertiary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isDisplaySwapped
                          ? AppColors.accentPrimary
                          : AppColors.borderSecondary,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '⇄',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _isDisplaySwapped
                            ? AppColors.bgPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),
          Center(
            child: Text(
              '${entriesWithBothLangs.length} mục từ • ${displaySourceMeta.label} → ${displayTargetMeta.label}',
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutlinedButton(String text, VoidCallback onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSecondary),
        ),
        backgroundColor: AppColors.bgTertiary,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSearchBar(LangMeta displaySourceMeta, LangMeta displayTargetMeta) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: AppColors.textMuted),
          ),
          Expanded(
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Tìm theo ${displaySourceMeta.label} hoặc ${displayTargetMeta.label}…',
                hintStyle: const TextStyle(color: AppColors.textMuted),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryList(LangMeta displaySourceMeta, LangMeta displayTargetMeta) {
    final entries = filteredEntries;

    if (entries.isEmpty) {
      return const Center(
        child: Text(
          'Không tìm thấy mục từ nào.',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textMuted,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final item = entries[index];
        return _buildEntryCard(item, displaySourceMeta, displayTargetMeta);
      },
    );
  }

  Widget _buildEntryCard(Entry item, LangMeta displaySourceMeta, LangMeta displayTargetMeta) {
    final srcWord = item.translations[displaySourceLang] ?? '—';
    final tgtWord = item.translations[displayTargetLang] ?? '—';
    final doc = _getDocForEntry(item.id, displayTargetLang);
    final summary = doc?.summarize() ?? item.notes ?? '';
    final isExpanded = _expandedEntryId == item.id;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content (tappable)
          InkWell(
            onTap: () {
              setState(() {
                _expandedEntryId = isExpanded ? null : item.id;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Source word row
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.bgTertiary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          displaySourceMeta.label,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          srcWord,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Target word row
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          tgtWord,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textAccent,
                          ),
                        ),
                      ),
                      if (tgtWord != '—')
                        TextButton(
                          onPressed: () => _speak(item, tgtWord, widget.targetLang),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            backgroundColor: AppColors.bgTertiary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _playingAudioId == item.id ? '⏸ Đang phát' : '▶ Nghe',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Notes and actions row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                // Notes
                Expanded(
                  child: summary.isNotEmpty
                      ? Text(
                          summary,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        )
                      : const SizedBox.shrink(),
                ),
                // Edit button
                TextButton(
                  onPressed: () => widget.onNavigateEdit(item.id),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    '✎ Sửa',
                    style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  ),
                ),
                // Delete button
                TextButton(
                  onPressed: () => widget.onNavigateDelete(item.id),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    minimumSize: Size.zero,
                  ),
                  child: const Text(
                    '✕ Xóa',
                    style: TextStyle(fontSize: 13, color: AppColors.dangerText),
                  ),
                ),
              ],
            ),
          ),

          // Expanded doc view
          if (isExpanded && doc != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: RichDocViewWidget(doc: doc),
            ),
        ],
      ),
    );
  }
}
