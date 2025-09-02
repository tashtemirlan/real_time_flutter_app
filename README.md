# 🌍 Voice Translator App

A modern Flutter-based **real-time voice translator** that empowers users to communicate seamlessly across languages. The app leverages **Google ML Kit Translation**, **speech recognition**, and **text-to-speech** to deliver an **end-to-end translation experience**: you speak in one language, and the app instantly translates and speaks it out loud in another.

---

## 💡 Idea & Ideology

Language should never be a barrier. The idea behind this project is simple but powerful:

1. **Accessibility** → Break down language barriers by enabling users to talk in their native language and instantly be understood in another.
2. **Offline-first** → Provide translation capabilities even without internet by allowing users to download language models.
3. **Minimalistic design** → Keep the UI simple and intuitive, with focus on usability (voice-first interaction).
4. **Open-source spirit** → Give developers and learners a ready-to-use template for integrating translation, speech-to-text, and text-to-speech in Flutter apps.

This project aims to be a **personal translator in your pocket** — designed for travelers, educators, and anyone who needs to communicate across languages.

---

## ✨ Features

* 🎤 **Voice Input** → Speak in your source language, instantly transcribed using `speech_to_text`.
* 🔊 **Voice Output** → Translated text is automatically spoken aloud in the target language with `flutter_tts`.
* 📥 **Downloadable Language Models** → Offline translation support using `google_mlkit_translation`.
* 🗑 **Language Management** → Dedicated page to view and delete downloaded language models.
* 📝 **Clipboard Copy** → Copy translations instantly without extra dependencies.
* 🔄 **Swap Languages** → Easily switch between source and target languages.
* 🖼 **Modern UI** → Intuitive interface with Drawer navigation instead of cluttered settings.

---

## 🌐 Supported Languages

The app supports **all ML Kit `TranslateLanguage` values**, automatically mapped to valid **speech-to-text locales**.

Examples:

* 🇺🇸 English → `en-US`
* 🇪🇸 Spanish → `es-ES`
* 🇯🇵 Japanese → `ja-JP`
* 🇷🇺 Russian → `ru-RU`
* 🇨🇳 Chinese → `zh-CN`

(And many more — covering 50+ languages).

---

## 📦 Dependencies

* [`google_mlkit_translation`](https://pub.dev/packages/google_mlkit_translation) → Offline translations
* [`speech_to_text`](https://pub.dev/packages/speech_to_text) → Voice input
* [`flutter_tts`](https://pub.dev/packages/flutter_tts) → Voice output
* [`hive`](https://pub.dev/packages/hive) + `hive_flutter` → Persistent local storage

---

## 🔮 Roadmap

* [ ] Add iOS voice support
* [ ] Implement favorites/history of translations
* [ ] Export/import downloaded language packs
* [ ] Live conversation mode (both-way translation)

## 📄 License

This project is licensed under the MIT License.

---

⚡ Built with Flutter & ❤️ for seamless multilingual communication.
