import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass.dart';
import '../../providers/providers.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (email.isEmpty || password.isEmpty || (!_isLogin && name.isEmpty)) {
      _showError('Lütfen tüm alanları doldurun.');
      return;
    }
    setState(() => _loading = true);
    try {
      final auth = ref.read(authServiceProvider);
      if (_isLogin) {
        await auth.signInWithEmail(email: email, password: password);
      } else {
        await auth.registerWithEmail(name: name, email: email, password: password);
      }
    } catch (e) {
      _showError(_friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _loading = true);
    try {
      await ref.read(authServiceProvider).signInWithGoogle();
    } catch (e) {
      _showError(_friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('user-not-found') || msg.contains('wrong-password') || msg.contains('invalid-credential')) {
      return 'E-posta veya şifre hatalı.';
    }
    if (msg.contains('email-already-in-use')) return 'Bu e-posta zaten kayıtlı.';
    if (msg.contains('weak-password')) return 'Şifre en az 6 karakter olmalı.';
    if (msg.contains('invalid-email')) return 'Geçerli bir e-posta girin.';
    return 'Bir hata oluştu. Lütfen tekrar deneyin.';
  }

  void _showError(String message) {
    showCupertinoDialog<void>(
      context: context,
      builder: (_) => CupertinoAlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('Tamam'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: const Color(0x00000000),
      child: GlassBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: GlassSurface(
                padding: const EdgeInsets.all(24),
                borderRadius: 28,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(CupertinoIcons.arrow_right_arrow_left,
                          color: CupertinoColors.white, size: 36),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Takas',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _isLogin ? 'Hesabına giriş yap' : 'Yeni hesap oluştur',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
                    ),
                    const SizedBox(height: 24),
                    if (!_isLogin) ...[
                      _field(_nameCtrl, 'Ad Soyad', CupertinoIcons.person),
                      const SizedBox(height: 12),
                    ],
                    _field(_emailCtrl, 'E-posta', CupertinoIcons.mail,
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 12),
                    _field(_passwordCtrl, 'Şifre', CupertinoIcons.lock, obscure: true),
                    const SizedBox(height: 20),
                    GlassButton(
                      label: _loading ? 'Lütfen bekleyin...' : (_isLogin ? 'Giriş Yap' : 'Kayıt Ol'),
                      onPressed: _loading ? null : _submit,
                    ),
                    const SizedBox(height: 12),
                    GlassButton(
                      label: 'Google ile devam et',
                      icon: CupertinoIcons.globe,
                      filled: false,
                      onPressed: _loading ? null : _google,
                    ),
                    const SizedBox(height: 16),
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin ? 'Hesabın yok mu? Kayıt ol' : 'Zaten hesabın var mı? Giriş yap',
                        style: const TextStyle(color: AppColors.accent, fontSize: 14),
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

  Widget _field(
    TextEditingController controller,
    String placeholder,
    IconData icon, {
    bool obscure = false,
    TextInputType? keyboardType,
  }) {
    return CupertinoTextField(
      controller: controller,
      placeholder: placeholder,
      obscureText: obscure,
      keyboardType: keyboardType,
      prefix: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Icon(icon, color: AppColors.textTertiary, size: 20),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      style: const TextStyle(color: AppColors.textPrimary),
      placeholderStyle: const TextStyle(color: AppColors.textTertiary),
      decoration: BoxDecoration(
        color: const Color(0x1AFFFFFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x33FFFFFF)),
      ),
    );
  }
}
