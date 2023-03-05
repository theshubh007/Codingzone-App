import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class Leetcodescreen extends StatefulWidget {
  const Leetcodescreen({Key? key}) : super(key: key);

  @override
  State<Leetcodescreen> createState() => _LeetcodescreenState();
}

class _LeetcodescreenState extends State<Leetcodescreen> {
  List _loadedPhotos = [];
  var isLoaded = false;

  Future<void> _lfetchData() async {
    const API_URL = 'https://kontests.net/api/v1/leet_code';

    final response = await http.get(Uri.parse(API_URL));
    final data = json.decode(response.body);
    Iterable inReverse = data.reversed;
    setState(() {
      _loadedPhotos = inReverse.toList();
      isLoaded = true;
    });
  }

  BannerAd? _bannerAd;
  bool adloaded = false;
  //fetch banner ad using google_mobile_ads
  BannerAd createBannerAd() {
    return BannerAd(
        // adUnitId: 'ca-app-pub-3940256099942544/6300978111',
        adUnitId: 'ca-app-pub-3810232873081376/6546403493',
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
        // adUnitId: 'ca-app-pub-3940256099942544/6300978111',
        adUnitId: 'ca-app-pub-3810232873081376/6546403493',
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
    _lfetchData();
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
      /*  appBar: AppBar(
        title: const Text("contests"),
        backgroundColor: Colors.orange,
      ),*/
      body: SafeArea(
          child: isLoaded == false
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Stack(children: [
                  Builder(builder: (context) {
                    return ListView.builder(
                      itemCount: _loadedPhotos.length,
                      itemBuilder: (BuildContext ctx, index) {
                        //var width = MediaQuery.of(context).size.width;
                        String etm = _loadedPhotos[index]["end_time"];
                        String tm = _loadedPhotos[index]["start_time"];
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
                        String ur = _loadedPhotos[index]['url'];
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
                                _loadedPhotos[index]['name'],
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
                                              fontSize: 20, color: Colors.red),
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
                    );
                  }),
                  if (_bannerAd != null && _bannerAd!.size.height > 0)
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    )
                ])),
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
