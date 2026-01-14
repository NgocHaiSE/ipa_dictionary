import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme/app_theme.dart';
import 'models/entry.dart';
import 'models/language.dart';
import 'models/rich_doc.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/entry_form_screen.dart';
import 'screens/delete_entry_screen.dart';
import 'services/database_service.dart';
import 'data/base_entries.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const DictionaryApp());
}

class DictionaryApp extends StatelessWidget {
  const DictionaryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Từ điển E246',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const AppRoot(),
    );
  }
}

enum AppScreen { splash, list, create, edit, delete }

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  final DatabaseService _db = DatabaseService();
  
  AppScreen _activeScreen = AppScreen.splash;
  LanguageCode _sourceLang = LanguageCode.vi;
  LanguageCode _targetLang = LanguageCode.tay;
  List<Entry> _entries = [];
  Map<String, RichDoc> _docsMap = {};
  int? _currentEntryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initAndLoad();
  }

  Future<void> _initAndLoad() async {
    try {
      // Import base entries
      await _db.importBaseEntries(BASE_ENTRIES);

      // Load all data
      final entries = await _db.loadAllEntries();
      final docs = await _db.loadAllRichDocs();

      setState(() {
        _entries = entries;
        _docsMap = docs;
        _isLoading = false;
      });
    } catch (e) {
      print('Error initializing database: $e');
      setState(() {
        _entries = BASE_ENTRIES;
        _isLoading = false;
      });
    }
  }

  String _getDocKey(int entryId, LanguageCode lang) => '$entryId:${lang.name}';

  RichDoc? _getDocForEntry(int entryId, LanguageCode lang) {
    return _docsMap[_getDocKey(entryId, lang)];
  }

  // Navigation handlers
  void _navigateToCreate() {
    setState(() {
      _currentEntryId = null;
      _activeScreen = AppScreen.create;
    });
  }

  void _navigateToEdit(int id) {
    setState(() {
      _currentEntryId = id;
      _activeScreen = AppScreen.edit;
    });
  }

  void _navigateToDelete(int id) {
    setState(() {
      _currentEntryId = id;
      _activeScreen = AppScreen.delete;
    });
  }

  void _navigateToList() {
    setState(() {
      _activeScreen = AppScreen.list;
    });
  }

  // Entry handlers
  Future<void> _handleSubmitCreate(Entry entry, RichDoc? docForTarget) async {
    try {
      await _db.saveEntry(entry);
      if (docForTarget != null) {
        await _db.saveRichDoc(entry.id, _targetLang, docForTarget);
      }

      setState(() {
        _entries = [entry, ..._entries];
        if (docForTarget != null) {
          final key = _getDocKey(entry.id, _targetLang);
          _docsMap = {..._docsMap, key: docForTarget};
        }
        _activeScreen = AppScreen.list;
      });
    } catch (e) {
      print('Error saving entry: $e');
      _showError('Không thể lưu mục từ');
    }
  }

  Future<void> _handleSubmitEdit(Entry entry, RichDoc? docForTarget) async {
    try {
      await _db.saveEntry(entry);
      if (docForTarget != null) {
        await _db.saveRichDoc(entry.id, _targetLang, docForTarget);
      }

      setState(() {
        _entries = _entries.map((e) => e.id == entry.id ? entry : e).toList();
        if (docForTarget != null) {
          final key = _getDocKey(entry.id, _targetLang);
          _docsMap = {..._docsMap, key: docForTarget};
        }
        _activeScreen = AppScreen.list;
      });
    } catch (e) {
      print('Error updating entry: $e');
      _showError('Không thể cập nhật mục từ');
    }
  }

  Future<void> _handleConfirmDelete() async {
    if (_currentEntryId == null) {
      _navigateToList();
      return;
    }

    final id = _currentEntryId!;

    try {
      await _db.deleteEntry(id);

      setState(() {
        _entries = _entries.where((e) => e.id != id).toList();
        _docsMap = Map.fromEntries(
          _docsMap.entries.where((e) => !e.key.startsWith('$id:')),
        );
        _activeScreen = AppScreen.list;
      });
    } catch (e) {
      print('Error deleting entry: $e');
      _showError('Không thể xóa mục từ');
    }
  }

  void _handleSplashFinish() {
    setState(() {
      _activeScreen = AppScreen.list;
    });
  }

  void _handleImportEntries(List<Entry> newEntries, Map<String, RichDoc>? newDocs) async {
    try {
      for (final entry in newEntries) {
        await _db.saveEntry(entry);
      }
      if (newDocs != null) {
        for (final e in newDocs.entries) {
          final parts = e.key.split(':');
          final entryId = int.parse(parts[0]);
          final langCode = LanguageCode.values.firstWhere((c) => c.name == parts[1]);
          await _db.saveRichDoc(entryId, langCode, e.value);
        }
      }

      setState(() {
        _entries = [...newEntries, ..._entries];
        if (newDocs != null) {
          _docsMap = {..._docsMap, ...newDocs};
        }
      });
    } catch (e) {
      print('Error importing entries: $e');
      _showError('Không thể nhập dữ liệu');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.danger),
    );
  }

  @override
  Widget build(BuildContext context) {
    switch (_activeScreen) {
      case AppScreen.splash:
        return SplashScreen(onFinish: _handleSplashFinish);

      case AppScreen.list:
        return HomeScreen(
          entries: _entries,
          docsMap: _docsMap,
          sourceLang: _sourceLang,
          targetLang: _targetLang,
          onChangeSourceLang: (code) => setState(() => _sourceLang = code),
          onChangeTargetLang: (code) => setState(() => _targetLang = code),
          onNavigateCreate: _navigateToCreate,
          onNavigateEdit: _navigateToEdit,
          onNavigateDelete: _navigateToDelete,
          onImportEntries: _handleImportEntries,
        );

      case AppScreen.create:
        return EntryFormScreen(
          mode: 'create',
          sourceLang: _sourceLang,
          targetLang: _targetLang,
          onCancel: _navigateToList,
          onSubmit: _handleSubmitCreate,
        );

      case AppScreen.edit:
        final entry = _entries.firstWhere(
          (e) => e.id == _currentEntryId,
          orElse: () => _entries.first,
        );
        final docForTarget = _getDocForEntry(entry.id, _targetLang);
        return EntryFormScreen(
          mode: 'edit',
          sourceLang: _sourceLang,
          targetLang: _targetLang,
          initialEntry: entry,
          initialDocForTarget: docForTarget,
          onCancel: _navigateToList,
          onSubmit: _handleSubmitEdit,
        );

      case AppScreen.delete:
        final entry = _entries.firstWhere(
          (e) => e.id == _currentEntryId,
          orElse: () => _entries.first,
        );
        return DeleteEntryScreen(
          entry: entry,
          sourceLang: _sourceLang,
          targetLang: _targetLang,
          onCancel: _navigateToList,
          onConfirm: _handleConfirmDelete,
        );
    }
  }
}
