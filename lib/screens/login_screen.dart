import 'package:flutter/material.dart';

import '../account_store.dart';
import '../models.dart';
import '../theme.dart';
import '../xtream_api.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _server = TextEditingController();
  final _user = TextEditingController();
  final _pass = TextEditingController();
  bool _busy = false;
  bool _hidePass = true;
  String? _error;

  @override
  void dispose() {
    _server.dispose();
    _user.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _openDemo() async {
    await AccountStore.save(Account.demo);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen(account: Account.demo)),
    );
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_server.text.trim().isEmpty) {
      setState(() => _error = 'Sunucu adresini girin.');
      return;
    }
    final account = Account.fromInput(_server.text, _user.text, _pass.text);
    if (account.username.isEmpty || account.password.isEmpty) {
      setState(() => _error = 'Kullanıcı adı ve şifreyi girin.');
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await XtreamApi(account).login();
      await AccountStore.save(account);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomeScreen(account: account)),
      );
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: AlpaColors.navy,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/logo.png', height: 110),
                  const SizedBox(height: 12),
                  const Text(
                    'Alpa Player',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AlpaColors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'IPTV hesabınızla giriş yapın',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: AlpaColors.white.withValues(alpha: 0.75)),
                  ),
                  const SizedBox(height: 28),
                  Card(
                    color: AlpaColors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _server,
                            keyboardType: TextInputType.url,
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Sunucu adresi (link)',
                              hintText: 'http://ornek.com:8080',
                              prefixIcon: Icon(Icons.link),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _user,
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            decoration: const InputDecoration(
                              labelText: 'Kullanıcı adı',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextField(
                            controller: _pass,
                            obscureText: _hidePass,
                            autocorrect: false,
                            onSubmitted: (_) => _submit(),
                            decoration: InputDecoration(
                              labelText: 'Şifre',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(_hidePass
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () =>
                                    setState(() => _hidePass = !_hidePass),
                              ),
                            ),
                          ),
                          if (_error != null) ...[
                            const SizedBox(height: 14),
                            Text(_error!,
                                style:
                                    TextStyle(color: theme.colorScheme.error)),
                          ],
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: _busy ? null : _submit,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              child: _busy
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AlpaColors.white))
                                  : const Text('Giriş yap',
                                      style: TextStyle(fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _busy ? null : _openDemo,
                    icon: const Icon(Icons.play_circle_outline,
                        color: AlpaColors.white),
                    label: const Text(
                      'Demo modunu dene',
                      style: TextStyle(color: AlpaColors.white, fontSize: 15),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Alpa Player yalnızca bir medya oynatıcıdır; herhangi bir '
                    'kanal, yayın veya içerik sağlamaz. İzleyeceğiniz içeriği '
                    'kendi IPTV sağlayıcınızdan almanız ve bu içeriği izleme '
                    'hakkına sahip olmanız gerekir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        color: AlpaColors.white.withValues(alpha: 0.6)),
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
