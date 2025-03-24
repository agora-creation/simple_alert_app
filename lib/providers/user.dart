import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/models/map_notice_user.dart';
import 'package:simple_alert_app/models/map_send_user.dart';
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

  Future<String?> updateSenderName({
    required String senderName,
  }) async {
    String? error;
    if (senderName == '') return '送信者名は必須入力です';
    try {
      _userService.update({
        'id': _user?.id,
        'senderName': senderName,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> addMapNoticeUsers({
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
      List<Map> mapNoticeUsers = [];
      if (_user!.mapNoticeUsers.isNotEmpty) {
        for (MapNoticeUserModel mapNoticeUser in _user!.mapNoticeUsers) {
          mapNoticeUsers.add(mapNoticeUser.toMap());
        }
      }
      mapNoticeUsers.add({
        'id': senderUser.id,
        'senderNumber': senderUser.senderNumber,
        'senderName': senderUser.senderName,
      });
      _userService.update({
        'id': _user?.id,
        'mapNoticeUsers': mapNoticeUsers,
      });
      //送信者側の追加
      List<Map> mapSendUsers = [];
      if (senderUser.mapSendUsers.isNotEmpty) {
        for (MapSendUserModel mapSendUser in senderUser.mapSendUsers) {
          mapSendUsers.add(mapSendUser.toMap());
        }
      }
      mapSendUsers.add({
        'id': _user!.id,
        'name': _user!.name,
        'email': _user!.email,
      });
      _userService.update({
        'id': senderUser.id,
        'mapSendUsers': mapSendUsers,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> removeMapNoticeUsers({
    required List<MapNoticeUserModel> deleteMapNoticeUsers,
  }) async {
    String? error;
    if (deleteMapNoticeUsers.isEmpty) return '受信先の削除に失敗しました';
    try {
      //受信者側の削除
      List<Map> mapNoticeUsers = [];
      if (_user!.mapNoticeUsers.isNotEmpty) {
        for (MapNoticeUserModel mapNoticeUser in _user!.mapNoticeUsers) {
          if (!deleteMapNoticeUsers.contains(mapNoticeUser)) {
            mapNoticeUsers.add(mapNoticeUser.toMap());
          }
        }
      }
      _userService.update({
        'id': _user?.id,
        'mapNoticeUsers': mapNoticeUsers,
      });
      //送信者側の削除
      for (MapNoticeUserModel mapNoticeUser in deleteMapNoticeUsers) {
        UserModel? senderUser = await _userService.selectData(
          id: mapNoticeUser.id,
        );
        if (senderUser == null) continue;
        List<Map> mapSendUsers = [];
        if (senderUser.mapSendUsers.isNotEmpty) {
          for (MapSendUserModel mapSendUser in senderUser.mapSendUsers) {
            if (mapSendUser.id != _user!.id) {
              mapSendUsers.add(mapSendUser.toMap());
            }
          }
        }
        _userService.update({
          'id': senderUser.id,
          'mapSendUsers': mapSendUsers,
        });
      }
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> addMapSendUsers({
    required String email,
  }) async {
    String? error;
    if (email == '') return 'メールアドレスは必須入力です';
    try {
      //送信者側の追加
      UserModel? noticeUser = await _userService.selectData(
        email: email,
      );
      if (noticeUser == null) return 'メールアドレスが見つかりませんでした';
      List<Map> mapSendUsers = [];
      if (_user!.mapSendUsers.isNotEmpty) {
        for (MapSendUserModel mapSendUser in _user!.mapSendUsers) {
          mapSendUsers.add(mapSendUser.toMap());
        }
      }
      mapSendUsers.add({
        'id': noticeUser.id,
        'name': noticeUser.name,
        'email': noticeUser.email,
      });
      _userService.update({
        'id': _user?.id,
        'mapSendUsers': mapSendUsers,
      });
      //受信者側の追加
      List<Map> mapNoticeUsers = [];
      if (noticeUser.mapNoticeUsers.isNotEmpty) {
        for (MapNoticeUserModel mapNoticeUser in noticeUser.mapNoticeUsers) {
          mapNoticeUsers.add(mapNoticeUser.toMap());
        }
      }
      mapNoticeUsers.add({
        'id': _user!.id,
        'senderNumber': _user!.senderNumber,
        'senderName': _user!.senderName,
      });
      _userService.update({
        'id': noticeUser.id,
        'mapNoticeUsers': mapNoticeUsers,
      });
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> removeMapSendUsers({
    required List<MapSendUserModel> deleteMapSendUsers,
  }) async {
    String? error;
    if (deleteMapSendUsers.isEmpty) return '送信先の削除に失敗しました';
    try {
      //送信者側の削除
      List<Map> mapSendUsers = [];
      if (_user!.mapSendUsers.isNotEmpty) {
        for (MapSendUserModel mapSendUser in _user!.mapSendUsers) {
          if (!deleteMapSendUsers.contains(mapSendUser)) {
            mapSendUsers.add(mapSendUser.toMap());
          }
        }
      }
      _userService.update({
        'id': _user?.id,
        'mapSendUsers': mapSendUsers,
      });
      //受信者側の削除
      for (MapSendUserModel mapSendUser in deleteMapSendUsers) {
        UserModel? noticeUser = await _userService.selectData(
          id: mapSendUser.id,
        );
        if (noticeUser == null) continue;
        List<Map> mapNoticeUsers = [];
        if (noticeUser.mapNoticeUsers.isNotEmpty) {
          for (MapNoticeUserModel mapNoticeUser in noticeUser.mapNoticeUsers) {
            if (mapNoticeUser.id != _user!.id) {
              mapNoticeUsers.add(mapNoticeUser.toMap());
            }
          }
        }
        _userService.update({
          'id': noticeUser.id,
          'mapNoticeUsers': mapNoticeUsers,
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
      UserModel? tmpUser;
      String senderNumber = randomNumber(8);
      while (tmpUser != null) {
        tmpUser = await _userService.selectData(
          senderNumber: senderNumber,
        );
        if (tmpUser == null) {
          senderNumber = randomNumber(8);
        }
      }
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
        'createdUserName': _user!.senderName,
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
    required List<MapSendUserModel> sendMapSendUsers,
  }) async {
    String? error;
    if (sendMapSendUsers.isEmpty) return '送信先が一件もありません';
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
          'createdUserName': _user!.senderName,
          'createdAt': DateTime.now(),
        });
      }
      for (MapSendUserModel mapSendUser in sendMapSendUsers) {
        UserModel? noticeUser = await _userService.selectData(
          id: mapSendUser.id,
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
          'createdUserName': _user!.senderName,
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
