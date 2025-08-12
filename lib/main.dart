import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';

import 'logo_start.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //todo: ensure to initialize all neccessary voids and methods =>
  await Hive.initFlutter();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(TranslateApp(),);
  });
}

class TranslateApp extends StatelessWidget{
  const TranslateApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(1.0)),
      child:   MaterialApp(
        theme: ThemeData(
            colorScheme: ThemeData().colorScheme.copyWith(primary: Colors.blue.shade200),
            fontFamily: 'Roboto'
        ),
        debugShowCheckedModeBanner: false,
        home: const LogoStart(),
      ),
    );
  }
}