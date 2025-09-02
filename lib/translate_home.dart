import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import 'package:hive_flutter/hive_flutter.dart';

import 'downloaded_languages.dart';

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

  stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;

  Future<void> _initHive() async {
    await Hive.initFlutter();
    downloadedBox = await Hive.openBox('downloadedModelsBox');
    setState(() {}); // Refresh after loading
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
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

  Future<void> _translateText([String? input]) async {
    final text = _inputController.text.trim();
    if (text.isEmpty) {
      setState(() => _translatedText = 'Please enter text to translate.');
      return;
    }

    setState(() => _translatedText = 'Translating...');
    try {
      await _prepareTranslator();
      final result = await _translator.translateText(text);
      _isListening = false;
      setState(() => _translatedText = result);

      // Auto voice playback after translation
      await flutterTts.setLanguage(targetLang.bcpCode);
      await flutterTts.speak(result);

    } catch (e) {
      _isListening= false;
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

  String speechLocaleId(TranslateLanguage lang) {
    switch (lang) {
      case TranslateLanguage.afrikaans: return 'af-ZA';
      case TranslateLanguage.albanian:  return 'sq-AL';
      case TranslateLanguage.arabic:    return 'ar-SA';
      case TranslateLanguage.belarusian: return 'be-BY';
      case TranslateLanguage.bengali:   return 'bn-IN';
      case TranslateLanguage.bulgarian: return 'bg-BG';
      case TranslateLanguage.catalan:   return 'ca-ES';
      case TranslateLanguage.chinese:   return 'zh-CN';
      case TranslateLanguage.croatian:  return 'hr-HR';
      case TranslateLanguage.czech:     return 'cs-CZ';
      case TranslateLanguage.danish:    return 'da-DK';
      case TranslateLanguage.dutch:     return 'nl-NL';
      case TranslateLanguage.english:   return 'en-US';
      case TranslateLanguage.estonian:  return 'et-EE';
      case TranslateLanguage.finnish:   return 'fi-FI';
      case TranslateLanguage.french:    return 'fr-FR';
      case TranslateLanguage.german:    return 'de-DE';
      case TranslateLanguage.greek:     return 'el-GR';
      case TranslateLanguage.hindi:     return 'hi-IN';
      case TranslateLanguage.hungarian: return 'hu-HU';
      case TranslateLanguage.indonesian:return 'id-ID';
      case TranslateLanguage.irish:     return 'ga-IE';
      case TranslateLanguage.italian:   return 'it-IT';
      case TranslateLanguage.japanese:  return 'ja-JP';
      case TranslateLanguage.korean:    return 'ko-KR';
      case TranslateLanguage.latvian:   return 'lv-LV';
      case TranslateLanguage.lithuanian:return 'lt-LT';
      case TranslateLanguage.malay:     return 'ms-MY';
      case TranslateLanguage.norwegian: return 'no-NO';
      case TranslateLanguage.polish:    return 'pl-PL';
      case TranslateLanguage.portuguese:return 'pt-PT';
      case TranslateLanguage.romanian:  return 'ro-RO';
      case TranslateLanguage.russian:   return 'ru-RU';
      case TranslateLanguage.slovak:    return 'sk-SK';
      case TranslateLanguage.slovenian: return 'sl-SI';
      case TranslateLanguage.spanish:   return 'es-ES';
      case TranslateLanguage.swedish:   return 'sv-SE';
      case TranslateLanguage.tamil:     return 'ta-IN';
      case TranslateLanguage.telugu:    return 'te-IN';
      case TranslateLanguage.thai:      return 'th-TH';
      case TranslateLanguage.turkish:   return 'tr-TR';
      case TranslateLanguage.ukrainian: return 'uk-UA';
      case TranslateLanguage.vietnamese:return 'vi-VN';
    // Add others as desired, default fallback:
      default: return 'en-US';
    }
  }

  Future<void> _startListening() async {
    if (_speechEnabled) {
      setState(() => _isListening = true);
      await _speechToText.listen(
        localeId: speechLocaleId(sourceLang),
        onResult: (val) {
          if (val.recognizedWords.isNotEmpty) {
            _inputController.text = val.recognizedWords;
            _translateText(val.recognizedWords);
          }
        },
      );
    }
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
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
  void initState() {
    super.initState();
    _initHive();
    //initialize speech
    _initSpeech();
    _translator = OnDeviceTranslator(
      sourceLanguage: sourceLang,
      targetLanguage: targetLang,
    );
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
      appBar: AppBar(title: const Text('Translate'),),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue.shade300),
              child: Text('Settings & Downloads',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            ListTile(
              leading: const Icon(Icons.download_done),
              title: const Text('Downloaded Languages'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DownloadedLanguagesPage(
                      downloadedBox: downloadedBox,
                      modelManager: modelManager,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(children: [
        // Language selectors
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

        // Input + mic
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _inputController,
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Enter text or use mic',
                suffixIcon: IconButton(
                  icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                  onPressed: _isListening ? _stopListening : _startListening,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                borderRadius: BorderRadius.circular(12)),
            child: SingleChildScrollView(child: Text(_translatedText)),
          ),
        ),

        // Actions (copy + speak)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
                icon: const Icon(Icons.copy), onPressed: _copyTranslatedText),
            IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: _speakTranslatedText),
          ],
        ),

        // Translate button (manual)
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: _translateText,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(width: 1, color: Colors.blue.shade500)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 10, horizontal: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.translate, color: Colors.blue.shade300),
                    Text("Translate",
                        style: TextStyle(
                            color: Colors.blue.shade400,
                            fontSize: 20,
                            fontWeight: FontWeight.w500))
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
