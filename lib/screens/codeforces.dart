import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../service/admobservice.dart';

class Codeforcescreen extends StatefulWidget {
  const Codeforcescreen({Key? key}) : super(key: key);

  @override
  State<Codeforcescreen> createState() => _CodeforcescreenState();
}

class _CodeforcescreenState extends State<Codeforcescreen> {
  // late RewardedAd rewardedAd;

  late InterstitialAd interstitialAd;
  List _loadeddataset = [];
  var isLoaded = false;

  Future<void> cffetchData() async {
    const API_URL = 'https://kontests.net/api/v1/codeforces';

    final response = await http.get(Uri.parse(API_URL));
    final data = json.decode(response.body);
    // Iterable inReverse = data.reversed;

    setState(() {
      _loadeddataset = data;

      /* for(int i=0;i<_loadeddataset.length;i++) {
        if (i % 2 == 0) {
          _loadeddataset.insert(i, AdmobHelper.getBannerAd()
            ..load());
        }
      }*/
      isLoaded = true;
    });
  }

  RewardedAd? rewardedAd;
  void rewardad() {
    RewardedAd.load(
        // adUnitId: 'ca-app-pub-3940256099942544/5224354917',
        adUnitId: 'ca-app-pub-3810232873081376/4586454566',
       
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            setState(() {
              rewardedAd = ad;
            });
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('RewardedAd failed to load: $error');
          },
        ));
  }

  Timer _timer = Timer(const Duration(seconds: 0), () {});
  void settimer() {
    _timer = Timer.periodic(const Duration(seconds: 40), (_) {
      setState(() {
        // rewardedAd?.dispose();
        rewardad();
        rewardedAd?.show(
            onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {});
      });
    });
  }

  @override
  void initState() {
    super.initState();
    cffetchData();
    rewardad();

    rewardedAd?.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {});
    settimer();
  }

  @override
  void dispose() {
    rewardedAd?.dispose();
    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      /*    appBar: AppBar(
        title: const Text("contests"),
        backgroundColor: Colors.red,
      ),*/
      body: SafeArea(
          child: isLoaded == false
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : ListView.builder(
                  itemCount: _loadeddataset.length,
                  itemBuilder: (BuildContext ctx, index) {
                    //   if((index%2)!=0){
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
                      onLongPress: () {
                        rewardedAd?.show(
                            onUserEarnedReward:
                                (AdWithoutView ad, RewardItem reward) {});
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "starting",
                                      style: TextStyle(
                                          fontSize: 18, color: Colors.green),
                                      overflow: TextOverflow.fade,
                                    ),
                                    Text(
                                      "$fdate   ",
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                      overflow: TextOverflow.fade,
                                    ),
                                    Text(
                                      "$ftime   ",
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
                                      overflow: TextOverflow.fade,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          fontSize: 18, color: Colors.white),
                                      overflow: TextOverflow.fade,
                                    ),
                                    Text(
                                      etime,
                                      style: const TextStyle(
                                          fontSize: 18, color: Colors.white),
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
                  })),
      bottomNavigationBar: SizedBox(
        height: 50,
        child: AdWidget(
          ad: AdmobHelper.getBannerAd()..load(),
          key: UniqueKey(),
        ),
      ),
    );
  }

  String removeUtcFromDate(String date) {
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
}
