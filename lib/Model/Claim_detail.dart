class Claim_details {
  int claimId;
  String serialNumber;
  int qty;

  Claim_details({this.claimId, this.serialNumber, this.qty});

  Claim_details.fromJson(Map<String, dynamic> json) {
    claimId = json['Claim_id'];
    serialNumber = json['Serial_Number'];
    qty = json['qty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Claim_id'] = this.claimId;
    data['Serial_Number'] = this.serialNumber;
    data['qty'] = this.qty;
    return data;
  }
}

