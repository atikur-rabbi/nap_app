import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'views/homePage.dart';

//Locking the application to portait mode as the interface does not support landscape.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(NapApp());
  });
}

class NapApp extends StatefulWidget {
  @override
  _NapAppState createState() => _NapAppState();

}

class _NapAppState extends State<NapApp> {
  @override
  void initState() {
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NapApp Menu Tests',
        theme: ThemeData(
          //Colors
            primaryColor: Color.fromRGBO(18, 18, 18, 1),
            scaffoldBackgroundColor: Color.fromRGBO(18, 18, 18, 1),
            cardColor: Color.fromRGBO(18, 18, 18, 0.8),
            brightness: Brightness.dark),
        home: HomeScreen());
  }
}
