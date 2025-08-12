import 'dart:async';

import 'package:flutter/material.dart';


class TranslateHome extends StatefulWidget {
  const TranslateHome({super.key});

  @override
  TranslateHomeState createState() => TranslateHomeState();
}

class TranslateHomeState extends State<TranslateHome> {
  String sourceLang = "English";
  String targetLang = "Spanish";
  final TextEditingController _inputController = TextEditingController();
  String _translatedText = "";

  void _swapLanguages() {
    setState(() {
      final temp = sourceLang;
      sourceLang = targetLang;
      targetLang = temp;
    });
  }

  Future<void> _translateText() async {
    // Here we will integrate google_mlkit_translation later
    setState(() {
      _translatedText = "Translated version of: ${_inputController.text}";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translate'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Language selector row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  value: sourceLang,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: "English", child: Text("English")),
                    DropdownMenuItem(value: "Spanish", child: Text("Spanish")),
                    DropdownMenuItem(value: "French", child: Text("French")),
                  ],
                  onChanged: (val) {
                    setState(() => sourceLang = val!);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.swap_horiz),
                  onPressed: _swapLanguages,
                ),
                DropdownButton<String>(
                  value: targetLang,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: "English", child: Text("English")),
                    DropdownMenuItem(value: "Spanish", child: Text("Spanish")),
                    DropdownMenuItem(value: "French", child: Text("French")),
                  ],
                  onChanged: (val) {
                    setState(() => targetLang = val!);
                  },
                ),
              ],
            ),
          ),

          // Input field
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: _inputController,
                maxLines: null,
                decoration: InputDecoration(
                  hintText: 'Enter text',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.mic),
                    onPressed: () {
                      // TODO: Implement speech-to-text
                    },
                  ),
                ),
              ),
            ),
          ),

          // Output field
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _translatedText,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
          ),

          // Translate button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              onPressed: _translateText,
              icon: const Icon(Icons.translate),
              label: const Text("Translate"),
            ),
          ),
        ],
      ),
    );
  }
}
