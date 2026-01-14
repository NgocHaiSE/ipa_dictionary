import 'dart:convert';

/// Types of rich content blocks
enum RichBlockType { paragraph, image, audio }

/// A block of rich content
abstract class RichBlock {
  RichBlockType get type;

  Map<String, dynamic> toJson();

  factory RichBlock.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    switch (type) {
      case 'paragraph':
        return ParagraphBlock.fromJson(json);
      case 'image':
        return ImageBlock.fromJson(json);
      case 'audio':
        return AudioBlock.fromJson(json);
      default:
        throw Exception('Unknown block type: $type');
    }
  }
}

/// Text paragraph block
class ParagraphBlock implements RichBlock {
  @override
  RichBlockType get type => RichBlockType.paragraph;

  final String text;
  final bool bold;
  final bool italic;
  final double? fontSize;

  ParagraphBlock({
    required this.text,
    this.bold = false,
    this.italic = false,
    this.fontSize,
  });

  factory ParagraphBlock.fromJson(Map<String, dynamic> json) {
    final styles = json['styles'] as Map<String, dynamic>?;
    return ParagraphBlock(
      text: json['text'] as String,
      bold: styles?['bold'] as bool? ?? false,
      italic: styles?['italic'] as bool? ?? false,
      fontSize: (styles?['fontSize'] as num?)?.toDouble(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'paragraph',
        'text': text,
        if (bold || italic || fontSize != null)
          'styles': {
            if (bold) 'bold': bold,
            if (italic) 'italic': italic,
            if (fontSize != null) 'fontSize': fontSize,
          },
      };
}

/// Image block
class ImageBlock implements RichBlock {
  @override
  RichBlockType get type => RichBlockType.image;

  final String uri;
  final String? caption;

  ImageBlock({required this.uri, this.caption});

  factory ImageBlock.fromJson(Map<String, dynamic> json) {
    return ImageBlock(
      uri: json['uri'] as String,
      caption: json['caption'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'image',
        'uri': uri,
        if (caption != null) 'caption': caption,
      };
}

/// Audio block
class AudioBlock implements RichBlock {
  @override
  RichBlockType get type => RichBlockType.audio;

  final String uri;
  final String? caption;

  AudioBlock({required this.uri, this.caption});

  factory AudioBlock.fromJson(Map<String, dynamic> json) {
    return AudioBlock(
      uri: json['uri'] as String,
      caption: json['caption'] as String?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': 'audio',
        'uri': uri,
        if (caption != null) 'caption': caption,
      };
}

/// Rich document with multiple blocks
class RichDoc {
  final List<RichBlock> blocks;

  RichDoc({required this.blocks});

  factory RichDoc.fromJson(List<dynamic> json) {
    return RichDoc(
      blocks: json.map((b) => RichBlock.fromJson(b as Map<String, dynamic>)).toList(),
    );
  }

  factory RichDoc.fromJsonString(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString);
    return RichDoc.fromJson(list);
  }

  String toJsonString() {
    return jsonEncode(blocks.map((b) => b.toJson()).toList());
  }

  /// Get summary from first paragraph
  String summarize() {
    for (final block in blocks) {
      if (block is ParagraphBlock) {
        return block.text;
      }
    }
    return '';
  }
}
