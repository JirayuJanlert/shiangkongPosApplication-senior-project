import 'package:flutter/material.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Screen/HomePage.dart';
import 'package:siangkong_mpos/Screen/LoginPage.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashScreenPage extends StatefulWidget {
  @override
  _SplashScreenPageState createState() => _SplashScreenPageState();
}

class _SplashScreenPageState extends State<SplashScreenPage> {
  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      seconds: 3,
      navigateAfterSeconds: HomePage(),
      title: Text("S. Shiangkong Motor\nSales Order and Billing System ",style: splashTitle, textAlign: TextAlign.center,),
      image: Image.asset("assets/logo.png"),
      gradientBackground: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
          colors: [
            royalblue,blueblue,hotpink
          ]
      ),
      photoSize: 100,

      loaderColor: royalblue,

    );
  } } //ec
