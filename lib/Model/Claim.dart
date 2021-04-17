import 'package:intl/intl.dart';

class Claim {
  int claimID;
  String customerId;
  int receiptId;
  DateTime claimDate;
  String claimDescription;
  String claimStatus;

  Claim(
      {this.claimID,
        this.customerId,
        this.receiptId,
        this.claimDate,
        this.claimDescription,
        this.claimStatus,
        });

  Claim.fromJson(Map<String, dynamic> json) {
    claimID = json['Claim_ID'];
    customerId = json['Customer_id'];
    receiptId = json['Receipt_id'];
    claimDate = DateTime.parse(json['Claim_date'].toString());
    claimDescription = json['Claim_description'];
    claimStatus = json['Claim_Status'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Claim_ID'] = this.claimID;
    data['Customer_id'] = this.customerId;
    data['Receipt_id'] = this.receiptId;
    data['Claim_date'] = DateFormat("yyyy-MM-dd HH:mm:ss").format(this.claimDate);
    data['Claim_description'] = this.claimDescription;
    data['Claim_Status'] = this.claimStatus;
    return data;
  }
}

