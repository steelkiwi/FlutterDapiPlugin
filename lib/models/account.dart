import 'currency.dart';

class Account {
    Currency currency;
  String iban;
    String id;
    bool isFavourite;
    String name;
    String number;
    String type;

    Account({this.currency, this.iban, this.id, this.isFavourite, this.name, this.number, this.type});




    @override
    String toString() {
      return 'Account{currency: $currency, iban: $iban, id: $id, isFavourite: $isFavourite, name: $name, number: $number, type: $type}';
    }

    factory Account.fromJson(Map<String, dynamic> json) {
        return Account(
            currency: json['currency'] != null ? Currency.fromJson(json['currency']) : null,
            iban: json['iban'],
            id: json['id'],
            isFavourite: json['isFavourite'],
            name: json['name'],
            number: json['number'],
            type: json['type'],
        );
    }

    Map<String, dynamic> toJson() {
        final Map<String, dynamic> data = new Map<String, dynamic>();
        data['iban'] = this.iban;
        data['id'] = this.id;
        data['isFavourite'] = this.isFavourite;
        data['name'] = this.name;
        data['number'] = this.number;
        data['type'] = this.type;
        if (this.currency != null) {
            data['currency'] = this.currency.toJson();
        }
        return data;
    }
}