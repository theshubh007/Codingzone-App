import 'dart:async';
import 'dart:convert';

import 'package:codingzone/screens/loginscreen.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../uiparts/tags.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({Key? key}) : super(key: key);

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  String platfrom = "All";
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  List _loadeddataset = [].obs;
  var isLoaded = false;

  static final FirebaseAuth auth = FirebaseAuth.instance;
  static final GoogleSignIn googleSignIn = GoogleSignIn();
  Future<void> signOutFromGoogle() async {
    await googleSignIn.signOut();
    await auth.signOut();
  }

  Future<void> _fetchData() async {
    const API_URL = 'https://kontests.net/api/v1/all';
    const codechef = 'https://kontests.net/api/v1/code_chef';

    final response = await http.get(Uri.parse(API_URL));
    final data = json.decode(response.body);

    setState(() {
      _loadeddataset = data;
      isLoaded = true;
    });
  }

  Future<void> _fetchDatacodechef() async {
    const codechef = 'https://kontests.net/api/v1/code_chef';

    final response = await http.get(Uri.parse(codechef));
    final data = json.decode(response.body);
    Iterable inReverse = data.reversed;

    setState(() {
      platfrom = "CodeChef";
      _loadeddataset = inReverse.toList();
      isLoaded = true;
    });
  }

  Future<void> _fetchDatacodeforces() async {
    const codeforces = 'https://kontests.net/api/v1/codeforces';

    final response = await http.get(Uri.parse(codeforces));
    final data = json.decode(response.body);

    setState(() {
      platfrom = "CodeForces";
      _loadeddataset = data;
      isLoaded = true;
    });
  }

  Future<void> _fetchDataleetcode() async {
    const leetcode = 'https://kontests.net/api/v1/leet_code';

    final response = await http.get(Uri.parse(leetcode));
    final data = json.decode(response.body);
    Iterable inReverse = data.reversed;

    setState(() {
      platfrom = "LeetCode";
      _loadeddataset = inReverse.toList();
      isLoaded = true;
    });
  }

  Future<void> setup() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('formfilled', false);
      prefs.setBool('logged', false);
    });
    Get.offAll(const Loginscreen());
  }

  BannerAd? _bannerAd;
  //fetch banner ad using google_mobile_ads
  BannerAd createBannerAd() {
    return BannerAd(
        adUnitId: 'ca-app-pub-3940256099942544/6300978111',
        //adUnitId: 'ca-app-pub-3810232873081376/6546403493',
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) => print('BannerAd loaded.'),
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            print('BannerAd failedToLoad: $error');
          },
          onAdOpened: (Ad ad) => print('BannerAd onAdOpened.'),
          onAdClosed: (Ad ad) => print('BannerAd onAdClosed.'),
        ));
  }

  BannerAd createlargeBannerAd() {
    return BannerAd(
        // https://developers.google.com/admob/android/test-ads#sample_ad_units
        adUnitId: 'ca-app-pub-3940256099942544/6300978111',
        //adUnitId: 'ca-app-pub-3810232873081376/6546403493',
        size: AdSize.largeBanner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) => print('large BannerAd loaded.'),
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            ad.dispose();
            print('BannerAd failedToLoad: $error');
          },
          onAdOpened: (Ad ad) => print('BannerAd onAdOpened.'),
          onAdClosed: (Ad ad) => print('BannerAd onAdClosed.'),
        ));
  }

  Timer _timer = Timer(const Duration(seconds: 0), () {});
  bool even = false;

  void setupTimer() {
    _timer = Timer.periodic(const Duration(seconds: 40), (_) {
      if (even) {
        final newBannerAd = createlargeBannerAd();
        newBannerAd.load();
        setState(() {
          _bannerAd?.dispose();
          _bannerAd = newBannerAd;
          even = false;
        });
      } else {
        final newBannerAd = createBannerAd();
        newBannerAd.load();
        setState(() {
          _bannerAd?.dispose();
          _bannerAd = newBannerAd;
          even = true;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchData();
    _bannerAd = createBannerAd()..load();
    setupTimer();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  InkWell(
                      onTap: () async {
                        setState(() {
                          isLoaded = false;
                        });
                        await _fetchData();
                      },
                      child: Tags(
                        title: "All",
                        width: 100,
                        color: Colors.blue,
                      )),
                  InkWell(
                      onTap: () async {
                        setState(() {
                          isLoaded = false;
                        });
                        await _fetchDatacodechef();
                      },
                      child: Tags(
                        title: "Codechef",
                        width: 120,
                        color: Colors.brown.shade300,
                      )),
                  InkWell(
                      onTap: () {
                        setState(() {
                          isLoaded = false;
                        });
                        _fetchDatacodeforces();
                      },
                      child: Tags(
                        title: "Codeforces",
                        width: 120,
                        color: Colors.red,
                      )),
                  InkWell(
                      onTap: () {
                        setState(() {
                          isLoaded = false;
                        });
                        _fetchDataleetcode();
                      },
                      child: Tags(
                        title: "Leetcode",
                        width: 120,
                        color: Colors.orange,
                      )),
                ]),
          ),
        ),
        Builder(builder: (BuildContext context) {
          return Expanded(
            child: isLoaded == false
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : platfrom == "All"
                    ? ListView.separated(
                        shrinkWrap: false,
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(
                            height: 5,
                          );
                        },
                        itemCount: _loadeddataset.length,
                        itemBuilder: (BuildContext ctx, index) {
                          String s = _loadeddataset[index]["site"];
                          String tm = _loadeddataset[index]["start_time"];
                          String etm = _loadeddataset[index]["end_time"];

                          String fstime = removeUtcFromDate(tm);
                          var fparts = fstime.split(' ');
                          var fdate = fparts[0];
                          var ftime = fparts[1];
                          ftime = ftime.substring(0, 8);
                          var outputFormat = DateFormat('dd/MM/yyyy');
                          fdate = outputFormat.format(DateTime.parse(fdate));

                          String estime = removeUtcFromDate(etm);
                          var eparts = estime.split(' ');
                          var edate = eparts[0];
                          var etime = eparts[1];
                          etime = etime.substring(0, 8);
                          edate = outputFormat.format(DateTime.parse(edate));
                          String ur = _loadeddataset[index]['url'];
                          Uri urrl = Uri.parse(ur);

                          return InkWell(
                            onTap: () async {
                              if (!await launchUrl(
                                urrl,
                                mode: LaunchMode.externalApplication,
                              )) {
                                throw 'Could not launch $ur';
                              }
                            },
                            child: Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              clipBehavior: Clip.antiAlias,
                              margin: const EdgeInsets.all(3),
                              child: ListTile(
                                tileColor: Colors.black87,
                                leading: imggen(s),
                                title: Text(
                                  _loadeddataset[index]['name'],
                                  style: const TextStyle(
                                      fontSize: 19, color: Colors.blue),
                                ),
                                subtitle: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            "starting",
                                            style: TextStyle(
                                                fontSize: 20,
                                                color: Colors.green),
                                            overflow: TextOverflow.fade,
                                          ),
                                          Text("$fdate   ",
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white),
                                              overflow: TextOverflow.fade),
                                          Text("$ftime   ",
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.white),
                                              overflow: TextOverflow.fade),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 4,
                                    ),
                                    Expanded(
                                        child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "ending",
                                          style: TextStyle(
                                              fontSize: 20, color: Colors.red),
                                          overflow: TextOverflow.fade,
                                        ),
                                        Text(
                                          edate,
                                          style: const TextStyle(
                                              fontSize: 16,
                                              color: Colors.white),
                                          overflow: TextOverflow.fade,
                                        ),
                                        Text(
                                          etime,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white),
                                          overflow: TextOverflow.fade,
                                        ),
                                      ],
                                    )),
                                  ],
                                ),

                                //trailing: Icon(Icons.more_vert),
                              ),
                            ),
                          );
                        },
                      )
                    : platfrom == "CodeChef"
                        ? ListView.builder(
                            shrinkWrap: true,
                            itemCount: _loadeddataset.length,
                            itemBuilder: (BuildContext ctx, index) {
                              String stm = _loadeddataset[index]["start_time"];
                              String etm = _loadeddataset[index]["end_time"];

                              String fstime = removeUtcFromDate(stm);
                              var fparts = fstime.split(' ');
                              var fdate = fparts[0];
                              var ftime = fparts[1];
                              ftime = ftime.substring(0, 8);
                              var outputFormat = DateFormat('dd/MM/yyyy');
                              fdate =
                                  outputFormat.format(DateTime.parse(fdate));

                              String estime = removeUtcFromDate(etm);
                              var eparts = estime.split(' ');
                              var edate = eparts[0];
                              var etime = eparts[1];
                              etime = etime.substring(0, 8);
                              edate =
                                  outputFormat.format(DateTime.parse(edate));
                              String ur = _loadeddataset[index]['url'];
                              Uri urrl = Uri.parse(ur);
                              return InkWell(
                                onTap: () async {
                                  if (!await launchUrl(
                                    urrl,
                                    mode: LaunchMode.externalApplication,
                                  )) {
                                    throw 'Could not launch $ur';
                                  }
                                },
                                child: Card(
                                  child: ListTile(
                                    tileColor: Colors.black87,
                                    leading: Image.asset(
                                      "assets/images/codechef.png",
                                      //width: width * 0.3,
                                      fit: BoxFit.contain,
                                    ),
                                    title: Text(
                                      _loadeddataset[index]['name'],
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.blue),
                                    ),
                                    subtitle: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "starting",
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.green),
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                "$fdate   ",
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white),
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                "$ftime   ",
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white),
                                                overflow: TextOverflow.fade,
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                "ending",
                                                style: TextStyle(
                                                    fontSize: 20,
                                                    color: Colors.red),
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                edate,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white),
                                                overflow: TextOverflow.fade,
                                              ),
                                              Text(
                                                etime,
                                                style: const TextStyle(
                                                    fontSize: 18,
                                                    color: Colors.white),
                                                overflow: TextOverflow.fade,
                                              ),
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          )
                        : platfrom == "CodeForces"
                            ? ListView.builder(
                                shrinkWrap: true,
                                itemCount: _loadeddataset.length,
                                itemBuilder: (BuildContext ctx, index) {
                                  //   if((index%2)!=0){
                                  String tm =
                                      _loadeddataset[index]["start_time"];
                                  String etm =
                                      _loadeddataset[index]["end_time"];

                                  String fstime = removeUtcFromDate(tm);
                                  var fparts = fstime.split(' ');
                                  var fdate = fparts[0];
                                  var ftime = fparts[1];
                                  ftime = ftime.substring(0, 8);
                                  var outputFormat = DateFormat('dd/MM/yyyy');
                                  fdate = outputFormat
                                      .format(DateTime.parse(fdate));
                                  String estime = removeUtcFromDate(etm);
                                  var eparts = estime.split(' ');
                                  var edate = eparts[0];
                                  var etime = eparts[1];
                                  etime = etime.substring(0, 8);
                                  edate = outputFormat
                                      .format(DateTime.parse(edate));
                                  String ur = _loadeddataset[index]['url'];
                                  Uri urrl = Uri.parse(ur);

                                  return InkWell(
                                    onTap: () async {
                                      if (!await launchUrl(
                                        urrl,
                                        mode: LaunchMode.externalApplication,
                                      )) {
                                        throw 'Could not launch $ur';
                                      }
                                    },
                                    onLongPress: () {
                                      // rewardedAd.show(onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {  });
                                    },
                                    child: Card(
                                      child: ListTile(
                                        tileColor: Colors.black87,
                                        leading: Image.asset(
                                          "assets/images/code-forces.png",
                                          //width: width * 0.3,
                                          // height: height*0.7,
                                          fit: BoxFit.contain,
                                        ),
                                        title: Text(
                                          _loadeddataset[index]['name'],
                                          style: const TextStyle(
                                              fontSize: 18, color: Colors.blue),
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "starting",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.green),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                  Text(
                                                    "$fdate   ",
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                  Text(
                                                    "$ftime   ",
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "ending",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.red),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                  Text(
                                                    edate,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                  Text(
                                                    etime,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                })
                            : ListView.builder(
                                shrinkWrap: true,
                                itemCount: _loadeddataset.length,
                                itemBuilder: (BuildContext ctx, index) {
                                  //var width = MediaQuery.of(context).size.width;
                                  String etm =
                                      _loadeddataset[index]["end_time"];
                                  String tm =
                                      _loadeddataset[index]["start_time"];
                                  String fstime = removeUtcFromDate(tm);
                                  var fparts = fstime.split(' ');
                                  var fdate = fparts[0];
                                  var ftime = fparts[1];
                                  ftime = ftime.substring(0, 8);
                                  var outputFormat = DateFormat('dd/MM/yyyy');
                                  fdate = outputFormat
                                      .format(DateTime.parse(fdate));

                                  String estime = removeUtcFromDate(etm);
                                  var eparts = estime.split(' ');
                                  var edate = eparts[0];
                                  var etime = eparts[1];
                                  etime = etime.substring(0, 8);
                                  edate = outputFormat
                                      .format(DateTime.parse(edate));
                                  String ur = _loadeddataset[index]['url'];
                                  Uri urrl = Uri.parse(ur);
                                  return InkWell(
                                    onTap: () async {
                                      if (!await launchUrl(
                                        urrl,
                                        mode: LaunchMode.externalApplication,
                                      )) {
                                        throw 'Could not launch $ur';
                                      }
                                    },
                                    child: Card(
                                      child: ListTile(
                                        tileColor: Colors.black87,
                                        leading: Image.asset(
                                          "assets/images/leetcode.png",
                                          //width: width * 0.3,
                                          fit: BoxFit.contain,
                                        ),
                                        title: Text(
                                          _loadeddataset[index]['name'],
                                          style: const TextStyle(
                                              fontSize: 18, color: Colors.blue),
                                        ),
                                        subtitle: Row(
                                          children: [
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "starting",
                                                    style: TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.green),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                  Text(
                                                    "$fdate   ",
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                  Text(
                                                    "$ftime   ",
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "ending",
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.red),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                  Text(
                                                    edate,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                  Text(
                                                    etime,
                                                    style: const TextStyle(
                                                        fontSize: 18,
                                                        color: Colors.white),
                                                    overflow: TextOverflow.fade,
                                                  ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
          );
        }),
      ],
    ));
  }

  String removeUtcFromDate(String date) {
    //2022-05-25 17:30:00 UTC
    // 2014-07-07T15:38:00.000Z

    try {
      var dt = DateTime.tryParse(date);
      if (dt != null) {
        return dt.toLocal().toString();
      } else {
        var test = '${date.replaceAll(' UTC', '')}.000Z';
        var temp = test.split(' ').toList().join('T');
        temp = DateTime.parse(temp).toLocal().toString();
        return temp;
      }
    } catch (e) {
      return date;
    }
  }

  Widget? imggen(String s) {
    //var height = MediaQuery.of(context).size.height;
    //var width = MediaQuery.of(context).size.width;
    Image im;
    switch (s) {
      case "HackerRank":
        im = Image.asset(
          "assets/images/hackerrank.png",
          //width: height * 0.14,
          fit: BoxFit.contain,
        );
        break;
      case "CodeChef":
        im = Image.asset(
          "assets/images/codechef.png",
          //width: width * 0.3,
          fit: BoxFit.contain,
        );
        break;
      case "HackerEarth":
        im = Image.asset(
          "assets/images/hacker-earth.png",
          //width: width * 0.28,
          //height: height * 0.6,
          fit: BoxFit.contain,
        );
        break;
      case "CodeForces":
        im = Image.asset(
          "assets/images/code-forces.png",
          //width: width * 0.3,
          // height: height*0.7,
          fit: BoxFit.contain,
        );
        break;
      case "AtCoder":
        im = Image.asset(
          "assets/images/at-coder.png",
          //width: width * 0.3,
          // height: height*0.6,

          fit: BoxFit.contain,
        );

        break;

      case "LeetCode":
        im = Image.asset(
          "assets/images/leetcode.png",
          //width: width * 0.3,
          fit: BoxFit.contain,
        );
        break;

      default:
        im = Image.asset(
          "assets/images/default.png",
          //width: 100,
          fit: BoxFit.contain,
        );
        break;
    }
    return im;
  }
}
