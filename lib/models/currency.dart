class Currency {
    String code;
    String name;

    Currency({this.code, this.name});

    factory Currency.fromJson(Map<String, dynamic> json) {
        return Currency(
            code: "json['code']",
            name: "json['name']",
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['code'] = this.code;
        data['name'] = this.name;
        return data;
    }
}