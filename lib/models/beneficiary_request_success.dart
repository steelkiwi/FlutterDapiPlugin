class BeneficiaryRequestSuccess {
  String jobID;
  String status;
  bool success;

  BeneficiaryRequestSuccess({this.jobID, this.status, this.success});

  factory BeneficiaryRequestSuccess.fromJson(Map<String, dynamic> json) {
    return BeneficiaryRequestSuccess(
      jobID: json['jobID'],
      status: json['status'],
      success: json['success'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['jobID'] = this.jobID;
    data['status'] = this.status;
    data['success'] = this.success;
    return data;
  }
}
