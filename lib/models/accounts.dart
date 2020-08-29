
import 'package:dapi_plugin/models/account.dart';

class Accounts {
    List<Account> accounts;
    String jobID;
    String status;
    bool success;

    Accounts({this.accounts, this.jobID, this.status, this.success});

    factory Accounts.fromJson(Map<String, dynamic> json) {
        return Accounts(
            accounts: json['accounts'] != null ? (json['accounts'] as List).map((i) => Account.fromJson(i)).toList() : null, 
            jobID: json['jobID'], 
            status: json['status'], 
            success: json['success'], 
        );
    }


    @override
  String toString() {
    return 'Accounts{accounts: $accounts, jobID: $jobID, status: $status, success: $success}';
  }

  Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['jobID'] = this.jobID;
        data['status'] = this.status;
        data['success'] = this.success;
        if (this.accounts != null) {
            data['accounts'] = this.accounts.map((v) => v.toJson()).toList();
        }
        return data;
    }
}