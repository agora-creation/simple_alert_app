import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:restart_app/restart_app.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/models/user.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/user_email.dart';
import 'package:simple_alert_app/screens/user_name.dart';
import 'package:simple_alert_app/screens/user_password.dart';
import 'package:simple_alert_app/screens/user_sender.dart';
import 'package:simple_alert_app/screens/user_sender_user.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';
import 'package:simple_alert_app/widgets/link_text.dart';
import 'package:simple_alert_app/widgets/sign_panel.dart';
import 'package:simple_alert_app/widgets/user_list.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    UserModel? user = userProvider.user;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          color: kWhiteColor,
          elevation: 0,
          shape: RoundedRectangleBorder(),
          child: userProvider.loginCheck()
              ? ListView(
                  children: [
                    UserList(
                      label: '名前',
                      subtitle: Text(
                        user?.name ?? '',
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: const FaIcon(
                        FontAwesomeIcons.pen,
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: UserNameScreen(
                              user: userProvider.user!,
                            ),
                          ),
                        );
                      },
                    ),
                    UserList(
                      label: 'メールアドレス',
                      subtitle: Text(
                        user?.email ?? '',
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: const FaIcon(
                        FontAwesomeIcons.pen,
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: UserEmailScreen(
                              user: userProvider.user!,
                            ),
                          ),
                        );
                      },
                    ),
                    UserList(
                      label: 'パスワード',
                      subtitle: Text(
                        '********',
                        style: TextStyle(fontSize: 14),
                      ),
                      trailing: const FaIcon(
                        FontAwesomeIcons.pen,
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: UserPasswordScreen(),
                          ),
                        );
                      },
                    ),
                    UserList(
                      label: '受信先一覧',
                      trailing: const FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          PageTransition(
                            type: PageTransitionType.rightToLeft,
                            child: UserSenderUserScreen(
                              user: userProvider.user!,
                            ),
                          ),
                        );
                      },
                    ),
                    user!.isSender
                        ? UserList(
                            label: '送信者情報',
                            subtitle: Text(
                              userProvider.user!.senderName,
                              style: TextStyle(fontSize: 14),
                            ),
                            leading: const FaIcon(
                              FontAwesomeIcons.userTag,
                              size: 16,
                            ),
                            trailing: const FaIcon(
                              FontAwesomeIcons.chevronRight,
                              size: 16,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: UserSenderScreen(
                                    user: userProvider.user!,
                                  ),
                                ),
                              );
                            },
                          )
                        : UserList(
                            label: '送信者として登録',
                            subtitle: Text(
                              '※サブスク課金が必要になります',
                              style: TextStyle(
                                color: kRedColor,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'SourceHanSansJP-Bold',
                              ),
                            ),
                            leading: const FaIcon(
                              FontAwesomeIcons.userTag,
                              size: 16,
                            ),
                            trailing: const FaIcon(
                              FontAwesomeIcons.chevronRight,
                              size: 16,
                            ),
                            tileColor: kRedColor.withOpacity(0.3),
                            onTap: () {
                              Navigator.push(
                                context,
                                PageTransition(
                                  type: PageTransitionType.rightToLeft,
                                  child: UserSenderScreen(
                                    user: userProvider.user!,
                                  ),
                                ),
                              );
                            },
                          ),
                    SizedBox(height: 24),
                    Center(
                      child: LinkText(
                        label: 'ログアウト',
                        color: kRedColor,
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => LogoutDialog(),
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                )
              : GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  behavior: HitTestBehavior.opaque,
                  child: SignPanel(
                    signUpChild: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            '本アプリをご利用いただくには、以下の情報のご登録が必要です。あらかじめご了承ください。',
                          ),
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            controller: nameController,
                            textInputType: TextInputType.name,
                            maxLines: 1,
                            label: '名前',
                            color: kBlackColor,
                            prefix: Icons.account_box,
                          ),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: emailController,
                            textInputType: TextInputType.emailAddress,
                            maxLines: 1,
                            label: 'メールアドレス',
                            color: kBlackColor,
                            prefix: Icons.email,
                          ),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: passwordController,
                            obscureText: true,
                            textInputType: TextInputType.visiblePassword,
                            maxLines: 1,
                            label: 'パスワード',
                            color: kBlackColor,
                            prefix: Icons.password,
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            type: ButtonSizeType.lg,
                            label: '登録して始める',
                            labelColor: kBlackColor,
                            backgroundColor: kBackgroundColor,
                            onPressed: () async {
                              String? error = await userProvider.registration(
                                name: nameController.text,
                                email: emailController.text,
                                password: passwordController.text,
                              );
                              if (error != null) {
                                return;
                              }
                              await userProvider.reload();
                              Restart.restartApp(
                                notificationTitle: 'アプリの再起動',
                                notificationBody:
                                    'ログイン情報を再読み込みするため、アプリを再起動します。',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    signInChild: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            '本アプリを既にご利用いただいたことがある方は、登録時のメールアドレスやパスワードでログインすることで、情報を引き継いで利用することが可能です。',
                          ),
                          const SizedBox(height: 16),
                          CustomTextFormField(
                            controller: emailController,
                            textInputType: TextInputType.emailAddress,
                            maxLines: 1,
                            label: 'メールアドレス',
                            color: kBlackColor,
                            prefix: Icons.email,
                          ),
                          const SizedBox(height: 8),
                          CustomTextFormField(
                            controller: passwordController,
                            obscureText: true,
                            textInputType: TextInputType.visiblePassword,
                            maxLines: 1,
                            label: 'パスワード',
                            color: kBlackColor,
                            prefix: Icons.password,
                          ),
                          const SizedBox(height: 16),
                          CustomButton(
                            type: ButtonSizeType.lg,
                            label: 'ログイン',
                            labelColor: kBlackColor,
                            backgroundColor: kBackgroundColor,
                            onPressed: () async {
                              String? error = await userProvider.login(
                                email: emailController.text,
                                password: passwordController.text,
                              );
                              if (error != null) {
                                return;
                              }
                              await userProvider.reload();
                              Restart.restartApp(
                                notificationTitle: 'アプリの再起動',
                                notificationBody:
                                    'ログイン情報を再読み込みするため、アプリを再起動します。',
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class LogoutDialog extends StatelessWidget {
  const LogoutDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return CustomAlertDialog(
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text(
            '本当にログアウトしますか？',
            style: TextStyle(color: kRedColor),
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: ButtonSizeType.sm,
          label: 'キャンセル',
          labelColor: kWhiteColor,
          backgroundColor: kBlackColor.withOpacity(0.5),
          onPressed: () => Navigator.pop(context),
        ),
        CustomButton(
          type: ButtonSizeType.sm,
          label: 'ログアウト',
          labelColor: kWhiteColor,
          backgroundColor: kRedColor,
          onPressed: () async {
            await userProvider.logout();
            Restart.restartApp(
              notificationTitle: 'アプリの再起動',
              notificationBody: 'ログイン情報を再読み込みするため、アプリを再起動します。',
            );
          },
        ),
      ],
    );
  }
}
