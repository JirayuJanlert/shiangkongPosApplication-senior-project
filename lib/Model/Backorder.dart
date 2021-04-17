import 'package:intl/intl.dart';

class Backorder {
  int backorderId;
  String serialNumber;
  int backorderQty;
  String backorderStatus;
  DateTime orderDate;
  double totalAmount;
  String customerId;

  Backorder(
      {this.backorderId,
        this.serialNumber,
        this.backorderQty,
        this.backorderStatus,
        this.orderDate,
        this.totalAmount,
        this.customerId});

  Backorder.fromJson(Map<String, dynamic> json) {
    backorderId = json['backorder_id'];
    serialNumber = json['Serial_Number'];
    backorderQty = json['backorder_qty'];
    backorderStatus = json['backorder_status'];
    orderDate = DateTime.parse(json['order_date'].toString());
    totalAmount = json['total_amount'].toDouble();
    customerId = json['customer_id'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['backorder_id'] = this.backorderId;
    data['Serial_Number'] = this.serialNumber;
    data['backorder_qty'] = this.backorderQty;
    data['backorder_status'] = this.backorderStatus;
    data['order_date'] = DateFormat("yyyy-MM-dd HH:mm:ss").format(this.orderDate);
    data['total_amount'] = this.totalAmount;
    data['customer_id'] = this.customerId;
    return data;
  }
}

