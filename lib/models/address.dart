class Address {
    String line1;
    String line2;
    String line3;

    Address({this.line1, this.line2, this.line3});

    factory Address.fromJson(Map<String, dynamic> json) {
        return Address(
            line1: json['line1'], 
            line2: json['line2'], 
            line3: json['line3'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['line1'] = this.line1;
        data['line2'] = this.line2;
        data['line3'] = this.line3;
        return data;
    }
}