import 'package:flutter/material.dart';

class RefreshController extends ChangeNotifier {
  void refrescar() {
    notifyListeners();
  }
}
