
import 'Balance.dart';
import 'Currency.dart';

class SubAccount {
    Balance balance;
    Currency currency;
    String iban;
    String id;
    bool isFavourite;
    String lastRefreshedDate;
    String name;
    String number;
    String type;

    SubAccount({this.balance, this.currency, this.iban, this.id, this.isFavourite, this.lastRefreshedDate, this.name, this.number, this.type});

    factory SubAccount.fromJson(Map<String, dynamic> json) {
        return SubAccount(
            balance: json['balance'] != null ? Balance.fromJson(json['balance']) : null, 
            currency: json['currency'] != null ? Currency.fromJson(json['currency']) : null,
            iban: json['iban'], 
            id: json['id'], 
            isFavourite: json['isFavourite'], 
            lastRefreshedDate: json['lastRefreshedDate'], 
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
        data['lastRefreshedDate'] = this.lastRefreshedDate;
        data['name'] = this.name;
        data['number'] = this.number;
        data['type'] = this.type;
        if (this.balance != null) {
            data['balance'] = this.balance.toJson();
        }
        if (this.currency != null) {
            data['currency'] = this.currency.toJson();
        }
        return data;
    }
}