import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Screen/BackorderList.dart';
import 'package:siangkong_mpos/Screen/Claim_menu.dart';
import 'package:siangkong_mpos/Screen/LoginPage.dart';
import 'package:siangkong_mpos/Screen/ManagementReport.dart';
import 'package:siangkong_mpos/Screen/OrderHistory.dart';
import 'package:siangkong_mpos/Screen/StockPage.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/Store/UserController.dart';

class DrawerData extends StatelessWidget {
  const DrawerData();

  @override
  Widget build(BuildContext context) {
    final MyStore agent = Get.find<MyStore>();
    final AppUserController _userController = Get.put(AppUserController());
    final List<DrawerItem> drawer = [
      DrawerItem('Order History', MdiIcons.history, () {
        Get.to(() => OrderHistory());
      }),
      DrawerItem('Backorder', MdiIcons.basketUnfill, () {
        Get.to(() => BackorderList());
      }),
      DrawerItem('Claim', MdiIcons.cashRefund, () {
        Get.to(() => Claim_menu());
      }),
      DrawerItem('Stock', MdiIcons.warehouse, () {
        Get.to(() => StockPage());
      }),
      DrawerItem('Management Report', MdiIcons.chartBarStacked, () {
        Get.to(() => ManagementReport());
      }),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: royalblue,
                radius: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                    child:
                    _userController.loginUser !=
                        null? agent.getImage(_userController.loginUser.profilePic):null),
              ),
              SizedBox(
                width: 20,
              ),
              Text(
                _userController.loginUser != null? "Hello,\n ${_userController.loginUser.firstName}":"Hello \n User",
                style: TextStyle(
                    color: flowerblue,
                    fontWeight: FontWeight.bold,
                    fontSize: 50),
              )
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Text(
              'Menu',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 50),
            ),
          ),
          const Divider(
            color: Colors.white54,
          ),
          Expanded(
            child: ListView.builder(
                itemCount: drawer.length,
                shrinkWrap: true,
                itemBuilder: (_, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 12),
                    child: InkWell(
                      onTap: drawer[index].onTap,
                      child: Container(
                        height: 48,
                        width: double.infinity,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Icon(drawer[index].icon),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Text(
                                drawer[index].name,
                                style: TextStyle(fontSize: 20),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                }),
          ),
          const Divider(
            color: Colors.white54,
          ),
          Container(
            height: 48,
            width: double.infinity,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(MdiIcons.cog),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    'Setting',
                    style: TextStyle(fontSize: 20),
                  ),
                )
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              // Get.offAll(LoginPage());
            },
            child: Container(
              height: 48,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.exit_to_app),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(fontSize: 20),
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DrawerItem {
  final String name;
  final IconData icon;
  final Function onTap;

  const DrawerItem(this.name, this.icon, this.onTap);
}
