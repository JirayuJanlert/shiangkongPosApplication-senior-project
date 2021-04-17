import 'dart:convert';
import 'dart:typed_data';

import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/Product.dart';
import 'package:http/http.dart' as http;
import 'package:siangkong_mpos/Model/Stock.dart';
import 'package:siangkong_mpos/Screen/HomePage.dart';

class MyStore extends GetxController {
  String url = 'http://13.250.64.212:1880';

  List<Product> _products = [];
  List<String> _categories = [];
  var categoriesSet = <String>{};
  Product  _activeStock;
  Product get activeStock => _activeStock;
  List<Product> get products => _products;
  List<Product> _allproducts = [];
  List<Product> _stockProducts = [];
  List<Product> get stockProducts => _stockProducts;
  List<Product> get allproducts => _allproducts;

  List<String> get categories => _categories;
  List<Stock> _stocks = [];

  List<Stock> get stocks => _stocks;

  //Detail Page
  Product _activeProduct;

  Product get activeProduct => _activeProduct;


  MyStore() {
    _products = [];
    _categories = [];
    _allproducts = [];

    notifyChildrens();
  }

  Future<List<String>> loadCategory() async {
    List<String> loadingCat = [];
    categoriesSet.add("ทั้งหมด");
    _allproducts.forEach((element) {
      categoriesSet.add(element.category);
    });

    _categories = categoriesSet.toList();
    loadingCat = categoriesSet.toList();
    update();
    return loadingCat;
  }

  Widget getImage(String pic) {

    try{
      if (pic.length > 200) {
        pic = pic.replaceAll(' ', '');
        // pic = base64.normalize(pic);
        // Uint8List  res = base64Decode(pic);
        Uint8List res = Base64Codec().decode(pic);
        return Image.memory(
          res,
          fit: BoxFit.fitHeight,
        );
      } else {
        return FadeInImage.assetNetwork(
            fit: BoxFit.cover, placeholder: "assets/loading.gif", image: pic);
      }
    }catch(e){
      print(e);
      // print(pic);
    }

  }

  void setActiveProduct(Product p) {
    _activeProduct = p;
    update();
  }

  void showCategory(String cat) {
    _products = _allproducts;
    List<Product> filter_product = [];
    if (cat == "ทั้งหมด") {
      _products = _products;
    } else {
      filter_product.addAll(
          _allproducts.where((element) => element.category == cat).toList());
      _products = filter_product;
    }
    notifyChildrens();
  }



