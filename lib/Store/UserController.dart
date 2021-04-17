import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:siangkong_mpos/Model/User.dart';
import 'package:http/http.dart' as http;
import 'package:siangkong_mpos/Screen/HomePage.dart';

class AppUserController extends GetxController {
  String url = 'http://13.250.64.212:1880';
   static User _loginUser;


  User get loginUser => _loginUser;

  Future<String> login(String _username, String _password,BuildContext context) {
    var obj = {"username": _username, "password": _password};
    String _res = "";
    http.post(url + "/loginUser", body: json.encode(obj), headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json'
    }).then((res){
      print(res.body);
       if(res.body != "no"){
         _loginUser = User.fromJson(json.decode(res.body));
         Get.offAll(HomePage());
       }else{
         AlertDialog alert = AlertDialog(
           title: Text("Login Fail"),
           content: Text("Username or Password do not exist.\n Please Try again"),
           actions: [
             RaisedButton(
                 child: Text("okay"),
                 onPressed: () {
                   Navigator.of(context).pop();
                 })
           ],
         );

         // show the dialog
         showDialog(
           context: context,
           builder: (BuildContext context) {
             return alert;
           },
         ); //e
       }
      return _res;
    });

  }

  Future<String> registerUser(User newUser) async {
    try {
      var data = json.encode(newUser.toJson());
      String res = "";
      print(data);
      await http.post(url + '/registeruser', body: data, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      }).then((result) {
        res = result.body;
      });
      return res;

    } catch (e) {
      print(e);
    }

  } //ef
}
