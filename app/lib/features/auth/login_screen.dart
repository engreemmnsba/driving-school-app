import 'package:flutter/material.dart';

import '../../core/auth/saved_accounts.dart';
import '../../core/ui/tokens.dart';

/// Login with national ID + password set by the Admin (DECISIONS A11: no SMS/OTP). Canvas: Login.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin, this.initialError, this.schoolName = 'مدرسة القيادة', this.savedAccounts});

  /// Accounts that signed in on this device (tap = fill the ID). Defaults to the device store.
  final SavedAccounts? savedAccounts;

  /// Throws an exception whose toString() is the message to show.
  final Future<void> Function(String nationalId, String password) onLogin;
  final String? initialError;

  /// Comes from school settings (with the logo) once they sync; shown before the first login too.
  final String schoolName;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// School brand colour — login screen only; the rest of the app keeps the design tokens.
const _brand = Color(0xFF0E5A5F);

class _LoginScreenState extends State<LoginScreen> {
  final _id = TextEditingController();
  final _pw = TextEditingController();
  final _pwFocus = FocusNode();
  late final SavedAccounts _store = widget.savedAccounts ?? SavedAccounts();
  List<SavedAccount> _saved = const [];
  bool _hidden = true;
  bool _busy = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _error = widget.initialError;
    _store.list().then((v) {
      if (mounted) setState(() => _saved = v);
    });
  }

  /// A saved account picked from the list: its ID is used to sign in but never shown in full
  /// (shared office computers — A35). Typing in the ID field drops the pick.
  SavedAccount? _picked;

  /// "9••••••01": first digit and last two only.
  static String masked(String id) => id.length < 4 ? '•••' : '${id.substring(0, 1)}${'•' * (id.length - 3)}${id.substring(id.length - 2)}';

  void _pick(SavedAccount a) {
    setState(() {
      _picked = a;
      // The real ID goes in the field (so the phone's password manager keeps the right login),
      // shown as dots while it's a picked account.
      _id.text = a.nationalId;
      _error = null;
    });
    _pwFocus.requestFocus();
  }

  Future<void> _forget(SavedAccount a) async {
    await _store.forget(a.nationalId);
    final v = await _store.list();
    if (mounted) setState(() => _saved = v);
  }

  @override
  void dispose() {
    _id.dispose();
    _pw.dispose();
    _pwFocus.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.onLogin(_id.text, _pw.text);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    const label = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    final theme = Theme.of(context);
    final focused = theme.inputDecorationTheme.focusedBorder;
    return Theme(
      data: theme.copyWith(
        textSelectionTheme: theme.textSelectionTheme.copyWith(cursorColor: _brand),
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          focusedBorder: focused is OutlineInputBorder
              ? focused.copyWith(borderSide: const BorderSide(color: _brand, width: 2))
              : OutlineInputBorder(borderRadius: BorderRadius.circular(Gap.radius), borderSide: const BorderSide(color: _brand, width: 2)),
        ),
      ),
      child: Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 48, 24, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(color: t.border),
                        ),
                        child: Image.asset('assets/images/logo.png', fit: BoxFit.contain, semanticLabel: 'شعار المدرسة'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(widget.schoolName, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text('لمتابعة الدروس والدفعات', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: t.textSecondary)),
                    const SizedBox(height: 32),
                    if (_saved.isNotEmpty) ...[
                      Text('حسابات دخلت من هالجهاز', style: label.copyWith(color: t.textSecondary)),
                      const SizedBox(height: 6),
                      for (final a in _saved)
                        Padding(
                          padding: const EdgeInsetsDirectional.only(bottom: 6),
                          child: Material(
                            color: _picked?.nationalId == a.nationalId ? t.tonalBg : t.card,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(Gap.radiusSmall),
                              side: BorderSide(color: _picked?.nationalId == a.nationalId ? t.primary : t.border),
                            ),
                            child: InkWell(
                              key: Key('saved_${a.nationalId}'),
                              borderRadius: BorderRadius.circular(Gap.radiusSmall),
                              onTap: () => _pick(a),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(12, 6, 4, 6),
                                child: Row(children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: t.tonalBg,
                                    child: Text(a.name.isEmpty ? '؟' : a.name.characters.first, style: TextStyle(color: t.info, fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text(a.name.isEmpty ? masked(a.nationalId) : a.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                                      Text(masked(a.nationalId), textDirection: TextDirection.ltr, style: TextStyle(fontSize: 12, color: t.textSecondary)),
                                    ]),
                                  ),
                                  IconButton(
                                    tooltip: 'شيله من هالجهاز',
                                    color: t.textSecondary,
                                    icon: const Icon(Icons.close_rounded, size: 20),
                                    onPressed: () => _forget(a),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
                    const Text('رقم الهوية', style: label),
                    const SizedBox(height: 6),
                    TextField(
                      key: const Key('nationalId'),
                      controller: _id,
                      obscureText: _picked != null,
                      // Typing replaces a picked account: start again from an empty field.
                      onChanged: (v) {
                        if (_picked != null) {
                          setState(() => _picked = null);
                          _id.text = '';
                        }
                      },
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username],
                      maxLength: 9,
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(hintText: '9 أرقام', counterText: ''),
                    ),
                    const SizedBox(height: 22),
                    const Text('كلمة السر', style: label),
                    const SizedBox(height: 6),
                    TextField(
                      key: const Key('password'),
                      controller: _pw,
                      focusNode: _pwFocus,
                      obscureText: _hidden,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      onSubmitted: (_) => _submit(),
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: 'من المدرسة',
                        suffixIcon: IconButton(
                          tooltip: _hidden ? 'إظهار كلمة السر' : 'إخفاء كلمة السر',
                          color: t.textSecondary,
                          icon: Icon(_hidden ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _hidden = !_hidden),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        key: const Key('loginError'),
                        padding: const EdgeInsetsDirectional.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(Gap.radiusSmall),
                          border: Border.all(color: t.problem),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: t.problem, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(_error!, style: TextStyle(color: t.problem, fontSize: 14, fontWeight: FontWeight.w600))),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),
                    FilledButton(
                      key: const Key('loginButton'),
                      onPressed: _busy ? null : _submit,
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56), backgroundColor: _brand, foregroundColor: Colors.white),
                      child: _busy
                          ? SizedBox.square(dimension: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                          : const Text('دخول'),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'نسيان كلمة السر: إدارة المدرسة بتعيد تعيينها.\nالدخول بيضل محفوظ على هذا الجوال لحد تسجيل الخروج.\nكلمة السر ما بتنحفظ بالتطبيق؛ المتصفح أو الجوال بيقدر يحفظها.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, height: 1.7, color: t.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}
