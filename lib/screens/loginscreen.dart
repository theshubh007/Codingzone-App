import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Constant/colorconstant.dart';
import '../firebase/firebase_service.dart';

class Loginscreen extends StatefulWidget {
  const Loginscreen({Key? key}) : super(key: key);

  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  CollectionReference dusers = FirebaseFirestore.instance.collection('users');
  User? user = FirebaseAuth.instance.currentUser;
  FirebaseAuth auth = FirebaseAuth.instance;
  GoogleSignIn googleSignIn = GoogleSignIn();

  Future<void> setup(String email) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('logged', true);
    });
    await dusers.doc(email).get().then((snap) {
      if (snap.data() != null) {
        Map data = snap.data() as Map;
        bool prevformfilled = data['formfilled'] == "true" ? true : false;
        if (prevformfilled == true) {
          print("prevfilled");
          // DialogBuilder(context).hideOpenDialog();
          setState(() {
            prefs.setBool('final', true);
          });
          Get.offAllNamed("/hm");
        } else {
          // DialogBuilder(context).hideOpenDialog();
          Get.toNamed("/fm");
        }
      } else {
        // DialogBuilder(context).hideOpenDialog();
        Get.toNamed("/fm");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    return Scaffold(
        backgroundColor: Colorconstant.skyblue,
        body: SingleChildScrollView(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
            padding: const EdgeInsets.only(left: 15, right: 15),
            child: Column(
              children: [
                SizedBox(
                  height: height * 0.1,
                ),
                Padding(
                  padding: const EdgeInsets.all(5),
                  child: Image(
                    image: const AssetImage("assets/images/logoimg.png"),
                    height: height * 0.5,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: FloatingActionButton.extended(
                      onPressed: () async {
                        // DialogBuilder(context).showLoadingIndicator();
                        // FirebaseService service = new FirebaseService();
                        UserCredential? usercredential =
                            await FirebaseService.fbinstance.signInWithGoogle();
                        // await dusers.doc(usercredential.user!.email).update({
                        //   'name': usercredential.user!.displayName,
                        //   'email': usercredential.user!.email,
                        //   'phone': usercredential.user!.phoneNumber,
                        // }).then((val) async {
                        await setup(usercredential.user!.email.toString());
                        // });
                      },
                      icon: Image.asset(
                        'assets/images/google.png',
                        height: 32,
                        width: 32,
                      ),
                      label: const Text("sign in with google"),
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ])));
  }
}

class DialogBuilder {
  DialogBuilder(this.context);

  final BuildContext context;

  void showLoadingIndicator() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () async => false,
            child: const AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8.0))),
              backgroundColor: Colors.black87,
              content: LoadingIndicator(text: 'processing'),
            ));
      },
    );
  }

  void hideOpenDialog() {
    Navigator.of(context).pop();
  }
}

class LoadingIndicator extends StatelessWidget {
  const LoadingIndicator({this.text = ''});

  final String text;

  @override
  Widget build(BuildContext context) {
    var displayedText = text;

    return Container(
        padding: const EdgeInsets.all(16),
        color: Colors.black87,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              _getLoadingIndicator(),
              _getHeading(context),
              _getText(displayedText)
            ]));
  }

  Padding _getLoadingIndicator() {
    return const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(strokeWidth: 3)));
  }

  Widget _getHeading(context) {
    return const Padding(
        padding: EdgeInsets.only(bottom: 4),
        child: Text(
          'Please wait …',
          style: TextStyle(color: Colors.white, fontSize: 16),
          textAlign: TextAlign.center,
        ));
  }

  Text _getText(String displayedText) {
    return Text(
      displayedText,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      textAlign: TextAlign.center,
    );
  }
}
