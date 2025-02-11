import 'package:coffee_shopp/classes/Adresses.dart';
import 'package:flutter/cupertino.dart';

class AdressesProvider extends ChangeNotifier {
  List<Adresses> _adresses= [];
  Adresses? _selectedAdress;
  Adresses? get selectedAdress => _selectedAdress;
  void setAdresses(List<Adresses> items) {
    _adresses = items;
    notifyListeners();
  }
  void setSelectedAdress(Adresses adress) {
    _selectedAdress = adress;
    notifyListeners();
  }

}