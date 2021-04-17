class Order_details {
  int orderId;
  int orderLineId;
  String serialNumber;
  int qty;
  double lineTotal;

  Order_details(
      {this.orderId,
        this.orderLineId,
        this.serialNumber,
        this.qty,
        this.lineTotal});

  Order_details.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    orderLineId = json['order_line_id'];
    serialNumber = json['serial_number'];
    qty = json['qty'];
    lineTotal = json['line_total'].toDouble();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.orderId;
    data['order_line_id'] = this.orderLineId;
    data['serial_number'] = this.serialNumber;
    data['qty'] = this.qty;
    data['line_total'] = this.lineTotal;
    return data;
  }
}

