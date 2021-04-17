import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/Product.dart';
import 'package:siangkong_mpos/Screen/CustomerSearch.dart';
import 'package:siangkong_mpos/Screen/HomePage.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/Store/ReportController.dart';
import 'package:siangkong_mpos/Widget/LineChart.dart';
import 'package:siangkong_mpos/Widget/PieChart.dart';
import 'package:siangkong_mpos/Widget/monthpicker/flutter_cupertino_date_picker.dart';

class ManagementReport extends StatefulWidget {
  @override
  _ManagementReportState createState() => _ManagementReportState();
}

class _ManagementReportState extends State<ManagementReport> {
  final ReportController manager = Get.put(ReportController());
  final OrderController oc = Get.put(OrderController());
  final MyStore agent = Get.find<MyStore>();
  var formatter = NumberFormat("#,##0.00", "en_US");
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    manager.setBargraph();
    manager.setCategorySale();
  }

  final AsyncMemoizer _memoizer = AsyncMemoizer();

  _fetchData() {
    return this._memoizer.runOnce(() async {
      return manager.setCategorySale();
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    return Scaffold(
        appBar: AppBar(
          leading: BackButton(
            color: Colors.white,
            onPressed: () {
              Get.off(HomePage());
            },
          ),
          backgroundColor: royalblue,
          centerTitle: false,
          actions: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: RaisedButton.icon(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                icon: Icon(
                  MdiIcons.calendar,
                  color: Colors.white,
                ),
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      initialDateTime: DateTime.now(),
                      onMonthChangeStartWithFirstDate: true,
                      maxDateTime: DateTime.now(), onConfirm: (dt, a) {
                    manager.setBargraph();
                    manager.setDateTime(dt);
                    manager.calculateNetEarning();
                    manager.setCategorySale();
                    setState(() {});
                  },
                      dateFormat: 'MMMM-yyyy',
                      minDateTime: DateTime(2021, 1, 1));
                },
                label: Text(
                  'Select month',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                color: hotpink,
              ),
            ),
          ],
          title: Text(
            "Dashboard",
            style: bigWhite,
          ),
        ),
        backgroundColor: azure,
        body: GetBuilder<ReportController>(
            init: ReportController(),
            builder: (controller) {
              return SingleChildScrollView(
                  child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: h * 0.1,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        MdiIcons.cash,
                                        color: limegreen,
                                        size: 30,
                                      ),
                                      Text(
                                        " Monthly Net Sales (" +
                                            DateFormat("MMMM")
                                                .format(controller.dt) +
                                            ")",
                                        style: h1,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    formatter.format(controller.netEarning)+ " THB",
                                    style: font2,
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        MdiIcons.numeric,
                                        color: hotpink,
                                        size: 30,
                                      ),
                                      Text(
                                        " Total Transactions (" +
                                            DateFormat("MMMM")
                                                .format(controller.dt) +
                                            ")",
                                        style: h5,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    controller.mReceipt.length.toString() +
                                        " transactions",
                                    style: font2,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      MediaQuery.of(context).orientation == Orientation.portrait
                          ? buildMReportPortrait(w, h)
                          : buildMReportLandScapeLayout(w, h)
                    ],
                  ),
                ),
              ));
            }));
  }

  Column buildMReportPortrait(double w, double h) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            child: FutureBuilder<List<double>>(
                future: manager.setBargraph(),
                initialData: manager.daySales,
                builder: (context, snapshot) {
                  if (snapshot.hasData ) {
                    return LineChartSample1();
                  } else {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                })),
        const SizedBox(
          height: 50,
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 50),
            child: SizedBox(
                width: w,
                height: h * 0.6,
                child: manager.categorySale.length == 0
                    ? Center(
                        child: Text("No data"),
                      )
                    : FutureBuilder(
                        future: _fetchData(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return PieChartCategory();
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        })),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              width: w * 0.45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        manager.topProduct
                            ? "Top Selling Products"
                            : "Least Selling Products",
                        style: manager.topProduct ? h3 : danger2,
                      ),
                      IconButton(
                          icon: Icon(MdiIcons.sort),
                          onPressed: () {
                            manager.changeToLeast();
                          })
                    ],
                  ),
                  ListTile(
                    leading: Text(
                      "ID",
                      style: h2,
                    ),
                    title: Text(
                      "Product Name",
                      style: h2,
                    ),
                    trailing: Text("Total", style: h2),
                  ),
                  SizedBox(
                    height: h * 0.5,
                    child: buildFutureListProductSale(),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: w * 0.45,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        manager.topCustomer
                            ? "Highest Customer Spending"
                            : "Lowest Customer Spending",
                        style: manager.topCustomer ? h3 : danger2,
                      ),
                      IconButton(
                          icon: Icon(MdiIcons.sort),
                          onPressed: () {
                            manager.changeToLeast2();
                          })
                    ],
                  ),
                  ListTile(
                    leading: Text(
                      "ID",
                      style: h2,
                    ),
                    title: Text(
                      "Product Name",
                      style: h2,
                    ),
                    trailing: Text("Total", style: h2),
                  ),
                  SizedBox(
                    height: h * 0.5,
                    child: buildFutureListCustomerSale(),
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  Widget buildMReportLandScapeLayout(double w, double h) {
    return Column(
      children: [
        SizedBox(
          height: h * 0.7,
          width: w,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                  width: w * 0.62,
                  child: FutureBuilder<List<double>>(
                      future: manager.setBargraph(),
                      initialData: manager.daySales,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return LineChartSample1();
                        } else {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      })),
              SizedBox(
                width: w * 0.35,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          manager.topProduct
                              ? "Top Selling Products"
                              : "Unsold Products",
                          style: manager.topProduct ? h3 : danger2,
                        ),
                        IconButton(
                            icon: Icon(MdiIcons.sort),
                            onPressed: () {
                              manager.changeToLeast();
                            })
                      ],
                    ),
                    ListTile(
                      leading: Text(
                        "ID",
                        style: h2,
                      ),
                      title: Text(
                        "Product Name",
                        style: h2,
                      ),
                      trailing: Text("Total", style: h2),
                    ),
                    Expanded(child: buildFutureListProductSale()),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 50,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
                width: w * 0.6,
                height: h * 0.6,
                child: manager.categorySale.length == 0
                    ? Center(
                        child: Text("No data"),
                      )
                    : FutureBuilder(
                        future: _fetchData(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return PieChartCategory();
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        })),
            SizedBox(
              width: w * 0.35,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        manager.topCustomer
                            ? "Highest Customer Spending"
                            : "Lowest Customer Spending",
                        style: manager.topCustomer ? h3 : danger2,
                      ),
                      IconButton(
                          icon: Icon(MdiIcons.sort),
                          onPressed: () {
                            manager.changeToLeast2();
                          })
                    ],
                  ),
                  ListTile(
                    leading: Text(
                      "ID",
                      style: h2,
                    ),
                    title: Text(
                      "Product Name",
                      style: h2,
                    ),
                    trailing: Text("Total", style: h2),
                  ),
                  SizedBox(
                    height: h * 0.5,
                    child: buildFutureListCustomerSale(),
                  ),
                ],
              ),
            )
          ],
        )
      ],
    );
  }

  FutureBuilder<List<ProductSale>> buildFutureListProductSale() {
    return FutureBuilder<List<ProductSale>>(
        future: manager.createTopProduct(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return Center(
                child: Text("No Record"),
              );
            } else {
              return Scrollbar(
                child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, i) {
                      Product p =
                          oc.findProductById(snapshot.data[i].Serial_Number);
                      return ListTile(
                        leading: Text(
                          p.serialNumber,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Unit Sold: " +
                            snapshot.data[i].unitSold.toString()),
                        title: Text(
                          p.productName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Text(
                         formatter.format( snapshot.data[i].total_sale) + " Baht",
                        ),
                      );
                    }),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  FutureBuilder<List<CustomerSale>> buildFutureListCustomerSale() {
    return FutureBuilder<List<CustomerSale>>(
        future: manager.createTopCustomer(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data.length == 0) {
              return Center(
                child: Text("No Record"),
              );
            } else {
              return Scrollbar(
                child: ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, i) {
                      return ListTile(
                        leading: Text(
                          snapshot.data[i].customer.customerID,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text("Transactions: " +
                            snapshot.data[i].orders.toString()),
                        title: Text(
                          snapshot.data[i].customer.customerName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14),
                        ),
                        trailing: Text(
                          formatter.format(snapshot.data[i].totalspending)+ " Baht",
                        ),
                      );
                    }),
              );
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }
} //ec
