import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/Product.dart';
import 'package:siangkong_mpos/Model/Stock.dart';
import 'package:siangkong_mpos/Store/ProductDb.dart';
import 'package:siangkong_mpos/Widget/dropdownfield.dart';

class AddNewProduct extends StatefulWidget {
  @override
  _AddNewProductState createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {
  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final MyStore agent = Get.put(MyStore());

  TextEditingController txt1 = new TextEditingController();
  TextEditingController txt2 = new TextEditingController();
  TextEditingController txt3 = new TextEditingController();
  TextEditingController txt4 = new TextEditingController();
  TextEditingController txt5 = new TextEditingController();
  TextEditingController catController = new TextEditingController();
  TextEditingController qtyTxt = new TextEditingController();

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

  String _validateSerialNumber(text) {
    var repeatedId = agent.products.firstWhere(
        (element) => element.serialNumber == text,
        orElse: () => null);
    print(repeatedId);
    RegExp regExp = new RegExp(r"(^p\d{3}$)");

    // bool res = regExp.hasMatch(text);
    // print(res);
    if (text.isEmpty) {
      return "Please enter some text";
    } else {
      if (repeatedId != null) {
        return "The serial number is already exist in the system";
      } else if (!regExp.hasMatch(text)) {
        return "The serial number is not in right format";
      } else {
        return null;
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // _loadCategoriesMenu();
  }

  @override
  Widget build(BuildContext context) {
    double bottom = MediaQuery.of(context).viewInsets.bottom;
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;
    List<String> _categories = agent.categories;

    _categories.removeWhere((element) => element == "ทั้งหมด");
    return Scaffold(
        backgroundColor: azure,
        key: _scaffoldKey,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: royalblue,
          title: Text("Add New Items"),
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
                  } else if (_imgFile == null) {
                    _scaffoldKey.currentState.showSnackBar(snackBar2);
                  } else {
                    List<int> imageBytes = _imgFile.readAsBytesSync();
                    String baseimage = base64Encode(imageBytes);
                    baseimage = base64.normalize(baseimage);
                    print(baseimage);

                    print(baseimage.length);
                    p = Product(
                        serialNumber: txt1.text,
                        productName: txt2.text,
                        category: catController.text.trim(),
                        sellingPrice: double.parse(txt4.text),
                        cost: double.parse(txt3.text),
                        pics: baseimage,
                        details: txt5.text);

                    Stock s = Stock(
                        stockId: null,
                        serialNumber: txt1.text,
                        qty: int.parse(qtyTxt.text));
                    agent.addProductToServer(context, p, s);
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
                                controller: txt1,
                                focusNode: txt1Focus,
                                onFieldSubmitted: (term) {
                                  txt1Focus.unfocus();
                                  FocusScope.of(context)
                                      .requestFocus(txt2Focus);
                                },
                                decoration: InputDecoration(
                                  labelText: "Serial Number",
                                  // icon: Icon(MdiIcons.product)
                                ),
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  return _validateSerialNumber(value);
                                }),
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
                              textInputAction: TextInputAction.next,
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
                                  return 'Please enter some text';
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
                                      child: Image.asset(
                                          "assets/image-placeholder.png"))
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
                                      label: Text("Upload Image")),
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
                                      label: Text("Take Photo")),
                                ),
                              ],
                            )
                          ]),
                    )),
              ),
            ),
          ),
        ));
  }
} //ec
