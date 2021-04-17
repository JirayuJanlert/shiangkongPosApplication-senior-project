import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Screen/ClaimList.dart';
import 'package:siangkong_mpos/Screen/Claim_Form.dart';
import 'package:siangkong_mpos/Screen/HomePage.dart';

class Claim_menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Colors.white,
            onPressed: (){
              Get.off(HomePage());
            },
          ),
          backgroundColor: royalblue,
          centerTitle: false,
          title: Text("Claim Menu",style: bigWhite,),
        ),
        body: Container(
          height: h,
          padding: const EdgeInsets.all(8.0),
          child: GridView.count(crossAxisCount: 2, childAspectRatio: 0.75, mainAxisSpacing: 100, crossAxisSpacing:30,children: [
            RaisedButton.icon(
              onPressed: () {
                Get.to(()=>Claim_Form());
              },
              label: Text("Accept Claim",style: bigWhite,),
              shape:
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              icon: Icon(MdiIcons.contentSaveEdit,size: 100,color: Colors.white,),
              color: flowerblue,
            ),
            RaisedButton.icon(
                onPressed: () {
                  Get.to(()=>ClaimList());
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                label: Text("View Claim",style: bigWhite,),
                icon: Icon(MdiIcons.fileSearchOutline,size: 100,color: Colors.white,),
                color: color1)
          ]),
        ));
  } //ef
} //ec
