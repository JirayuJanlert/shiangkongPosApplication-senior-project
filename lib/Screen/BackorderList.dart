import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:siangkong_mpos/Model/Backorder.dart';
import 'package:siangkong_mpos/Model/Product.dart';
import 'package:siangkong_mpos/Screen/HomePage.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/Widget/SearchBar.dart';
import 'package:siangkong_mpos/Widget/monthpicker/src/date_picker.dart';
import 'package:siangkong_mpos/sizing.dart';

import '../CSS.dart';

class BackorderList extends StatefulWidget {
  @override
  _BackorderListState createState() => _BackorderListState();
}

class _BackorderListState extends State<BackorderList>
    with SingleTickerProviderStateMixin {
  FocusNode searchNode = FocusNode();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  Future loadData;
  final MyStore agent = Get.find<MyStore>();
  var selectedOption = "All";
  var formatter = NumberFormat("#,##0.00", "en_US");
  String options =
  '''
[
    "All",
    "Filled Backorder",
    "Unfilled Backorder",
    "In-Stock Unfilled Backorder"
]
    ''';
  showPicker(BuildContext context) {
    Picker picker = new Picker(
        adapter: PickerDataAdapter<String>(pickerdata: new JsonDecoder().convert(options)),
        changeToFirst: true,
        textAlign: TextAlign.left,
        columnPadding: const EdgeInsets.all(8.0),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          // print(picker.getSelectedValues());
          o.filterBorders(value.toString());
        }
    );
    picker.show(_scaffoldKey.currentState);
  }

  TextEditingController searchTxt = TextEditingController();

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
      return o.loadBackOrderFromDb();
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(
          leading: BackButton(
            color: Colors.white,
            onPressed: (){
              Get.off(HomePage());
            },
          ),
          backgroundColor: royalblue,
          centerTitle: false,
          actions: [
            IconButton(
              icon: AIcon,
              onPressed: (){
                setState(() {
                  if(isA){
                    o.sortByDescending2();
                    AIcon = DIcon;
                    isA = !isA;
                  }else{
                    o.sortByAscending2();
                    AIcon = AIcon2;
                    isA = !isA;
                  }
                });
              },
            ),
          ],
          title: Text("Backorder Record",style: bigWhite,),
        ),
        body: GetBuilder<OrderController>(
            initState: (_) {
              loadData = OrderController().loadBackOrderFromDb();
            },
            init: OrderController(),
            builder: (o) {
              return FutureBuilder(
                future: _fetchData(),
                builder: (context, snapshot) {
                  print(snapshot);
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
                                  label: "Search Backorder",
                                  searchFunction: o.setSearchKey2,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(15.0),
                                child: RaisedButton.icon(
                                  icon: Icon(
                                    MdiIcons.filter,
                                    color: Colors.white,
                                  ),
                                  onPressed: () {
                                    showPicker(context);
                                  },
                                  label: Text(
                                    'Filter Backorders',
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
                          child: o.bOrders.length > 0
                              ? buildBackorderListView(o, w, h)
                              : Center(
                                  child: Text(
                                  "No record",
                                  style: font3,
                                )),
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

  ListView buildBackorderListView(OrderController o, double w, double h) {

    return ListView.builder(
        itemCount: o.bOrders.length,
        itemBuilder: (context, index) {
          int stock = agent.findStockQtyByProductID(o.bOrders[index].serialNumber);
          String cusId = o.bOrders[index].customerId;
          return Card(
            color:o.bOrders[index].backorderStatus == "filled"? Colors.white54: o.bOrders[index].backorderQty > stock? color1:limegreen,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.transparent, width: 3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onTap: () {
              if(o.bOrders[index].backorderStatus != 'filled') {
                buildShowOrderDetailModalBottomSheet(
                    context, index, w, h, o, o.bOrders[index]);
              }
              },
              child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: royalblue,
                    radius: 25,
                    child: Text(o.bOrders[index].backorderId.toString())),
                title:
                    Text("Customer: " + c.findCustomerByID(cusId).customerName),
                trailing: Container(
                  width: 80,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white,
                    border: Border.all(color: o.bOrders[index].backorderStatus == "filled"? limegreen: Colors.redAccent,width: 3),
                    borderRadius: BorderRadius.circular(15)
                  ),
                  child: Center(
                    child: Text(
                        o.bOrders[index].backorderStatus.toString(),style: TextStyle(color:o.bOrders[index].backorderStatus == "filled"? limegreen:color1),),
                  ),
                ),
                subtitle: Text(DateFormat("yyyy-MM-dd HH:mm:ss")
                    .format(o.bOrders[index].orderDate)
                    .toString()),
              ),
            ),
          );
        });
  }

  Future buildShowOrderDetailModalBottomSheet(BuildContext context, int index,
      double w, double h, OrderController o, Backorder b) {
    Product p = o.findProductById(b.serialNumber);
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              color: azure,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(100)),
            ),
            padding: const EdgeInsets.only(top: 60.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ListTile(
                  leading: ClipRRect(
                      borderRadius: BorderRadius.circular(300.0),
                      child: SizedBox(
                          width: 60,
                          height: 60,
                          child: agent.getImage(p.pics))),
                  subtitle: Text(
                    "X" + b.backorderQty.toString(),
                  ),
                  title: Text(
                    p.productName,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                   formatter.format(b.totalAmount) + " Baht",
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 50.0),
                  child: Container(
                    decoration: BoxDecoration(

                      borderRadius: BorderRadius.circular(20)
                    ),
                    width: SizeConfig.isMobilePortrait ? w * 0.9 : w * 0.75,
                    height: h * 0.07,
                    child: RaisedButton.icon(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100)
                      ),
                      color: agent.findStockQtyByProductID(b.serialNumber) >= b.backorderQty?royalblue:Colors.grey,
                      onPressed: () {
                        if(agent.findStockQtyByProductID(b.serialNumber) >= b.backorderQty){
                          o.fillBackorder(b, context);
                          o.setActiveBackorder(b);
                        }else{
                          AlertDialog alert = AlertDialog(
                            title: Text("Error"),
                            content: Text("Stock insufficient."),
                            actions: [
                              RaisedButton(
                                  child: Text("okay"),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  })
                            ],
                          );

                          // show the dialog
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return alert;
                            },
                          );
                        }

                      },
                      icon: Icon(
                        MdiIcons.basketFill
                        ,
                        size: 30,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Fill order",
                        style: whiteFont,
                      ),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
} //ec
