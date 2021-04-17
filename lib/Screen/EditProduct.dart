import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/Product.dart';
import 'package:siangkong_mpos/Model/Stock.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/Widget/dropdownfield.dart';

class EditProduct extends StatefulWidget {
  @override
  _EditProductState createState() => _EditProductState();
}

class _EditProductState extends State<EditProduct> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final MyStore agent = Get.find<MyStore>();
  TextEditingController txt1 = new TextEditingController();
  TextEditingController txt2 = new TextEditingController();
  TextEditingController txt3 = new TextEditingController();
  TextEditingController txt4 = new TextEditingController();
  TextEditingController txt5 = new TextEditingController();
  TextEditingController catController = new TextEditingController();
  TextEditingController qtyTxt = new TextEditingController();
  var formatters = NumberFormat("#,##0.00", "en_US");
  final FocusNode txt1Focus = FocusNode();
  final FocusNode txt2Focus = FocusNode();
  final FocusNode txt3Focus = FocusNode();
  final FocusNode txt4Focus = FocusNode();
  final FocusNode txt5Focus = FocusNode();
  final FocusNode qtyFocus = FocusNode();
  final FocusNode catFocus = FocusNode();

  Product p = new Product();
  String _selectedCat;

  File _imgFile;
  final _picker = ImagePicker();

  Future<void> selectImg(ImageSource imgSource) async {
    try {
      PickedFile myImg = await _picker.getImage(
          source: imgSource, maxHeight: 1080, maxWidth: 1080);
      // setState(() {
      //   _imgFile = File(myImg.path);
      // });
      _cropImage(myImg.path);
    } catch (e) {
      print(e);
    }
  }

  _cropImage(filePath) async {
    // print(filePath);
    try {
      File croppedImage = await ImageCropper.cropImage(
          sourcePath: filePath,
          cropStyle: CropStyle.rectangle,
          aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),
          maxWidth: 300,
          maxHeight: 300,
          androidUiSettings: AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.deepOrange,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          iosUiSettings: IOSUiSettings(
            minimumAspectRatio: 1.0,
          ));
      print(croppedImage);

      _imgFile = croppedImage;
      print(_imgFile);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    txt2.text = agent.activeProduct.productName;
    txt3.text = formatters.format(agent.activeProduct.cost);
    txt4.text = formatters.format(agent.activeProduct.sellingPrice);
    txt5.text = agent.activeProduct.details;
    catController.text = agent.activeProduct.category;
    qtyTxt.text = agent
        .findStockQtyByProductID(agent.activeProduct.serialNumber)
        .toString();
  }

  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery.of(context).viewInsets.bottom;
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    List<String> _categories = agent.categories;
    _selectedCat = agent.activeProduct.category;

    _categories.removeWhere((element) => element == "ทั้งหมด");
    return Scaffold(
        backgroundColor: azure,
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text("Edit Products"),
          centerTitle: false,
          actions: [
            GestureDetector(
              onTap: () {
                final snackBar = SnackBar(
                  backgroundColor: flowerblue,
                  content: Text(
                    'Please Choose Categories',
                    style: font2,
                  ),
                );
                final snackBar2 = SnackBar(
                  backgroundColor: flowerblue,
                  content: Text(
                    'Please Provide a Product Picture',
                    style: font2,
                  ),
                );

                if (_formKey.currentState.validate()) {
                  if (catController.text.isEmpty) {
                    _scaffoldKey.currentState.showSnackBar(snackBar);
                  } else {
                    String img;
                    if (_imgFile == null) {
                      img = agent.activeProduct.pics;
                    } else {
                      List<int> imageBytes = _imgFile.readAsBytesSync();
                      String baseimage = base64Encode(imageBytes);
                      img = baseimage;
                    }

                    p = Product(
                        serialNumber: txt1.text,
                        productName: txt2.text,
                        category: catController.text,
                        sellingPrice: double.parse(txt4.text),
                        cost: double.parse(txt3.text),
                        pics: img,
                        details: txt5.text);

                    Stock s = Stock(
                        stockId: null,
                        serialNumber: txt1.text,
                        qty: int.parse(qtyTxt.text));
                    agent.updateProduct(p, s, context);
                  }
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Text(
                      "Save",
                      style: whiteFont,
                    ),
                    Icon(MdiIcons.checkboxMarkedCircle)
                  ],
                ),
              ),
            )
          ],
        ),
        body: GestureDetector(
          onTap: () {
            FocusScopeNode currentFocus = FocusScope.of(context);

            if (!currentFocus.hasPrimaryFocus) {
              currentFocus.unfocus();
            }
          },
          child: SingleChildScrollView(
            child: Center(
              child: Container(
                color: azure,
                padding: EdgeInsets.only(
                    bottom: bottom + 30, left: 50, right: 50, top: 50),
                child: Form(
                    key: _formKey,
                    child: Container(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            TextFormField(
                              enabled: false,
                              controller: txt1
                                ..text = agent.activeProduct.serialNumber,
                              focusNode: txt1Focus,
                              onFieldSubmitted: (term) {
                                txt1Focus.unfocus();
                                FocusScope.of(context).requestFocus(txt2Focus);
                              },
                              // initialValue: agent.activeProduct.serialNumber,
                              decoration: InputDecoration(
                                labelText: "Serial Number",
                                // icon: Icon(MdiIcons.product)
                              ),
                              textInputAction: TextInputAction.next,
                            ),
                            TextFormField(
                              controller: txt2,
                              focusNode: txt2Focus,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: "Product Name",
                                // icon: Icon(MdiIcons.product)
                              ),
                              onFieldSubmitted: (term) {
                                txt2Focus.unfocus();
                                FocusScope.of(context).requestFocus(catFocus);
                              },
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            DropDownField(
                              focusNode: catFocus,
                              textInputAction: TextInputAction.next,
                              controller: catController,
                              items: agent.categories,

                              itemsVisibleInDropdown: 3,
                              // required: true,

                              strict: false,
                              setter: (dynamic newValue) {
                                _selectedCat = newValue;
                              },
                              value: _selectedCat,
                              labelText: 'Category',
                              hintText: 'Choose or Type Category',
                              onSubmitted: (value) {
                                catFocus.unfocus();
                                FocusScope.of(context).requestFocus(txt3Focus);
                              },
                              onValueChanged: (value) {
                                setState(() {
                                  _selectedCat = value;
                                });
                              },
                            ),
                            TextFormField(
                              controller: txt3,
                              textInputAction: TextInputAction.next,
                              focusNode: txt3Focus,
                              onFieldSubmitted: (value) {
                                txt3Focus.unfocus();
                                FocusScope.of(context).requestFocus(txt4Focus);
                              },
                              decoration: InputDecoration(
                                labelText: "Cost",

                                // icon: Icon(MdiIcons.currencyBdt)
                              ),
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    (RegExp("[.0-9]")))
                              ],
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some number';
                                } else if (double.parse(value) >
                                    double.parse(txt4.text)) {
                                  return "Cost should be lower than price";
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: txt4,
                              textInputAction: TextInputAction.next,
                              focusNode: txt4Focus,
                              onFieldSubmitted: (value) {
                                txt4Focus.unfocus();
                                FocusScope.of(context).requestFocus(qtyFocus);
                              },
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    (RegExp("[.0-9]")))
                              ],
                              decoration: InputDecoration(
                                labelText: "Price",
                                // icon: Icon(MdiIcons.home)
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some number';
                                } else if (double.parse(value) <
                                    double.parse(txt3.text)) {
                                  return "Price should be higher than cost";
                                } else {
                                  return null;
                                }
                              },
                            ),
                            TextFormField(
                              controller: qtyTxt,
                              textInputAction: TextInputAction.done,
                              focusNode: qtyFocus,
                              onFieldSubmitted: (value) {
                                qtyFocus.unfocus();
                                FocusScope.of(context).requestFocus(txt5Focus);
                              },
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    (RegExp("[.0-9]")))
                              ],
                              decoration: InputDecoration(
                                labelText: "Quantity",
                                // icon: Icon(MdiIcons.home)
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some number';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: txt5,
                              maxLines: 3,
                              focusNode: txt5Focus,
                              onFieldSubmitted: (value) {
                                txt5Focus.unfocus();
                              },
                              textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                labelText: "Details",
                              ),
                              validator: (value) {
                                if (value.isEmpty) {
                                  return 'Please enter some number';
                                }
                                return null;
                              },
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Product Image:",
                                style: font1,
                              ),
                            ),
                            Container(
                              child: _imgFile == null
                                  ? SizedBox(
                                      height: 300,
                                      width: 300,
                                      child: agent
                                          .getImage(agent.activeProduct.pics))
                                  : Image.file(
                                      _imgFile,
                                      height: 300,
                                      width: 300,
                                    ),
                            ),
                            SizedBox(
                              height: 50,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Container(
                                  width: 300,
                                  child: RaisedButton.icon(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      color: lightskyblue,
                                      icon: Icon(MdiIcons.upload),
                                      onPressed: () {
                                        selectImg(ImageSource.gallery);
                                      },
                                      label: Text("Upload New Image")),
                                ),
                                Text(
                                  "OR",
                                  style: font3,
                                ),
                                Container(
                                  width: 300,
                                  child: RaisedButton.icon(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      color: lightskyblue,
                                      icon: Icon(MdiIcons.camera),
                                      onPressed: () {
                                        selectImg(ImageSource.camera);
                                      },
                                      label: Text("Take New Photo")),
                                ),
                              ],
                            ),
                            Divider(
                              thickness: 5,
                              height: h * 0.05,
                            ),
                            SizedBox(
                              height: h * 0.07,
                              child: RaisedButton.icon(
                                onPressed: () {
                                  showAlertDialog(context);
                                },
                                icon: Icon(
                                  MdiIcons.deleteEmptyOutline,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  "Delete product ",
                                  style: whiteFont,
                                ),
                                color: color1,
                              ),
                            )
                          ]),
                    )),
              ),
            ),
          ),
        ));
  }

  showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget cancelButton = FlatButton(
      child: Text(
        "Cancel",
        style: danger,
      ),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget continueButton = FlatButton(
      child: Text("Confirm"),
      onPressed: () {
        Navigator.of(context).pop();
        agent.deleteProduct(context);
      },
    );
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(
        "Are you sure?",
        style: font1,
      ),
      content: Text(
          "Pressing confirm button will permanently delete your product record."),
      actions: [
        cancelButton,
        continueButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
} //ec
