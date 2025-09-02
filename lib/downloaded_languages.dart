import 'package:flutter/material.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DownloadedLanguagesPage extends StatefulWidget {
  final Box downloadedBox;
  final OnDeviceTranslatorModelManager modelManager;

  const DownloadedLanguagesPage({
    super.key,
    required this.downloadedBox,
    required this.modelManager,
  });

  @override
  State<DownloadedLanguagesPage> createState() =>
      _DownloadedLanguagesPageState();
}

class _DownloadedLanguagesPageState extends State<DownloadedLanguagesPage> {
  late Set<String> downloadedModels;

  @override
  void initState() {
    super.initState();
    downloadedModels = (widget.downloadedBox.get('models',
        defaultValue: <String>[]) as List)
        .map((e) => e.toString())
        .toSet();
  }

  Future<void> _saveDownloadedModels() async {
    await widget.downloadedBox.put('models', downloadedModels.toList());
    setState(() {});
  }

  Future<void> _deleteModel(TranslateLanguage lang) async {
    await widget.modelManager.deleteModel(lang.bcpCode);
    downloadedModels.remove(lang.bcpCode);
    await _saveDownloadedModels();
  }

  Future<void> _downloadModel(TranslateLanguage lang) async {
    await widget.modelManager.downloadModel(lang.bcpCode);
    downloadedModels.add(lang.bcpCode);
    await _saveDownloadedModels();
  }

  @override
  Widget build(BuildContext context) {
    final languages = TranslateLanguage.values;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Downloaded Languages'),
      ),
      body: ListView.builder(
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          final isDownloaded = downloadedModels.contains(lang.bcpCode);

          return ListTile(
            leading: Icon(
              isDownloaded ? Icons.check_circle : Icons.language,
              color: isDownloaded ? Colors.green : Colors.grey,
            ),
            title: Text(lang.name),
            subtitle: Text(lang.bcpCode),
            trailing: isDownloaded
                ? IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteModel(lang),
            )
                : IconButton(
              icon: const Icon(Icons.download, color: Colors.blue),
              onPressed: () => _downloadModel(lang),
            ),
          );
        },
      ),
    );
  }
}
