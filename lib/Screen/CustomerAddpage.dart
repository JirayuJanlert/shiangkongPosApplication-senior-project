import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/Customer.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:progress_dialog/progress_dialog.dart';

class CustomerAdd extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController txt1 = new TextEditingController();
  TextEditingController txt2 = new TextEditingController();
  TextEditingController txt3 = new TextEditingController();

  final FocusNode txt1Focus = FocusNode();
  final FocusNode txt2Focus = FocusNode();
  final FocusNode txt3Focus = FocusNode();
  final c =Get.find<CustomerController>();

  Future<void> addNewCus(BuildContext context) async {
    String customerId = "C"+(c.customers.length + 1).toString().padLeft(4,"0");
    print(customerId);
    Customer newCus = Customer(customerName: txt1.text,tel: txt2.text,address: txt3.text,customerID: customerId);
    final ProgressDialog pr = new ProgressDialog(context);
    pr.style(
      message: 'Completing ',
      progressWidget: SpinKitRotatingCircle(
        color: hotpink,
      ),
      elevation: 10.0,
    );
    await pr.show();
    await c.insertNewCustomerIntoDb(newCus).then((value){

       if(value == "yes"){
         c.activeCus.value = newCus;
         pr.update(message: "Customer is successfully added");
         Future.delayed(Duration(seconds: 1)).whenComplete(() => pr.hide().whenComplete(() => Get.back()));
       }else{
         pr.update(message: "Fail to add customer");
         Future.delayed(Duration(seconds: 1)).whenComplete(() => pr.hide());
       }
    });

  }
  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: azure,
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: royalblue,
          title: Text("Add New Customer"),
          centerTitle: false,
          actions: [
            GestureDetector(
              onTap: () {
                if (_formKey.currentState.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.

                  addNewCus(context);
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [Text("Save",style: whiteFont,), Icon(MdiIcons.checkboxMarkedCircle)],
                ),
              ),
            )
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            reverse: true,
            child: Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: bottom, left: 50, right: 50,top: 20),
                child: Form(
                    key: _formKey,
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          TextFormField(
                            controller: txt1,
                            focusNode: txt1Focus,
                            decoration: InputDecoration(
                                labelText: "Customer Name",
                                icon: Icon(MdiIcons.account)),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                            onFieldSubmitted: (value){
                              txt1Focus.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(txt2Focus);
                            },
                            textInputAction: TextInputAction.next,
                          ),
                          TextFormField(
                            controller: txt2,
                            focusNode: txt2Focus,
                            onFieldSubmitted: (value){
                              txt2Focus.unfocus();
                              FocusScope.of(context)
                                  .requestFocus(txt3Focus);
                            },
                            keyboardType: TextInputType.numberWithOptions(
                                signed: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  (RegExp("[.0-9]")))
                            ],
                            maxLength: 10,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                                labelText: "Telephone Number",
                                icon: Icon(MdiIcons.phone)),
                            validator: (value) {
                              RegExp regExp = new RegExp(r"(^[08|02|06][0-9]+\d{7,8}$)");
                              if (value.isEmpty) {
                                return 'Please enter some text';
                              }else if(!regExp.hasMatch(value)){
                                return "Telephone Number is not in right format";
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            minLines: 1,//Normal textInputField will be displayed
                            maxLines: null,
                            controller: txt3,
                            onFieldSubmitted: (value){
                              txt3Focus.unfocus();

                            },
                            focusNode: txt3Focus,
                            textInputAction: TextInputAction.done,
                            decoration: InputDecoration(
                                labelText: "Address",
                                icon: Icon(MdiIcons.home)),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter some text';
                              }
                              return null;
                            },
                          ),
                        ])),
              ),
            ),
          ),
        ));
  } //ef
} //ec
