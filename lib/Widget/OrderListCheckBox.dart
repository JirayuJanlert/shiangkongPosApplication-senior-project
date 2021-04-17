import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/Claim_detail.dart';
import 'package:siangkong_mpos/Model/OrderDetails.dart';
import 'package:siangkong_mpos/Model/Product.dart';
import 'package:siangkong_mpos/Screen/Claim_menu.dart';
import 'package:siangkong_mpos/Store/ClaimController.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';

class OrderListCheckBox extends StatefulWidget {
  final List<Order_details> orderedProducts;
  final TextStyle style1;
  final TextStyle style2;

  const OrderListCheckBox({
    Key key,
    this.style1,
    this.style2,
    @required this.orderedProducts,
  }) : super(key: key);

  @override
  _OrderListCheckBoxState createState() => _OrderListCheckBoxState();
}

class _OrderListCheckBoxState extends State<OrderListCheckBox> {
  List<bool> _checked = [];
  List<TextEditingController> qtyTxt = [];
  final _formKey = GlobalKey<FormState>();
  final ClaimController cm = Get.find<ClaimController>();

  Future<void> showProgressandInsertdata() async {


    final ProgressDialog pr = new ProgressDialog(context);
    pr.style(
      message: 'Completing ',
      progressWidget: SpinKitRotatingCircle(
        color: hotpink,
      ),
      elevation: 10.0,
    );
    await pr.show();

    await cm.insertClaimtableDb().then((value) async {
      await cm.insertClaimDetailtableDb(value).then((res) async {
        if (res == "yes") {

          pr.update(message: "Claim is saved");
          Future.delayed(Duration(seconds: 2)).whenComplete(
                  () => pr.hide().whenComplete(() => Get.off(Claim_menu())));
        } else {
          pr.update(message: "Fail to save claim");
          Future.delayed(Duration(seconds: 1)).whenComplete(() => pr.hide());
        }


      });
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    for (var i = 0; i <= widget.orderedProducts.length; i++) {
      _checked.add(false);
      qtyTxt.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    MyStore agent = Get.find<MyStore>();
    return GetBuilder<OrderController>(
        init: OrderController(),
        builder: (oc) {
          return Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    child: ListView.builder(
                        itemCount: widget.orderedProducts.length,
                        itemBuilder: (context, i) {
                          Product p = oc.findProductById(
                              widget.orderedProducts[i].serialNumber);

                          return CheckboxListTile(
                            controlAffinity: ListTileControlAffinity.leading,
                            activeColor: limegreen,
                            tristate: false,
                            subtitle: Text(
                                "X" + widget.orderedProducts[i].qty.toString()),
                            secondary: SizedBox(
                              width: 250,
                              child: TextFormField(
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                controller: qtyTxt[i],
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if(_checked[i]){
                                    if (value == "") {
                                      return "Please enter quantity";
                                    } else if (int.parse(value) >
                                        widget.orderedProducts[i].qty) {
                                      return "Cannot claim more than ordered quantity";
                                    }
                                  }

                                  return null;
                                },
                                enabled: _checked[i],
                                decoration: InputDecoration(
                                  hintText: "Qty",
                                  enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.black54,
                                      style: BorderStyle.solid,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              p.productName,
                              overflow: TextOverflow.ellipsis,
                              style: widget.style2,
                            ),
                            onChanged: (bool value) {
                              setState(() {
                                _checked[i] = !_checked[i];
                              });
                            },
                            value: _checked[i],
                          );
                        }),
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(15),
                  width: 300,
                  height: 50,
                  child: RaisedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState.validate()) {
                          List<Claim_details> cds = [];
                          for (var i = 0;
                              i <= widget.orderedProducts.length;
                              i++) {
                            if (_checked[i]) {
                              Claim_details cd = Claim_details(
                                  claimId: null,
                                  serialNumber:
                                      widget.orderedProducts[i].serialNumber,
                                  qty: int.parse(qtyTxt[i].text));
                              cds.add(cd);

                            }
                          }
                          cm.setListClaimDetails(cds);
                          showProgressandInsertdata();
                        }
                      },
                      color: color1,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      icon: Icon(
                        MdiIcons.checkboxMarkedCircleOutline,
                        color: Colors.white,
                      ),
                      label: Text(
                        "Submit",
                        style: whiteFont,
                      )),
                )
              ],
            ),
          );
        });
  }
} //ec
