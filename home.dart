import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:timer_builder/timer_builder.dart';








class Home extends StatefulWidget {




  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //banner
  late BannerAd _bannerAd;
  bool _isAdLoaded=false;


  //timer
  Map data = {};

  late DateTime alert;






  @override
  void initState() {
    super.initState();
    _initBannerAd();
    alert = DateTime.now().add(Duration(seconds: 300)); // default is 5 min study time.
  }

  Text BreakText(TextStyle a) {
    // display Break notification text for ___ mins, then change reached to false.
    Future.delayed(Duration(seconds: data['breakTime']), () {
      setState(() {
        alert = DateTime.now().add(Duration(seconds: data['studyTime']));
      });
    });
    return Text(
      ((data['breakTime']/60).toInt()).toString() + ' min break!',
      style: TextStyle(
        fontSize: 30.0,
        color: Colors.white,
      ),
    );
  }

  _initBannerAd(){
    _bannerAd=BannerAd(
        size: AdSize.banner,
        adUnitId: BannerAd.testAdUnitId,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              _isAdLoaded=true;
            });
          },
           onAdFailedToLoad: (ad,error){},

    ),
        request: AdRequest()
    );
    _bannerAd.load();
  }

  @override
  Widget build(BuildContext context) {

 data = data.isNotEmpty ? data : ModalRoute.of(context)!.settings.arguments as Map;










    return Scaffold(


      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text('shūchū',
            style: TextStyle(
              fontSize: 15.0,

            )),
        centerTitle: true,
      ),
      body:
      TimerBuilder.scheduled([alert],
          builder: (context) {
            var now = DateTime.now();
            var reached = now.compareTo(alert) >= 0;
            final textStyle = Theme.of(context).textTheme.headline6;

            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  !reached ?
                  TimerBuilder.periodic(
                      Duration(seconds: 1),
                      alignment: Duration.zero,
                      builder: (context) {
                        // This function will be called every second until the time is reached.
                        var now = DateTime.now();
                        var remaining = alert.difference(now);
                        return Text(formatDuration(remaining),
                            style: TextStyle(
                              fontSize: 60.0,
                              color: Colors.white,
                              //fontWeight: FontWeight.bold,
                            )
                        );
                      }
                  )
                      :
                  BreakText(textStyle!),

                  const SizedBox(height: 18),

                  FlatButton.icon(
                    minWidth: 200.0,
                    height: 50.0,
                    color: Colors.indigo,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),

                       onPressed: () {
                        setState(() {
                          alert = DateTime.now().add(Duration(seconds: data['studyTime']));
                        });
                      },
                     icon: Icon(Icons.replay_rounded,color: Colors.white,),
                     label: Text('Reset',style: TextStyle(
                       fontSize: 15.0,
                       color: Colors.white,
                     ) ),

                    ),

                  const SizedBox(height: 18),
                    FlatButton.icon(
                     minWidth: 200.0,
                     height: 50.0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      color: Colors.indigoAccent,
                      onPressed: () {
                        setState(() {
                          alert = DateTime.now();
                        });
                      },
                      icon:Icon(Icons.pause_rounded,color: Colors.white,),

                    label: Text('Take Break', style: TextStyle(
                                fontSize: 15.0,
                                color: Colors.white,
                              )),
                          ),




                  const SizedBox(height: 18),


                     FlatButton.icon(
                      minWidth: 200.0,
                      height: 50.0,
                        onPressed: () async {
                          dynamic result = await Navigator.pushNamed(context, '/settings');
                          if(result != null) {
                            setState(() {
                              data = {
                                'studyTime': result['studyTime'],
                                'breakTime': result['breakTime'],
                              };
                            });
                          }
                        },






                      icon:         Icon(Icons.settings,
                                color: Colors.white,),

                      label:        Text('Settings', style: TextStyle(
                                  fontSize: 20.0,
                                  color: Colors.white,
                                  decoration: TextDecoration.underline,
                                )
                                ),





                    ),

                ],
              ),
            );
          }
      ),
      bottomNavigationBar: _isAdLoaded ? Container(
        height: _bannerAd.size.height.toDouble(),
        width: _bannerAd.size.width.toDouble(),
        child: AdWidget(ad: _bannerAd),
      ): SizedBox(),

    );
  }
}


String formatDuration(Duration d) {
  String f(int n) {
    return n.toString().padLeft(2, '0');
  }
  // Need to round up the remaining time to the nearest second
  d += Duration(microseconds: 999999);
  return "${f(d.inMinutes)}:${f(d.inSeconds%60)}";
}




  



