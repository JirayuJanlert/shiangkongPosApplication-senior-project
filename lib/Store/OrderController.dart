import 'dart:convert';

import 'package:async/async.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:intl/intl.dart';
import 'package:siangkong_mpos/Model/Backorder.dart';
import 'package:siangkong_mpos/Model/Order.dart';
import 'package:siangkong_mpos/Model/OrderDetails.dart';
import 'package:siangkong_mpos/Model/Product.dart';
import 'package:siangkong_mpos/Screen/HomePage.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:http/http.dart' as http;

class OrderController extends GetxController {

  String url = 'http://13.250.64.212:1880';
  Order _customer_order;
  List<Backorder> _bOrders = [];
  List<Backorder> get bOrders => _bOrders;
  List<Backorder> _bOrders2 = [];
  Order get customer_order => _customer_order;
  final MyStore agent = Get.find<MyStore>();
  final CustomerController _customerController = Get.find<CustomerController>();
  List<Order_details> _orderedProducts;
  
  Order _claimOrder = Order();
  Order get cliamOrder => _claimOrder;
  List<Order_details> _claimOrderDetails =[];
  List<Order_details> get claimOrderDetails => _claimOrderDetails;
  String _pId = "";

  Backorder _activeBackorder = new Backorder();

  Backorder get activeBackorder => _activeBackorder;

  bool _camState = true;
  List<Order> _hcustomerOrder =[];
  List<Order> _hcustomerOrder2 =[];
  List<Order> get hcustomerOrder => _hcustomerOrder;

  List<Order_details> _hcustomerOrderDetails =[];

  List<Order_details> get hcustomerOrderDetails => _hcustomerOrderDetails;
  bool get camState => _camState;

  String get pId => _pId;

  double change = 0;
  double discount = 0;

  List<Order_details> get orderedProducts => _orderedProducts;

  OrderController() {
    _orderedProducts = [];
    _customer_order = new Order();

    notifyChildrens();
  }
  
  void setClaimOrder(int rId) {
    try{
      _claimOrder = new Order();
      _claimOrder = _hcustomerOrder2.firstWhere((element) => element.receipt_id == rId, orElse: null);
      _claimOrderDetails.clear();
      _claimOrderDetails = _hcustomerOrderDetails.where((element) => element.orderId == _claimOrder.orderId).toList();
    }catch(e){
      print(e);
    }

    update();
  }

  void setActiveBackorder(Backorder b){
    _activeBackorder = b;
    update();
  }

  void setCustomerOrder(Order o){
    _customer_order = o;
    update();
  }
  
  void fillBackorder(Backorder b, BuildContext context){
    Product p = findProductById(b.serialNumber);
      addProductToBasket(p, b.backorderQty);
      _customerController.selectCustomer(_customerController.findCustomerByID(b.customerId));

      agent.cutStock(b.serialNumber, b.backorderQty);
      Get.offAll(() => HomePage());

  }

