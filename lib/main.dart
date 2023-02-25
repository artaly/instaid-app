// ignore_for_file: prefer_const_constructors
// Test commit
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_phone_auth_handler/firebase_phone_auth_handler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:instaid_dev/models/user_model.dart';
import 'package:instaid_dev/screens/login/login.dart';
import 'package:instaid_dev/screens/main_screen.dart';
import 'package:instaid_dev/utils/colors.dart';
import 'package:instaid_dev/utils/route_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await dotenv.load(fileName: ".env");
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var email = prefs.getString('email');
  await UserPref.init();
  configLoading();
  runApp(MyApp(defaultHome: email == null ? LoginScreen() : MainScreen()));
}

void configLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.light
    ..maskType = EasyLoadingMaskType.black
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..progressColor = Colors.yellow
    ..backgroundColor = Colors.green
    ..indicatorColor = Colors.yellow
    ..textColor = Colors.yellow
    ..maskColor = Colors.blue.withOpacity(0.5)
    ..userInteractions = true
    ..dismissOnTap = false;
}

class MyApp extends StatelessWidget {
  final Widget defaultHome;
  const MyApp({Key? key, required this.defaultHome}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FirebasePhoneAuthProvider(
      child: MaterialApp(
        title: 'InstAID',
        home: defaultHome,
        debugShowCheckedModeBanner: true,
        builder: EasyLoading.init(),
        theme: ThemeData(
            appBarTheme: AppBarTheme(
              color: Colors.white,
              elevation: 0,
              systemOverlayStyle: SystemUiOverlayStyle(
                systemNavigationBarIconBrightness: Brightness.light,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              ),
              //iconTheme: IconThemeData(color: Colors.black)
              titleTextStyle: Theme.of(context).textTheme.headline6?.copyWith(
                  fontFamily: 'OpenSans',
                  fontSize: 18,
                  color: Color(0XFF8B8B8B)),
            ),
            scaffoldBackgroundColor: primaryBackground,
            fontFamily: 'Gotham',
            primaryColor: primaryColor,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        onGenerateRoute: RouteGenerator.generateRoute,
        //initialRoute: LoginScreen.id,
      ),
    );
  }
}
