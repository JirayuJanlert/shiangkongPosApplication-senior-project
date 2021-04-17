import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:siangkong_mpos/Model/Backorder.dart';
import 'package:siangkong_mpos/Model/Customer.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/Widget/dropdownfield.dart';

import '../CSS.dart';

class BackorderAdd extends StatefulWidget {
  @override
  _BackorderAddState createState() => _BackorderAddState();
}

class _BackorderAddState extends State<BackorderAdd> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController txt1 = new TextEditingController();
  TextEditingController txt2 = new TextEditingController();
  TextEditingController txt3 = new TextEditingController();
  final FocusNode txt1Focus = FocusNode();
  final FocusNode txt2Focus = FocusNode();
  final FocusNode txt3Focus = FocusNode();
  final MyStore agent = Get.put(MyStore());
  final OrderController o = Get.find<OrderController>();
  final CustomerController c = Get.find<CustomerController>();
  List<String> cusNames = [];
  String _selectedCus;
  @override
  void initState() {
    if(c.activeCus.value!=null){
      txt3.text = c.activeCus.value.customerName;
    }
    // TODO: implement initState
    super.initState();
    c.all_customers.forEach((element) {
      cusNames.add(element.customerName.toString());
    });

  }
  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery.of(context).viewInsets.bottom;

    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: false,
        backgroundColor: flowerblue,
        toolbarHeight: 100,
        elevation: 5,
        leading:CloseButton(),
        title: Text("Backorder Form",style: bigWhite,),
        actions: [ GestureDetector(
          onTap: () async {
            if (_formKey.currentState.validate()) {
              final ProgressDialog pr = new ProgressDialog(context);
              pr.style(
                message: 'Saving Backorder',
                progressWidget: SpinKitRotatingCircle(
                  color: hotpink,
                ),
                elevation: 10.0,
              );
              await pr.show();
              
              double totalAmount = agent.activeProduct.sellingPrice*int.parse(txt2.text);
              Customer cId = c.all_customers.firstWhere((element) => element.customerName == txt3.text);
              Backorder b = Backorder(customerId: cId.customerID,backorderQty: int.parse(txt2.text),serialNumber: txt1.text, orderDate: DateTime.now(),backorderStatus: "unfilled",totalAmount: totalAmount);
              await o.insertBackordertableDb(b).then((value){
                print(value);
                if (value == "yes") {
                
                  pr.update(message: "Backorder Saved");
                } else {
                  pr.update(message: "Fail to save Backorder");
                }

                Future.delayed(Duration(seconds: 2)).whenComplete(
                        () => pr.hide().whenComplete(() => Get.back())
                );
              }
                
              );
            }
          },
          child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(children: [
                Text(
                  "Save",
                  style: success_2,
                ),
                Icon(MdiIcons.checkboxMarkedCircleOutline,color: limegreen,size:35,)
              ])),
        )],
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30.0),
                topRight: Radius.circular(30.0))),
      ),
      body: GestureDetector(
        onTap: () {
      FocusScopeNode currentFocus = FocusScope.of(context);

      if (!currentFocus.hasPrimaryFocus) {
        currentFocus.unfocus();
      }},
        child: SingleChildScrollView(
          child: Center(
            child: Container(
         decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25.0),
              bottomRight: Radius.circular(25.0)),
          color: azure,),
              padding: EdgeInsets.only(
                  bottom: bottom , left: 50, right: 50, top: 50),
              child: Form(
                  key: _formKey,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        TextFormField(
                          enabled: false,
                          controller: txt1
                            ..text = agent.activeProduct.serialNumber,
                          focusNode: txt1Focus,
                          onFieldSubmitted: (term) {
                            txt1Focus.unfocus();
                            FocusScope.of(context).requestFocus(txt3Focus);
                          },
                          // initialValue: agent.activeProduct.serialNumber,
                          decoration: InputDecoration(
                            labelText: "Serial Number",
                            // icon: Icon(MdiIcons.product)
                          ),
                          textInputAction: TextInputAction.next,
                        ),
                        SizedBox(height: h*0.05,),
                        TextFormField(
                            controller: txt2,
                            focusNode: txt2Focus,
                            onFieldSubmitted: (term) {
                              txt2Focus.unfocus();
                              FocusScope.of(context).requestFocus(txt3Focus);
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              labelText: "Quantity to Backorder",
                              // icon: Icon(MdiIcons.product)
                            ),
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if(value.isEmpty){
                                return "Please input some number";
                              }
                              return null;
                            }),
                        SizedBox(height: h*0.05,),
                        DropDownField(
                          focusNode: txt3Focus,
                          textInputAction: TextInputAction.done,
                          controller: txt3,
                          items: cusNames,

                          itemsVisibleInDropdown: 3,
                          // required: true,

                          strict: false,
                          setter: (dynamic newValue) {
                            _selectedCus = newValue;
                          },
                          value: _selectedCus,
                          labelText: 'Customer',
                          hintText: 'Choose or Type Customer',
                          onSubmitted: (value){
                            txt3Focus.unfocus();

                          },
                          onValueChanged: (value) {
                            setState(() {
                              _selectedCus = value;
                            });
                          },
                        ),
                        SizedBox(height: h*0.05,),


                      ])),
            ),
          ),
        ),
      ),
    );
  } } //ec
