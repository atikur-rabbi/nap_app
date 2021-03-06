import 'dart:async';

import 'package:first_app/setting.dart';
import 'package:first_app/views/summaryPage.dart';
import 'package:wakelock/wakelock.dart';
import '../userNapData.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:volume/volume.dart';

class NapTimer extends StatefulWidget {

  final int napLength;
  final UserNapData napData;
  final NapSettingsData settings;
  NapTimer({this.napLength, this.napData, this.settings});

  @override
  _NapTimerState createState() => _NapTimerState();
}

class _NapTimerState extends State<NapTimer> with TickerProviderStateMixin, WidgetsBindingObserver {
  AnimationController controller;
  Stopwatch timeSlept = Stopwatch();
  double alarmVolume = 1; 
  AudioManager audioManager;
  int currentVol, maxVol;
  Timer gentleWakeTimer;
  bool hasRunCode = false;
  Duration duration;

  @override
  void dispose(){
    Wakelock.disable();
    controller.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

    @override
  void initState() {
    super.initState();
    timeSlept.start();

    WidgetsBinding.instance
      .addPostFrameCallback((_) => startTimer(context));
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: this.widget.napLength),
    );

    audioManager = AudioManager.STREAM_NOTIFICATION;
    initPlatformState();
    updateVolumes();

    WidgetsBinding.instance.addObserver(this);
  }

  void startTimer(BuildContext context){
    controller.reverse(
      from: controller.value == 0.0
             ? 1.0
             : controller.value);
  }


//TODO add wigetsbindingobserver to catch application suspension

//didChangeAppLifeCycleState allows any code to be run when the app is paused (minimized) or resumed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state){
    super.didChangeAppLifecycleState(state);
    switch(state){
      case AppLifecycleState.paused:
        print("paused");

        if(gentleWakeTimer.isActive){
          gentleWakeTimer.cancel();
        }
        FlutterRingtonePlayer.stop();
        break;

      case AppLifecycleState.resumed:
        print("resumed");
        print(duration.inSeconds);

        if(duration.inSeconds <= 1){
          timerString();
        }
        break;

      case AppLifecycleState.inactive:
        print("inactive");

        if(gentleWakeTimer.isActive){
          gentleWakeTimer.cancel();
        }
        FlutterRingtonePlayer.stop();
        break;

      case AppLifecycleState.detached:
        print("suspending");

        if(gentleWakeTimer.isActive){
          gentleWakeTimer.cancel();
        }
        FlutterRingtonePlayer.stop();
        break;
    }
  }
  
  Future<void> initPlatformState() async{
    await Volume.controlVolume(AudioManager.STREAM_NOTIFICATION);
  }

  

//Must be called after setVol is used to change volume.
  updateVolumes() async {
    // get Max Volume
    maxVol = await Volume.getMaxVol;
    // get Current Volume
    currentVol = await Volume.getVol;
    setState(() {});
  }

//Call this to change the system volume on phone.
//Requires an INT parameter of range from 0 - Volume.getMaxVol;
  setVol(int i) async {
    await Volume.setVol(i);
  }

  gentleWake(){
    FlutterRingtonePlayer.playAlarm(volume: alarmVolume, looping: true);
    setVol(0);
    updateVolumes();
    gentleWakeTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if(currentVol >= maxVol){
        gentleWakeTimer.cancel();
      }
      else{
        setVol(currentVol + 1);
        updateVolumes();
      }
    });
  }

  String timerString() {
    duration = controller.duration * controller.value;

    if(duration.inSeconds == 1.0){
      if(!hasRunCode){
        if(widget.settings.wantsGentleWake){
          gentleWake();
        }
        else{
          FlutterRingtonePlayer.playAlarm(volume: alarmVolume, looping: true);
        }

      hasRunCode = true;
      }
    }

    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

//Navigates to the summary pages passing through the napData and napSettings objects.
//Ensure all navigation out of this page stops all relevant timers/media players.
  navigateToSummary(){
    FlutterRingtonePlayer.stop();
    timeSlept.stop();
    if(gentleWakeTimer != null){
      if(gentleWakeTimer.isActive){
        gentleWakeTimer.cancel();
      }
    }
    widget.napData.timeSleptInSeconds = timeSlept.elapsed.inSeconds;
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => SummaryPage(napData: widget.napData,)), ModalRoute.withName('/'));
  }

//This is called if the android back button is pressed during the timer countdown.
//If yes is tapped, it will navigate to the summary page.
//Tapping no dismisses the dialog box.
  Future<bool> willPop(){
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Are you sure you want to terminate your sleep session?"),
        actions: <Widget>[
          FlatButton(
            child: Text("Yes"),
            onPressed: navigateToSummary
            ),
          FlatButton(
            child: Text("No"),
            onPressed: () => Navigator.pop(context, false),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return WillPopScope(
      onWillPop: willPop,
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Align(
                  alignment: FractionalOffset.center,
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: controller,
                            builder: (BuildContext context, Widget child) {
                              return CustomPaint(
                                  painter: TimerPainter(
                                animation: controller,
                                backgroundColor: Colors.white,
                                color: widget.settings.wantColourblindMode
                                ? Colors.red
                                : Color.fromRGBO(10, 86, 148, 1)
                              ));
                            },
                          ),
                        ),
                        Align(
                          alignment: FractionalOffset.center,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                "Nap Timer",
                                style: themeData.textTheme.subhead,
                              ),
                              AnimatedBuilder(
                                  animation: controller,
                                  builder: (BuildContext context, Widget child) {
                                    return Text(
                                      timerString(),
                                      style: themeData.textTheme.display4,
                                    );
                                  }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    FloatingActionButton(
                      backgroundColor: widget.settings.wantColourblindMode
                      ? Colors.red
                      : Color.fromRGBO(10, 86, 148, 1),
                      child: AnimatedBuilder(
                        animation: controller,
                        builder: (BuildContext context, Widget child) {
                          return Icon(controller.isAnimating
                              ? Icons.stop
                              : Icons.stop);
                        },
                      ),
                      onPressed: () {
                        navigateToSummary();
                      }
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TimerPainter extends CustomPainter {
  TimerPainter({
    this.animation,
    this.backgroundColor,
    this.color,
  }) : super(repaint: animation);

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;
    double progress = (1.0 - animation.value) * 2 * math.pi;
    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(TimerPainter old) {
    return animation.value != old.animation.value ||
        color != old.color ||
        backgroundColor != old.backgroundColor;
  }
}
