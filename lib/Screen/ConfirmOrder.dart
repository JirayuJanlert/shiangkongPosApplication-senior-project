import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/Order.dart';
import 'package:siangkong_mpos/Screen/PrintReceipt.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/Store/ReceiptController.dart';
import 'package:siangkong_mpos/sizing.dart';

class ConfirmOrder extends StatefulWidget {
  @override
  _ConfirmOrderState createState() => _ConfirmOrderState();
}

class _ConfirmOrderState extends State<ConfirmOrder> {
  TextEditingController chargeTxt = new TextEditingController();
  TextEditingController receiveTxt = new TextEditingController();
  OrderController o = Get.find<OrderController>();
  MyStore agent = Get.find<MyStore>();
  CustomerController c = Get.find<CustomerController>();
  ReceiptController rc = Get.put(ReceiptController());
  final _formKey2 = GlobalKey<FormState>();
  final FocusNode _chargeFocus = FocusNode();
  final FocusNode _receivetFocus = FocusNode();
  var formatter = NumberFormat("#,##0.00", "en_US");

  Future<void> showProgressandInsertdata() async {

    o.calulateChange(
        double.parse(chargeTxt.text), double.parse(receiveTxt.text));
    Order cusOrder = new Order(
        orderDate: DateTime.now(),
        orderStatus: "Completed",
        customerId: c.activeCus.value.customerID,
        totalAmount: o.calculateGrandTotal());
    o.setCustomerOrder(cusOrder);
    o.calulateDiscount(double.parse(chargeTxt.text));
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
          await agent.updateStock();
          if(!o.activeBackorder.isNullOrBlank){
            o.updateBackorderStatus();
          }
          pr.update(message: "Order is saved");
          Future.delayed(Duration(seconds: 2)).whenComplete(
                  () => pr.hide().whenComplete(() => Get.offAll(PrintReceipt(
                receive: double.parse(receiveTxt.text),
                charge: double.parse(chargeTxt.text),
              ))));
        } else {
          pr.update(message: "Fail to save order");
          Future.delayed(Duration(seconds: 1)).whenComplete(() => pr.hide());
        }


      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rc.loadReceiptFromDb();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    double bottom = MediaQuery.of(context).viewInsets.bottom;
    if (SizeConfig.isMobilePortrait) {
      return MobileConfitmPage(context, bottom, h, w);
    } else {
      return TabletConfitmPage(context, bottom, h, w);
    }
  }

  Scaffold TabletConfitmPage(
      BuildContext context, double bottom, double h, double w) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: flowerblue,
        toolbarHeight: 100,
        elevation: 5,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CloseButton(),
          )
        ],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0))),
        title: Text(
          "Total Receivable: " + formatter.format(o.calculateGrandTotal()),
          style: bigWhite,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Center(
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25.0),
                      bottomRight: Radius.circular(25.0)),
                  color: azure,
                ),
                // height: SizeConfig.isMobilePortrait ? h * 0.3 : h * 0.42,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextFormField(
                          controller: chargeTxt,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            } else if (double.parse(value) >
                                o.calculateGrandTotal()) {
                              return "You can't charge more than the total receivable";
                            } else {
                              return null;
                            }
                          },
                          focusNode: _chargeFocus,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                (RegExp("[.0-9]")))
                          ],
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (term) {
                            _chargeFocus.unfocus();
                            FocusScope.of(context).requestFocus(_receivetFocus);
                          },
                          decoration: InputDecoration(
                              labelText: "Charge", icon: Icon(MdiIcons.cash)),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            } else if (double.parse(value) <
                                double.parse(chargeTxt.text)) {
                              return "The amount received is not sufficient";
                            } else {
                              return null;
                            }
                          },
                          focusNode: _receivetFocus,
                          controller: receiveTxt,
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                (RegExp("[.0-9]")))
                          ],
                          decoration: InputDecoration(
                              labelText: "Receive",
                              icon: Icon(MdiIcons.cashRegister)),
                        ),
                        Container(
                          width: w,
                          height: h * 0.2,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(
                                width: SizeConfig.isMobilePortrait
                                    ? w * 0.45
                                    : w * 0.27,
                                height: h * 0.08,
                                child: RaisedButton.icon(
                                    color: hotpink,
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: Icon(
                                      MdiIcons.cancel,
                                      color: Colors.white,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    label: Text(
                                      "Cancel",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    )),
                              ),
                              SizedBox(
                                width: SizeConfig.isMobilePortrait
                                    ? w * 0.45
                                    : w * 0.27,
                                height: h * 0.08,
                                child: RaisedButton.icon(
                                    color: chargeTxt.text == "" ||
                                            receiveTxt.text == ""
                                        ? Colors.grey
                                        : limegreen,
                                    onPressed: () {
                                      if (_formKey2.currentState.validate()) {
                                        showProgressandInsertdata();
                                      }
                                    },
                                    icon: Icon(
                                      MdiIcons.checkboxMarkedCircleOutline,
                                      color: Colors.white,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    label: Text(
                                      "Confirm",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20),
                                    )),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }

  Scaffold MobileConfitmPage(
      BuildContext context, double bottom, double h, double w) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        actions: [
          GestureDetector(
            onTap: () {
              if (_formKey2.currentState.validate()) {
                showProgressandInsertdata();
              }
            },
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(children: [
                  Text(
                    "Confirm",
                    style: success_2,
                  ),
                  Icon(
                    MdiIcons.checkboxMarkedCircleOutline,
                    color: limegreen,
                    size: 35,
                  )
                ])),
          )
        ],
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: flowerblue,
        toolbarHeight: 110,
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0))),
        title: Text(
          "Total Receivable: " + formatter.format(o.calculateGrandTotal()),
          style: bigWhite,
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);

          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: SingleChildScrollView(
          child: Center(
            child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(25.0),
                      bottomRight: Radius.circular(25.0)),
                  color: azure,
                ),
                padding: EdgeInsets.only(bottom: bottom),
                height: h * 0.58,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _formKey2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextFormField(
                          controller: chargeTxt,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            } else if (double.parse(value) >
                                o.calculateGrandTotal()) {
                              return "You can't charge more than the total receivable";
                            } else {
                              return null;
                            }
                          },
                          focusNode: _chargeFocus,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                (RegExp("[.0-9]")))
                          ],
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (term) {
                            _chargeFocus.unfocus();
                            FocusScope.of(context).requestFocus(_receivetFocus);
                          },
                          decoration: InputDecoration(
                              labelText: "Charge", icon: Icon(MdiIcons.cash)),
                        ),
                        TextFormField(
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some text';
                            } else if (double.parse(value) <
                                double.parse(chargeTxt.text)) {
                              return "The amount received is not sufficient";
                            } else {
                              return null;
                            }
                          },
                          focusNode: _receivetFocus,
                          controller: receiveTxt,
                          keyboardType: TextInputType.numberWithOptions(
                              decimal: true, signed: true),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                (RegExp("[.0-9]")))
                          ],
                          decoration: InputDecoration(
                              labelText: "Receive",
                              icon: Icon(MdiIcons.cashRegister)),
                        ),

                        // ListTile(
                        //   leading: Text("Change:"),
                        //   trailing: Text(oc.change.toString()),
                        // ),
                      ],
                    ),
                  ),
                )),
          ),
        ),
      ),
    );
  }
} //ec
