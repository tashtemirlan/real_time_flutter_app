import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hive/hive.dart';
import 'package:translator_real_time/translate_home.dart';

import 'globals.dart';


class LogoStart extends StatefulWidget{
  const LogoStart({super.key});

  @override
  LogoStartState createState ()=> LogoStartState();

}

class LogoStartState extends State<LogoStart>{


  Future<void> checkLaunchData() async{
    var box = await Hive.openBox("LaunchData");
    bool isLanguageSet = box.containsKey("Language");
    if(isLanguageSet){
      String language = box.get("Language");
      userLanguage = language;
    }
    else{
      userLanguage = "ru";
    }
  }

  Future<void> logoMainMethod() async{
    //get and set user data for system
    await checkLaunchData();
    if(userLanguage=="ru"){
      Fluttertoast.showToast(
        msg: "Добро пожаловать!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 12.0,
      );
    }
    else{
      Fluttertoast.showToast(
        msg: "Кош келиңиз!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 12.0,
      );
    }
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (BuildContext context) => const TranslateHome()));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    logoMainMethod();
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: const Color.fromRGBO(250, 250, 250, 1),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.only(left: width*0.3),
                child : FaIcon(
                  FontAwesomeIcons.language ,
                  size: width*0.4,
                  color: Colors.blue.shade300,
                )
            ),
          ],
        )
    );
  }
}