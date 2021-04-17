class Customer {
  String customerID;
  String customerName;
  String tel;
  String address;

  Customer({this.customerID, this.customerName, this.tel, this.address});

  Customer.fromJson(Map<String, dynamic> json) {
    customerID = json['Customer_ID'];
    customerName = json['Customer_Name'];
    tel = json['Tel'];
    address = json['Address'];
  }


  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Customer_ID'] = this.customerID;
    data['Customer_Name'] = this.customerName;
    data['Tel'] = this.tel;
    data['Address'] = this.address;
    return data;
  }
}

