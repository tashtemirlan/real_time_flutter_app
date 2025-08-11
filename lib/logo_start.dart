import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';


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
      globals.userLanguage = language;
    }
    else{
      globals.userLanguage = "ru";
    }
  }

  Future<bool> isUserLogged() async{
    //check our logic =>
    var box = await Hive.openBox("logins");
    bool isRefreshTokenInHive= box.containsKey("refresh");
    bool isAccessTokenInHive= box.containsKey("access");
    if(isRefreshTokenInHive && isAccessTokenInHive){
      String refresh = box.get("refresh");

      final dio = Dio();
      dio.options.headers['Accept-Language'] = globals.userLanguage;
      dio.options.connectTimeout = const Duration(seconds: 30);
      dio.options.receiveTimeout = const Duration(seconds: 30);
      try{
        //try to refresh our tokens =>

        final respose = await dio.post(globals.endpointRefreshTokens, data: {"refresh" : refresh});
        if(respose.statusCode == 200){
          String toParseData = respose.toString();

          Map<String, dynamic> jsonData = jsonDecode(toParseData);
          // Access the values
          String refresh = jsonData['refresh'];
          String access = jsonData['access'];

          box.put("refresh", refresh);
          box.put("access", access);


          globals.isUserRegistered = true;
          return true;
        }
        else{
          return false;
        }
      }
      catch(error){
        if(error is DioException){
          if (error.response != null) {
            String toParseData = error.response.toString();
            dynamic data = jsonDecode(toParseData);
            String loginErrorMessage = data['detail'];
            Fluttertoast.showToast(
              msg: loginErrorMessage,
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM, // Position of the toast on the screen
              backgroundColor: Colors.white, // Background color of the toast
              textColor: Colors.black,
              fontSize: 12.0,
            );
          }
        }
      }
      return false;
    }
    else{
      globals.isUserRegistered = false;
      return false;
    }
  }

  Future<bool> getAppVersion() async{
    final dio = Dio();
    //set Dio response =>
    dio.options.headers['Accept-Language'] = globals.userLanguage;
    dio.options.connectTimeout = const Duration(seconds: 30);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    try{
      final response = await dio.get(globals.serverAppVersionGetEndpoint);
      if(response.statusCode == 200){
        final result = appVersionDataClassFromJson(response.toString());
        appVersionString = result.result!.first.appVersion!;
        digits = appVersionString.split('.').map(int.parse).toList();
        verIntData = (digits[0]*100) + (digits[1]*10) + digits[2];
        return true;
      }
    }
    catch(error){
      if(error is DioException){
        if (error.response != null) {
          String toParseData = error.response.toString();
          print(toParseData);
        }
      }
    }
    return false;
  }

  Future<void> _launchURL(Uri url) async {
    await launchUrl(url);
  }

  void showOutDateDialog(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double width = MediaQuery.of(context).size.width;
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          child: SizedBox(
            width: 150,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10,),
                Text((globals.userLanguage == "ru")? versionOutdatedStringTitleRu : versionOutdatedStringTitleKg, textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500 , letterSpacing: 0.2
                    )
                ),
                const SizedBox(height: 10,),
                Text((globals.userLanguage == "ru")? versionOutdatedStringSubTitleRu : versionOutdatedStringSubTitleKg, textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500 , letterSpacing: 0.2
                    )
                ),
                const SizedBox(height: 20,),
                GestureDetector(
                  onTap: (){
                    //todo : => here we need navigate user to a newer version :
                    if(Platform.isIOS){
                      final String urlIOSPath = "https://apps.apple.com/kg/app/zherdesh/id6478204121";
                      Uri uri = Uri.parse(urlIOSPath);
                      _launchURL(uri);
                    }
                    if(Platform.isAndroid){
                      final String urlAndroidPath = "https://play.google.com/store/apps/details?id=com.zherdeshapp.zherdeshmobileapplication&hl=ru";
                      Uri uri = Uri.parse(urlAndroidPath);
                      _launchURL(uri);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      width: width,
                      decoration: BoxDecoration(
                          color: mainZherdeshColor,
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text((globals.userLanguage == "ru")? buttonDataStringRu : buttonDataStringKg, textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500 , letterSpacing: 0.2
                            )
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20,),
              ],
            ),
          ),
        );
      },
    );
  }

  void noUserHaveInternet(){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        double width = MediaQuery.of(context).size.width;
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10,),
              Text((globals.userLanguage == "ru")? noInternetRu : noInternetKg, textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 20, color: Colors.black, fontWeight: FontWeight.w500 , letterSpacing: 0.2
                  )
              ),
              const SizedBox(height: 20,),
              GestureDetector(
                onTap: () async{
                  await retryFetchData();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    width: width,
                    decoration: BoxDecoration(
                        color: mainZherdeshColor,
                        borderRadius: BorderRadius.circular(20)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text((globals.userLanguage == "ru")? buttonDataStringRu : buttonDataStringKg, textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 20, color: Colors.white, fontWeight: FontWeight.w500 , letterSpacing: 0.2
                          )
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20,),
            ],
          ),
        );
      },
    );
  }

  Future<void> retryFetchData() async{
    bool userHaveInternet = await getAppVersion();
    if(userHaveInternet){
      await AppMetrica.reportEvent('Открыто приложение');
      if(globals.globalVersion >= verIntData){
        bool userLogged = await isUserLogged();
        if(userLogged){
          if(globals.userLanguage=="ru"){
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
        }
        final navController = ref.read(navIndexProvider.notifier);
        navController.setIndex(0);
        context.goNamed(routes.GoRoutePath.homePageRoute);
      }
      else{
        //If version is outdated we need to show alert dialog with excuses
        showOutDateDialog();
      }
    }
    else{
      // if user don't have internet
      noUserHaveInternet();
    }
  }

  Future<void> logoMainMethod() async{
    //get and set user data for system
    await checkLaunchData();
    //check Internet connection :
    bool userHaveInternet = await getAppVersion();
    if(userHaveInternet){
      await AppMetrica.reportEvent('Открыто приложение');
      if(globals.globalVersion >= verIntData){
        bool userLogged = await isUserLogged();
        if(userLogged){
          if(globals.userLanguage=="ru"){
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
        }
        final navController = ref.read(navIndexProvider.notifier);
        navController.setIndex(0);
        context.goNamed(routes.GoRoutePath.homePageRoute);
      }
      else{
        //If version is outdated we need to show alert dialog with excuses
        showOutDateDialog();
      }
    }
    else{
      // if user don't have internet
      noUserHaveInternet();
    }
  }

  Widget casualTheme(double width , double height){
    return
  }

  Widget newYearTheme(double width, double height){
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: newYearBackgroundColor,
        body: Align(
          alignment: Alignment.center,
          child: Container(
            width: width,
            height: height,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage("assets/images/snow_falling.gif"),
                    fit: BoxFit.cover)
            ),
            child: Container(
              width: width*0.75,
              height: height,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage("assets/images/logo_new_year_zherdesh.png"),
                      fit: BoxFit.fitWidth)
              ),
            ),
          ),
        )
    );
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: scaffoldColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.only(left: width*0.3), child :
            Container(
              width: width*0.4,
              height: height*0.4,
              decoration: const BoxDecoration(image: DecorationImage(image: AssetImage("assets/images/logo.png"),fit: BoxFit.contain)),
            )),
          ],
        )
    );
  }
}