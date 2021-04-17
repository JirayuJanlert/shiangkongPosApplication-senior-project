import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:responsive_framework/responsive_wrapper.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Screen/HomePage.dart';
import 'package:siangkong_mpos/Screen/SplashScreen.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/sizing.dart';

void main() {

  WidgetsFlutterBinding.ensureInitialized();
  return runApp(
      MyApp()
  );
}
class InitialBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CustomerController(),fenix: true);
    Get.lazyPut(() => MyStore(),fenix: true);
    Get.lazyPut(() => OrderController(),fenix: true);
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context,constraints){
      return OrientationBuilder(
        builder: (context, orientation){
          SizeConfig().init(constraints, orientation);
          if(SizeConfig.isMobilePortrait){
            SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
          }else{
            SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
            SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
          }
          //fix orientation based on devices
          return GetMaterialApp(
            initialBinding: InitialBinding(),
            theme: ThemeData(fontFamily: 'Nunito'),
            builder: (context, widget) => ResponsiveWrapper.builder(
                BouncingScrollWrapper.builder(context, widget),
                maxWidth: 2200,
                minWidth: 600,
                defaultScale: true,
                breakpoints: [
                  ResponsiveBreakpoint.resize(550, name: MOBILE),
                  ResponsiveBreakpoint.autoScale(600, name: MOBILE),
                  ResponsiveBreakpoint.autoScale(1100, name: TABLET),
                  ResponsiveBreakpoint.resize(660, name: TABLET)

                ],

                ),
            getPages: [
              GetPage(name: 'HomePage', page: () => HomePage(), binding: InitialBinding()),

// adding the new bindings class in the binding field below will link those controllers to the page and fire the dependancies override when you route to the page

            ],

            debugShowCheckedModeBanner: false,
            home: SplashScreenPage(),
          );
        },
      );
    });
  }
}
