import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/OrderDetails.dart';
import 'package:siangkong_mpos/Screen/HomePage.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Widget/OrderList.dart';
import 'package:siangkong_mpos/Widget/SearchBar.dart';
import 'package:siangkong_mpos/Widget/monthpicker/src/date_picker.dart';
import 'dart:async';

import 'package:siangkong_mpos/sizing.dart';


class OrderHistory extends StatefulWidget {
  @override
  _OrderHistoryState createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory>
    with SingleTickerProviderStateMixin {
  FocusNode searchNode = FocusNode();

  Future loadData;

  DateTime selectedDate = DateTime.now();

  TextEditingController searchTxt = TextEditingController();
  var formatter = NumberFormat("#,##0.00", "en_US");
  CustomerController c = Get.find<CustomerController>();

  OrderController o = Get.find<OrderController>();
  AnimationController _animationController;
  bool isA = true;
  Icon AIcon = Icon(MdiIcons.sortCalendarDescending);
  Icon AIcon2 = Icon(MdiIcons.sortCalendarDescending);
  Icon DIcon = Icon(MdiIcons.sortCalendarAscending);

  _toggleAnimation() {
    _animationController.isDismissed
        ? _animationController.forward()
        : _animationController.reverse();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  _fetchData() {
    return this._memoizer.runOnce(() async {
      return o.loadOrderFromDb();
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery
        .of(context)
        .size
        .width;
    double h = MediaQuery
        .of(context)
        .size
        .height;
    return Scaffold(
        backgroundColor: azure,
        appBar: AppBar(
          leading: BackButton(
            color: Colors.white,
            onPressed: (){
              Get.offAll(HomePage());
            },
          ),
          actions: [
            IconButton(
              icon: AIcon,
              onPressed: () {
                setState(() {
                  if (isA) {
                    o.sortByDescending();
                    AIcon = DIcon;
                    isA = !isA;
                  } else {
                    o.sortByAscending();
                    AIcon = AIcon2;
                    isA = !isA;
                  }
                });
              },
            ),
            IconButton(
                icon: Icon(
                  MdiIcons.refresh,
                  size: 30,
                ),
                onPressed: () => o.refreshOrderHistory()),

          ],
          backgroundColor: royalblue,
          title: Text(
            "Order History",
            style: bigWhite,
          ),
        ),
        body: GetBuilder<OrderController>(
            initState: (_) {
              loadData = OrderController().loadOrderFromDb();
            },
            init: OrderController(),
            builder: (o) {
              return FutureBuilder(
                future: _fetchData(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Column(
                      children: [
                        SizedBox(
                          height: h * 0.09,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: w * 0.6,
                                padding: const EdgeInsets.all(15.0),
                                child: SearchBar(
                                  searchNode: searchNode,
                                  searchTxt: searchTxt,
                                  label: "Search Order by Customer ID or Order ID",
                                  searchFunction: o.setSearchKey,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: RaisedButton.icon(
                                  icon: Icon(
                                    MdiIcons.calendar,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    DatePicker.showDatePicker(context,
                                        maxDateTime: DateTime.now(),
                                        onConfirm: (dt, a) {
                                          print(dt);
                                          o.selectMonthOrder(dt);
                                        },
                                        onMonthChangeStartWithFirstDate: true,
                                        dateFormat: 'MMMM-yyyy',
                                        minDateTime: DateTime(2021, 1, 1));
                                  },
                                  label: Text(
                                    'Select month',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  color: royalblue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(color: Colors.grey,thickness: 1,),
                        Expanded(
                          child: o.hcustomerOrder.length > 0
                              ? buildOrderHistoryListView(o, w, h)
                              : Center(child: Text("No record", style: font3,)),
                        ),
                      ],
                    );
                  } else {
                    return Center(
                        child: SpinKitRotatingCircle(
                          color: hotpink,
                        ));
                  }
                },
              );
            }));
  }

  ListView buildOrderHistoryListView(OrderController o, double w, double h) {
    return ListView.builder(
        itemCount: o.hcustomerOrder.length,
        itemBuilder: (context, index) {
          String cusId =
              o.hcustomerOrder[index].customerId;
          return Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: Colors.transparent, width: 3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onTap: () {
                buildShowOrderDetailModalBottomSheet(context, index, w, h, o);
              },
              child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: royalblue,
                    radius: 25,
                    child: Text(o
                        .hcustomerOrder[index].orderId
                        .toString())),
                title: cusId != "null"
                    ? Text("Customer: " +
                    c
                        .findCustomerByID(cusId)
                        .customerName)
                    : Text("Customer: no data"),
                subtitle: Text("Status: " +
                    o.hcustomerOrder[index].orderStatus, style: TextStyle(
                    color: o.hcustomerOrder[index].orderStatus == "Completed"
                        ? limegreen
                        : Colors.deepOrangeAccent
                ),),
                trailing: Text(DateFormat(
                    "yyyy-MM-dd HH:mm:ss")
                    .format(
                    o.hcustomerOrder[index].orderDate)
                    .toString()),
              ),
            ),
          );
        });
  }

  Future buildShowOrderDetailModalBottomSheet(BuildContext context, int index,
      double w, double h, OrderController o) {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return GetBuilder<OrderController>(
              init: OrderController(),
              initState: (_) =>
                  OrderController()
                      .loadOrderDetailFromDb(),
              builder: (oc) {
                return FutureBuilder<
                    List<Order_details>>(
                    future: oc
                        .loadOrderDetailFromDb(),
                    builder:
                        (context, snapshot) {
                      if (snapshot.hasData) {
                        return Container(
                          decoration:
                          BoxDecoration(
                            color: azure,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius
                                    .circular(
                                    100)),
                          ),
                          padding:
                          const EdgeInsets
                              .only(
                              top: 60.0),
                          child: Column(
                            mainAxisAlignment:
                            MainAxisAlignment
                                .spaceAround,
                            children: [
                              Expanded(
                                  child:
                                  OrderList(
                                    orderedProducts: oc.findOrderLineByID(oc
                                        .hcustomerOrder[
                                    index]
                                        .orderId),
                                    style1: font2,
                                    style2: font3,
                                  )),
                              const SizedBox(
                                height: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left:50.0),
                                child: ListTile(
                                    leading: Text("Total Amount: ",style: headline3,),
                                    title: Text(formatter.format(oc
                                        .hcustomerOrder[
                                    index].totalAmount) + " Baht"),
                                ),
                              ),   const SizedBox(
                                height: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets
                                    .only(
                                    bottom:
                                    50.0),
                                child:
                                Container(

                                  width:
                                  SizeConfig.isMobilePortrait ? w * 0.9 : w *
                                      0.75,
                                  height: h *
                                      0.07,
                                  child:
                                  RaisedButton
                                      .icon(
                                    color:
                                    color1,
                                    onPressed:
                                        () {
                                      List<Order_details>
                                      rOrder =
                                      oc.findOrderLineByID(
                                          oc.hcustomerOrder[index].orderId)
                                          .toList();
                                      o.reorder(
                                          oc.hcustomerOrder[index],
                                          rOrder, context);
                                    },
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25)
                                    ),
                                    icon:
                                    Icon(
                                      MdiIcons
                                          .redo,
                                      size:
                                      30,
                                      color: Colors
                                          .white,
                                    ),
                                    label:
                                    Text(
                                      "Reorder",
                                      style:
                                      whiteFont,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      } else {
                        return Center(
                            child:
                            CircularProgressIndicator());
                      }
                    });
              });
        });
  }
} //ec
