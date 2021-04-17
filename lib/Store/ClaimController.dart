
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:siangkong_mpos/CSS.dart';
import 'package:siangkong_mpos/Model/Claim.dart';
import 'package:siangkong_mpos/Model/Claim_detail.dart';
import 'package:siangkong_mpos/Store/OrderController.dart';

class ClaimController extends GetxController {
  String url = 'http://13.250.64.212:1880';
  Claim _activeClaim = new Claim();
  Claim get activeClaim => _activeClaim;
  List<Claim_details> _claim_details =[];
  List<Claim_details> get claim_detail =>_claim_details;
  OrderController o = Get.find<OrderController>();

  List<Claim> _hClaims = [];
  List<Claim> _hClaims2 = [];
  List<Claim> get hClaim =>_hClaims;

  List<Claim_details> _hClaimdetail = [];
  List<Claim_details> get hClaimdetail => _hClaimdetail;

  void setActiveClaim(Claim c){
    _activeClaim = c;

    update();
  }
  void setListClaimDetails(List<Claim_details> c){
    _claim_details = c;

    update();
  }
  Future<List<Claim>> loadClaimFromDb() async {

    List<Claim> loadedOrder = [];
    var result = await http.get(url + "/loadclaims");
    if (result.statusCode == 200) {
      var basket = json.decode(result.body) as List;
      var orderFromJson = basket.map((apple) => Claim.fromJson(apple)).toList();

      _hClaims = orderFromJson;
      _hClaims2 = orderFromJson;
      loadedOrder = orderFromJson;
      update();
      return loadedOrder;
    } else {
      throw Exception('fail to load');
    }
  } //ef


  void setSearchKey(String query) {
    print(query);
    List<Claim> searchRes = [];
    if (query != "") {
      searchRes = _hClaims2
          .where((element) => element.customerId.toLowerCase().contains(query) || element.claimID.toString().contains(query)
      )
          .toList();

      _hClaims = searchRes;
      update();
    } else {
      _hClaims = _hClaims2;
      update();
    }
    notifyChildrens();

  }
  void filterClaim(String option){
    print(option);
    if(option =='[0]'){
      _hClaims = _hClaims2.where((element) => element.claimStatus.toLowerCase() == "processing").toList();
    }else if(option=='[1]'){
      _hClaims = _hClaims2.where((element) => element.claimStatus.toLowerCase() == "approved").toList();
    }else if(option == '[2]'){
      _hClaims = _hClaims2.where((element) => element.claimStatus.toLowerCase() == "rejected").toList();
    }else{
      _hClaims = _hClaims2;
    }
    update();
  }

  Future<String> updateClaimStatus(Claim c, BuildContext context) async {
    try {
      final ProgressDialog pr = new ProgressDialog(context);
      pr.style(
        message: 'Completing ',
        progressWidget: SpinKitRotatingCircle(
          color: hotpink,
        ),
        elevation: 10.0,
      );
      await pr.show();
      var data = json.encode(c.toJson());
      print(data);
      await http.post(url + '/updateclaim', body: data, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      }).then((value) {
        print(value.body);
        if (value.statusCode == 200) {
          if (value.body == "yes") {
            pr.update(message: "Claim is successfully updated");

            Future.delayed(Duration(seconds: 1)).then((value) async {
              loadClaimFromDb();
              loadClaimDetailFromDb();
            }).whenComplete(() {

              pr.hide().whenComplete(() {
                Navigator.of(context).pop();
                update();
              });
            });
          } else {
            pr.update(message: "Fail to update claim");
            Future.delayed(Duration(seconds: 1))
                .then((value) async {})
                .whenComplete(() => pr.hide());
          }
        return value.body;
      }});


    } catch (e) {
      print(e);
    }

  } //ef

  void sortByAscending(){
    _hClaims.sort((a,b)=> a.claimDate.compareTo(b.claimDate));
    update();
  }

  void sortByDescending(){
    _hClaims.sort((b,a)=> a.claimDate.compareTo(b.claimDate));
    update();
  }

  Future<List<Claim_details>> loadClaimDetailFromDb() async {
    List<Claim_details> loadedOrder = [];
    var result = await http.get(url + "/loadclaimdetails");
    if (result.statusCode == 200) {
      // print(result.body);
      var basket = json.decode(result.body) as List;
      var orderFromJson = basket.map((apple) => Claim_details.fromJson(apple)).toList();

      _hClaimdetail = orderFromJson;
      loadedOrder = orderFromJson;
      return loadedOrder;
    } else {
      throw Exception('fail to load');
    }
  } //ef

  Future<String> insertClaimDetailtableDb(int claim_id) async {
    _claim_details.forEach((element) async {
      element.claimId = claim_id;
    });
    print(_claim_details);
    var data = jsonEncode(_claim_details);
    String res = "no";
    await http.post(url + '/insertclaimdetail', body: data, headers: {
      'Content-type': 'application/json',
      'Accept': 'application/json',
    }).then((result) {
      if (result.statusCode != 200) {
        throw Exception("fail to insert");
      } else {
        res = result.body;
      }
    });

    return res;
  } //ef
  Future<int> insertClaimtableDb() async {
    try {
      _activeClaim.customerId = o.cliamOrder.customerId;
      _activeClaim.claimDate = DateTime.now();
      var data = json.encode(_activeClaim.toJson());
      int _claimID = 0;
      print(data);
      await http.post(url + '/insertclaim', body: data, headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json'
      }).then((result) {
        _activeClaim.claimID = int.parse(result.body);
        _claimID = int.parse(result.body);
      });
      return _claimID;

    } catch (e) {
      print(e);
    }

  } //ef
}