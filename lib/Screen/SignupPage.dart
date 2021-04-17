import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/User.dart';
import 'package:siangkong_mpos/Screen/LoginPage.dart';
import 'package:siangkong_mpos/Store/UserController.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _agreeCheck = false;
  ScrollController _controller;
  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _password2Controller = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _fnController = TextEditingController();
  TextEditingController _surenameController = TextEditingController();

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
    _controller = ScrollController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AppUserController _userController = Get.put(AppUserController());
    return Scaffold(
      key: _scaffoldKey,
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        title: Text("Sign Up"),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          },
          icon: Icon(
            Icons.arrow_back,
            size: 20,
            color: Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _controller,
        child: Container(
            height: MediaQuery.of(context).size.height * 1.7,
            width: double.infinity,
            child: Container(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Column(
                      children: <Widget>[
                        Text(
                          "Sign Up",
                          style: TextStyle(
                              fontSize: 45, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          "Create an account",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: Card(
                          color: Colors.grey[70],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {
                                    final action = CupertinoActionSheet(
                                      title: Text(
                                        "Please select profile photo",
                                        style: TextStyle(fontSize: 30),
                                      ),
                                      message: Text(
                                        "Select any option ",
                                        style: TextStyle(fontSize: 15.0),
                                      ),
                                      actions: <Widget>[
                                        CupertinoActionSheetAction(
                                          child: Text("Camera"),
                                          isDefaultAction: true,
                                          onPressed: () {
                                            selectImg(ImageSource.camera);
                                            Navigator.pop(context);
                                          },
                                        ),
                                        CupertinoActionSheetAction(
                                          child: Text("Select photo"),
                                          isDefaultAction: true,
                                          onPressed: () {
                                            selectImg(ImageSource.gallery);
                                            Navigator.pop(context);
                                          },
                                        )
                                      ],
                                      cancelButton: CupertinoActionSheetAction(
                                        child: Text("Cancel"),
                                        isDestructiveAction: true,
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    );
                                    showCupertinoModalPopup(
                                        context: context,
                                        builder: (context) => action);
                                  },
                                  child: Stack(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: royalblue,
                                        radius: 80,
                                        child: _imgFile == null
                                            ? Icon(MdiIcons.account, size: 80)
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(100),
                                                child: Image.file(
                                                  _imgFile,
                                                  height: 300,
                                                  width: 300,
                                                ),
                                              ),
                                      ),
                                      Positioned(
                                          right: 5,
                                          bottom: 5,
                                          child: Icon(
                                            MdiIcons.cameraAccount,
                                            size: 50,
                                            color: color1,
                                          ))
                                    ],
                                  ),
                                ),
                                MakeInput(
                                  label: "Username",
                                  textfieldController: _usernameController,
                                  validation: (value) {
                                    if (value.isEmpty) {
                                      return "This is the required field";
                                    }
                                    return null;
                                  },
                                ),
                                MakeInput(
                                  label: "First Name",
                                  textfieldController: _fnController,
                                  validation: (value) {
                                    if (value.isEmpty) {
                                      return "This is the required field";
                                    }
                                    return null;
                                  },
//                                  move: _moveUp(),
                                ),
                                MakeInput(
                                  label: "Surename",
                                  obscureText: false,
                                  textfieldController: _surenameController,
//                                    move2: _moveUp(),
//                                  move: _moveDown(),
                                  validation: (value) {
                                    if (value == "") {
                                      return "This is the required field";
                                    }
                                    return null;
                                  },
                                ),
                                MakeInput(
                                  label: "Email",
                                  obscureText: false,
                                  textfieldController: _emailController,
//                                    move2: _moveUp(),
//                                  move: _moveDown(),
                                  validation: (value) {
                                    if (value == "") {
                                      return "This is the required field";
                                    }
                                    return null;
                                  },
                                ),
                                MakeInput(
                                  label: "Password",
                                  obscureText: true,
                                  textfieldController: _passwordController,
//                                    move2: _moveUp(),
//                                  move: _moveDown(),
                                  validation: (value) {
                                    if (value.length < 8) {
                                      return "password must be more than 8 characters";
                                    }
                                    return null;
                                  },
                                ),
                                MakeInput(
                                  label: "Confirm  Password",
                                  obscureText: true,
                                  textfieldController: _password2Controller,
                                  validation: (value) {
                                    // ignore: missing_return
                                    if (_passwordController.text != value) {
                                      return "password is not match";
                                    }
                                    return null;
                                  },
//                                    move2: _moveUp()
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Stack(
                          children: <Widget>[
                            Positioned(
                              left: 15,
                              top: 15,
                              child: Icon(
                                Icons.check,
                                color:
                                    _agreeCheck ? Colors.black : Colors.white,
                                size: 20,
                              ),
                            ),
                            IconButton(
                              iconSize: 30,
                              enableFeedback: false,
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              icon: Icon(
                                Icons.check_box_outline_blank,
                                color: Colors.black,
                                size: 25,
                              ),
                              onPressed: () async {
                                setState(() {
                                  _agreeCheck = !_agreeCheck;
                                });
                              },
                            ),
                          ],
                        ),
                        Text("I agree with:  "),
                        Text(
                          "Terms & Policies",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        )
                      ],
                    ),
                  ]),
            )),
      ),
      persistentFooterButtons: [
        Container(
          height: 120,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 5),
          child: MaterialButton(
            minWidth: double.infinity,
            height: 60,
            highlightElevation: 0,
            splashColor: Colors.transparent,
            onPressed: () async {
              final ProgressDialog pr = new ProgressDialog(context);
              pr.style(
                message: 'Completing Registration ',
                progressWidget: SpinKitRotatingCircle(
                  color: hotpink,
                ),
                elevation: 10.0,
              );
              await pr.show();
              if (_formKey.currentState.validate() && _agreeCheck == true && _imgFile != null) {
                List<int> imageBytes = _imgFile.readAsBytesSync();
                String baseimage = base64Encode(imageBytes);
                baseimage = base64.normalize(baseimage);
                User newUser = new User(
                    firstName: _fnController.text,
                    email: _emailController.text,
                    surename: _surenameController.text,
                    username: _usernameController.text,
                    password: _passwordController.text,
                    profilePic: baseimage);

                _userController.registerUser(newUser).then((value) {
                  if(value == "yes"){
                    pr.update(message: "Sign Up Successfully");
                    Future.delayed(Duration(seconds: 2)).whenComplete(() => pr.hide().whenComplete(() => Get.offAll(LoginPage())));
                  }else{
                    pr.update(message: "Sign Up Fail");
                    Future.delayed(Duration(seconds: 2)).whenComplete(() => pr.hide());
                  }

                });
              } else {
                if (_agreeCheck == false) {
                  AlertDialog alert = AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    title: Text("Sign up failed"),
                    content: Text(
                        "Please check agree to the terms and policies tick box"),
                    actions: [
                      RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Text("okay"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          })
                    ],
                  );

                  // show the dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context2) {
                      return alert;
                    },
                  ); //end show dialog
                }else if(_imgFile.isNullOrBlank){
                  AlertDialog alert = AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    title: Text("Sign up failed"),
                    content: Text(
                        "Please upload profile picture"),
                    actions: [
                      RaisedButton(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          child: Text("okay"),
                          onPressed: () {
                            Navigator.of(context).pop();
                          })
                    ],
                  );

                  // show the dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context2) {
                      return alert;
                    },
                  ); //end show dialog
                }
              }
            },
            color: royalblue,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              "Sign Up",
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                  color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  @override
  void dispose() {
    // Don't forget to dispose the ScrollController.
    _controller.dispose();
    super.dispose();
  }
}

class MakeInput extends StatefulWidget {
  final String label;
  final bool obscureText;
  final Future move;
  final TextEditingController textfieldController;
  final Function validation;

  const MakeInput({
    Key key,
    this.obscureText,
    this.move,
    this.validation,
    @required this.label,
    @required this.textfieldController,
  }) : super(key: key);

  @override
  _MakeInputState createState() => _MakeInputState();
}

class _MakeInputState extends State<MakeInput> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: 8,
          ),
          Text(
            widget.label,
            style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Colors.black87),
          ),
          SizedBox(
            height: 3,
          ),
          Padding(
            padding: const EdgeInsets.all(10.5),
            child: TextFormField(
              controller: widget.textfieldController,
              validator: widget.validation,
//              onFieldSubmitted: (type) async {
//
//              },
              onTap: () {
//                widget.move;
              },
//                obscureText: widget.obscureText,
              decoration: InputDecoration(
                labelText: widget.label,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400])),
                border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[400])),
              ),
            ),
          ),
        ],
      ),
    );
  }
} //ec
