
import 'beneficiary.dart';
class Beneficiaries {
    List<Beneficiary> beneficiaries;
    String jobID;
    String status;
    bool success;

    Beneficiaries({this.beneficiaries, this.jobID, this.status, this.success});

    factory Beneficiaries.fromJson(Map<String, dynamic> json) {
        return Beneficiaries(
            beneficiaries: json['beneficiaries'] != null ? (json['beneficiaries'] as List).map((i) => Beneficiary.fromJson(i)).toList() : null, 
            jobID: json['jobID'], 
            status: json['status'], 
            success: json['success'], 
        );
    }

    @override
  String toString() {
    return 'Beneficiaries{beneficiaries: $beneficiaries, jobID: $jobID, status: $status, success: $success}';
  }

  Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['jobID'] = this.jobID;
        data['status'] = this.status;
        data['success'] = this.success;
        if (this.beneficiaries != null) {
            data['beneficiaries'] = this.beneficiaries.map((v) => v.toJson()).toList();
        }
        return data;
    }
}