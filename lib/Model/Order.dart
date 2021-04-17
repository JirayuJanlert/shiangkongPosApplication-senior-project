import 'package:intl/intl.dart';

class Order {
  int orderId;
  DateTime orderDate;
  double totalAmount;
  String customerId;
  String orderStatus;
  int receipt_id;

  Order(
      {this.orderId,
        this.orderDate,
        this.totalAmount,
        this.customerId,
        this.orderStatus,
        this.receipt_id
       });

  Order.fromJson(Map<String, dynamic> json) {
    orderId = json['Order_Id'];
    orderDate = DateTime.parse(json['Order_date'].toString());
    totalAmount = json['Total_Amount'].toDouble();
    customerId = json['Customer_id'];
    orderStatus = json['Order_status'];
    receipt_id = json['receipt_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Order_Id'] = this.orderId;
    data['Order_date'] = DateFormat("yyyy-MM-dd HH:mm:ss").format(this.orderDate);
    data['Total_Amount'] = this.totalAmount;
    data['Customer_id'] = this.customerId;
    data['Order_status'] = this.orderStatus;
    data['receipt_id'] = this.receipt_id;
    return data;
  }
}