  Future<String> updateBackorderStatus() async {
    try {
      var data = json.encode(_activeBackorder.toJson());
      print(data);
      await http.post(url + '/updatebackorder', body: data, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      }).then((result) {
        return result.body;
      });


    } catch (e) {
      print(e);
    }

  } //ef

  Future<Product> scan(context) async {
    print("scan");
    try {
      String barcode = await BarcodeScanner.scan();
      _pId = barcode;
      Product addedP = findProductById(pId);
      return addedP;
      update();
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.CameraAccessDenied) {
        // The user did not grant the camera permission.
      } else {
        // Unknown error.
      }
    } on FormatException {
      // User returned using the "back"-button before scanning anything.
    } catch (e) {
      // Unknown error.
    }
  }

  Future<int> insertOrdertableDb(Order insertedOrder) async {
    try {
      var data = json.encode(insertedOrder.toJson());
      int orderID = 0;
      print(data);
      await http.post(url + '/insertorder', body: data, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      }).then((result) {
        customer_order.orderId = int.parse(result.body);
        orderID = int.parse(result.body);
      });
      return orderID;

    } catch (e) {
      print(e);
    }

  } //ef

  Future<String> insertBackordertableDb(Backorder backorder) async {
    String res = "";
    try {
      var data = json.encode(backorder.toJson());
      print(data);
      await http.post(url + '/insertbackorder', body: data, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      }).then((result) {
        if(result.statusCode ==200){
          print(result.body);
          res = result.body;
        }
      });
      return res;

    } catch (e) {
      print(e);
    }

  } //ef


  Future<List<Order>> loadOrderFromDb() async {

    List<Order> loadedOrder = [];
    var result = await http.get(url + "/loadorders");
    if (result.statusCode == 200) {
      var basket = json.decode(result.body) as List;
      var orderFromJson = basket.map((apple) => Order.fromJson(apple)).toList();

      _hcustomerOrder = orderFromJson;
      _hcustomerOrder2 = orderFromJson;
      loadedOrder = orderFromJson;
      update();
      return loadedOrder;
    } else {
      throw Exception('fail to load');
    }
  } //ef

  Future<List<Backorder>> loadBackOrderFromDb() async {

    List<Backorder> loadedOrder = [];
    var result = await http.get(url + "/loadbackorder");
    if (result.statusCode == 200) {
      print(result.body);
      var basket = json.decode(result.body) as List;
      var orderFromJson = basket.map((apple) => Backorder.fromJson(apple)).toList();

      _bOrders = orderFromJson;
      _bOrders2 = orderFromJson;
      loadedOrder = orderFromJson;
      update();
      return loadedOrder;
    } else {
      throw Exception('fail to load');
    }
  } //ef

  void setSearchKey(String query) {
    print(query);
    List<Order> searchRes = [];
    if (query != "") {
      searchRes = _hcustomerOrder2
          .where((element) => element.customerId.toLowerCase().contains(query) || element.orderId.toString().contains(query)
      )
          .toList();
     
      _hcustomerOrder = searchRes;
      update();
    } else {
      _hcustomerOrder = _hcustomerOrder2;
      update();
    }
    notifyChildrens();

  }
  void setSearchKey2(String query) {
    print(query);
    List<Backorder> searchRes = [];
    if (query != "") {
      searchRes = _bOrders2
          .where((element) => element.customerId.toLowerCase().contains(query) || element.backorderId.toString().contains(query)
      )
          .toList();

      _bOrders = searchRes;
      update();
    } else {
      _bOrders = _bOrders2
      ;
      update();
    }
    notifyChildrens();

  }
  Future<List<Order_details>> loadOrderDetailFromDb() async {
    List<Order_details> loadedOrder = [];
    var result = await http.get(url + "/loadorderdetail");
    if (result.statusCode == 200) {
      // print(result.body);
      var basket = json.decode(result.body) as List;
      var orderFromJson = basket.map((apple) => Order_details.fromJson(apple)).toList();

      _hcustomerOrderDetails = orderFromJson;
      loadedOrder = orderFromJson;
      return loadedOrder;
    } else {
      throw Exception('fail to load');
    }
  } //ef

