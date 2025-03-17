import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/models/sender_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/services/user.dart';

enum AuthStatus {
  authenticated,
  uninitialized,
  authenticating,
  unauthenticated,
}

class UserProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;
  final FirebaseAuth? _auth;
  User? _authUser;
  User? get authUser => _authUser;

  final UserService _userService = UserService();

  UserModel? _user;
  UserModel? get user => _user;

  UserProvider.initialize() : _auth = FirebaseAuth.instance {
    _auth?.authStateChanges().listen(_onStateChanged);
  }

  bool loginCheck() {
    switch (_status) {
      case AuthStatus.uninitialized:
        return false;
      case AuthStatus.unauthenticated:
      case AuthStatus.authenticating:
        return false;
      case AuthStatus.authenticated:
        return true;
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    String? error;
    if (email == '') return 'メールアドレスは必須入力です';
    if (password == '') return 'パスワードは必須入力です';
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();
      final result = await _auth?.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result == null) return 'ログインに失敗しました';
      UserModel? tmpUser = await _userService.selectData(
        id: result.user!.uid,
      );
      if (tmpUser == null) return 'ログインに失敗しました';
      _authUser = result.user;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      error = 'ログインに失敗しました';
    }
    return error;
  }

  Future<String?> registration({
    required String name,
    required String email,
    required String password,
  }) async {
    String? error;
    if (name == '') return '名前は必須入力です';
    if (email == '') return 'メールアドレスは必須入力です';
    if (password == '') return 'パスワードは必須入力です';
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();
      final result = await _auth?.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (result == null) return '登録に失敗しました';
      _userService.create({
        'id': result.user!.uid,
        'name': name,
        'email': email,
        'password': password,
        'tokens': [],
        'senderUsers': [],
        'isSender': false,
        'senderNumber': '',
        'senderName': '',
        'sendUserLimit': 0,
      });
      _authUser = result.user;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      error = '登録に失敗しました';
    }
    return error;
  }

  Future<String?> updateName({
    required String name,
  }) async {
    String? error;
    if (name == '') return '名前は必須入力です';
    try {
      _userService.update({
        'id': _user?.id,
        'name': name,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> updateEmail({
    required String email,
  }) async {
    String? error;
    if (email == '') return 'メールアドレスは必須入力です';
    try {
      if (_authUser == null) return 'メールアドレスの変更に失敗しました';
      await _authUser!.updateEmail(email);
      _userService.update({
        'id': _user?.id,
        'email': email,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> updatePassword({
    required String password,
  }) async {
    String? error;
    if (password == '') return 'パスワードは必須入力です';
    try {
      if (_authUser == null) return 'パスワードの変更に失敗しました';
      await _authUser!.updatePassword(password);
      _userService.update({
        'id': _user?.id,
        'password': password,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> addSenderUsers({
    required String senderNumber,
  }) async {
    String? error;
    if (senderNumber == '') return '発信者番号は必須入力です';
    try {
      UserModel? tmpUser = await _userService.selectData(
        senderNumber: senderNumber,
      );
      if (tmpUser == null) return '受信先の追加に失敗しました';
      List<Map> senderUsers = [];
      if (_user!.senderUsers.isNotEmpty) {
        for (SenderUserModel senderUser in _user!.senderUsers) {
          senderUsers.add(senderUser.toMap());
        }
      }
      senderUsers.add({
        'id': tmpUser.id,
        'name': tmpUser.name,
        'email': tmpUser.email,
      });
      _userService.update({
        'id': _user?.id,
        'senderUsers': senderUsers,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> removeSenderUsers({
    required List<SenderUserModel> deleteSenderUsers,
  }) async {
    String? error;
    if (deleteSenderUsers.isEmpty) return '受信先の削除に失敗しました';
    try {
      List<Map> senderUsers = [];
      if (_user!.senderUsers.isNotEmpty) {
        for (SenderUserModel senderUser in _user!.senderUsers) {
          if (!deleteSenderUsers.contains(senderUser)) {
            senderUsers.add(senderUser.toMap());
          }
        }
      }
      _userService.update({
        'id': _user?.id,
        'senderUsers': senderUsers,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> senderRegistration({
    required String senderName,
  }) async {
    String? error;
    if (senderName == '') return '送信者名は必須入力です';
    try {
      String senderNumber = randomNumber(8);
      _userService.update({
        'id': _user?.id,
        'isSender': true,
        'senderNumber': senderNumber,
        'senderName': senderName,
        'sendUserLimit': 10,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> senderReset() async {
    String? error;
    try {
      _userService.update({
        'id': _user?.id,
        'isSender': false,
        'senderNumber': '',
        'senderName': '',
        'sendUserLimit': 0,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future logout() async {
    await _auth?.signOut();
    _status = AuthStatus.unauthenticated;
    _user = null;
    notifyListeners();
    return Future.delayed(Duration.zero);
  }

  Future reload() async {
    if (_authUser == null) return;
    UserModel? tmpUser = await _userService.selectData(
      id: _authUser!.uid,
    );
    if (tmpUser == null) return;
    _user = tmpUser;
    notifyListeners();
  }

  Future _onStateChanged(User? authUser) async {
    if (authUser == null) {
      _status = AuthStatus.unauthenticated;
    } else {
      _authUser = authUser;
      _status = AuthStatus.authenticated;
      UserModel? tmpUser = await _userService.selectData(
        id: _authUser!.uid,
      );
      if (tmpUser != null) {
        _user = tmpUser;
      } else {
        _authUser = null;
        _status = AuthStatus.unauthenticated;
      }
    }
    notifyListeners();
  }
}
