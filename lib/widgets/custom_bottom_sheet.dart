import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:simple_alert_app/common/style.dart';
import 'package:simple_alert_app/widgets/custom_alert_dialog.dart';
import 'package:simple_alert_app/widgets/custom_button.dart';

class CustomBottomSheet extends StatefulWidget {
  const CustomBottomSheet({super.key});

  @override
  State<CustomBottomSheet> createState() => _CustomBottomSheetState();
}

class _CustomBottomSheetState extends State<CustomBottomSheet>
    with WidgetsBindingObserver {
  final _remoteConfig = FirebaseRemoteConfig.instance;

  Future _initRemoteConfig() async {
    await _remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: Duration.zero,
    ));
    await _remoteConfig.fetchAndActivate();
    _checkForceUpdate();
  }

  void _checkForceUpdate() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final requiredVersion = _remoteConfig.getString(
      'force_update_current_version',
    );
    final forceUpdate = _remoteConfig.getBool(
      'force_update_required',
    );
    if (forceUpdate && _isVersionLower(currentVersion, requiredVersion)) {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => UpdateDialog(),
      );
    }
  }

  bool _isVersionLower(String current, String required) {
    final currentVersion = current.split('+')[0];
    final requiredVersion = required.split('+')[0];
    final currentParts = currentVersion
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    final requiredParts = requiredVersion
        .split('.')
        .map((part) => int.tryParse(part) ?? 0)
        .toList();
    while (currentParts.length < 3) {
      currentParts.add(0);
    }
    while (requiredParts.length < 3) {
      requiredParts.add(0);
    }
    for (int i = 0; i < 3; i++) {
      if (currentParts[i] < requiredParts[i]) return true;
      if (currentParts[i] > requiredParts[i]) return false;
    }
    return false;
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {});
    FlutterAppBadger.removeBadge();
    super.initState();
    // _initRemoteConfig();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      FlutterAppBadger.removeBadge();
    } else if (state == AppLifecycleState.paused) {
    } else if (state == AppLifecycleState.detached) {}
  }

  @override
  Widget build(BuildContext context) {
    return Container(height: 0);
  }
}

class UpdateDialog extends StatelessWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomAlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 8),
          Text('アップデートが必要です。'),
          Text('新しいバージョンのアプリが必要です。現在のバージョンではアプリを使用できません。'),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        CustomButton(
          type: ButtonSizeType.sm,
          label: '閉じる',
          labelColor: kWhiteColor,
          backgroundColor: kBlackColor.withOpacity(0.5),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }
}
