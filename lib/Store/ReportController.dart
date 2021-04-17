import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:siangkong_mpos/Model/Customer.dart';
import 'package:siangkong_mpos/Model/Order.dart';
import 'package:siangkong_mpos/Model/OrderDetails.dart';
import 'package:siangkong_mpos/Model/Product.dart';
import 'package:siangkong_mpos/Model/Receipt.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/Store/ReceiptController.dart';

class ReportController extends GetxController {
  final MyStore agent = Get.find<MyStore>();
  final CustomerController _customerController = Get.put(CustomerController());
  final ReceiptController _receiptController = Get.put(ReceiptController());
  final OrderController _orderController = Get.put(OrderController());

  double _netEarning = 0;

  double get netEarning => _netEarning;
  DateTime _dt;

  DateTime get dt => _dt;
  List<double> _daySales = [];
  List<int> _transactions = [];

  List<int> get transactions => _transactions;

  List<double> get daySales => _daySales;
  List<int> _allDate = [];

  List<int> get allDate => _allDate;
  List<Receipt> _mReceipts = [];

  List<CategorySale> _categorySale = [];

  List<CategorySale> get categorySale => _categorySale;

  List<CustomerSale> _customerSale = [];

  List<CustomerSale> get customerSale => _customerSale;

  List<Receipt> get mReceipt => _mReceipts;
  List<Order> _mOrder = [];
  List<Order_details> _mOrderDetail = [];
  int _daysInMonth;

  bool _topProduct = true;

  bool get topProduct => _topProduct;
  bool _topCustomer = true;

  bool get topCustomer => _topCustomer;

