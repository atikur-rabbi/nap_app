import 'package:flutter/material.dart';

class AboutUs extends StatefulWidget
{
  @override 
  _AboutUsState createState() => _AboutUsState();
}

//Converts hex code to dart color object
Color hexToColor(String code) {
      return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
    }

class _AboutUsState extends State<AboutUs> {

  //Text for Who Are We section
  final aboutUsString = '''
  Lifespan Trust is a NZ Registered Charity (Non-profit
   organisation) aimed at educating and coaching
    healthy relationships with sleep, stress, weight and 
    mental wellbeing. Read more: lifespantrust.com
  ''';

  //Test for Why Should You Nap section
  final whyNapString = '''
  Power napping is like resetting your hard drive,
   feeling energized and invigorated.
Increase your ability to learn and perform
Overcome tiredness, fatigue and increase your
 vigilance, attention and alertness
So much more effective than having a caffeine or
 sugar fix.

  ''';

  //Test for Why This App section
  final thisAppString = '''
  It has been found a 10-minute nap (from when 
  you fall asleep) is the optimum time for an effective
    rejuvenating short nap.
This app determines when you fall asleep and
 wakes you up 10 minutes later.
You need to be careful that if you nap longer you
 can wake with sleep inertia or tiredness. Read more
  if YOU should nap or not: lifespantrust.com

  ''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Why Should You Nap?'),
      ),
    body: SingleChildScrollView(
      child: Row(    
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget> [
              Container(
                height: 50,
                width: 100,
              ),

              Text('Who Are We?',
              style: new TextStyle(color: hexToColor("#3DA8F7"), fontSize: 25.0),),

              Text(       
                aboutUsString,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.0),
                maxLines: 10,),
               
               Container(
                height: 20,
                width: 100,
              ),

              Text('Why You Should Nap!',
              style: new TextStyle(color: hexToColor("#3DA8F7"), fontSize: 25.0),),
              
              Text(       
                whyNapString,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.0),
                maxLines: 10,),
                
                Container(
                height: 20,
                width: 100,
              ),

              Text('Why Use Nap Optimize App',
              style: new TextStyle(color: hexToColor("#3DA8F7"), fontSize: 25.0),),

              Text(       
                thisAppString,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.0),
                maxLines: 10,),

           ],
          ),
        ],           
       ),
    ),
   );
  }
}