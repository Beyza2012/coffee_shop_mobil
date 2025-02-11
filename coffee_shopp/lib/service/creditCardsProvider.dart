import 'package:coffee_shopp/classes/creditCards.dart';
import 'package:flutter/cupertino.dart';

class CreditCardProvider extends ChangeNotifier {
  List<CreditCards> _creditCards= [];
  CreditCards? _selectedCard;
  CreditCards? get selectedCard => _selectedCard;

  void setCreditCards(List<CreditCards> items) {
    _creditCards = items;
    notifyListeners();
  }
  void setSelectedCard(CreditCards card) {
    _selectedCard = card;
    notifyListeners();
  }

}