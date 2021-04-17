import 'package:intl/intl.dart';

class Receipt {
  int receiptId;
  int orderId;
  DateTime paymentDate;
  double vat;
  double discount;
  double grandTotal;
  double receive;
  double changes;

  Receipt(
      {this.receiptId,
        this.orderId,
        this.paymentDate,
        this.vat,
        this.discount,
        this.grandTotal,
        this.receive,
        this.changes});

  Receipt.fromJson(Map<String, dynamic> json) {
    receiptId = json['Receipt_id'];
    orderId = json['Order_id'];
    paymentDate = DateTime.parse(json['Payment_date'].toString());
    vat = json['VAT'].toDouble();
    discount = json['Discount'].toDouble();
    grandTotal = json['Grand_total'].toDouble();
    receive = json['receive'].toDouble();
    changes = json['changes'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Receipt_id'] = this.receiptId;
    data['Order_id'] = this.orderId;
    data['Payment_date'] = DateFormat("yyyy-MM-dd HH:mm:ss").format(this.paymentDate);
    data['VAT'] = this.vat;
    data['Discount'] = this.discount;
    data['Grand_total'] = this.grandTotal;
    data['receive'] = this.receive;
    data['changes'] = this.changes;
    return data;
  }
}

