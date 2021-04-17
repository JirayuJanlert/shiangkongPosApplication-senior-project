import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/Claim_detail.dart';
import 'package:siangkong_mpos/Model/OrderDetails.dart';
import 'package:siangkong_mpos/Model/Product.dart';
import 'package:siangkong_mpos/Screen/HomePage.dart';
import 'package:siangkong_mpos/Store/ClaimController.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/Widget/OrderList.dart';
import 'package:siangkong_mpos/Widget/SearchBar.dart';
import 'package:siangkong_mpos/Widget/monthpicker/src/date_picker.dart';
import 'dart:async';

import 'package:siangkong_mpos/sizing.dart';

class ClaimList extends StatefulWidget {
  @override
  _ClaimListState createState() => _ClaimListState();
}

class _ClaimListState extends State<ClaimList>
    with SingleTickerProviderStateMixin {
  FocusNode searchNode = FocusNode();
  final MyStore agent = Get.find<MyStore>();

  Future loadData;

  DateTime selectedDate = DateTime.now();
  OrderController o = Get.find<OrderController>();

  TextEditingController searchTxt = TextEditingController();

  CustomerController c = Get.find<CustomerController>();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ClaimController cm = Get.put(ClaimController());
  AnimationController _animationController;
  bool isA = true;
  Icon AIcon = Icon(MdiIcons.sortCalendarDescending);
  Icon AIcon2 = Icon(MdiIcons.sortCalendarDescending);
  Icon DIcon = Icon(MdiIcons.sortCalendarAscending);


  var selectedOption = "All";

  String options =
'''
[
"Processing",
"Approved",
"Rejected",
"All"
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
          cm.filterClaim(value.toString());
        }
    );
    picker.show(_scaffoldKey.currentState);
  }
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
      return cm.loadClaimFromDb();
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
        backgroundColor: azure,
        appBar: AppBar(
          actions: [
            IconButton(
              icon: AIcon,
              onPressed: () {
                setState(() {
                  if (isA) {
                    cm.sortByDescending();
                    AIcon = DIcon;
                    isA = !isA;
                  } else {
                    cm.sortByAscending();
                    AIcon = AIcon2;
                    isA = !isA;
                  }
                });
              },
            ),
          ],
          backgroundColor: royalblue,
          title: Text(
            "Claim Record",
            style: bigWhite,
          ),
        ),
        body: GetBuilder<ClaimController>(
            initState: (_) {
              loadData = ClaimController().loadClaimFromDb();
            },
            init: ClaimController(),
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
                                  searchFunction: cm.setSearchKey,
                                  label:
                                      "Search Claim by Customer ID or Claim ID",
                                  // searchFunction: o.setSearchKey,
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
                                    'Filter Claim',
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
                          child: cm.hClaim.length > 0
                              ? buildOrderHistoryListView(cm, w, h)
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

  ListView buildOrderHistoryListView(ClaimController cm, double w, double h) {
    return ListView.builder(
        itemCount: cm.hClaim.length,
        itemBuilder: (context, index) {
          String cusId = cm.hClaim[index].customerId;
          return Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.transparent, width: 3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onTap: () {
                buildShowOrderDetailModalBottomSheet(context, index, w, h, cm);
              },
              child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: royalblue,
                    radius: 25,
                    child: Text(cm.hClaim[index].claimID.toString())),
                title: cusId != "null"
                    ? Text(
                        "Customer: " + c.findCustomerByID(cusId).customerName)
                    : Text("Customer: no data"),
                trailing: Container(
                  width: 90,
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: cm.hClaim[index].claimStatus.toLowerCase() == "processing"
                          ? lightskyblue
                          : cm.hClaim[index].claimStatus == "approved"? limegreen:color1,
                      // border: Border.all(color: o.bOrders[index].backorderStatus == "filled"? limegreen: Colors.redAccent,width: 3),
                      borderRadius: BorderRadius.circular(15)),
                  child: Center(
                    child: Text(
                      cm.hClaim[index].claimStatus,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                subtitle: Text(DateFormat("yyyy-MM-dd HH:mm:ss")
                    .format(cm.hClaim[index].claimDate)
                    .toString()),
              ),
            ),
          );
        });
  }

  Future buildShowOrderDetailModalBottomSheet(
      BuildContext context, int index, double w, double h, ClaimController cm) {
    return showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          return GetBuilder<ClaimController>(
              init: ClaimController(),
              initState: (_) => ClaimController().loadClaimDetailFromDb(),
              builder: (oc) {
                return FutureBuilder<List<Claim_details>>(
                    future: cm.loadClaimDetailFromDb(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Claim_details> cds = cm.hClaimdetail
                            .where((element) =>
                                element.claimId == cm.hClaim[index].claimID)
                            .toList();
                        print(cds.length);
                        return Container(
                          decoration: BoxDecoration(
                            color: azure,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(100)),
                          ),
                          padding: const EdgeInsets.only(top: 60.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Center(
                                  child: Scrollbar(
                                    child: ListView.builder(
                                        itemCount: cds.length,
                                        itemBuilder: (context, i) {
                                          Product p = o.findProductById(
                                              cds[i].serialNumber);
                                          return ListTile(
                                            leading: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        300.0),
                                                child: SizedBox(
                                                    width: 60,
                                                    height: 60,
                                                    child: agent
                                                        .getImage(p.pics))),
                                            subtitle: Text(
                                              "X" + cds[i].qty.toString(),
                                            ),
                                            title: Text(
                                              p.productName,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          );
                                        }),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                             Padding(
                               padding: const EdgeInsets.only(bottom: 100.0, left: 50,right: 100),
                               child: ListTile(
                                 title: Text("Description :",style: headline3,),
                                 trailing:  Text( cm.hClaim[index].claimDescription,style: font3,),
                               ),
                             ),
                              cm.hClaim[index].claimStatus.toLowerCase() == "processing"? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 50.0),
                                    child: Container(
                                      width: SizeConfig.isMobilePortrait
                                          ? w * 0.45
                                          : w * 0.35,
                                      height: h * 0.07,
                                      child: RaisedButton.icon(
                                        color: color1,
                                        onPressed: () {
                                          cm.hClaim[index].claimStatus = "rejected";
                                          cm.updateClaimStatus(cm.hClaim[index],ctx);
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        icon: Icon(
                                          MdiIcons.cancel,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          "Reject",
                                          style: whiteFont,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 50.0),
                                    child: Container(
                                      width: SizeConfig.isMobilePortrait
                                          ? w * 0.45
                                          : w * 0.35,
                                      height: h * 0.07,
                                      child: RaisedButton.icon(
                                        color: limegreen,
                                        onPressed: () {
                                          cm.hClaim[index].claimStatus = "approved";
                                          cm.updateClaimStatus(cm.hClaim[index],ctx);
                                        },
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        icon: Icon(
                                          MdiIcons.checkboxMarkedCircleOutline,
                                          size: 30,
                                          color: Colors.white,
                                        ),
                                        label: Text(
                                          "Approve",
                                          style: whiteFont,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ):Container()
                            ],
                          ),
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    });
              });
        });
  }
} //ec
