import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Store/ClaimController.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Widget/OrderListCheckBox.dart';

class ClaimDetail_Form extends StatefulWidget {
  @override
  _ClaimDetail_FormState createState() => _ClaimDetail_FormState();
}

class _ClaimDetail_FormState extends State<ClaimDetail_Form> {
  final ClaimController cm = Get.find<ClaimController>();

  final OrderController o = Get.find<OrderController>();

  CustomerController c = Get.find<CustomerController>();

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  Future loadData;

  _fetchData() {
    return this._memoizer.runOnce(() async {
      return o.loadOrderFromDb().whenComplete(() => o.loadOrderDetailFromDb());
    });
  }

  @override
  Widget build(BuildContext context) {
    double h = MediaQuery.of(context).size.height;
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
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
        body: GetBuilder<OrderController>(
          init: OrderController(),

          builder: (o) {
            return FutureBuilder(
              future: _fetchData(),
              builder: (context, snapshot) {
                if(snapshot.hasData && o.cliamOrder!=null){
                  o.setClaimOrder(cm.activeClaim.receiptId);
                  String cusId =
                      o.cliamOrder.customerId;
                  return Center(
                    child: Container(
                      width: w*0.8 ,
                      height: h*0.7,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: lightskyblue
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                                backgroundColor: royalblue,
                                radius: 25,
                                child: Text(o
                                    .cliamOrder.orderId
                                    .toString())),
                            title: cusId != "null"
                                ? Text("Customer: " +
                                c
                                    .findCustomerByID(cusId)
                                    .customerName)
                                : Text("Customer: no data"),
                            subtitle: Text("Total Amount: " +
                                o.cliamOrder.totalAmount
                                    .toString() +
                                " Baht"),
                            trailing: Text(DateFormat(
                                "yyyy-MM-dd HH:mm:ss")
                                .format(
                                o.cliamOrder.orderDate)
                                .toString()),
                          ),
                          Divider(thickness: 3,),
                          Expanded(child: OrderListCheckBox(orderedProducts: o.claimOrderDetails))
                        ],
                      ),
                    ),
                  );
                }else if(o.cliamOrder.isNullOrBlank){
                  return Center(child: Text("Error"),);
                }
                else{
                  return Center(child: CircularProgressIndicator());
                }
              }
            );
          }
        ));
  } } //ec