  int get daysInMonth => _daysInMonth;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _orderController
        .loadOrderDetailFromDb()
        .whenComplete(() => _orderController.loadOrderFromDb().whenComplete(() {
              _mOrder = _orderController.hcustomerOrder
                  .where((element) =>
                      element.orderDate.month == _dt.month &&
                      element.orderDate.year == _dt.year)
                  .toList();

              createTopProduct().whenComplete(() => update());
              setCategorySale().whenComplete(() => update());
            }));
    _receiptController.loadReceiptFromDb().whenComplete(() {
      calculateNetEarning();
      setReceipt();
      setBargraph();
    });
    _categorySale.clear();
    _dt = DateTime.now();
    _daysInMonth = DateTime(_dt.year, _dt.month + 1, 0).day;
    _daySales = List<double>.generate(_daysInMonth, (index) => 0);
    _transactions = List<int>.generate(_daysInMonth, (index) => 0);
    _allDate = List<int>.generate(_daysInMonth, (index) => index + 1);
  }

  void changeToLeast() {
    _topProduct = !_topProduct;
    update();
  }
  void changeToLeast2() {
    _topCustomer = !_topCustomer;
    update();
  }

  //top 10 selling product  report
  Future<List<ProductSale>> createTopProduct() async {
    List<ProductSale> _pds = [];
    ProductSale p;
    agent.products.forEach((a) {
      double total = 0;
      int units = 0;
      _orderController.hcustomerOrderDetails.forEach((b) {
        DateTime orderDate = _orderController.hcustomerOrder
            .firstWhere((element) => element.orderId == b.orderId)
            .orderDate;
        if (orderDate.month == _dt.month && orderDate.year == _dt.year) {
          if (b.serialNumber == a.serialNumber) {
            total += b.lineTotal;
            units += b.qty;
          }
        }
      });

      p = new ProductSale(a.serialNumber, total, units);
      _pds.add(p);
    });

    if (_netEarning == 0) {
      return [];
    } else {
      if (_topProduct) {
        _pds.sort((a, b) => b.unitSold.compareTo(a.unitSold));
        _pds = _pds.sublist(0,10);
      } else {
        _pds = _pds.where((element) => element.unitSold ==0).toList();
      }
      return _pds;
    }
  }

  Future<List<CustomerSale>> createTopCustomer() async {
    _customerSale.clear();
    setMonthlyOrderDetail();
    _customerController.all_customers.forEach((item) {
      double total = 0;
      int orders = 0;

      List<Order> cods = _mOrder.where((element) => element.customerId == item.customerID).toList();
     if(cods.isNotEmpty){
       total = cods.fold(0, (previousValue, element) => previousValue + element.totalAmount);
       orders = cods.length;

       _customerSale.add(new CustomerSale(customer: item, orders: orders,totalspending: total));

     }


    });

    if (_topCustomer) {
      _customerSale.sort((a, b) => b.totalspending.compareTo(a.totalspending));
    } else {
      _customerSale.sort((a, b) => a.totalspending.compareTo(b.totalspending));
    }
    update();
    if (_netEarning == 0) {
      return [];
    } else {
      return  _customerSale;
    }

  }
  void setMonthlyOrderDetail(){
    _mOrder.forEach((element) {
      List<Order_details> ods = _orderController.hcustomerOrderDetails
          .where((item) => item.orderId == element.orderId)
          .toList();
      ods.forEach((a) {
        _mOrderDetail.add(a);
      });
    });
  }
  Future<List<CategorySale>> setCategorySale() async {
    _mOrderDetail.clear();
    _categorySale.clear();
    setMonthlyOrderDetail();
    double monthlySubtotal =
        _mOrder.fold(0, (value, element) => value + element.totalAmount);
    agent.categories.forEach((element) {
      List<Order_details> catOrderdetail = _mOrderDetail
          .where((item) =>
              _orderController.findProductById(item.serialNumber).category ==
              element)
          .toList();

      double total = catOrderdetail.fold(
          0, (previousValue, element) => previousValue + element.lineTotal);

      _categorySale.add(new CategorySale(
          category_name: element,
          total: total,
          percentage: (total / monthlySubtotal) * 100));
    });
    _categorySale.removeWhere((element) => element.total == 0);
    print(_categorySale.length);
    _categorySale.sort((a, b) => b.total.compareTo(a.total));

    return _categorySale;
  }

  void cleanPieChart() {
    double monthlySubtotal =
        _mOrder.fold(0, (value, element) => value + element.totalAmount);
    List<CategorySale> cList = _categorySale.getRange(5, _categorySale.length).toList();
    double total = cList.fold(
        0, (previousValue, element) => previousValue + element.total);
    _categorySale = _categorySale.getRange(0, 5).toList();
    _categorySale.add(new CategorySale(
        category_name: "Other",
        percentage: total / monthlySubtotal * 100,
        total: total));

  }

  Future<List<double>> setBargraph() async {
    setReceipt();
    _daysInMonth = DateTime(_dt.year, _dt.month + 1, 0).day;
    _daySales = List<double>.generate(_daysInMonth, (index) => 0);
    _transactions = List<int>.generate(_daysInMonth, (index) => 0);
    _allDate = List<int>.generate(_daysInMonth, (index) => index + 1);
     for (var i = 0; i < _allDate.length; i++) {
       double total = 0;
       int transactions = 0;
       _mReceipts.forEach((element) {
         if (element.paymentDate.day == _allDate[i] &&
             element.paymentDate.month == _dt.month) {
           total += element.grandTotal;
           transactions += 1;
         }
       });
       _daySales[i] = total;
       _transactions[i] = transactions;
     }

    update();
    return _daySales;
  }

  void setDateTime(DateTime dt) {
    _dt = dt;
    _mOrder.clear();
    _mOrderDetail.clear();
    _mOrder = _orderController.hcustomerOrder
        .where((element) =>
            element.orderDate.month == _dt.month &&
            element.orderDate.year == _dt.year)
        .toList();

    setBargraph();
    update();
  }

  void setReceipt() {
    _mReceipts = _receiptController.receipts
        .where((element) =>
            element.paymentDate.year == _dt.year &&
            element.paymentDate.month == _dt.month)
        .toList();
  }

  void calculateNetEarning() {
    _netEarning = 0;
    _receiptController.receipts.forEach((element) {
      if (element.paymentDate.year == _dt.year &&
          element.paymentDate.month == _dt.month) {
        _netEarning += element.grandTotal;
      }
    });

    update();
  }
}

class ProductSale {
  String Serial_Number;
  double total_sale;
  int unitSold;

  ProductSale(this.Serial_Number, this.total_sale, this.unitSold);
}

class CategorySale {
  String category_name;
  double percentage;
  double total;

  CategorySale({this.category_name, this.percentage, this.total});
}
class CustomerSale {
  Customer customer;
  double totalspending;
  int orders;

  CustomerSale({this.customer, this.orders, this.totalspending});
}