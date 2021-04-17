import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/Customer.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Widget/SearchBar.dart';

class CustomerSearch extends StatefulWidget {
  @override
  _CustomerSearchState createState() => _CustomerSearchState();
}

class _CustomerSearchState extends State<CustomerSearch> {
  FocusNode searchNode = FocusNode();

  TextEditingController searchTxt = TextEditingController();
  Future loadData;

  @override
  void initState() {
    // TODO: implement initState
    final CustomerController c = Get.put(CustomerController());
    loadData = c.loadCusFromDb();
    Future.delayed(const Duration(seconds: 2));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final CustomerController c = Get.find<CustomerController>();
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: azure,
        appBar: AppBar(
          centerTitle: false,
          backgroundColor: royalblue,
          title: Text("Search Customer"),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  SearchBar(searchFunction: c.setSearchKey,searchNode: searchNode, searchTxt: searchTxt,label: "Search Customer",),
                  Divider(thickness: 5, color: Colors.white,),
                  FutureBuilder<List<Customer>>(
                      future: loadData,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return GetX<CustomerController>(
                              init: CustomerController(),
                              builder: (value) {
                                return Expanded(
                                  child: ListView.builder(
                                      itemCount: value.customers.length,
                                      itemBuilder: (context, index) {
                                        return InkWell(
                                          onTap: () {
                                            value.selectCustomer(
                                                value.customers[index]);
                                            Get.back();
                                          },
                                          child: Card(
                                            child: ListTile(
                                              title: Text(value
                                                  .customers[index].customerName),
                                              leading: Text(value
                                                  .customers[index].customerID),
                                              trailing: Text(
                                                  value.customers[index].tel),
                                              subtitle: Text(
                                                  value.customers[index].address),
                                            ),
                                          ),
                                        );
                                      }),
                                );
                              });
                        } else {
                          return CircularProgressIndicator();
                        }
                      })
                ],
              ),
            ),
          ),
        ));
  }

} //ec
