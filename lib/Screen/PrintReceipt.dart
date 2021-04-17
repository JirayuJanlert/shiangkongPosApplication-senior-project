import 'dart:typed_data';

import 'package:charset_converter/charset_converter.dart';
import 'package:esc_pos_bluetooth/esc_pos_bluetooth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/Receipt.dart';
import 'package:siangkong_mpos/Screen/HomePage.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/Store/ReceiptController.dart';
import 'package:siangkong_mpos/Widget/OrderList.dart';
import 'package:siangkong_mpos/sizing.dart';

class PrintReceipt extends StatefulWidget {
  final double receive;
  final double charge;

  const PrintReceipt({
    Key key,
    @required this.receive,
    @required this.charge,

  }) : super(key: key);

  @override
  _PrintReceiptState createState() => _PrintReceiptState();
}

class _PrintReceiptState extends State<PrintReceipt> {
  PrinterBluetoothManager printerManager = PrinterBluetoothManager();
  List<PrinterBluetooth> _devices = [];
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Uint8List encoded;
  bool printReceipt = false;
  final ReceiptController rc = Get.put(ReceiptController());
  final CustomerController _customerController = Get.put(CustomerController());
  final OrderController o = Get.put(OrderController());
  var formatter = NumberFormat("#,##0.00", "en_US");
  List<Uint8List> list1 = [];

  @override
  void initState() {
    // TODO: implement initState
    setReceipt();

    o.orderedProducts.forEach((element) async {
      encoded = await CharsetConverter.encode("TIS620", o
          .findProductById(element.serialNumber)
          .productName
          .substring(0, 14)
          .removeAllWhitespace);
      list1.add(encoded);
    });
    super.initState();


    // Receipt r = new Receipt();
    // rc.setReceipt(r);
    _startScanDevices();
    printerManager.scanResults.listen((devices) async {
      print('UI: Devices found ${devices.length}');

      setState(() {
        _devices = devices;
      });
    });
  }

  void setReceipt() {
    Receipt receipt = new Receipt(
      receiptId: rc.receipts.length +1,
        orderId: o.customer_order.orderId,
        receive: widget.receive,
        grandTotal: widget.charge,
        discount
        :o.discount,vat: o.calculateVat(), paymentDate: DateTime.now(),changes: o.change);

    rc.setReceipt(receipt);
  }

  void _startScanDevices() {
    setState(() {
      _devices = [];
    });
    printerManager.startScan(Duration(seconds: 4));

    _devices.forEach((element) {
      print(element.name);
    });
  }

  void _stopScanDevices() {
    printerManager.stopScan();
  }

