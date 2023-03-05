import 'package:auto_size_text/auto_size_text.dart';
import 'package:codingzone/screens/codechefscreen.dart';
import 'package:codingzone/screens/codeforces.dart';
import 'package:codingzone/screens/homescreen.dart';
import 'package:codingzone/screens/leetcodescreen.dart';
import 'package:codingzone/screens/loginscreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Drawermain extends StatefulWidget {
  final int ind;
  const Drawermain({required this.ind});

  @override
  State<Drawermain> createState() => _DrawermainState();
}

class _DrawermainState extends State<Drawermain> {
  final _advancedDrawerController = AdvancedDrawerController();
  User? user = FirebaseAuth.instance.currentUser;
  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<void> signOutFromGoogle() async {
    await googleSignIn.signOut();
    await auth.signOut();
    await setup();
  }

  Future<void> setup() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('formfilled', false);
      prefs.setBool('logged', false);
      prefs.setBool('final', false);
    });
    Get.offAll(const Loginscreen());
  }

  final pages = [
    const Homescreen(),
    const Codeforcescreen(),
    const Leetcodescreen(),
    const Codechefscreen(),
  ];
  List<dynamic> listOfIcons = [
    Icons.home_rounded,
    Icons.bar_chart_rounded,
    Icons.code,
    Icons.local_cafe,
  ];
  List<String> appbarstr = [
    'All contests',
    "Code force",
    "Leetcode",
    "Codechef",
  ];

  var currentIndex = 0;

  void onTab(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    currentIndex = widget.ind;
    super.initState();
    const Codeforcescreen();
    const Codeforcescreen();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return AdvancedDrawer(
      backdropColor: Colors.blueGrey,
      controller: _advancedDrawerController,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      animateChildDecoration: true,
      rtlOpening: false,
      // openScale: 1.0,
      disabledGestures: false,
      childDecoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      drawer: SafeArea(
        child: Container(
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 128.0,
                    height: 128.0,
                    margin: const EdgeInsets.only(
                      top: 24.0,
                      bottom: 24.0,
                    ),
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(user!.photoURL!),
                  ),
                  AutoSizeText(
                    user!.email!,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  AutoSizeText(
                    user!.displayName!,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 24.0,
                  ),
                  ListTile(
                    onTap: () {
                      Get.offAll(const Drawermain(ind: 0));
                    },
                    leading: const Icon(Icons.home),
                    title: const Text('Home'),
                  ),
                  ListTile(
                    onTap: () {
                      Get.offAll(const Drawermain(ind: 1));
                    },
                    leading: const Icon(Icons.bar_chart_rounded),
                    title: const Text('Codeforces'),
                  ),
                  ListTile(
                    onTap: () {
                      Get.offAll(const Drawermain(ind: 2));
                    },
                    leading: const Icon(Icons.code),
                    title: const Text('Leetcode'),
                  ),
                  ListTile(
                    onTap: () {
                      Get.offAll(const Drawermain(ind: 3));
                    },
                    leading: const Icon(Icons.local_cafe),
                    title: const Text('Codechef'),
                  ),
                  ListTile(
                    onTap: () async {
                      await signOutFromGoogle();
                      // await setup();
                    },
                    leading: const Icon(Icons.power_settings_new),
                    title: const Text('Log out'),
                  ),
                  const Spacer(),
                  /*DefaultTextStyle(
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white54,
                    ),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 16.0,
                      ),
                      child: Text('Terms of Service | Privacy Policy'),
                    ),
                  ),*/
                ],
              ),
            ),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: setcl(currentIndex),
          title: Text(
            appbarstr[currentIndex],
          ),
          leading: IconButton(
            onPressed: _handleMenuButtonPressed,
            icon: ValueListenableBuilder<AdvancedDrawerValue>(
              valueListenable: _advancedDrawerController,
              builder: (_, value, __) {
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    value.visible ? Icons.clear : Icons.menu,
                    key: ValueKey<bool>(value.visible),
                  ),
                );
              },
            ),
          ),
        ),
        body: pages[currentIndex],
        bottomNavigationBar: Container(
          margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          height: screenWidth * .195,
          decoration: BoxDecoration(
            color: Colors.black87,

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.15),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
            // borderRadius: BorderRadius.circular(50),
          ),
          child: ListView.builder(
            itemCount: 4,
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: screenWidth * .064),
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                setState(() {
                  currentIndex = index;
                  HapticFeedback.lightImpact();
                });
              },
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Stack(
                children: [
                  SizedBox(
                    width: screenWidth * .2125,
                    child: Center(
                      child: AnimatedContainer(
                        duration: const Duration(seconds: 1),
                        curve: Curves.fastLinearToSlowEaseIn,
                        height: index == currentIndex ? screenWidth * .12 : 0,
                        width: index == currentIndex ? screenWidth * .2125 : 0,
                        decoration: BoxDecoration(
                          color: index == currentIndex
                              ? Colors.blueAccent.withOpacity(.5)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: screenWidth * .2125,
                    alignment: Alignment.center,
                    child: Icon(
                      listOfIcons[index],
                      size: screenWidth * .076,
                      color: index == currentIndex
                          // ? Colors.lightBlueAccent.withOpacity(0.9)
                          ? setcl(index)
                          : Colors.white24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color setcl(int index) {
    switch (index) {
      case 0:
        return Colors.lightBlueAccent.withOpacity(0.9);
        break;
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.orange;
        break;
      default:
        return Colors.lime;
    }
  }

  void _handleMenuButtonPressed() {
    // NOTICE: Manage Advanced Drawer state through the Controller.
    // _advancedDrawerController.value = AdvancedDrawerValue.visible();
    _advancedDrawerController.showDrawer();
  }
}
