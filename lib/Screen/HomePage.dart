import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/Order.dart';
import 'package:siangkong_mpos/Model/Product.dart';
import 'package:siangkong_mpos/Screen/AddNewProduct.dart';
import 'package:siangkong_mpos/Screen/BasketPage.dart';
import 'package:siangkong_mpos/Screen/ConfirmOrder.dart';
import 'package:siangkong_mpos/Screen/CustomerAddpage.dart';
import 'package:siangkong_mpos/Screen/CustomerSearch.dart';
import 'package:siangkong_mpos/Screen/ProductDetail.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/Store/ReceiptController.dart';
import 'package:siangkong_mpos/Widget/drawer_data.dart';
import 'package:siangkong_mpos/sizing.dart';
import 'package:flutter/services.dart';

import '../Widget/ProductGrid.dart';

// ignore: must_be_immutable
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FocusNode searchNode = FocusNode();
  TextEditingController searchTxt = TextEditingController();
  var selectedIndex = 0;
  var formatter = NumberFormat("#,##0.00", "en_US");
  Future loadData;
  AnimationController _animationController;

  @override
  void initState() {
    // TODO: implement initState
    final MyStore agent = Get.put(MyStore());
    final CustomerController c = Get.put(CustomerController());
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    agent.loadPartsFromDb().then((res) => agent.loadCategory());
    agent.loadStockFromDb();
    c.loadCusFromDb();
    setState(() {});

    super.initState();
    if (SizeConfig.isMobilePortrait) {}
    SystemChrome.setPreferredOrientations([]);

    loadData = agent.loadPartsFromDb();
  }


  Future<void> holdOrder(CustomerController c, MyStore agent, OrderController o) async {

    Order cusOrder = new Order(
        orderDate: DateTime.now(),
        orderStatus: "progressing",
        customerId: c.activeCus.value.customerID,
        totalAmount: o.calculateGrandTotal());
    o.setCustomerOrder(cusOrder);
    final ProgressDialog pr = new ProgressDialog(context);
    pr.style(
      message: 'Completing ',
      progressWidget: SpinKitRotatingCircle(
        color: hotpink,
      ),
      elevation: 10.0,
    );
    await pr.show();

    await o.insertOrdertableDb(cusOrder).then((value) async {
      await o.insertOrderInfotableDb(value).then((res) async {
        if (res == "yes") {
          pr.update(message: "Order is saved");
          Future.delayed(Duration(seconds: 2)).whenComplete(
                  () => pr.hide());
        } else {
          pr.update(message: "Fail to save order");
          Future.delayed(Duration(seconds: 1)).whenComplete(() => pr.hide());
        }


      });
    });
  }

  _toggleAnimation() {
    _animationController.isDismissed
        ? _animationController.forward()
        : _animationController.reverse();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final MyStore agent = Get.put(MyStore());
    final OrderController o = Get.put(OrderController());
    final CustomerController c = Get.put(CustomerController());
    agent.loadCategory();

    print(SizeConfig.isMobilePortrait);

    return LayoutBuilder(builder: (context, constraints) {
      return OrientationBuilder(builder: (context, orientation) {
        SizeConfig().init(constraints, orientation);
        if (SizeConfig.isMobilePortrait) {
          return MobileLayout(context, agent, o,c);
        } else {
          return TabletLayout(context, agent, o, c);
        }
      });
    });
  }

  Widget MobileLayout(BuildContext context, MyStore agent, OrderController o,CustomerController c) {
    final rightSlide = MediaQuery.of(context).size.width * 0.6;
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          double slide = rightSlide * _animationController.value;
          double scale = 1 - (_animationController.value * 0.3);
          return Stack(
            children: [
              Scaffold(
                backgroundColor: color1,
                body: const DrawerData(),
              ),
              Transform(
                transform: Matrix4.identity()
                  ..translate(slide)
                  ..scale(scale),
                alignment: Alignment.center,
                child: Scaffold(
                    key: _scaffoldKey,
                    backgroundColor: lightskyblue,
                    resizeToAvoidBottomInset: false,
                    // drawer: Drawer(
                    //   child: ListView(
                    //     children: [
                    //       ListTile(
                    //         leading: Icon(MdiIcons.history,size: 25),
                    //         title: Text("Order History",style: font2,),
                    //       )
                    //     ],
                    //   ),
                    // ),
                    appBar: AppBar(
                      title: Text(
                        "ShiangKong POS",
                        style: bigWhite,
                      ),
                      backgroundColor: royalblue,
                      leading: IconButton(
                        onPressed: () => _toggleAnimation(),
                        icon: AnimatedIcon(
                          icon: AnimatedIcons.menu_close,
                          size: 38,
                          progress: _animationController,
                        ),
                      ),
                      actions: [
                        GetBuilder<OrderController>(
                            init: OrderController(),
                            builder: (oc) {
                              return Stack(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      MdiIcons.basket,
                                      size: 32,
                                    ),
                                    onPressed: () {
                                      Get.to(() => BasketPage());
                                    },
                                  ),
                                  Positioned(
                                    right: 5,
                                    bottom: 8,
                                    child: ClipOval(
                                        child: Container(
                                            height: 22.0,
                                            margin: const EdgeInsets.all(20),
                                            width: 20,
                                            decoration: BoxDecoration(
                                                color: hotpink,
                                                border: Border.all(
                                                    color: Color(0x00ffffff),
                                                    width: 0.0),
                                                borderRadius: BorderRadius.all(
                                                    Radius.elliptical(20, 30))),
                                            // this line makes the coffee.
                                            child: Center(
                                                child: Text(oc
                                                    .countTotalQty()
                                                    .toString())))),
                                  ),
                                ],
                              );
                            })
                      ],
                    ),
                    body: OrientationBuilder(
                      builder: (context, orientation) {
                        return GestureDetector(
                          onTap: () {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);

                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                          child: Stack(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  width: w,
                                  child: Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                color: Colors.black, width: 1)),
                                        height: h * 0.67,
                                        child: Column(
                                          children: [
                                            Container(
                                              color: lightskyblue,
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  RaisedButton.icon(
                                                    onPressed: () {
                                                      Get.to(() =>
                                                          AddNewProduct());
                                                    },
                                                    shape:
                                                        RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20)),
                                                    icon: Icon(
                                                      Icons.add,
                                                      color: Colors.white,
                                                    ),
                                                    label: Text(
                                                      "Add New Item",
                                                      style: whiteFont,
                                                    ),
                                                    color: flowerblue,
                                                  ),
                                                  Container(
                                                      width: w * 0.5,
                                                      child: buildSearchBar(
                                                          agent,
                                                          selectedIndex)),
                                                ],
                                              ),
                                            ),
                                            GetBuilder<MyStore>(
                                                init: MyStore(),
                                                builder: (controller) {
                                                  return Expanded(
                                                      child:
                                                          buildProductShowBox(
                                                              agent,
                                                              o,
                                                              orientation));
                                                }),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 20),
                                        child: SizedBox(
                                          height: h * 0.1,
                                          child: FutureBuilder(
                                              future: loadData,
                                              builder: (context, snapshot) {
                                                if (snapshot.hasData &&
                                                    snapshot.data.length > 1) {
                                                  return buildCategoryList(
                                                      agent, w, 0.2);
                                                } else {
                                                  return Center(
                                                      child:
                                                          CircularProgressIndicator());
                                                }
                                              }),
                                        ),
                                      ),
                                      buildHoldCancleButtons(o, agent,c)
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    )),
              ),
            ],
          );
        });
  }

  Widget TabletLayout(BuildContext context, MyStore agent, OrderController o, CustomerController c) {
    final rightSlide = MediaQuery.of(context).size.width * 0.6;
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          double slide = rightSlide * _animationController.value;
          double scale = 1 - (_animationController.value * 0.3);
          return Stack(
            children: [
              Scaffold(
                backgroundColor: color1,
                body: const DrawerData(),
              ),
              Transform(
                transform: Matrix4.identity()
                  ..translate(slide)
                  ..scale(scale),
                alignment: Alignment.center,
                child: Scaffold(
                    key: _scaffoldKey,
                    backgroundColor: Colors.blue[100],
                    resizeToAvoidBottomInset: false,
                    appBar: AppBar(
                      leading: IconButton(
                        onPressed: () => _toggleAnimation(),
                        icon: AnimatedIcon(
                          icon: AnimatedIcons.menu_close,
                          size: 38,
                          progress: _animationController,
                        ),
                      ),
                      backgroundColor: royalblue,
                      title: Text(
                        "SiangKong POS",
                        style: bigWhite,
                      ),
                    ),
                    body: OrientationBuilder(
                      builder: (context, orientation) {
                        Get.lazyPut(() => MyStore());
                        Get.lazyPut(() => CustomerController());
                        Get.lazyPut(() => OrderController());
                        return GestureDetector(
                          onTap: () {
                            FocusScopeNode currentFocus =
                                FocusScope.of(context);

                            if (!currentFocus.hasPrimaryFocus) {
                              currentFocus.unfocus();
                            }
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              buildTabletHomepageLeftColumn(
                                  orientation, w, h, agent, o,c),
                              buildTabletCheckOutSession(
                                  h, orientation, w, o, context, agent)
                            ],
                          ),
                        );
                      },
                    )),
              ),
            ],
          );
        });
  }

  Widget buildTabletCheckOutSession(double h, Orientation orientation, double w,
      OrderController o, BuildContext context, MyStore agent) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            height: h * 0.8,
            width: orientation == Orientation.portrait ? 0.43 * w : 0.4 * w,
            decoration: BoxDecoration(
                color: Colors.white, border: Border.all(color: Colors.black54)),
            child: Column(
              children: [
                SizedBox(
                  height: h * 0.12,
                  child: Column(
                    children: [
                      Container(
                        color: lightskyblue,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GetBuilder<CustomerController>(
                                  init: CustomerController(),
                                  builder: (controller) {
                                    if (controller.activeCus.value.customerID !=
                                        null) {
                                      return Row(
                                        children: [
                                          CircleAvatar(
                                            child: Icon(MdiIcons.account),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(controller
                                                .activeCus.value.customerName),
                                          ),
                                          IconButton(
                                              icon: Icon(MdiIcons.close),
                                              onPressed: () {
                                                controller.dismissCustomer();
                                              })
                                        ],
                                      );
                                    }

                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        IconButton(
                                            icon: Icon(MdiIcons.accountSearch),
                                            onPressed: () {
                                              Get.to(() => CustomerSearch());
                                            }),
                                        IconButton(
                                          icon: Icon(MdiIcons.accountPlus),
                                          onPressed: () {
                                            Get.to(() => CustomerAdd());
                                          },
                                        )
                                      ],
                                    );
                                  }),
                              IconButton(
                                  icon: Icon(MdiIcons.barcodeScan),
                                  onPressed: () async {
                                    o.scan(context);
                                    Product _scannedP = await o.scan(context);

                                    if (_scannedP != null) {
                                      int qty = agent.findStockQtyByProductID(
                                          _scannedP.serialNumber);

                                      if (qty > 0) {
                                        o.addProductToBasket(_scannedP, 1);
                                        agent.cutStock(
                                            _scannedP.serialNumber, 1);
                                        setState(() {

                                        });
                                      } else {
                                        final snackBar = SnackBar(
                                          backgroundColor: lightskyblue,
                                          content: Text(
                                            'Item out of stock',
                                            style: danger,
                                          ),
                                        );
                                        _scaffoldKey.currentState
                                            .showSnackBar(snackBar);
                                      }
                                    } else {
                                      final snackBar = SnackBar(
                                        backgroundColor: lightskyblue,
                                        content: Text(
                                          'Product not found, Please try again',
                                          style: danger,
                                        ),
                                      );
                                      _scaffoldKey.currentState
                                          .showSnackBar(snackBar);
                                    }
                                  }),
                            ]),
                      ),
                      //add customer, search customer, scan barcode
                      Expanded(
                        child: Container(
                          height: h * 0.055,
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SizedBox(
                                width: w * 0.13,
                              ),
                              Text(
                                "Check Out",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20),
                              ),
                              SizedBox(
                                width: w * 0.1,
                              ),
                              GetBuilder<OrderController>(
                                  init: OrderController(),
                                  builder: (oc) {
                                    return CircleAvatar(
                                      radius: 15,
                                      backgroundColor: hotpink,
                                      child: Text(
                                        oc.countTotalQty().toString(),
                                        style: whiteFont,
                                      ),
                                    );
                                  })
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: h * 0.42,
                  child: GetBuilder<OrderController>(
                      init: OrderController(),
                      builder: (oc) {
                        if (oc.orderedProducts.isBlank) {
                          return Center(child: Text("The basket is blank"));
                        } else {
                          return Scrollbar(
                            child: ListView.builder(
                                itemCount: oc.orderedProducts.length,
                                itemBuilder: (context, i) {
                                  return ListTile(
                                    leading: IconButton(
                                      icon: Icon(Icons.delete),
                                      onPressed: () {
                                        setState(() {
                                          agent.addBackStock(
                                              oc.orderedProducts[i]
                                                  .serialNumber,
                                              oc.orderedProducts[i].qty);
                                          oc.deleteOrderLine(oc.findProductById(
                                              oc.orderedProducts[i]
                                                  .serialNumber));
                                        });
                                      },
                                    ),
                                    title: Text(
                                      oc
                                          .findProductById(oc
                                              .orderedProducts[i].serialNumber)
                                          .productName,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: SizedBox(
                                      width: w * 0.14,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          IconButton(
                                              icon: Icon(Icons.remove),
                                              onPressed: () {
                                                setState(() {
                                                  int stock = agent
                                                      .findStockQtyByProductID(
                                                          oc.orderedProducts[i]
                                                              .serialNumber);

                                                    agent.addBackStock(
                                                        oc.orderedProducts[i]
                                                            .serialNumber,
                                                        1);
                                                    oc.removeOneFromBasket(
                                                        oc.findProductById(oc
                                                            .orderedProducts[
                                                        i]
                                                            .serialNumber));

                                                });
                                              }),
                                          Text(oc.orderedProducts[i].qty
                                              .toString()),
                                          IconButton(
                                              icon: Icon(Icons.add),
                                              onPressed: () {
                                                setState(() {
                                                  int stock = agent
                                                      .findStockQtyByProductID(oc
                                                      .orderedProducts[
                                                  i]
                                                      .serialNumber);

                                                  if(stock>0){
                                                    agent.cutStock(oc
                                                        .orderedProducts[
                                                    i]
                                                        .serialNumber, 1);
                                                    oc.addProductToBasket(
                                                        oc.findProductById(oc
                                                            .orderedProducts[
                                                        i]
                                                            .serialNumber),1);
                                                  }else{

                                                    final snackBar = SnackBar(
                                                      backgroundColor: flowerblue,
                                                      content: Text(
                                                        'Item out of stock',
                                                        style: danger2,
                                                      ),
                                                    );
                                                    _scaffoldKey.currentState.showSnackBar(snackBar);
                                                  }

                                                });
                                              })
                                        ],
                                      ),
                                    ),
                                    subtitle: Text(formatter.format(oc
                                        .orderedProducts[i].lineTotal)
                                             +
                                        " Baht"),
                                  );
                                }),
                          );
                        }
                      }),
                ),
                Divider(
                  thickness: 5,
                ),
                Expanded(
                  child: Container(
                    color: azure,
                    height: h * 0.23,
                    child: GetBuilder<OrderController>(
                        init: OrderController(),
                        builder: (controller) {
                          return Column(
                            children: [
                              ListTile(
                                leading: Text(
                                  "Sub Total",
                                  style: font1,
                                ),
                                trailing: Text(
                                    formatter.format(o.calculateOrderSubTotal()) +
                                        " Baht",
                                    style: font2),
                              ),
                              ListTile(
                                leading: Text(
                                  "VAT (7%)",
                                  style: font1,
                                ),
                                trailing: Text(
                                    formatter.format(o.calculateVat()) + " Baht",
                                    style: font2),
                              ),
                              ListTile(
                                leading: Text(
                                  "Grand Total",
                                  style: TextStyle(
                                      fontSize: 25,
                                      color: color1,
                                      fontWeight: FontWeight.bold),
                                ),
                                trailing: Text(
                                  formatter.format(o.calculateGrandTotal()) + " Baht",
                                  style: TextStyle(
                                      fontSize: 20,
                                      color: color1,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          );
                        }),
                  ),
                )
              ],
            ),
          ), //checkout section
          GetBuilder<OrderController>(
              init: OrderController(),
              builder: (controller) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: SizedBox(
                    width: orientation == Orientation.portrait
                        ? 0.43 * w
                        : 0.4 * w,
                    height: h * 0.06,
                    child: RaisedButton(
                      color: o.orderedProducts.length > 0
                          ? limegreen
                          : Colors.grey,
                      onPressed: () {
                        if (o.orderedProducts.length > 0) {
                          showCupertinoModalPopup(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  margin: EdgeInsets.only(
                                      bottom: h * 0.2,
                                      top: h * 0.1,
                                      left: w * 0.15,
                                      right: w * 0.15),
                                  child: ConfirmOrder(),
                                );
                              });
                        } else {
                          final snackBar = SnackBar(
                            backgroundColor: flowerblue,
                            content: Text(
                              'Please add some product into order',
                              style: danger2,
                            ),
                          );
                          _scaffoldKey.currentState.showSnackBar(snackBar);
                        }
                      },
                      child: Text("Charge",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                );
              }) //charge button
        ],
      ),
    );
  }

  Padding buildTabletHomepageLeftColumn(Orientation orientation, double w,
      double h, MyStore agent, OrderController o,CustomerController c) {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: Container(
        width: orientation == Orientation.portrait ? 0.53 * w : 0.57 * w,
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black54)),
              height: h * 0.67,
              child: Column(
                children: [
                  Container(
                    color: lightskyblue,
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RaisedButton.icon(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          onPressed: () {
                            Get.to(() => AddNewProduct());
                          },
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          label: Text(
                            "Add New Item",
                            style: whiteFont,
                          ),
                          color: flowerblue,
                        ),
                        Container(
                            width: w * 0.25,
                            child: buildSearchBar(agent, selectedIndex)),
                      ],
                    ),
                  ),
                  Expanded(child: buildProductShowBox(agent, o, orientation)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: SizedBox(
                height: h * 0.1,
                child: FutureBuilder(
                    future: loadData,
                    builder: (context, snapshot) {
                      if (snapshot.hasData && snapshot.data.length > 1) {
                        return buildCategoryList(agent, w, 0.14);
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }),
              ),
            ),
            buildHoldCancleButtons(o, agent,c)
          ],
        ),
      ),
    );
  }

  Padding buildHoldCancleButtons(OrderController o, MyStore agent,CustomerController c) {
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          RaisedButton.icon(
            highlightColor: flowerblue,
            onPressed: () {
              setState(() {
                if (o.orderedProducts.length > 0) {
                  o.orderedProducts.forEach((element) {
                    agent.addBackStock(element.serialNumber, element.qty);
                  });
                }
                o.cancleOrder();
              });
            },
            icon: Icon(MdiIcons.cancel),
            label: Text(
              "Cancel Order",
              style: font2,
            ),
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: color1, width: 4)),
          ),
          SizedBox(
            width: 20,
          ),
          RaisedButton.icon(
            highlightColor: flowerblue,
            onPressed: () {
              if(o.orderedProducts.length>0){
                holdOrder(c, agent, o);
              }
            },
            label: Text(
              "Hold Order",
              style: font2,
            ),
            color: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: beige, width: 4)),
            icon: Icon(MdiIcons.contentSave),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryList(MyStore agent, double w, double size) {
    return GetBuilder<MyStore>(
        init: MyStore(),
        builder: (controller) {
          return ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: agent.categories.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: w * size,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        agent.showCategory(agent.categories[index]);
                      });
                    },
                    child: Card(
                      color: selectedIndex == index ? royalblue : Colors.white,
                      elevation: 5,
                      child: Center(
                        child: Text(
                          agent.categories[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17,
                              color: index == selectedIndex
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }

  CupertinoScrollbar buildProductShowBox(
      MyStore agent, OrderController o, Orientation orientation) {
    return CupertinoScrollbar(
      child: Container(
        color: azure,
        child: FutureBuilder(
            future: loadData,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (agent.products.isNotEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                orientation == Orientation.portrait ? 2 : 3,
                            crossAxisSpacing: 30,
                            mainAxisSpacing: 10,
                            childAspectRatio:
                                SizeConfig.isMobilePortrait ? 0.85 : 0.68),
                        itemCount: agent.products.length,
                        itemBuilder: (BuildContext context, index) => Card(
                              shape: RoundedRectangleBorder(
                                side: BorderSide(
                                    color: Colors.transparent, width: 3),
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: OpenContainer(

                                closedBuilder:
                                    (BuildContext c, VoidCallback action) =>
                                        ProductGrid(
                                  p: agent.products,
                                  orientation: orientation,
                                  index: index,
                                  scaffoldKey: _scaffoldKey,
                                ),
                                openBuilder:
                                    (BuildContext c, VoidCallback action) {
                                  agent.setActiveProduct(agent.products[index]);
                                  return ProductDetail();
                                },
                                transitionDuration: Duration(milliseconds: 500),
                                closedElevation: 0,
                                closedShape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(30.0)),
                                ),
                                closedColor: Colors.white,
                                openColor: azure,
                                openElevation: 0,
                                transitionType:
                                    ContainerTransitionType.fadeThrough,
                              ),
                            )),
                  );
                } else {
                  return Center(child: Text("Product Not Found"));
                }
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error"),
                );
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }),
      ),
    );
  }

  TextField buildSearchBar(MyStore agent, int selectedCate) {
    return TextField(
      cursorColor: Colors.black,
      autofocus: false,
      focusNode: searchNode,
      controller: searchTxt,
      onChanged: (text) {
        setState(() {
          selectedIndex = 0;
          agent.setSearchKey(text, selectedCate);
        });
      },
      style: TextStyle(color: Colors.black54),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: new Icon(Icons.search),
        suffix: searchNode.hasFocus
            ? SizedBox(
                height: 15.0,
                child: GestureDetector(
                  child: Icon(
                    MdiIcons.closeCircle,
                    color: Colors.grey,
                  ),
                  onTap: () {
                    searchTxt.text = "";
                    selectedIndex = 0;
                    agent.setSearchKey("", selectedCate);
                    searchNode.unfocus();
                  },
                ),
              )
            : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: Colors.black54,
            style: BorderStyle.solid,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(50),
          borderSide:
              BorderSide(color: blueblue, style: BorderStyle.solid, width: 2),
        ),
        focusColor: royalblue,
        hintStyle: TextStyle(color: Colors.black54),
        contentPadding:
            EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
        hintText: "Search Products",
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
