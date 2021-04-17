import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Screen/BackorderAdd.dart';
import 'package:siangkong_mpos/Screen/BasketPage.dart';
import 'package:siangkong_mpos/Screen/EditProduct.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/sizing.dart';

class ProductDetail extends StatefulWidget {
  @override
  _ProductDetailState createState() => _ProductDetailState();
}

class _ProductDetailState extends State<ProductDetail> {
  final MyStore agent = Get.find<MyStore>();
  final OrderController o = Get.find<OrderController>();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  int addQty = 1;
  var formatters = NumberFormat("#,##0.00", "en_US");
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery.of(context).viewInsets.bottom;
    var h = MediaQuery
        .of(context)
        .size
        .height;
    var w = MediaQuery
        .of(context)
        .size
        .width;
    int qty = agent.findStockQtyByProductID(agent.activeProduct.serialNumber);
    return GetBuilder<MyStore>(
        init: MyStore(),
        builder: (controller) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Colors.white,
            key: _scaffoldKey,
            appBar: AppBar(
              actions: [
                Container(
                    width: 80,
                    child: GestureDetector(
                        child: Icon(
                          MdiIcons.pencil,
                          size: 45,
                          color: Colors.black,
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => EditProduct()));
                        }

                    ))
              ],
              leading: new IconButton(
                icon: new Icon(
                  MdiIcons.closeThick,
                  color: Colors.black,
                  size: 50,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(""),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    height: h * 0.35,
                    width: w,
                    child: agent.getImage(agent.activeProduct.pics),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      agent.activeProduct.productName,
                      style: headline,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                        "Stock: " +
                            agent
                                .findStockQtyByProductID(
                                agent.activeProduct.serialNumber)
                                .toString() +
                            " unit",
                        style: TextStyle(fontSize: 18,
                            color: qty > 0 ? limegreen : Colors.red)),
                  ),
                  SizedBox(
                    height: h * 0.03,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: SizeConfig.isMobilePortrait ? w * 0.3 : w * 0.2,
                        height: h * 0.05,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: color1),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              icon: new Icon(
                                Icons.remove,
                                color: Colors.white,
                                size: 25,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (addQty > 1) {
                                    addQty -= 1;
                                  }
                                });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0),
                              child: Text(addQty.toString(),
                                  // agent.activeProduct.qty.toString(),
                                  style:
                                  TextStyle(fontSize: 25, color: Colors.white)),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (addQty < qty) {
                                    addQty += 1;
                                  } else {
                                    final snackBar = SnackBar(
                                      backgroundColor: flowerblue,
                                      content: Text(
                                        'Stock Insufficient',
                                        style: danger2,
                                      ),
                                    );
                                    _scaffoldKey.currentState.showSnackBar(
                                        snackBar);
                                  }
                                });
                              },
                              icon: Icon(
                                Icons.add,
                                color: Colors.white,
                                size: 25,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatters.format(agent.activeProduct.sellingPrice) + " Baht",
                        style: headline2,
                      )
                    ],
                  ),
                  SizedBox(
                    height: h * 0.01,
                  ),
                  Divider(
                    thickness: 7,
                  ),
                  SizedBox(
                    height: h * 0.01,
                  ),
                  Text(
                    "About the product",
                    style: headline3,
                  ),
                  SizedBox(
                    height: h * 0.01,
                  ),
                  Text(
                    agent.activeProduct.details,
                    style: detailtxt,
                  )
                ],
              ),
            ),
            persistentFooterButtons: [
              SizedBox(
                width: w,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Spacer(),
                    SizedBox(
                      height: h * 0.07,
                      width: 80,
                      child: Stack(
                        children: [
                          IconButton(
                            icon: Icon(
                              MdiIcons.basket,
                              size: 52,
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => BasketPage()));
                            },
                          ),
                          Positioned(
                            right: 25,
                            bottom: 1,
                            child: ClipOval(
                                child: Container(
                                    height: 28.0,
                                    margin: const EdgeInsets.all(20),
                                    width: 25,
                                    decoration: BoxDecoration(
                                        color: hotpink,
                                        border: Border.all(
                                            color: Color(0x00ffffff),
                                            width: 0.0),
                                        borderRadius: BorderRadius.all(
                                            Radius.elliptical(20, 30))),
                                    // this line makes the coffee.
                                    child: Center(
                                        child: Text(o
                                            .countTotalQty()
                                            .toString(), style: whiteFont,)))),
                          ),
                        ],
                      ),
                    ),
                    Spacer(),
                    SizedBox(
                      height: h * 0.05,
                      width: SizeConfig.isMobilePortrait ? w * 0.5 : w * 0.3,
                      child: RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          onPressed: () {
                            setState(() {
                              print(qty);
                              if (qty > 0) {
                                agent.cutStock(
                                    agent.activeProduct.serialNumber, addQty);
                                o.addProductToBasket(
                                    agent.activeProduct, addQty);
                              } else {
                                //create backorder
                                showCupertinoModalPopup(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        padding: EdgeInsets.only(bottom: bottom),
                                        color: Colors.transparent,
                                        margin: EdgeInsets.only(
                                            bottom: h * 0.1,
                                            top: h * 0.1,
                                            left: w * 0.15,
                                            right: w * 0.15),
                                        child: BackorderAdd(),
                                      );
                                    });

                              }
                            });
                          },
                          icon: Icon(
                            MdiIcons.plus,
                            color: Colors.white,
                            size: 30,
                          ),
                          color: qty > 0 ? flowerblue : Colors.blueGrey,
                          label: Text(
                            qty > 0 ? "Add to Cart" : "Backorder",
                            style: TextStyle(color: Colors.white, fontSize: 30),
                          )),
                    ),
                  ],
                ),
              )
            ],
          );
        }
    );
  }
} //ec