  Future<void> addStocktoserver(Stock addedS) async {
    try {
      var data = json.encode(addedS.toJson());
      await http.post(url + "/insertstock",
          body: data,
          headers: {"Content-Type": "application/json"}).then((res) {
        print(res.body);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateStock() async {
    try {
      var data = jsonEncode(stocks);

      await http.post(url + "/updatestock",
          body: data,
          headers: {"Content-Type": "application/json"}).then((res) {
        print(res);
      });
    } catch (e) {
      print(e);
    }
  }

  Future<String> updateStock2() async {
    try {
      Stock _s = _stocks.firstWhere((element) => element.serialNumber == _activeStock.serialNumber);
      var data =  json.encode(_s.toJson());
      String result = "";
      await http.post(url + "/updatestock2",
          body: data,
          headers: {"Content-Type": "application/json"}).then((res) {
            print(res.body);
            result = res.body;
      });
      update();
      return result;
    } catch (e) {
      print(e);
    }
  }

  Future<void> updateProduct(Product p, Stock s, BuildContext context) async {
    print("starting");
    final ProgressDialog pr = new ProgressDialog(context);
    pr.style(
      message: 'Completing ',
      progressWidget: SpinKitRotatingCircle(
        color: hotpink,
      ),
      elevation: 10.0,
    );
    await pr.show();


    var data = json.encode(p.toJson());

    var body = {
      'product': p.toJson(),
      'qty': s.qty
    };
    await http.post(url + "/updateproduct",
        body: jsonEncode(body),
        headers: {"Content-Type": "application/json"}).then((value) {

      if (value.statusCode == 200) {
        if (value.body == "yes") {
          pr.update(message: "Product is successfully updated");

          Future.delayed(Duration(seconds: 1)).then((value) async {
            loadPartsFromDb();
            loadStockFromDb();
            _activeProduct = p;
          }).whenComplete(() {

            pr.hide().whenComplete(() {
              Get.back();
              update();
            });
          });
        } else {
          pr.update(message: "Fail to update product");
          Future.delayed(Duration(seconds: 1))
              .then((value) async {})
              .whenComplete(() => pr.hide());
        }
      } else {
        throw Exception("fail");
      }
    });
  }


  void addProductToServer(context, Product addedP, Stock addedS) async {
    final ProgressDialog pr = new ProgressDialog(context);
    pr.style(
      message: 'Completing ',
      progressWidget: SpinKitRotatingCircle(
        color: hotpink,
      ),
      elevation: 10.0,
    );
    await pr.show();
    var data = json.encode(addedP.toJson());

    await http.post(url + "/insertproduct",
        body: data,
        headers: {"Content-Type": "application/json"}).then((value) async {
      // print(res2);
      if (value.statusCode == 200) {
        // String jsonsDataString = value.body.toString(); // toString of Response's body is assigned to jsonDataString
        // var _data = jsonDecode(jsonsDataString);
        // print(_data.toString());
        await addStocktoserver(addedS).then((res2) => {
              Future.delayed(Duration(seconds: 2))
                  .then((val) async {})
                  .whenComplete(() async {
                // print("check" + res2);
                if (value.body == "yes") {
                  pr.update(message: "Product is successfully added");
                  Future.delayed(Duration(seconds: 5)).then((value) async {
                  }).whenComplete(() {
                    loadPartsFromDb().whenComplete((){
                      pr.hide().whenComplete(() {
                        Get.offAll(HomePage());
                        update();
                      });
                    });

                  });
                } else {
                  pr.update(message: "Fail to add new product");
                  Future.delayed(Duration(seconds: 1))
                      .then((value) async {})
                      .whenComplete(() => pr.hide());
                }
              })
            });
      } else {
        pr.update(message: "Fail");
        pr.hide();
        throw Exception("fail");
      }
    });
  }
void setActiveStock(Product p){
    _activeStock = p;
    update();
}

  void filterStock(String option){
    print(option);
    if(option =='[1]'){
      _stockProducts = _allproducts.where((element) => findStockQtyByProductID(element.serialNumber) == 0).toList();
    }else if(option=='[2]'){
      _stockProducts = _allproducts.where((element) => findStockQtyByProductID(element.serialNumber)>0).toList();
    }else{
      _stockProducts = _allproducts;
    }
    update();
  }

  Future<List<Product>> loadPartsFromDb() async {
    List<Product> loadedproduct = [];
    var result = await http.get(url + "/loadpartsdata");
    if (result.statusCode == 200) {
      print(result.body);
      var basket = json.decode(result.body) as List;
      var productFromJson =
          basket.map((apple) => Product.fromJson(apple)).toList();

      _products = productFromJson;
      _allproducts = productFromJson;
      _stockProducts = productFromJson;
      loadedproduct = productFromJson;
      return loadedproduct;
    } else {
      throw Exception('fail to load');
    }
  } //ef

  Future<List<Stock>> loadStockFromDb() async {
    List<Stock> loadedStock = [];
    var result = await http.get(url + "/loadstock");
    if (result.statusCode == 200) {
      print(result.body);
      var basket = json.decode(result.body) as List;
      var stockFromJson = basket.map((apple) => Stock.fromJson(apple)).toList();

      _stocks = stockFromJson;
      loadedStock = stockFromJson;
      update();
      return loadedStock;
    } else {
      throw Exception('fail to load');
    }

  } //ef




  Future<String> deleteProduct(BuildContext context)async{
    final ProgressDialog pr = new ProgressDialog(context);
    pr.style(
      message: 'Completing ',
      progressWidget: SpinKitRotatingCircle(
        color: hotpink,
      ),
      elevation: 10.0,
    );
    await pr.show();
    Map<String, String> body = {
      'serial_number': activeProduct.serialNumber,
    };

    await http.post(url + "/deleteproduct",body: body).then((value) async {
      print(value);
      if(value.statusCode ==200){
        if (value.body == "yes") {
          pr.update(message: "Product is deleted!");

          Future.delayed(Duration(seconds: 5)).whenComplete(() {
            loadPartsFromDb().whenComplete((){
              pr.hide().whenComplete(() {
                Get.offAll(()=>HomePage());
                update();
              });
            });

          });
        } else {
          pr.update(message: "Fail to delete product");
          Future.delayed(Duration(seconds: 1))
              .then((value) async {})
              .whenComplete(() => pr.hide());
        }
      }else{
        throw Exception("fail");
      }
    });
  }
  int findStockQtyByProductID(String pId) {
    Stock foundedStock =
        _stocks.firstWhere((element) => element.serialNumber == pId);
    return foundedStock.qty;
  }

  void cutStock(String pId, int num) {
    Stock foundedStock =
        _stocks.firstWhere((element) => element.serialNumber == pId);
    foundedStock.qty -= num;

    update();
  }

  void addBackStock(String pId, int num) {
    Stock foundedStock =
        _stocks.firstWhere((element) => element.serialNumber == pId);
    foundedStock.qty += num;

    update();
  }

  void setSearchKey(String query, int selectedCate) {
    List<Product> searchRes = [];
    if (query != "") {
      searchRes = _allproducts
          .where((element) => element.productName.contains(query))
          .toList();
      _products = searchRes;
    } else {
      showCategory(_categories[selectedCate]);
    }
    notifyChildrens();
  }



  void setSearchKey2(String query) {
    List<Product> searchRes = [];
    if (query != "") {
      searchRes = _allproducts
          .where((element) => element.productName.contains(query))
          .toList();
      _stockProducts = searchRes;
    } else {
      _stockProducts = _allproducts;
      showCategory2("ทั้งหมด");
    }
    notifyChildrens();
  }


  void showCategory2(String cat) {
    _stockProducts = _allproducts;
    List<Product> filter_product = [];
    if (cat == "ทั้งหมด") {
      _products = _products;
    } else {
      filter_product.addAll(
          _allproducts.where((element) => element.category == cat).toList());
      _stockProducts = filter_product;
    }
    notifyChildrens();
  }
} //ec
