class Product {
  String serialNumber;
  String category;
  String productName;
  double cost;
  double sellingPrice;
  var pics;
  String details;

  Product(
      {this.serialNumber,
        this.category,
        this.productName,
        this.cost,
        this.sellingPrice,
        this.pics,
        this.details});

  Product.fromJson(Map<String, dynamic> json) {
    serialNumber = json['Serial_Number'];
    category = json['Category'];
    productName = json['Product_Name'];
    cost = json['Cost'].toDouble();
    sellingPrice = json['Selling_Price'].toDouble();
    pics = json['pics'].toString();
    details = json['Details'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Serial_Number'] = this.serialNumber;
    data['Category'] = this.category;
    data['Product_Name'] = this.productName;
    data['Cost'] = this.cost;
    data['Selling_Price'] = this.sellingPrice;
    data['pics'] = this.pics;
    data['Details'] = this.details;
    return data;
  }
}

