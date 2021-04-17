import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
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

class RefilStock extends StatefulWidget {
  final BuildContext ctx;


  RefilStock(this.ctx);

  @override
  _RefilStockState createState() => _RefilStockState();
}

class _RefilStockState extends State<RefilStock> {
  TextEditingController qtyTxt = new TextEditingController();
  MyStore agent = Get.find<MyStore>();
  final _formKey2 = GlobalKey<FormState>();
  final FocusNode _qtyFocus = FocusNode();

  Future<void> showProgressandInsertdata(BuildContext context) async {
agent.addBackStock(agent.activeStock.serialNumber, int.parse(qtyTxt.text));
    final ProgressDialog pr = new ProgressDialog(context);
    pr.style(
      message: 'Completing ',
      progressWidget: SpinKitRotatingCircle(
        color: hotpink,
      ),
      elevation: 10.0,
    );

    await pr.show();
    await agent.updateStock2().then((value){
      print(value);
      if(value == "yes"){
        pr.update(message: "Stock updated");
      }else{
      pr.update(message: "Fail to update stock");
      }
    }).whenComplete((){
      Future.delayed(Duration(seconds: 2)).whenComplete(() =>pr.hide().whenComplete(() => Navigator.of(widget.ctx).pop()));
    }
    );


  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    double bottom = MediaQuery.of(context).viewInsets.bottom;
    return buildRefilPage(context, bottom, h, w);
  }

  Scaffold buildRefilPage(
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
          "Stock of " + agent.activeStock.productName,
          style: bigWhite,
          overflow: TextOverflow.ellipsis,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Current Stock: "+ agent.findStockQtyByProductID(agent.activeStock.serialNumber).toString(), style: h4,),
                        TextFormField(
                          controller: qtyTxt,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter some quantity';
                            }else if(int.parse(value) <=0){
                              return "The refill quantity should be more than 0";
                            }
                              return null;
                          },
                          focusNode: _qtyFocus,
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                            signed: true,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                                (RegExp("[.0-9]")))
                          ],
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (term) {
                            _qtyFocus.unfocus();
                          },
                          decoration: InputDecoration(
                              labelText: "Quantity to Refill", icon: Icon(MdiIcons.numeric)),
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
                                    color: qtyTxt.text == ""
                                        ? Colors.grey
                                        : limegreen,
                                    onPressed: () {
                                      if (_formKey2.currentState.validate()) {
                                        showProgressandInsertdata(context);
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


} //ec
