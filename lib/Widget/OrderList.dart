import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/OrderDetails.dart';
import 'package:siangkong_mpos/Model/Product.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';

class OrderList extends StatelessWidget {
  final List<Order_details> orderedProducts;
  final TextStyle style1;
  final TextStyle style2;
  const OrderList ({
    Key key,
    this.style1,
    this.style2,
    @required this.orderedProducts,

  }) : super(key: key);


  @override
  Widget build(BuildContext context) {
    var formatter = NumberFormat("#,##0.00", "en_US");
    MyStore agent = Get.find<MyStore>();
    return GetBuilder<OrderController>(
          init: OrderController(),
          builder: (oc) {
            return Scrollbar(
              child: ListView.builder(
                  itemCount: orderedProducts.length,
                  itemBuilder: (context, i) {
                    Product p =
                    oc.findProductById(orderedProducts[i].serialNumber);
                    return ListTile(
                      leading: ClipRRect(
                          borderRadius: BorderRadius.circular(300.0),
                          child: SizedBox(
                              width: 60,
                              height: 60,
                              child: agent.getImage(p.pics))),
                      subtitle: Text("X" + orderedProducts[i].qty.toString(),style: style1,),
                      title: Text(
                        p.productName,
                        overflow: TextOverflow.ellipsis,
                        style: style2,
                      ),
                      trailing: Text(
                       formatter.format( orderedProducts[i].lineTotal) + " Baht",
                        style: style2,
                      ),
                    );
                  }),
            );
          });

  } //ef
} //ec
