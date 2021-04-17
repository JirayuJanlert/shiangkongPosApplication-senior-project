import 'dart:convert';

import 'package:async/async.dart';
import 'package:get/get.dart';
import 'package:siangkong_mpos/Model/Customer.dart';
import 'package:http/http.dart' as http;

String url = 'http://13.250.64.212:1880';

class CustomerController extends GetxController {
  void onInit() {
    // called immediately after the widget is allocated memory
    loadCusFromDb();

    super.onInit();
  }

  final customers = List<Customer>().obs;

  List<Customer> _all_customers = [];

  final activeCus = Customer().obs;

  List<Customer> get all_customers => _all_customers;

  Future<String> insertNewCustomerIntoDb(Customer c) async {
    String res = "no";
    try {
      var data = json.encode(c.toJson());
      print(data);
      await http.post(url + '/insertnewcus', body: data, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      }).then((result) {
        print(result.body);
        res = result.body.toString();
      }).whenComplete(() => loadCusFromDb());
      return res;
    } catch (e) {
      print(e);
    }
  }

  void setSearchKey(String query) {
    List<Customer> searchRes = [];
    if (query != "") {
      searchRes = customers.value
          .where((element) =>
              element.customerName.contains(query) ||
              element.customerID.contains(query))
          .toList();
      customers.value = searchRes;
    } else {
      customers.value = _all_customers;
    }
    notifyChildrens();
  }

  selectCustomer(Customer c) {
    activeCus.value = c;
    update();
  }

  dismissCustomer() {
    activeCus.value = Customer();
    update();
  }

  Customer findCustomerByID(String id) {
    Customer c =
        _all_customers.firstWhere((element) => element.customerID == id);
    return c;
  }

  Future<List<Customer>> loadCusFromDb() async {
    List<Customer> loadedcus = [];
    var result = await http.get(url + "/loadcusdata");
    if (result.statusCode == 200) {
      print(result.body);
      var basket = json.decode(result.body) as List;
      var cusFromJson =
          basket.map((apple) => Customer.fromJson(apple)).toList();

      customers.value = cusFromJson;
      _all_customers = cusFromJson;
      loadedcus = cusFromJson;
      return loadedcus;
    } else {
      throw Exception('fail to load');
    }
  } //ef

}
