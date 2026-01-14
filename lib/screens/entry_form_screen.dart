import 'package:flutter/material.dart';
import '../models/entry.dart';
import '../models/language.dart';
import '../models/rich_doc.dart';
import '../theme/app_theme.dart';

class EntryFormScreen extends StatefulWidget {
  final String mode; // 'create' or 'edit'
  final LanguageCode sourceLang;
  final LanguageCode targetLang;
  final Entry? initialEntry;
  final RichDoc? initialDocForTarget;
  final VoidCallback onCancel;
  final Function(Entry entry, RichDoc? docForTarget) onSubmit;

  const EntryFormScreen({
    super.key,
    required this.mode,
    required this.sourceLang,
    required this.targetLang,
    this.initialEntry,
    this.initialDocForTarget,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  State<EntryFormScreen> createState() => _EntryFormScreenState();
}

class _EntryFormScreenState extends State<EntryFormScreen> {
  late Map<LanguageCode, TextEditingController> _translationControllers;
  late TextEditingController _notesController;
  late TextEditingController _audioUriController;
  bool _showMoreLangs = false;

  @override
  void initState() {
    super.initState();

    _translationControllers = {};
    for (final lang in LanguageCode.values) {
      _translationControllers[lang] = TextEditingController(
        text: widget.initialEntry?.translations[lang] ?? '',
      );
    }

    _notesController = TextEditingController(
      text: widget.initialDocForTarget?.summarize() ?? widget.initialEntry?.notes ?? '',
    );

    _audioUriController = TextEditingController(
      text: widget.initialEntry?.lemmaAudios?[widget.targetLang] ?? '',
    );
  }

  @override
  void dispose() {
    for (final controller in _translationControllers.values) {
      controller.dispose();
    }
    _notesController.dispose();
    _audioUriController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final src = _translationControllers[widget.sourceLang]?.text.trim() ?? '';
    final dst = _translationControllers[widget.targetLang]?.text.trim() ?? '';

    if (src.isEmpty || dst.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ từ nguồn và đích.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final translations = <LanguageCode, String>{};
    for (final lang in LanguageCode.values) {
      final text = _translationControllers[lang]?.text.trim() ?? '';
      if (text.isNotEmpty) {
        translations[lang] = text;
      }
    }

    final baseId = widget.mode == 'create'
        ? DateTime.now().millisecondsSinceEpoch
        : widget.initialEntry!.id;

    final lemmaAudios = <LanguageCode, String>{};
    if (widget.initialEntry?.lemmaAudios != null) {
      lemmaAudios.addAll(widget.initialEntry!.lemmaAudios!);
    }
    if (_audioUriController.text.trim().isNotEmpty) {
      lemmaAudios[widget.targetLang] = _audioUriController.text.trim();
    }

    final entry = Entry(
      id: baseId,
      translations: translations,
      lemmaAudios: lemmaAudios.isNotEmpty ? lemmaAudios : null,
    );

    RichDoc? doc;
    if (_notesController.text.trim().isNotEmpty) {
      doc = RichDoc(blocks: [
        ParagraphBlock(text: _notesController.text.trim()),
      ]);
    }

    widget.onSubmit(entry, doc);
  }

  List<LangMeta> get _otherLangs {
    return LANGS
        .where((l) => l.code != widget.sourceLang && l.code != widget.targetLang)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final sourceMeta = getLangMeta(widget.sourceLang);
    final targetMeta = getLangMeta(widget.targetLang);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(sourceMeta, targetMeta),

            // Form content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Basic translations section
                    _buildSection(
                      title: 'Từ & nghĩa cơ bản',
                      subtitle: 'Bắt buộc',
                      child: Column(
                        children: [
                          _buildTextField(
                            label: sourceMeta.label,
                            controller: _translationControllers[widget.sourceLang]!,
                            placeholder: 'Từ bằng ${sourceMeta.label}…',
                          ),
                          const SizedBox(height: 14),
                          _buildTextField(
                            label: targetMeta.label,
                            controller: _translationControllers[widget.targetLang]!,
                            placeholder: 'Nghĩa bằng ${targetMeta.label}…',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Other languages section
                    _buildSection(
                      title: 'Thêm nghĩa ở ngôn ngữ khác',
                      subtitle: _showMoreLangs ? 'Ẩn' : 'Hiện',
                      onTapHeader: () => setState(() => _showMoreLangs = !_showMoreLangs),
                      child: _showMoreLangs
                          ? Column(
                              children: _otherLangs.map((lang) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 14),
                                  child: _buildTextField(
                                    label: lang.label,
                                    controller: _translationControllers[lang.code]!,
                                    placeholder: 'Nghĩa bằng ${lang.label}…',
                                  ),
                                );
                              }).toList(),
                            )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 14),

                    // Audio pronunciation section
                    _buildSection(
                      title: 'Audio phát âm (${targetMeta.label})',
                      subtitle: 'Tùy chọn',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            label: 'URL audio hoặc đường dẫn file',
                            controller: _audioUriController,
                            placeholder: 'https://example.com/audio.mp3',
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Nút nghe sẽ ưu tiên phát audio này, nếu trống sẽ dùng TTS.',
                            style: TextStyle(fontSize: 13, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Notes section
                    _buildSection(
                      title: 'Ghi chú & ví dụ',
                      subtitle: 'Tùy chọn',
                      child: TextField(
                        controller: _notesController,
                        maxLines: 4,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Nhập ghi chú, ví dụ câu…',
                          hintStyle: const TextStyle(color: AppColors.textMuted),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.borderPrimary),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.borderPrimary),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(LangMeta sourceMeta, LangMeta targetMeta) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.bgSecondary,
        border: Border(
          bottom: BorderSide(color: AppColors.accentPrimary, width: 2),
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: widget.onCancel,
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: const Text(
                '←',
                style: TextStyle(
                  color: AppColors.accentPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.mode == 'create' ? 'Tạo mục từ mới' : 'Chỉnh sửa mục từ',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.accentPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${sourceMeta.label} ⇄ ${targetMeta.label}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Save button
          ElevatedButton(
            onPressed: _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentPrimary,
              foregroundColor: AppColors.bgPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'Lưu',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String subtitle,
    required Widget child,
    VoidCallback? onTapHeader,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderPrimary),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onTapHeader,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.black, fontSize: 16),
          decoration: InputDecoration(
            fillColor: Colors.white,
            filled: true,
            hintText: placeholder,
            hintStyle: const TextStyle(color: AppColors.textMuted),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderPrimary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.borderPrimary),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.accentPrimary, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
