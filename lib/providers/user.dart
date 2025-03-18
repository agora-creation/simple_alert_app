import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/models/receive_user.dart';
import 'package:simple_alert_app/models/send_user.dart';
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
        'receiveUsers': [],
        'isSender': false,
        'senderNumber': '',
        'senderName': '',
        'sendUserLimit': 0,
        'sendUsers': [],
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

  Future<String?> addReceiveUsers({
    required String senderNumber,
  }) async {
    String? error;
    if (senderNumber == '') return '送信者番号は必須入力です';
    try {
      //受信者側の追加
      UserModel? senderUser = await _userService.selectData(
        senderNumber: senderNumber,
      );
      if (senderUser == null) return '送信者番号が見つかりませんでした';
      List<Map> receiveUsers = [];
      if (_user!.receiveUsers.isNotEmpty) {
        for (ReceiveUserModel receiveUser in _user!.receiveUsers) {
          receiveUsers.add(receiveUser.toMap());
        }
      }
      receiveUsers.add({
        'id': senderUser.id,
        'senderNumber': senderUser.senderNumber,
        'senderName': senderUser.senderName,
      });
      _userService.update({
        'id': _user?.id,
        'receiveUsers': receiveUsers,
      });
      //送信者側の追加
      List<Map> sendUsers = [];
      if (senderUser.sendUsers.isNotEmpty) {
        for (SendUserModel sendUser in senderUser.sendUsers) {
          sendUsers.add(sendUser.toMap());
        }
      }
      sendUsers.add({
        'id': _user!.id,
        'name': _user!.name,
        'email': _user!.email,
      });
      _userService.update({
        'id': senderUser.id,
        'sendUsers': sendUsers,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> removeReceiveUsers({
    required List<ReceiveUserModel> deleteReceiveUsers,
  }) async {
    String? error;
    if (deleteReceiveUsers.isEmpty) return '受信先の削除に失敗しました';
    try {
      //受信者側の削除
      List<Map> receiveUsers = [];
      if (_user!.receiveUsers.isNotEmpty) {
        for (ReceiveUserModel receiveUser in _user!.receiveUsers) {
          if (!deleteReceiveUsers.contains(receiveUser)) {
            receiveUsers.add(receiveUser.toMap());
          }
        }
      }
      _userService.update({
        'id': _user?.id,
        'receiveUsers': receiveUsers,
      });
      //送信者側の削除
      for (ReceiveUserModel receiveUser in deleteReceiveUsers) {
        UserModel? senderUser = await _userService.selectData(
          id: receiveUser.id,
        );
        if (senderUser == null) continue;
        List<Map> sendUsers = [];
        if (senderUser.sendUsers.isNotEmpty) {
          for (SendUserModel sendUser in senderUser.sendUsers) {
            if (sendUser.id != _user!.id) {
              sendUsers.add(sendUser.toMap());
            }
          }
        }
        _userService.update({
          'id': receiveUser.id,
          'sendUsers': sendUsers,
        });
      }
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

  Future<String?> addSendUsers({
    required String email,
  }) async {
    String? error;
    if (email == '') return 'メールアドレスは必須入力です';
    try {
      //送信者側の追加
      UserModel? receiveUser = await _userService.selectData(
        email: email,
      );
      if (receiveUser == null) return 'メールアドレスが見つかりませんでした';
      List<Map> sendUsers = [];
      if (_user!.sendUsers.isNotEmpty) {
        for (SendUserModel sendUser in _user!.sendUsers) {
          sendUsers.add(sendUser.toMap());
        }
      }
      sendUsers.add({
        'id': receiveUser.id,
        'name': receiveUser.name,
        'email': receiveUser.email,
      });
      _userService.update({
        'id': _user?.id,
        'sendUsers': sendUsers,
      });
      //受信者側の追加
      List<Map> receiveUsers = [];
      if (receiveUser.receiveUsers.isNotEmpty) {
        for (ReceiveUserModel receiveUser in receiveUser.receiveUsers) {
          receiveUsers.add(receiveUser.toMap());
        }
      }
      receiveUsers.add({
        'id': _user!.id,
        'senderNumber': _user!.senderNumber,
        'senderName': _user!.senderName,
      });
      _userService.update({
        'id': receiveUser.id,
        'receiveUsers': receiveUsers,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> removeSendUsers({
    required List<SendUserModel> deleteSendUsers,
  }) async {
    String? error;
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
