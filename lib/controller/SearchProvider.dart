import 'package:flutter/material.dart';

class SearchProvider extends ChangeNotifier {
  String _searchQuery = "";

  String get searchQuery => _searchQuery;

  void updateSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
