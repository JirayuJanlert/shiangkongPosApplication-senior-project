import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:siangkong_mpos/Model/Product.dart';

import 'package:charset_converter/charset_converter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:image/image.dart';
import 'package:http/http.dart' as http;
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:siangkong_mpos/Model/Receipt.dart';
import 'package:siangkong_mpos/Store/CustomerController.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';

class ReceiptController extends GetxController {
  Uint8List encoded;
  final OrderController oc = Get.find<OrderController>();
  final CustomerController c = Get.find<CustomerController>();
  String url = 'http://13.250.64.212:1880';
  List<Receipt> _receipts = [];
  var formatters = NumberFormat("#,##0.00", "en_US");
  List<Receipt> get receipts => _receipts;

 Receipt _receipt = new Receipt();
 Receipt get receipt => _receipt;

 void setReceipt( Receipt r){
   _receipt = r;
   update();
 }

  Future<List<Receipt>> loadReceiptFromDb() async {

try{
  List<Receipt> loaded = [];
  var result = await http.get(url + "/loadreceipt");
  if (result.statusCode == 200) {
    var basket = json.decode(result.body) as List;
    var receiptFromJson = basket.map((apple) => Receipt.fromJson(apple)).toList();
    print(result.body);
    _receipts = receiptFromJson;
    loaded = receiptFromJson;
    update();
    return loaded;
  } else {
    throw Exception('fail to load');
  }
}catch(e){
  print(e);
}
  } //ef

  Future<String> insertReceipttableDb() async {
    try {
      var data = json.encode(receipt.toJson());
      print(data);
      await http.post(url + '/insertreceipt', body: data, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      }).then((result) {
        print(result.body);
        return result.body;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<Ticket> demoReceipt(PaperSize paper, List<Uint8List> productNames) async {
    final Ticket ticket = Ticket(paper);

    // Print image
    final ByteData data = await rootBundle.load('assets/logo.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final  image = decodeImage(bytes);
    ticket.image(image);

    // ticket.text('Sor Siangkong',
    //     styles: PosStyles(
    //       align: PosAlign.center,
    //       height: PosTextSize.size2,
    //       width: PosTextSize.size2,
    //     ),
    //     linesAfter: 1);
    // 82/14 Maliwan Rd., Kudpong, Muang, Loei, Thailand 420
    ticket.text('82/14 Maliwan Rd', styles: PosStyles(align: PosAlign.center));
    ticket.text('Kudpong, Muang,' ,styles: PosStyles(align: PosAlign.center));
    ticket.text('Loei, Thailand 42000,' ,styles: PosStyles(align: PosAlign.center));
    ticket.text('Tel: 042-833-092', styles: PosStyles(align: PosAlign.center));
    ticket.text(' ', styles: PosStyles(align: PosAlign.center));
    ticket.row([

      PosColumn(
          text: "No.: " + (_receipts.length+1).toString().padLeft(6,"0"), width: 6, styles: PosStyles(align: PosAlign.left)),
      PosColumn(text: c.activeCus.value.customerID ==null?"Customer: -":"Customer: "+c.activeCus.value.customerID, width: 6, styles: PosStyles(align: PosAlign.right)),
    ]);

    ticket.hr();
    ticket.row([
      PosColumn(text: 'Qty', width: 1,),
      PosColumn(text: ' Item', width: 5,),
      PosColumn(
          text: '  Price', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: ' ', width: 2, styles: PosStyles(align: PosAlign.right)),
      PosColumn(
          text: 'Total', width: 2, styles: PosStyles(align: PosAlign.right)),
    ]);

    for(int i = 0; i < productNames.length; i++) {
      Product p = oc.findProductById(oc.orderedProducts[i].serialNumber);
      ticket.row([
        PosColumn(text: oc.orderedProducts[i].qty.toString(), width: 1,),

        PosColumn(textEncoded:productNames[i], width: 6,
            styles: PosStyles(codeTable: PosCodeTable.thai_1)),
        PosColumn(
            text: p.sellingPrice.toString() + " ",
            width: 2,
            styles: PosStyles(align: PosAlign.right)),

        PosColumn(
            text: oc.orderedProducts[i].lineTotal.toString(),
            width: 3,
            styles: PosStyles(align: PosAlign.right))]);
    }



    ticket.hr();
    encoded = await CharsetConverter.encode("TIS620", "฿"+formatters.format(oc.customer_order.totalAmount));
    ticket.row([
      PosColumn(
          text: 'SUBTOTAL',
          width: 6,
          styles: PosStyles(
            height: PosTextSize.size2,
            bold: true,
            width: PosTextSize.size1,
          )),

      PosColumn(
          textEncoded: encoded,
          width: 6,
          styles: PosStyles(
            codeTable: PosCodeTable.thai_1,
            align: PosAlign.right,
            bold: true,
            height: PosTextSize.size2,
            width: PosTextSize.size1,
          )),
    ]);

    ticket.hr(ch: '=', linesAfter: 1);
    ticket.row([
      PosColumn(
          text: 'Total (Before VAT)',
          width: 5,
          styles: PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
      PosColumn(
          text: (oc.customer_order.totalAmount-receipt.vat).toString(),
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
    ]);
    ticket.row([
      PosColumn(
          text: 'VAT 7%',
          width: 5,
          styles: PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
      PosColumn(
          text: receipt.vat.toString(),
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
    ]);
    ticket.row([
      PosColumn(
          text: 'Discount',
          width: 5,
          styles: PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
      PosColumn(
          text: "-" +receipt.discount.toString(),
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
    ]);
    ticket.hr();
    ticket.row([
      PosColumn(
          text: 'Total',
          width: 5,
          styles: PosStyles(align: PosAlign.left, width: PosTextSize.size2,bold: true)),
      PosColumn(
          text: formatters.format(receipt.grandTotal),
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size2,bold: true)),
    ]);
    ticket.row([
      PosColumn(
          text: 'Cash',
          width: 5,
          styles: PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
      PosColumn(
          text: receipt.receive.toString(),
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
    ]);
    ticket.row([
      PosColumn(
          text: 'Change',
          width: 5,
          styles: PosStyles(align: PosAlign.left, width: PosTextSize.size1)),
      PosColumn(
          text: receipt.changes.toString(),
          width: 7,
          styles: PosStyles(align: PosAlign.right, width: PosTextSize.size1)),
    ]);

    ticket.feed(2);
    ticket.text('Thank you!',
        styles: PosStyles(align: PosAlign.center, bold: true));

    final now = receipt.paymentDate;
    final formatter = DateFormat('yyyy-MM-dd HH:mm');
    final String timestamp = formatter.format(now);
    ticket.text(timestamp,
        styles: PosStyles(align: PosAlign.center), linesAfter: 2);
    ticket.hr();


    // Print QR Code from image
    // try {
    //   const String qrData = 'example.com';
    //   const double qrSize = 200;
    //   final uiImg = await QrPainter(
    //     data: qrData,
    //     version: QrVersions.auto,
    //     gapless: false,
    //   ).toImageData(qrSize);
    //   final dir = await getTemporaryDirectory();
    //   final pathName = '${dir.path}/qr_tmp.png';
    //   final qrFile = File(pathName);
    //   final imgFile = await qrFile.writeAsBytes(uiImg.buffer.asUint8List());
    //   final img = decodeImage(imgFile.readAsBytesSync());
    //
    //   ticket.image(img);
    // } catch (e) {
    //   print(e);
    // }

    // Print QR Code using native function
    // ticket.qrcode('example.com');

    ticket.feed(2);
    ticket.cut();
    return ticket;
  }


}