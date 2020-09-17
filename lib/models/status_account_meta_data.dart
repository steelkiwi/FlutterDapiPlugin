import 'dapi_bank_metadata.dart';

class StatusAccountMetaData {
    DapiBankMetadata accountsMetadata;
    String jobID;
    String status;
    bool success;

    StatusAccountMetaData({this.accountsMetadata, this.jobID, this.status, this.success});

    factory StatusAccountMetaData.fromJson(Map<String, dynamic> json) {
        return StatusAccountMetaData(
            accountsMetadata: json['accountsMetadata'] != null ? DapiBankMetadata.fromJson(json['accountsMetadata']) : null, 
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
        if (this.accountsMetadata != null) {
            data['accountsMetadata'] = this.accountsMetadata.toJson();
        }
        return data;
    }
}