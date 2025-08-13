import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'package:hive_flutter/hive_flutter.dart';

class TranslateHome extends StatefulWidget {
  const TranslateHome({super.key});

  @override
  TranslateHomeState createState() => TranslateHomeState();
}

class TranslateHomeState extends State<TranslateHome> {
  TranslateLanguage sourceLang = TranslateLanguage.russian;
  TranslateLanguage targetLang = TranslateLanguage.english;
  final _inputController = TextEditingController();
  String _translatedText = '';
  late OnDeviceTranslator _translator;
  final modelManager = OnDeviceTranslatorModelManager();
  final languages = TranslateLanguage.values;
  late Box downloadedBox;
  final FlutterTts flutterTts = FlutterTts();


  @override
  void initState() {
    super.initState();
    _initHive();
    _translator = OnDeviceTranslator(
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
    );
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    downloadedBox = await Hive.openBox('downloadedModelsBox');
    setState(() {}); // Refresh after loading
  }

  Set<String> get downloadedModels {
    final list = downloadedBox.get('models', defaultValue: <String>[]) as List;
    return list.map((e) => e.toString()).toSet();
  }

  Future<void> _saveDownloadedModels(Set<String> models) async {
    await downloadedBox.put('models', models.toList());
    setState(() {});
  }

  Future<bool> _isModelAvailable(TranslateLanguage lang) async {
    return await modelManager.isModelDownloaded(lang.bcpCode);
  }

  Future<void> _selectLanguage(bool isSource, TranslateLanguage lang) async {
    final downloaded = await _isModelAvailable(lang);
    if (!downloaded) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Download Language Model'),
          content: Text('The model for "${lang.name}" is not downloaded. Download now?'),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel')),
            TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Download')),
          ],
        ),
      );
      if (confirmed == true) {
        await modelManager.downloadModel(lang.bcpCode);
        final updated = downloadedModels..add(lang.bcpCode);
        await _saveDownloadedModels(updated);
      } else {
        return;
      }
    }

    setState(() {
      if (isSource) {
        sourceLang = lang;
      } else {
        targetLang = lang;
      }
      _translator.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );
    });
  }

  Future<void> _prepareTranslator() async {
    final src = sourceLang.bcpCode;
    final tgt = targetLang.bcpCode;
    final updated = downloadedModels;

    if (!await modelManager.isModelDownloaded(src)) {
      await modelManager.downloadModel(src);
      updated.add(src);
    }
    if (!await modelManager.isModelDownloaded(tgt)) {
      await modelManager.downloadModel(tgt);
      updated.add(tgt);
    }
    await _saveDownloadedModels(updated);
  }

  Future<void> _translateText() async {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      setState(() => _translatedText = 'Please enter text to translate.');
      return;
    }

    setState(() => _translatedText = 'Translating...');
    try {
      await _prepareTranslator();
      _translator.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );

      final result = await _translator.translateText(text);
      setState(() => _translatedText = result);
    } catch (e) {
      setState(() => _translatedText = 'Error: $e');
    }
  }

  Future<void> _speakTranslatedText() async {
    if (_translatedText.isNotEmpty) {
      await flutterTts.setLanguage(targetLang.bcpCode);
      await flutterTts.speak(_translatedText);
    }
  }

  Future<void> _copyTranslatedText() async {
    if (_translatedText.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: _translatedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Translated text copied to clipboard')),
      );
    }
  }

  void _swapLanguages() {
    setState(() {
      final temp = sourceLang;
      sourceLang = targetLang;
      targetLang = temp;
      _translator.close();
      _translator = OnDeviceTranslator(
        sourceLanguage: sourceLang,
        targetLanguage: targetLang,
      );
    });
  }

  @override
  void dispose() {
    _translator.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (!Hive.isBoxOpen('downloadedModelsBox')) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Translate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => LanguageSettingsPage(
                    modelManager: modelManager,
                    knownDownloaded: downloadedModels,
                    onDelete: (code) async {
                      await modelManager.deleteModel(code);
                      final updated = downloadedModels..remove(code);
                      await _saveDownloadedModels(updated);
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<TranslateLanguage>(
                value: sourceLang,
                underline: const SizedBox(),
                items: languages.map(
                      (lang) => DropdownMenuItem(
                    value: lang,
                    child: Row(
                      children: [
                        Text(lang.name),
                        const SizedBox(width: 6),
                        FutureBuilder<bool>(
                          future: _isModelAvailable(lang),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            return Icon(
                              snapshot.data!
                                  ? Icons.check_circle
                                  : Icons.download,
                              size: 14,
                              color: snapshot.data!
                                  ? Colors.green
                                  : Colors.grey,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _selectLanguage(true, val);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.swap_horiz),
                onPressed: _swapLanguages,
              ),
              DropdownButton<TranslateLanguage>(
                value: targetLang,
                underline: const SizedBox(),
                items: languages.map(
                      (lang) => DropdownMenuItem(
                    value: lang,
                    child: Row(
                      children: [
                        Text(lang.name),
                        const SizedBox(width: 6),
                        FutureBuilder<bool>(
                          future: _isModelAvailable(lang),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox.shrink();
                            }
                            return Icon(
                              snapshot.data!
                                  ? Icons.check_circle
                                  : Icons.download,
                              size: 14,
                              color: snapshot.data!
                                  ? Colors.green
                                  : Colors.grey,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ).toList(),
                onChanged: (val) {
                  if (val != null) {
                    _selectLanguage(false, val);
                  }
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _inputController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Enter text',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Container(
            width: width,
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(_translatedText),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.copy),
                      tooltip: 'Copy translated text',
                      onPressed: _copyTranslatedText,
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up),
                      tooltip: 'Listen to translated text',
                      onPressed: _speakTranslatedText,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: _translateText,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
                border: Border.all(width: 1, color: Colors.blue.shade500),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.translate, color: Colors.blue.shade300),
                    const SizedBox(width: 6),
                    Text(
                      "Translate",
                      style: TextStyle(
                        color: Colors.blue.shade400,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

class LanguageSettingsPage extends StatelessWidget {
  final OnDeviceTranslatorModelManager modelManager;
  final Set<String> knownDownloaded;
  final Function(String) onDelete;

  const LanguageSettingsPage({
    super.key,
    required this.modelManager,
    required this.knownDownloaded,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final downloadedCodes = knownDownloaded.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Languages')),
      body: downloadedCodes.isEmpty
          ? const Center(child: Text('No models downloaded (according to app).'))
          : ListView.builder(
        itemCount: downloadedCodes.length,
        itemBuilder: (context, index) {
          final code = downloadedCodes[index];
          return ListTile(
            title: Text(code),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                await onDelete(code);
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => LanguageSettingsPage(
                      modelManager: modelManager,
                      knownDownloaded: knownDownloaded,
                      onDelete: onDelete,
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
