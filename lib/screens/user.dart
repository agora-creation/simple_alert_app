import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';
import 'package:simple_alert_app/widgets/custom_text_form_field.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    bool isLogin = false;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Card(
          color: kWhiteColor,
          elevation: 0,
          child: isLogin
              ? Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: kBlackColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text('名前'),
                        trailing: Text(
                          '山田太郎',
                          style: TextStyle(fontSize: 14),
                        ),
                        onTap: () {},
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: kBlackColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text('メールアドレス'),
                        trailing: Text(
                          'yamada@agora-c.com',
                          style: TextStyle(fontSize: 14),
                        ),
                        onTap: () {},
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: kBlackColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text('パスワード'),
                        trailing: Text(
                          '********',
                          style: TextStyle(fontSize: 14),
                        ),
                        onTap: () {},
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: kBlackColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text('送信者登録'),
                        trailing: Text(
                          'サブスク課金',
                          style: TextStyle(fontSize: 14),
                        ),
                        onTap: () {},
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: kBlackColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text('送信先一覧'),
                        trailing: const FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 16,
                        ),
                        onTap: () {},
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: kBlackColor.withOpacity(0.5),
                          ),
                        ),
                      ),
                      child: ListTile(
                        title: Text('受信先一覧'),
                        trailing: const FaIcon(
                          FontAwesomeIcons.chevronRight,
                          size: 16,
                        ),
                        onTap: () {},
                      ),
                    ),
                  ],
                )
              : GestureDetector(
                  onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                    child: DefaultTabController(
                      initialIndex: 0,
                      length: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TabBar(
                            tabs: [
                              Tab(text: '初めての方'),
                              Tab(text: '既に登録済の方'),
                            ],
                            indicatorColor: kRedColor,
                            labelColor: kBlackColor,
                            unselectedLabelColor: kBlackColor.withOpacity(0.5),
                          ),
                          Expanded(
                            child: TabBarView(
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '本アプリをご利用いただくには、以下の情報のご登録が必要です。あらかじめご了承ください。',
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextFormField(
                                      controller: TextEditingController(),
                                      textInputType: TextInputType.name,
                                      maxLines: 1,
                                      label: '名前',
                                      color: kBlackColor,
                                      prefix: Icons.account_box,
                                    ),
                                    const SizedBox(height: 8),
                                    CustomTextFormField(
                                      controller: TextEditingController(),
                                      textInputType: TextInputType.emailAddress,
                                      maxLines: 1,
                                      label: 'メールアドレス',
                                      color: kBlackColor,
                                      prefix: Icons.email,
                                    ),
                                    const SizedBox(height: 8),
                                    CustomTextFormField(
                                      controller: TextEditingController(),
                                      obscureText: true,
                                      textInputType:
                                          TextInputType.visiblePassword,
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
                                      onPressed: () async {},
                                    ),
                                  ],
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '本アプリを既にご利用いただいたことがある方は、登録時のメールアドレスやパスワードでログインすることで、情報を引き継いで利用することが可能です。',
                                    ),
                                    const SizedBox(height: 16),
                                    CustomTextFormField(
                                      controller: TextEditingController(),
                                      textInputType: TextInputType.emailAddress,
                                      maxLines: 1,
                                      label: 'メールアドレス',
                                      color: kBlackColor,
                                      prefix: Icons.email,
                                    ),
                                    const SizedBox(height: 8),
                                    CustomTextFormField(
                                      controller: TextEditingController(),
                                      obscureText: true,
                                      textInputType:
                                          TextInputType.visiblePassword,
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
                                      onPressed: () async {},
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
