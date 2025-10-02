import 'package:doto_manager/app.dart';
import 'package:doto_manager/ui/controller/auth_controller.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthController.getUserData();
  runApp(TaskManagerApp());
}
