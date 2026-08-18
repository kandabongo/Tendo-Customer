import 'package:flutter/material.dart';
import 'package:fuodz/models/property.dart';
import 'package:fuodz/view_models/base.view_model.dart';

class PropertyChatViewModel extends MyBaseViewModel {
  PropertyChatViewModel(BuildContext context, this.property) {
    this.viewContext = context;
  }

  final Property property;
  final TextEditingController messageController = TextEditingController();
  List<String> messages = []; // Placeholder for chat messages

  void initialise() {}

  void sendMessage() async {
    if (messageController.text.trim().isEmpty) {
      return;
    }

    final message = messageController.text.trim();
    messageController.clear();

    setBusy(true);
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate sending
    messages.add(message); // Optimistically add message
    setBusy(false);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
