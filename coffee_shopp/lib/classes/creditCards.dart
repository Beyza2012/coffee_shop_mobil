import 'package:cloud_firestore/cloud_firestore.dart';

class CreditCards {
  String? id;
  String cardNo;
  String month;
  String years;
  String cvv;
  String cardName;
  String holderName;
  bool? selected;

  CreditCards(
      {this.id,
        required this.cardNo,
        required this.month,
        required this.years,
        required this.cvv,
        required this.cardName,
        required this.holderName,
         this.selected});

  factory CreditCards.fromFirestore(String id, Map<String, dynamic> doc ){
    return CreditCards(
        id: id,
        cardNo: doc['cardNo'] ?? '',
        month: doc['month'] ?? '',
        years: doc['years'] ?? '',
        cvv: doc['cvv'] ?? '',
        cardName: doc['cardName'] ?? '',
        holderName: doc['holderName'] ?? '',
        selected: doc['selected'] ?? false,
    );

  }

  Map<String, dynamic> toFirestore() {
    return {
      'cardNo': cardNo,
      'month': month,
      'years': years,
      'cvv': cvv,
      'cardName': cardName,
      'holderName': holderName,
      'selected' : selected,
    };
  }

}