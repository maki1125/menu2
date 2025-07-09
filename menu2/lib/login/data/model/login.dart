
import 'package:flutter/material.dart';

//ログインのテキストコントローラーセット
class LoginTextControllers {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  LoginTextControllers()
      : emailController = TextEditingController(),
        passwordController = TextEditingController();

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}