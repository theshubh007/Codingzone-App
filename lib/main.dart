import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:codingzone/screens/Mainsetupscreen.dart';
import 'package:codingzone/screens/codechefscreen.dart';
import 'package:codingzone/screens/codeforces.dart';
import 'package:codingzone/screens/homescreen.dart';
import 'package:codingzone/screens/leetcodescreen.dart';
import 'package:codingzone/screens/loginscreen.dart';
import 'package:codingzone/screens/userdetailform.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<int> fetchsharedpref() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  bool tempformfilled = prefs.getBool("formfilled") ?? false;
  bool templogged = prefs.getBool("logged") ?? false;
  bool finall = prefs.getBool("final") ?? false;
  bool formfilled = (tempformfilled == true) ? true : false;
  bool logged = (templogged == true) ? true : false;
  bool finalll = (finall == true) ? true : false;
  User? user = FirebaseAuth.instance.currentUser;
  CollectionReference dusers = FirebaseFirestore.instance.collection('users');
  var snap = await dusers.doc(user?.email).get();
  // Map data = snap.data() as Map;
  // bool prevformfilled = data['formfilled'] == "true" ? true : false;

  if (finalll == true) {
    FlutterNativeSplash.remove();
    return 1;
  } else if (logged == true && formfilled != true) {
    FlutterNativeSplash.remove();
    return 2;
  }
  FlutterNativeSplash.remove();
  return 3;

}

void main() async {
   WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  // bool tempformfilled = prefs.getBool("formfilled") ?? false;
  // bool templogged = prefs.getBool("logged") ?? false;
  // bool formfilled = (tempformfilled == true) ? true : false;
  // bool logged = (templogged == true) ? true : false;
  const mobileBackgroundColor = Color.fromRGBO(0, 0, 0, 1);
  runApp(GetMaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData.dark().copyWith(
      scaffoldBackgroundColor: mobileBackgroundColor,
    ),
    home: FutureBuilder(
        future: fetchsharedpref(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return snapshot.data == 1
                ? Drawermain(
                    ind: 0,
                  )
                : snapshot.data == 2
                    ? const Userdetailform()
                    : const Loginscreen();
          }
        }),

    // (formfilled == true && logged == true)
    //     ? Drawermain(
    //         ind: 0,
    //       )
    //     : const Loginscreen(),
    getPages: [
      GetPage(name: "/fm", page: () => const Userdetailform()),
      GetPage(name: "/lg", page: () => const Loginscreen()),
      GetPage(
          name: "/hm",
          page: () => Drawermain(
                ind: 0,
              )),
      GetPage(name: "/hmscreen", page: () => const Homescreen()),
      GetPage(name: "/cf", page: () => const Codeforcescreen()),
      GetPage(name: "/cc", page: () => const Codechefscreen()),
      GetPage(name: "/lt", page: () => const Leetcodescreen()),
    ],
  ));
}
