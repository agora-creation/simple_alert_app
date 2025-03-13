import 'package:flutter/material.dart';

enum AuthStatus {
  authenticated,
  uninitialized,
  authenticating,
  unauthenticated,
}

class LoginProvider with ChangeNotifier {}
