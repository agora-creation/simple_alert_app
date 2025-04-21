import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simple_alert_app/common/functions.dart';
import 'package:simple_alert_app/models/send_user.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/models/user_notice.dart';
import 'package:simple_alert_app/models/user_noticer.dart';
import 'package:simple_alert_app/models/user_send.dart';
import 'package:simple_alert_app/models/user_sender.dart';
import 'package:simple_alert_app/services/push.dart';
import 'package:simple_alert_app/services/user.dart';
import 'package:simple_alert_app/services/user_notice.dart';
import 'package:simple_alert_app/services/user_noticer.dart';
import 'package:simple_alert_app/services/user_send.dart';
import 'package:simple_alert_app/services/user_sender.dart';

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
  final UserNoticerService _userNoticerService = UserNoticerService();
  final UserSenderService _userSenderService = UserSenderService();
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

  //受信者側が送信者情報を登録する
  Future<String?> addSenderUser({
    required UserModel senderUser,
  }) async {
    String? error;
    try {
      //受信者側の登録処理
      UserSenderModel? userSender = await _userSenderService.selectData(
        userId: _user!.id,
        senderUserId: senderUser.id,
      );
      if (userSender == null) {
        String userSenderId = _userSenderService.id(userId: _user!.id);
        _userSenderService.create({
          'id': userSenderId,
          'userId': _user?.id,
          'senderUserId': senderUser.id,
          'senderUserName': senderUser.senderName,
          'block': false,
        });
      }
      //送信者側の登録処理
      UserNoticerModel? userNoticer = await _userNoticerService.selectData(
        userId: senderUser.id,
        noticerUserId: _user!.id,
      );
      if (userNoticer == null) {
        String userNoticerId = _userNoticerService.id(userId: senderUser.id);
        _userNoticerService.create({
          'id': userNoticerId,
          'userId': senderUser.id,
          'noticerUserId': _user?.id,
          'noticerUserName': _user?.name,
          'block': false,
        });
      }
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  //受信者側が登録した送信者情報を削除する
  Future<String?> removeUserSender({
    required UserSenderModel userSender,
  }) async {
    String? error;
    try {
      //受信者側の削除処理
      _userSenderService.delete({
        'id': userSender.id,
        'userId': userSender.userId,
      });
      //送信者側の削除処理
      UserNoticerModel? userNoticer = await _userNoticerService.selectData(
        userId: userSender.id,
        noticerUserId: userSender.userId,
      );
      if (userNoticer != null) {
        _userNoticerService.delete({
          'id': userNoticer.id,
          'userId': userNoticer.userId,
        });
      }
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  //送信者側が登録した受信者情報を削除する
  Future<String?> removeUserNoticer({
    required UserNoticerModel userNoticer,
  }) async {
    String? error;
    try {
      //送信者側の削除処理
      _userNoticerService.delete({
        'id': userNoticer.id,
        'userId': userNoticer.userId,
      });
      //受信者側の削除処理
      UserSenderModel? userSender = await _userSenderService.selectData(
        userId: userNoticer.id,
        senderUserId: userNoticer.userId,
      );
      if (userSender != null) {
        _userSenderService.delete({
          'id': userSender.id,
          'userId': userSender.userId,
        });
      }
    } catch (e) {
      error = e.toString();
    }
    return error;
  }

  Future<String?> blockUserSender({
    required UserSenderModel userSender,
  }) async {
    String? error;
    try {
      //受信者側の更新処理
      _userSenderService.update({
        'id': userSender.id,
        'userId': userSender.userId,
        'block': true,
      });
      //送信者側の更新処理
      UserNoticerModel? userNoticer = await _userNoticerService.selectData(
        userId: userSender.id,
        noticerUserId: userSender.userId,
      );
      if (userNoticer != null) {
        _userNoticerService.update({
          'id': userNoticer.id,
          'userId': userNoticer.userId,
          'block': true,
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
        'sendUsers': [],
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
    required List<SendUserModel> selectedSendUsers,
  }) async {
    String? error;
    if (title == '') return '件名は必須入力です';
    if (content == '') return '内容は必須入力です';
    if (isChoice && choices.isEmpty) {
      return '選択肢が設定されていません';
    }
    try {
      List<Map> mapSendUsers = [];
      if (selectedSendUsers.isNotEmpty) {
        for (final selectSendUser in selectedSendUsers) {
          mapSendUsers.add(selectSendUser.toMap());
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
          'sendUsers': mapSendUsers,
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
          'sendUsers': mapSendUsers,
          'createdUserId': _user!.id,
          'createdUserName': _user!.name,
          'createdAt': DateTime.now(),
        });
        userSendId = id;
      }
      if (selectedSendUsers.isNotEmpty) {
        for (final selectSendUser in selectedSendUsers) {
          UserModel? noticeUser = await _userService.selectData(
            id: selectSendUser.id,
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
        List<Map> mapSendUsers = [];
        if (userSend.sendUsers.isNotEmpty) {
          for (final sendUser in userSend.sendUsers) {
            if (sendUser.id == userNotice.userId) {
              sendUser.answer = answer;
            }
            mapSendUsers.add(sendUser.toMap());
          }
        }
        _userSendService.update({
          'id': userSend.id,
          'userId': userSend.userId,
          'sendUsers': mapSendUsers,
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
