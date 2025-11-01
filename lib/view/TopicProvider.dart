import 'package:flutter/material.dart';

class TopicProvider extends ChangeNotifier {
  String _selectedSubject = "";
  String _selectedTopic = "";

  String get selectedSubject => _selectedSubject;
  String get selectedTopic => _selectedTopic;

  void setSubject(String subject) {
    _selectedSubject = subject;
    notifyListeners();
  }

  void setTopic(String topic) {
    _selectedTopic = topic;
    notifyListeners();
  }
}