List<Order_details> findOrderLineByID(int id){
  return _hcustomerOrderDetails.where((element) => element.orderId == id).toList();
}
  Future<String> insertOrderInfotableDb(int order_id) async {
    _orderedProducts.forEach((element) async {
      element.orderId = order_id;
    });

    var data = jsonEncode(_orderedProducts);
      String res = "no";
    await http.post(url + '/insertorderdetail', body: data, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    }).then((result) {
      if (result.statusCode != 200) {
        throw Exception("fail to insert");
      } else {
        res = result.body;
      }
    });

    return res;
  } //ef

  String getDate(DateTime datetime) {
    String _date = "";
    final df = new DateFormat('dd MMM yyyy');

    _date = df.format(datetime).toString();

    return _date;
  } //ef

  void removeOneFromBasket(Product p) {
    //check if the product is the the basket
    Order_details found = _orderedProducts.firstWhere(
        (item) => item.serialNumber == p.serialNumber,
        orElse: () => null);
    //if there just update qty
    if (found != null && found.qty == 1) {
      _orderedProducts
          .removeWhere((element) => element.serialNumber == p.serialNumber);
    } else {
      found.qty -= 1;
      found.lineTotal -= p.sellingPrice;
    }
    update();
  } //ef

  void cancleOrder() {
    _customerController.dismissCustomer();
    _customer_order = new Order();
    if(_orderedProducts.length>0){
      _orderedProducts.clear();
    }
    _activeBackorder = new Backorder();

  }

  double calculateOrderSubTotal() {
    return calculateTotalAmount() - calculateVat();
  }

  double calculateTotalAmount() {
    double total = 0;
    _orderedProducts.forEach((element) {
      total += element.lineTotal;
    });
    return total;
  }

  void filterBorders(String option){
  print(option);
    if(option =='[1]'){
      _bOrders = _bOrders2.where((element) => element.backorderStatus == "filled").toList();
    }else if(option=='[2]'){
      _bOrders = _bOrders2.where((element) => element.backorderStatus == "unfilled").toList();
    }else if(option == '[3]'){
      _bOrders = _bOrders2.where((element) => element.backorderStatus == "unfilled" && element.backorderQty<=agent.findStockQtyByProductID(element.serialNumber)).toList();
    }else{
      _bOrders = _bOrders2;
    }
    update();
  }

  int countTotalQty() {
    int total = 0;
    _orderedProducts.forEach((element) {
      total += element.qty;
    });
    return total;
  }

  double calculateVat() {
    double total = calculateTotalAmount();
    double vat = total * 0.07;

    return vat.roundToDouble();
  }

  double calculateGrandTotal() {
    double subtotal = calculateOrderSubTotal();
    double vat = calculateVat();

    return subtotal + vat;
  }
  void reorder(Order o, List<Order_details> ods,BuildContext context){
    cancleOrder();
    bool alert = false;
    if(o.customerId != "null"){
      _customerController.activeCus.value = _customerController.findCustomerByID(o.customerId);
    }

    ods.forEach((element) {
      int qty = agent.findStockQtyByProductID(element.serialNumber);
      if(qty >= element.qty){
        addProductToBasket(findProductById(element.serialNumber), element.qty);
        agent.cutStock(element.serialNumber, element.qty);
      }else{
        alert = true;
      }

    });

    if(alert){
      AlertDialog alert = AlertDialog(
        title: Text("Notice"),
        content: Text("Some items are out of stock."),
        actions: [
          RaisedButton(
              child: Text("okay"),
              onPressed: () {
                Navigator.of(context).pop();
                Get.offAll(() =>
                    HomePage());
              })
        ],
      );

      // show the dialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return alert;
        },
      ); //end show dialog
    }else{
      Get.offAll(() =>
          HomePage());
    }

    update();
  }

  void refreshOrderHistory(){
    _hcustomerOrder = _hcustomerOrder2;
    update();
  }

void sortByAscending(){
    _hcustomerOrder.sort((a,b)=> a.orderDate.compareTo(b.orderDate));
    update();
  }

  void sortByDescending(){
    _hcustomerOrder.sort((b,a)=> a.orderDate.compareTo(b.orderDate));
    update();
  }

  void sortByAscending2(){
    _bOrders.sort((a,b)=> a.orderDate.compareTo(b.orderDate));
    update();
  }

  void sortByDescending2(){
    _bOrders.sort((b,a)=> a.orderDate.compareTo(b.orderDate));
    update();
  }
  void selectMonthOrder(DateTime dt){
    _hcustomerOrder = _hcustomerOrder2.where((element) => element.orderDate.year == dt.year && element.orderDate.month == dt.month).toList();
    update();
  }

  void deleteOrderLine(Product p) {
    _orderedProducts
        .removeWhere((element) => element.serialNumber == p.serialNumber);
    update();
  }

  Product findProductById(String id) {
    Product foundedProduct =
        agent.allproducts.firstWhere((element) => element.serialNumber == id);
    return foundedProduct;
  }



  void calulateChange(double total, double receive) {
    change = receive - total;

    update();
  }
  void calulateDiscount(double charge) {
    discount = _customer_order.totalAmount -charge;

    update();
  }
  void addProductToBasket(Product p, int num) {
    Order_details found = _orderedProducts.firstWhere(
        (item) => item.serialNumber == p.serialNumber,
        orElse: () => null);

    if (found != null) {
      _orderedProducts.forEach((element) {
        if (element.serialNumber == p.serialNumber) {
          element.qty += num;
          element.lineTotal += p.sellingPrice;
          print(element);
        }
      });
    } else {
      Order_details addedOrderDetails = Order_details(
          orderId: null,
          serialNumber: p.serialNumber,
          orderLineId: null,
          qty: num,
          lineTotal: p.sellingPrice);
      _orderedProducts.add(addedOrderDetails);
      print(addedOrderDetails);
    }
    update();
  }
}