  void _testPrint(PrinterBluetooth printer) async {

    printerManager.selectPrinter(printer);

    final ProgressDialog pr = new ProgressDialog(context);
    pr.style(
      message: 'Printing Receipt',
      progressWidget: SpinKitRotatingCircle(
        color: hotpink,
      ),
      elevation: 10.0,
    );
    await pr.show();

    // TODO Don't forget to choose printer's paper
    const PaperSize paper = PaperSize.mm58;

    // TEST PRINT
    // final PosPrintResult res =
    // await printerManager.printTicket(await testTicket(paper));

    // DEMO RECEIPT

    await printerManager
        .printTicket(await rc.demoReceipt(paper, list1))
        .then((value) {
          Future.delayed(Duration(seconds: 5)).whenComplete((){
            print(value.msg);
            if (value.msg == "Success") {
              rc.insertReceipttableDb();
              setState(() {
                printReceipt = true;
              });
              pr.update(message: "Receipt printed");
            } else {
              pr.update(message: "Fail to print receipt");
            }

            Future.delayed(Duration(seconds: 2)).whenComplete(
                    () => pr.hide()
            );
          });

    });
  }


  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text("Cancel", style: danger,),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Continue without receipt"),
      onPressed: () {
        o.cancleOrder();
        _customerController.dismissCustomer();
        Get.offAll(() => HomePage());
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("Are you sure?", style: font1,),
      content: Text("You haven't print receipt yet."),
      actions: [
        cancelButton,
        continueButton,
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

  @override
  Widget build(BuildContext context) {
   MyStore agent = Get.put(MyStore());
   final CustomerController _customerController2 = Get.put(CustomerController());
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
        key: _scaffoldKey,
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: BuildCustomerRow(),
            )
          ],
          backgroundColor: royalblue,
          leading: BackButton(
            onPressed: () {
              if (!printReceipt) {
                showAlertDialog(context);
              } else {
                o.cancleOrder();
                _customerController2.dismissCustomer();
                Get.off(HomePage());
              }
            },
          ),
          title: Text(" Back To Home"),
          centerTitle: false,
        ),
        floatingActionButton: StreamBuilder<bool>(
            stream: printerManager.isScanningStream,
            initialData: false,
            builder: (context, snapshot) {
              PrinterBluetooth pt = _devices.firstWhere((element) =>
              element.name == "BlueTooth Printer", orElse: () => null);
              if (snapshot.data) {
                return FloatingActionButton(
                  child: Icon(MdiIcons.stop),
                  onPressed: _stopScanDevices,
                  backgroundColor: Colors.red,
                );
              }
              if (snapshot.hasData && _devices.length > 0) {
                return FloatingActionButton(
                  child: pt == null ? Icon(MdiIcons.printerOff) : Icon(
                      MdiIcons.printerCheck),
                  onPressed: _startScanDevices,
                  backgroundColor: pt == null ? Colors.red : limegreen,
                );
              }
              else {
                return FloatingActionButton(
                  child: Icon(MdiIcons.printerSearch),
                  onPressed: _startScanDevices,
                );
              }
            }),
        body: buildPrintReceiptBody(h, w));
  }


  Center buildPrintReceiptBody(double h, double w) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Container(
                  height: h * 0.71,
                  decoration: BoxDecoration(
                      color: flowerblue,
                      borderRadius: BorderRadius.circular(20)),
                  padding:
                  EdgeInsets.symmetric(horizontal: w * 0.05, vertical: 10),
                  child: Column(
                    children: [
                      Expanded(
                          child: OrderList(
                            orderedProducts: o.orderedProducts,
                            style1: bigWhite,
                            style2: whiteFont,
                          )),
                      Divider(
                        thickness: 5,
                      ),
                      SizedBox(
                        height: h*0.38,
                          child: buildOrderCalculationSection())
                    ],
                  )),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  MdiIcons.checkboxMarkedCircleOutline,
                  color: limegreen,
                  size: 40,
                ),
                SizedBox(
                  width: 20,
                ),
                Text(
                  "Order is completed",
                  style: headline,
                ),
              ],
            ),
            SizedBox(
              height: h * 0.02,
            ),
            Container(
              width: w * 0.75,
              height: h * 0.08,
              child: RaisedButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)
                ),
                onPressed: () {
                  if (_devices.length > 0) {
                    PrinterBluetooth pt = _devices.firstWhere((
                        element) => element.name == "BlueTooth Printer",
                        orElse: () => null);
                    if (pt != null) {
                      _testPrint(pt);
                    } else {
                      final snackBar = SnackBar(
                        backgroundColor: flowerblue,
                        content: Text(
                          'Printer not found, please retry',
                          style: danger2,
                        ),
                      );
                      _scaffoldKey.currentState.showSnackBar(
                          snackBar);
                    }
                  } else {
                    final snackBar = SnackBar(
                      backgroundColor: flowerblue,
                      content: Text(
                        'No devices detected, please check bluetooth connection',
                        style: danger2,
                      ),
                    );
                    _scaffoldKey.currentState.showSnackBar(
                        snackBar);
                  }
                },
                icon: Icon(
                  MdiIcons.receipt,
                  color: Colors.white,
                ),
                label: Text(
                  "Print Receipt",
                  style: bigWhite,
                ),
                color:
                _devices.length > 0 && _devices.firstWhere((element) =>
                element.name == "BlueTooth Printer", orElse: () => null) != null
                    ? royalblue
                    : Colors.grey,
              ),
            ),
          ],
        ));
  }

  GetBuilder<OrderController> buildOrderCalculationSection() {
    return GetBuilder<OrderController>(
        init: OrderController(),
        builder: (o) {
          return Container(
            child: Column(
              children: [
                ListTile(
                  leading: Text(
                    "Total Amount",
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    formatter.format(o.calculateGrandTotal()) + " Baht",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: Text(
                    "Discount",
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                   "-"+ formatter.format(o.discount) + " Baht",

                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Spacer(),
                    SizedBox(
                        width: 150,
                        height: 5,
                        child: Divider(
                          thickness: 3,
                          color: Colors.white54,
                        ))
                  ],
                ),
                ListTile(
                  leading: Text(
                    "Grand Total",
                    style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    formatter.format((o.calculateGrandTotal() - o.discount)) +
                        " Baht",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: Text(
                    "Cash",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    formatter.format(widget.receive)+ " Baht",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                ListTile(
                  leading: Text(
                    "Change",
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    formatter.format(o.change)+ " Baht",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizeConfig.isMobilePortrait
                    ? SizedBox(
                  height: 20,
                )
                    : Container(),
                SizeConfig.isMobilePortrait ? BuildCustomerRow() : Container()
              ],
            ),
          );
        });
  }

  Row BuildCustomerRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(
          MdiIcons.accountCircle,
          color: color1,
          size: 35,
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          "Customer: ",
          style: TextStyle(
              color: color1, fontSize: 22, fontWeight: FontWeight.bold),
        ),
        _customerController.activeCus.value.customerName == null
            ? Text(
          "No Data",
          style: font5,
        )
            : Text(
          _customerController.activeCus.value.customerName,
          style: font5,
          overflow: TextOverflow.ellipsis,
        )
      ],
    );
  }
} //ec
