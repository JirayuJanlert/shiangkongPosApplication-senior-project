import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:siangkong_mpos/Model/Product.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/sizing.dart';

import '../CSS.dart';

class ProductGrid extends StatefulWidget {
  const ProductGrid({
    Key key,
    @required this.p,
    @required this.index,
    this.scaffoldKey,
    this.orientation
  }) : super(key: key);

  final List<Product> p;
  final int index;
  final Orientation orientation;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  _ProductGridState createState() => _ProductGridState();
}

class _ProductGridState extends State<ProductGrid> {
  @override
  Widget build(BuildContext context) {
    OrderController o = Get.find<OrderController>();
    MyStore agent = Get.find<MyStore>();
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    var formatter = NumberFormat("#,##0.00", "en_US");
    int qty = agent.findStockQtyByProductID(agent.products[widget.index].serialNumber);
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: w,
              child: agent.getImage( widget.p[widget.index].pics)
            ),
          ),
          Divider(
            thickness: 5,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.p[widget.index].productName,
                  overflow: TextOverflow.ellipsis,
                  style: font3,
                ),
                SizedBox(
                  height: h * 0.01,
                ),
                Text(
                  "Price: " + formatter.format(widget.p[widget.index].sellingPrice)+ " Baht",
                  style: SizeConfig.isMobilePortrait ? font4 : font4_1,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom:8.0),
                      child: Text("Stock: " + qty.toString(),style: qty>0? success:danger,),
                    ),
                    SizedBox(
                      width: SizeConfig.isMobilePortrait? 80:65,
                      child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          onPressed: () {
                           setState(() {
                             if(qty>0){
                               agent.cutStock(agent.products[widget.index].serialNumber,1);
                               o.addProductToBasket(agent.products[widget.index],1);
                             }else{
                               final snackBar = SnackBar(
                                 backgroundColor: flowerblue,
                                 content: Text(
                                   'Item out of stock',
                                   style: danger2,
                                 ),
                               );
                               widget.scaffoldKey.currentState.showSnackBar(snackBar);
                             }
                           });
                          },
                          icon: Icon(MdiIcons.plus,color: Colors.white,size: SizeConfig.isMobilePortrait? 16:12,),
                          color: qty>0? flowerblue: Colors.grey,
                          label: Text("Add",style: TextStyle(color: Colors.white,fontSize: SizeConfig.isMobilePortrait? 14:8),)),
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
} //ec
