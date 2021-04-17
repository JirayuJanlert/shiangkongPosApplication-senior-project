class Stock {
  int stockId;
  String serialNumber;
  int qty;

  Stock({this.stockId, this.serialNumber, this.qty});

  Stock.fromJson(Map<String, dynamic> json) {
    stockId = json['stock_id'];
    serialNumber = json['Serial_Number'];
    qty = json['qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['stock_id'] = this.stockId;
    data['Serial_Number'] = this.serialNumber;
    data['qty'] = this.qty;
    return data;
  }
}

