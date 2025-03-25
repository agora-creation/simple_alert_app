import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_alert_app/models/map_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/services/push.dart';
import 'package:simple_alert_app/services/user.dart';
import 'package:simple_alert_app/services/user_notice.dart';
import 'package:simple_alert_app/services/user_send.dart';

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

  final PushService _pushService = PushService();
  final UserService _userService = UserService();
  final UserNoticeService _userNoticeService = UserNoticeService();
  final UserSendService _userSendService = UserSendService();

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
      String? token = await _pushService.getFcmToken();
      if (token == null) return 'ログインに失敗しました';
      _userService.update({
        'id': tmpUser.id,
        'token': token,
      });
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
      String? token = await _pushService.getFcmToken();
      if (token == null) return '登録に失敗しました';
      _userService.create({
        'id': result.user!.uid,
        'name': name,
        'email': email,
        'password': password,
        'token': token,
        'noticeMapUsers': [],
        'sendMapUsers': [],
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

  Future<String?> addNoticeMapUsers({
    required String email,
  }) async {
    String? error;
    if (email == '') return 'メールアドレスは必須入力です';
    try {
      //受信者側の追加
      UserModel? senderUser = await _userService.selectData(
        email: email,
      );
      if (senderUser == null) return '送信者が見つかりませんでした';
      List<Map> noticeMapUsers = [];
      if (_user!.noticeMapUsers.isNotEmpty) {
        for (MapUserModel mapUser in _user!.noticeMapUsers) {
          noticeMapUsers.add(mapUser.toMap());
        }
      }
      noticeMapUsers.add({
        'id': senderUser.id,
        'name': senderUser.name,
        'email': senderUser.email,
      });
      _userService.update({
        'id': _user?.id,
        'noticeMapUsers': noticeMapUsers,
      });
      //送信者側の追加
      List<Map> sendMapUsers = [];
      if (senderUser.sendMapUsers.isNotEmpty) {
        for (MapUserModel mapUser in senderUser.sendMapUsers) {
          sendMapUsers.add(mapUser.toMap());
        }
      }
      sendMapUsers.add({
        'id': _user!.id,
        'name': _user!.name,
        'email': _user!.email,
      });
      _userService.update({
        'id': senderUser.id,
        'sendMapUsers': sendMapUsers,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> removeNoticeMapUsers({
    required List<MapUserModel> selectedNoticeMapUsers,
  }) async {
    String? error;
    if (selectedNoticeMapUsers.isEmpty) return '選択されていません';
    try {
      //受信者側の削除
      List<Map> noticeMapUsers = [];
      if (_user!.noticeMapUsers.isNotEmpty) {
        for (MapUserModel mapUser in _user!.noticeMapUsers) {
          if (!selectedNoticeMapUsers.contains(mapUser)) {
            noticeMapUsers.add(mapUser.toMap());
          }
        }
      }
      _userService.update({
        'id': _user?.id,
        'noticeMapUsers': noticeMapUsers,
      });
      //送信者側の削除
      for (MapUserModel mapUser in selectedNoticeMapUsers) {
        UserModel? senderUser = await _userService.selectData(
          id: mapUser.id,
        );
        if (senderUser == null) continue;
        List<Map> sendMapUsers = [];
        if (senderUser.sendMapUsers.isNotEmpty) {
          for (MapUserModel mapUser in senderUser.sendMapUsers) {
            if (mapUser.id != _user!.id) {
              sendMapUsers.add(mapUser.toMap());
            }
          }
        }
        _userService.update({
          'id': senderUser.id,
          'sendMapUsers': sendMapUsers,
        });
      }
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> addSendMapUsers({
    required String email,
  }) async {
    String? error;
    if (email == '') return 'メールアドレスは必須入力です';
    try {
      //送信者側の追加
      UserModel? noticeUser = await _userService.selectData(
        email: email,
      );
      if (noticeUser == null) return '受信者が見つかりませんでした';
      List<Map> sendMapUsers = [];
      if (_user!.sendMapUsers.isNotEmpty) {
        for (MapUserModel mapUser in _user!.sendMapUsers) {
          sendMapUsers.add(mapUser.toMap());
        }
      }
      sendMapUsers.add({
        'id': noticeUser.id,
        'name': noticeUser.name,
        'email': noticeUser.email,
      });
      _userService.update({
        'id': _user?.id,
        'sendMapUsers': sendMapUsers,
      });
      //受信者側の追加
      List<Map> noticeMapUsers = [];
      if (noticeUser.noticeMapUsers.isNotEmpty) {
        for (MapUserModel mapUser in noticeUser.noticeMapUsers) {
          noticeMapUsers.add(mapUser.toMap());
        }
      }
      noticeMapUsers.add({
        'id': _user!.id,
        'name': _user!.name,
        'email': _user!.email,
      });
      _userService.update({
        'id': noticeUser.id,
        'noticeMapUsers': noticeMapUsers,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> removeSendMapUsers({
    required List<MapUserModel> selectedSendMapUsers,
  }) async {
    String? error;
    if (selectedSendMapUsers.isEmpty) return '選択されていません';
    try {
      //送信者側の削除
      List<Map> sendMapUsers = [];
      if (_user!.sendMapUsers.isNotEmpty) {
        for (MapUserModel mapUser in _user!.sendMapUsers) {
          if (!selectedSendMapUsers.contains(mapUser)) {
            sendMapUsers.add(mapUser.toMap());
          }
        }
      }
      _userService.update({
        'id': _user?.id,
        'sendMapUsers': sendMapUsers,
      });
      //受信者側の削除
      for (MapUserModel mapUser in selectedSendMapUsers) {
        UserModel? noticeUser = await _userService.selectData(
          id: mapUser.id,
        );
        if (noticeUser == null) continue;
        List<Map> noticeMapUsers = [];
        if (noticeUser.noticeMapUsers.isNotEmpty) {
          for (MapUserModel mapUser in noticeUser.noticeMapUsers) {
            if (mapUser.id != _user!.id) {
              noticeMapUsers.add(mapUser.toMap());
            }
          }
        }
        _userService.update({
          'id': noticeUser.id,
          'noticeMapUsers': noticeMapUsers,
        });
      }
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
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> createSendDraft({
    required String title,
    required String content,
  }) async {
    String? error;
    if (title == '') return '件名は必須入力です';
    try {
      String id = _userSendService.id(userId: _user!.id);
      _userSendService.create({
        'id': id,
        'userId': _user?.id,
        'title': title,
        'content': content,
        'draft': true,
        'sendAt': DateTime.now(),
        'createdUserId': _user!.id,
        'createdUserName': _user!.name,
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> updateSendDraft({
    required UserSendModel userSend,
    required String title,
    required String content,
  }) async {
    String? error;
    if (title == '') return '件名は必須入力です';
    try {
      _userSendService.update({
        'id': userSend.id,
        'userId': userSend.userId,
        'title': title,
        'content': content,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> deleteSendDraft({
    required UserSendModel userSend,
  }) async {
    String? error;
    try {
      _userSendService.delete({
        'id': userSend.id,
        'userId': userSend.userId,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> send({
    required UserSendModel? userSend,
    required String title,
    required String content,
    required List<MapUserModel> selectedSendMapUsers,
  }) async {
    String? error;
    if (selectedSendMapUsers.isEmpty) return '選択されていません';
    try {
      if (userSend != null) {
        _userSendService.update({
          'id': userSend.id,
          'userId': userSend.userId,
          'title': title,
          'content': content,
          'draft': false,
          'sendAt': DateTime.now(),
        });
      } else {
        String id = _userSendService.id(userId: _user!.id);
        _userSendService.create({
          'id': id,
          'userId': _user?.id,
          'title': title,
          'content': content,
          'draft': false,
          'sendAt': DateTime.now(),
          'createdUserId': _user!.id,
          'createdUserName': _user!.name,
          'createdAt': DateTime.now(),
        });
      }
      for (MapUserModel mapUser in selectedSendMapUsers) {
        UserModel? noticeUser = await _userService.selectData(
          id: mapUser.id,
        );
        if (noticeUser == null) continue;
        String id = _userNoticeService.id(userId: noticeUser.id);
        _userNoticeService.create({
          'id': id,
          'userId': noticeUser.id,
          'title': title,
          'content': content,
          'read': false,
          'token': noticeUser.token,
          'createdUserId': _user!.id,
          'createdUserName': _user!.name,
          'createdAt': DateTime.now(),
        });
      }
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
