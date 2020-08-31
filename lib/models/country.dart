class Country {
    String code;
    String name;

    Country({this.code, this.name});

    factory Country.fromJson(Map<String, dynamic> json) {
        return Country(
            code: json['code'], 
            name: json['name'], 
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['code'] = this.code;
        data['name'] = this.name;
        return data;
    }
}