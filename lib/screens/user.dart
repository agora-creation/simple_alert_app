import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/providers/user.dart';
import 'package:simple_alert_app/screens/home.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          color: kWhiteColor,
          elevation: 0,
          child: userProvider.loginCheck()
              ? Column(
                  children: [
                    UserList(
                      label: '名前',
                      trailing: Text(
                        '山田太郎',
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () {},
                    ),
                    UserList(
                      label: 'メールアドレス',
                      trailing: Text(
                        'yamada@agora-c.com',
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () {},
                    ),
                    UserList(
                      label: 'パスワード',
                      trailing: Text(
                        '********',
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () {},
                    ),
                    UserList(
                      label: '送信者登録',
                      trailing: Text(
                        'サブスク課金',
                        style: TextStyle(fontSize: 14),
                      ),
                      onTap: () {},
                    ),
                    UserList(
                      label: '送信先一覧',
                      trailing: const FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 16,
                      ),
                      onTap: () {},
                    ),
                    UserList(
                      label: '受信先一覧',
                      trailing: const FaIcon(
                        FontAwesomeIcons.chevronRight,
                        size: 16,
                      ),
                      onTap: () {},
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  behavior: HitTestBehavior.opaque,
                  child: SignPanel(
                    signUpChild: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: const HomeScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    signInChild: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                            if (!mounted) return;
                            Navigator.pushReplacement(
                              context,
                              PageTransition(
                                type: PageTransitionType.bottomToTop,
                                child: const HomeScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
