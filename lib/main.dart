import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';

import 'account_store.dart';
import 'ad_service.dart';
import 'models.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final account = await AccountStore.load();
  runApp(AlpaApp(initialAccount: account));
  AdService.instance.init();
}

class AlpaApp extends StatelessWidget {
  final Account? initialAccount;
  const AlpaApp({super.key, this.initialAccount});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alpa Player',
      debugShowCheckedModeBanner: false,
      theme: buildAlpaTheme(),
      home: initialAccount == null
          ? const LoginScreen()
          : HomeScreen(account: initialAccount!),
    );
  }
}
