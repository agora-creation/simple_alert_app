import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/models/map_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_notice.dart';
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

enum HomeMode { notice, send }

class UserProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized;
  AuthStatus get status => _status;
  final FirebaseAuth? _auth;
  User? _authUser;
  User? get authUser => _authUser;
  String _verificationId = '';
  HomeMode mode = HomeMode.values.first;

  final PushService _pushService = PushService();
  final UserService _userService = UserService();
  final UserNoticeService _userNoticeService = UserNoticeService();
  final UserSendService _userSendService = UserSendService();

  UserModel? _user;
  UserModel? get user => _user;

  UserProvider.initialize() : _auth = FirebaseAuth.instance {
    _auth?.authStateChanges().listen(_onStateChanged);
  }

  Future modeChange(HomeMode newMode) async {
    mode = newMode;
    await setPrefsInt('modeIndex', mode.index);
    notifyListeners();
  }

  Future<({bool autoAuth, String? error})> signIn({
    required String name,
    required String tel,
  }) async {
    bool autoAuth = false;
    String? error;
    if (name == '') return (autoAuth: false, error: '名前は必須入力です');
    if (tel == '') return (autoAuth: false, error: '電話番号は必須入力です');
    try {
      String remove0Tel = tel.substring(1);
      String phoneNumber = '+81$remove0Tel';
      await _auth?.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          //Androidの自動認証が有効になっている場合
          final result = await _auth.signInWithCredential(credential);
          if (result.user != null) {
            autoAuth = true;
            String token = await _pushService.getFcmToken() ?? '';
            UserModel? tmpUser = await _userService.selectData(
              id: result.user!.uid,
            );
            if (tmpUser == null) {
              _userService.create({
                'id': result.user!.uid,
                'name': name,
                'tel': tel,
                'token': token,
                'sender': false,
                'senderName': '',
                'noticeMapUsers': [],
                'sendMapUsers': [],
              });
            } else {
              _userService.update({
                'id': tmpUser.id,
                'name': name,
                'token': token,
              });
            }
            _authUser = result.user;
          }
        },
        verificationFailed: (e) {
          error = e.toString();
        },
        codeSent: (verificationId, resendToken) {
          //SMS送信成功
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (verificationId) {},
        forceResendingToken: null,
      );
    } catch (e) {
      error = '認証に失敗しました';
    }
    notifyListeners();
    return (autoAuth: autoAuth, error: error);
  }

  Future<String?> signInConf({
    required String name,
    required String tel,
    required String smsCode,
  }) async {
    String? error;
    if (smsCode == '') return '認証コードは必須入力です';
    try {
      _status = AuthStatus.authenticating;
      notifyListeners();
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      final result = await _auth?.signInWithCredential(credential);
      if (result != null) {
        if (result.user != null) {
          String token = await _pushService.getFcmToken() ?? '';
          UserModel? tmpUser = await _userService.selectData(
            id: result.user!.uid,
          );
          if (tmpUser == null) {
            _userService.create({
              'id': result.user!.uid,
              'name': name,
              'tel': tel,
              'token': token,
              'sender': false,
              'senderName': '',
              'noticeMapUsers': [],
              'sendMapUsers': [],
            });
          } else {
            _userService.update({
              'id': tmpUser.id,
              'name': name,
              'token': token,
            });
          }
          _authUser = result.user;
        }
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      error = e.toString();
    }
    notifyListeners();
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

  Future<String?> updateSender({
    required String senderName,
  }) async {
    String? error;
    if (senderName == '') return '送信者名は必須入力です';
    try {
      _userService.update({
        'id': _user?.id,
        'sender': true,
        'senderName': senderName,
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

  Future<String?> addNoticeMapUsers({
    required UserModel senderUser,
  }) async {
    String? error;
    try {
      //受信者側のデータ追加
      List<Map> noticeMapUsers = [];
      if (_user!.noticeMapUsers.isNotEmpty) {
        for (MapUserModel mapUser in _user!.noticeMapUsers) {
          noticeMapUsers.add(mapUser.toMap());
        }
      }
      noticeMapUsers.add({
        'id': senderUser.id,
        'name': senderUser.senderName,
      });
      _userService.update({
        'id': _user?.id,
        'noticeMapUsers': noticeMapUsers,
      });
      //送信者側のデータ追加
      List<Map> sendMapUsers = [];
      if (senderUser.sendMapUsers.isNotEmpty) {
        for (MapUserModel mapUser in senderUser.sendMapUsers) {
          sendMapUsers.add(mapUser.toMap());
        }
      }
      sendMapUsers.add({
        'id': _user!.id,
        'name': _user!.name,
        'tel': _user!.tel,
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
      //受信者側のデータ削除
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
      //送信者側のデータ削除
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

  Future<String?> removeSendMapUsers({
    required List<MapUserModel> selectedSendMapUsers,
  }) async {
    String? error;
    if (selectedSendMapUsers.isEmpty) return '選択されていません';
    try {
      //送信者側のデータ削除
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
      //受信者側のデータ削除
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

  Future<String?> createSendDraft({
    required String title,
    required String content,
    required bool isChoice,
    required List<String> choices,
  }) async {
    String? error;
    if (title == '') return '件名は必須入力です';
    if (content == '') return '内容は必須入力です';
    if (isChoice && choices.isEmpty) {
      return '選択肢が設定されていません';
    }
    try {
      String id = _userSendService.id(userId: _user!.id);
      _userSendService.create({
        'id': id,
        'userId': _user?.id,
        'title': title,
        'content': content,
        'isChoice': isChoice,
        'choices': choices,
        'draft': true,
        'sendAt': DateTime.now(),
        'sendMapUsers': [],
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
    required bool isChoice,
    required List<String> choices,
  }) async {
    String? error;
    if (title == '') return '件名は必須入力です';
    if (content == '') return '内容は必須入力です';
    if (isChoice && choices.isEmpty) {
      return '選択肢が設定されていません';
    }
    try {
      _userSendService.update({
        'id': userSend.id,
        'userId': userSend.userId,
        'title': title,
        'content': content,
        'isChoice': isChoice,
        'choices': choices,
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
    required bool isChoice,
    required List<String> choices,
    required List<MapUserModel> selectedSendMapUsers,
  }) async {
    String? error;
    if (title == '') return '件名は必須入力です';
    if (content == '') return '内容は必須入力です';
    if (isChoice && choices.isEmpty) {
      return '選択肢が設定されていません';
    }
    try {
      List<Map> sendMapUsers = [];
      if (selectedSendMapUsers.isNotEmpty) {
        for (MapUserModel mapUser in selectedSendMapUsers) {
          sendMapUsers.add(mapUser.toMap());
        }
      }
      String userSendId = '';
      if (userSend != null) {
        _userSendService.update({
          'id': userSend.id,
          'userId': userSend.userId,
          'title': title,
          'content': content,
          'isChoice': isChoice,
          'choices': choices,
          'draft': false,
          'sendAt': DateTime.now(),
          'sendMapUsers': sendMapUsers,
        });
        userSendId = userSend.id;
      } else {
        String id = _userSendService.id(userId: _user!.id);
        _userSendService.create({
          'id': id,
          'userId': _user?.id,
          'title': title,
          'content': content,
          'isChoice': isChoice,
          'choices': choices,
          'draft': false,
          'sendAt': DateTime.now(),
          'sendMapUsers': sendMapUsers,
          'createdUserId': _user!.id,
          'createdUserName': _user!.name,
          'createdAt': DateTime.now(),
        });
        userSendId = id;
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
          'userSendId': userSendId,
          'title': title,
          'content': content,
          'isChoice': isChoice,
          'choices': choices,
          'answer': '',
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

  Future<String?> answer({
    required UserNoticeModel userNotice,
    required String answer,
  }) async {
    String? error;
    if (answer == '') return '回答が選択されていません';
    try {
      _userNoticeService.update({
        'id': userNotice.id,
        'userId': userNotice.userId,
        'answer': answer,
      });
      UserSendModel? userSend = await _userSendService.selectData(
        id: userNotice.userSendId,
        userId: userNotice.userId,
      );
      if (userSend != null) {
        List<Map> sendMapUsers = [];
        if (userSend.sendMapUsers.isNotEmpty) {
          for (MapUserModel mapUser in userSend.sendMapUsers) {
            if (mapUser.id == userNotice.userId) {
              mapUser.answer = answer;
            }
            sendMapUsers.add(mapUser.toMap());
          }
        }
        _userSendService.update({
          'id': userSend.id,
          'userId': userSend.userId,
          'sendMapUsers': sendMapUsers,
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
    await allRemovePrefs();
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
    int modeIndex =
        await getPrefsInt('modeIndex') ?? HomeMode.values.first.index;
    mode = HomeMode.values[modeIndex];
    notifyListeners();
  }
}
