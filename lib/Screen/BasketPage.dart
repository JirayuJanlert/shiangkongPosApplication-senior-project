import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/Product.dart';
import 'package:siangkong_mpos/Screen/ConfirmOrder.dart';
import 'package:siangkong_mpos/Screen/CustomerAddpage.dart';
import 'package:siangkong_mpos/Screen/CustomerSearch.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';

class BasketPage extends StatefulWidget {
  @override
  _BasketPageState createState() => _BasketPageState();
}

class _BasketPageState extends State<BasketPage> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  var formatter = NumberFormat("#,##0.00", "en_US");

  @override
  Widget build(BuildContext context) {
    final MyStore agent = Get.put(MyStore());
    final OrderController o = Get.put(OrderController());
    // final CustomerController c = Get.put(CustomerController());
    agent.loadCategory();
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: lightskyblue,
        key: _scaffoldKey,
        appBar: AppBar(
          backgroundColor: royalblue,
          title: Text(""),
          actions: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GetBuilder<CustomerController>(
                  init: CustomerController(),
                  builder: (controller) {
                    // ignore: deprecated_member_use
                    if (controller.activeCus.value.customerID != null) {
                      return Row(
                        children: [
                          CircleAvatar(
                            child: Icon(MdiIcons.account),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(controller.activeCus.value.customerName),
                          ),
                          IconButton(
                              icon: Icon(MdiIcons.close),
                              onPressed: () {
                                controller.dismissCustomer();
                              })
                        ],
                      );
                    } else {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                              icon: Icon(MdiIcons.accountSearch),
                              onPressed: () {
                                Get.to(CustomerSearch());
                              }),
                          IconButton(
                            icon: Icon(MdiIcons.accountPlus),
                            onPressed: () {
                              Get.to(CustomerAdd());
                            },
                          )
                        ],
                      );
                    }
                  }),
              IconButton(
                  icon: Icon(MdiIcons.barcodeScan),
                  onPressed: () async {
                    o.scan(context);
                    Product _scannedP =
                    await o.scan(context);

                    if (_scannedP != null) {
                      int qty = agent.findStockQtyByProductID(_scannedP.serialNumber);

                      if(qty >0){
                        o.addProductToBasket(
                            _scannedP,1);
                        agent.cutStock(_scannedP.serialNumber, 1);
                      }else{
                        final snackBar = SnackBar(
                          backgroundColor: flowerblue,
                          content: Text(
                            'Item out of stock',style: danger2,),
                        );
                        _scaffoldKey.currentState
                            .showSnackBar(snackBar);
                      }
                    } else {
                      final snackBar = SnackBar(
                        backgroundColor: flowerblue,
                        content: Text(
                          'Product not found, Please try again',style: danger2,),
                      );
                      _scaffoldKey.currentState
                          .showSnackBar(snackBar);
                    }
                    // o.setScanner();
                    // Get.to(Scanner());
                  }),
            ])
          ],
        ),
        body: Container(
          width: w,
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Container(
                height: h * 0.8,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black54)),
                child: Column(
                  children: [
                    SizedBox(
                      height: h * 0.05,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Check Out",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: h * 0.55,
                      child: buildOrderProductList(agent, w),
                    ),
                    Divider(
                      thickness: 5,
                    ),
                    buildOrderCalculationSection(o)
                  ],
                ),
              ), //checkout section
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: SizedBox(
                  width: w * 0.95,
                  height: h * 0.06,
                  child: RaisedButton(
                    color:
                        o.orderedProducts.length > 0 ? limegreen : Colors.grey,
                    onPressed: () {
                      if (o.orderedProducts.length > 0) {
                        showModalBottomSheet<dynamic>(
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            barrierColor: Colors.transparent,
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  color: Colors.transparent,
                                  height: h * 0.63,
                                  child: ConfirmOrder());
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
                    child: Text(
                      "Charge",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ) //pay button
            ],
          ),
        ));
  }

  GetBuilder<OrderController> buildOrderCalculationSection(OrderController o) {
    return GetBuilder<OrderController>(
                      init: OrderController(),
                      builder: (controller) {
                        return Expanded(
                          child: Container(
                            color: azure,
                            child: Column(
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
                                        fontSize: 28,
                                        color: color1,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Text(
                                    formatter.format(o.calculateGrandTotal())+
                                        " Baht",
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: color1,
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      });
  }

  GetBuilder<OrderController> buildOrderProductList(MyStore agent, double w) {
    return GetBuilder<OrderController>(
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
                                            agent.addBackStock(oc
                                                .orderedProducts[i]
                                                .serialNumber, oc.orderedProducts[i].qty);
                                            oc.deleteOrderLine(
                                                oc.findProductById(oc
                                                    .orderedProducts[i]
                                                    .serialNumber));
                                          });
                                        },
                                      ),
                                      title: Text(
                                        oc
                                            .findProductById(oc
                                                .orderedProducts[i]
                                                .serialNumber)
                                            .productName,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      trailing: SizedBox(
                                        width: w * 0.22,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceAround,
                                          children: [
                                            IconButton(
                                                icon: Icon(Icons.remove),
                                                onPressed: () {
                                                  setState(() {
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
                        });
  }
} //ec
