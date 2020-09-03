class DelinkUser {
    String msg;
    bool success;

    DelinkUser({this.msg, this.success});

    factory DelinkUser.fromJson(Map<String, dynamic> json) {
        return DelinkUser(
            msg: json['msg'], 
            success: json['success'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['msg'] = this.msg;
        data['success'] = this.success;
        return data;
    }
}