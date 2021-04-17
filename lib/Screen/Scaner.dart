// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:siangkong_mpos/Store/OrderController.dart';
//
// class Scanner extends StatefulWidget {
//   @override
//   _ScannerState createState() => _ScannerState();
// }
//
// class _ScannerState extends State<Scanner> {
//   @override
//   Widget build(BuildContext context) {
//     double w = MediaQuery.of(context).size.width;
//     double h = MediaQuery.of(context).size.height;
//     return GetBuilder<OrderController>(
//         init: OrderController(),
//         builder: (controller) {
//           if (controller.camState == false) {
//             controller
//                 .addProductToBasket(controller.findProductById(controller.pId));
//             Get.back();
//           }
//           return Scaffold(
//             appBar: AppBar(
//               backgroundColor: Colors.black,
//               title: Text(""),
//             ),
//             backgroundColor: Colors.black,
//             body: controller.camState
//                 ? Column(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       Center(
//                         child: SizedBox(
//                             height: 500,
//                             width: 500,
//                             child: controller.showScanner()),
//                       ),
//                       Text("Scan a barcode to add product into order",style: TextStyle(color: Colors.white,fontSize: 20),)
//                     ],
//                   )
//                 : Center(
//                     child: Text(controller.pId),
//                   ),
//           );
//         });
//   }
// } //ec
