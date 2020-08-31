class CreateTransferResponse {
  String jobID;
  String status;
  bool success;

  CreateTransferResponse({this.jobID, this.status, this.success});

  factory CreateTransferResponse.fromJson(Map<String, dynamic> json) {
    return CreateTransferResponse(
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

  @override
  String toString() {
    return 'CreateTransferResponse{jobID: $jobID, status: $status, success: $success}';
  }
}
