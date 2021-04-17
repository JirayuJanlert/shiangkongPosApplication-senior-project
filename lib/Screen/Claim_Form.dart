import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/Claim.dart';
import 'package:siangkong_mpos/Screen/ClaimDetail_Form.dart';
import 'package:siangkong_mpos/Screen/CustomerAddpage.dart';
import 'package:siangkong_mpos/Store/ClaimController.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Store/ReceiptController.dart';
import 'package:siangkong_mpos/Widget/dropdownfield.dart';

class Claim_Form extends StatefulWidget {
  @override
  _Claim_FormState createState() => _Claim_FormState();
}

class _Claim_FormState extends State<Claim_Form> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController txt1 = new TextEditingController();
  TextEditingController txt2 = new TextEditingController();

  final FocusNode txt1Focus = FocusNode();
  final FocusNode txt2Focus = FocusNode();

  final ClaimController cm = Get.put(ClaimController());
  final ReceiptController rc = Get.put(ReceiptController());
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<String> cusNames = [];

  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery.of(context).viewInsets.bottom;
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: azure,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: royalblue,
          centerTitle: false,
          title: Text(
            "Fill Claim Info",
            style: bigWhite,
          ),
        ),
        persistentFooterButtons: [
          SizedBox(
            width: w * 0.3,
            height: h * 0.08,
            child: RaisedButton.icon(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  Claim claim = new Claim(
                      receiptId: int.parse(txt1.text),
                      claimStatus: "processing",
                      claimDescription: txt2.text);
                  cm.setActiveClaim(claim);

                  Get.to(() => ClaimDetail_Form());
                }
              },
              icon: Icon(MdiIcons.pageNextOutline),
              label: Text(
                "Next",
                style: TextStyle(fontSize: 20),
              ),
              color: royalblue,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          )
        ],
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: GetBuilder<ReceiptController>(
            init: ReceiptController(),
            initState: (_)=>ReceiptController().loadReceiptFromDb(),
            builder: (rc) {
              return FutureBuilder(
                future: rc.loadReceiptFromDb(),
                builder: (context, snapshot) {
                  if(snapshot.hasData){
                    return SingleChildScrollView(
                      child: Container(
                        color: azure,
                        padding:
                        EdgeInsets.only(bottom: bottom, left: 50, right: 50, top: 50),
                        child: Form(
                            key: _formKey,
                            child: Container(
                              child: Column(children: <Widget>[
                                TextFormField(
                                    controller: txt1,
                                    focusNode: txt1Focus,
                                    onFieldSubmitted: (term) {
                                      txt1Focus.unfocus();
                                      FocusScope.of(context).requestFocus(txt2Focus);
                                    },
                                    decoration: InputDecoration(
                                      labelText: "Receipt ID",
                                      // icon: Icon(MdiIcons.product)
                                    ),
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    keyboardType: TextInputType.number,
                                    validator: (text) {

                                      if (text.isEmpty) {
                                        return "Please enter some text";
                                      } else {
                                        var _receipt = rc.receipts.firstWhere(
                                                (element) => element.receiptId == int.parse(text),
                                            orElse: () => null);
                                        if (_receipt == null) {
                                          return "No receipt Id exist in the system";
                                        }else{
                                          DateTime orderDate = _receipt.paymentDate;
                                          final date2 = DateTime.now();
                                          final difference = date2.difference(orderDate).inDays;

                                          if(difference>7){
                                            return "The 7-days claim duration is expired";
                                          }
                                        }
                                      }
                                      return null;

                                      // return _validateSerialNumber(value);
                                    }),
                                SizedBox(
                                  height: h * 0.08,
                                ),
                                TextFormField(
                                  controller: txt2,
                                  maxLines: 3,
                                  focusNode: txt2Focus,
                                  onFieldSubmitted: (value) {
                                    txt2Focus.unfocus();
                                  },
                                  textInputAction: TextInputAction.done,
                                  decoration: InputDecoration(
                                    labelText: "Details",
                                  ),
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  },
                                ),
                              ]),
                            )),
                      ),
                    );
                  }else{
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                }
              );
            }
          ),
        ));
  }
} //ec
