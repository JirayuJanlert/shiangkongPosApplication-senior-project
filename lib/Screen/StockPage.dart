import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Screen/HomePage.dart';
import 'package:siangkong_mpos/Screen/RefilStock.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/Widget/SearchBar.dart';

class StockPage extends StatefulWidget {
  @override
  _StockPageState createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  int selectedIndex = 0;
  var selectedOption = "All";
  FocusNode searchNode = FocusNode();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  String options =
  '''
[
    "All",
    "Out of Stock Items",
    "Available Items"
]
    ''';

  showPicker(BuildContext context) {
    Picker picker = new Picker(
        adapter: PickerDataAdapter<String>(pickerdata: new JsonDecoder().convert(options)),
        changeToFirst: true,
        textAlign: TextAlign.left,
        columnPadding: const EdgeInsets.all(8.0),
        onConfirm: (Picker picker, List value) {
          print(value.toString());
          // print(picker.getSelectedValues());
          agent.filterStock(value.toString());

          // o.filterBorders(value.toString());
        }
    );
    picker.show(_scaffoldKey.currentState);
  }

  TextEditingController searchTxt = TextEditingController();
  final MyStore agent = Get.find<MyStore>();
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(
          leading: BackButton(
            color: Colors.white,
            onPressed: (){
              Get.off(HomePage());
            },
          ),
          backgroundColor: royalblue,
          centerTitle: false,
          title: Text("Stock Management",style: bigWhite,),
        ),
        backgroundColor: azure,
        body: Container(
          child: Column(
            children: [
              SizedBox(
                height: h * 0.09,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: w * 0.6,
                      padding: const EdgeInsets.all(15.0),
                      child: SearchBar(
                        searchNode: searchNode,
                        searchTxt: searchTxt,
                        label: "Search Products",
                        searchFunction: agent.setSearchKey2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: RaisedButton.icon(
                        icon: Icon(
                          MdiIcons.filter,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          showPicker(context);
                        },
                        label: Text(
                          'Filter Stock',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        color: royalblue,
                      ),
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey,thickness: 1,),
              Expanded(
                child: GetBuilder<MyStore>(
                  init: MyStore(),
                  builder: (_) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: w*0.75,
                            height: h,
                            child: buildStockListView(w, h)),
                        SizedBox(
                          width: w*0.2,
                            height: h,
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: buildCategoryList(agent,w,h),
                            ))
                      ],
                    );
                  }
                ),
              ),
            ],
          ),
        ));
  }
  ListView buildStockListView( double w, double h) {
    return ListView.builder(
        itemCount: agent.stockProducts.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          int qty =agent.findStockQtyByProductID(agent.stockProducts[index].serialNumber);
          return Card(
            shape: RoundedRectangleBorder(
              side: BorderSide(
                  color: qty>0? limegreen:color1, width: 3),
              borderRadius: BorderRadius.circular(15),
            ),
            child: InkWell(
              onTap: () {
                agent.setActiveStock(agent.stockProducts[index]);
                showCupertinoModalPopup(
                    context: context,
                    builder: (BuildContext ctx) {
                      return Container(
                        margin: EdgeInsets.only(
                            bottom: h * 0.4,
                            top: h * 0.1,
                            left: w * 0.15,
                            right: w * 0.15),
                        child: RefilStock(ctx)
                      );
                    });
              },
              child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: royalblue,
                    radius: 25,
                    child: agent.getImage(agent.products[index].pics)),
                title: Text(agent.stockProducts[index].productName),
                subtitle: Text(agent.stockProducts[index].category
                ),
                trailing: Text("Stock: "+ qty.toString() + " units",style: qty>0? success:danger,),
              ),
            ),
          );
        });
  }

  Widget buildCategoryList(MyStore agent, double w, double size) {
    return GetBuilder<MyStore>(
        init: MyStore(),
        builder: (controller) {
          return ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: agent.categories.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                  width: w * 0.2,
                  height: 80,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        agent.showCategory2(agent.categories[index]);
                      });
                    },
                    child: Card(
                      color: selectedIndex == index ? royalblue : Colors.white,
                      elevation: 5,
                      child: Center(
                        child: Text(
                          agent.categories[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 17,
                              color: index == selectedIndex
                                  ? Colors.white
                                  : Colors.black),
                        ),
                      ),
                    ),
                  ),
                );
              });
        });
  }
} //ec
