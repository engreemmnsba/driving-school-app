import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show appFlavor, FilteringTextInputFormatter;
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_scope.dart';
import '../../core/config/version.dart';
import '../../core/ui/tokens.dart';
import '../../core/ui/widgets.dart';
import '../../data/queries.dart';
import '../../data/settings_queries.dart';

const playStoreUrl = 'https://play.google.com/store/apps/details?id=ps.reem.driving_school';

/// The latest version the Admin published (setting "appVersion").
class AppRelease {
  const AppRelease({required this.version, required this.build, required this.apkUrl, this.notes = const [], this.sizeMb, this.date});
  final String version;
  final int build;
  final String apkUrl;
  final List<String> notes;
  final double? sizeMb;
  final String? date;

  bool get isNewer => build > appBuild;

  static AppRelease? fromJson(Object? v) {
    if (v is! Map) return null;
    final b = v['build'];
    if (v['version'] is! String || b is! num || v['apkUrl'] is! String) return null;
    return AppRelease(
      version: v['version'] as String,
      build: b.toInt(),
      apkUrl: v['apkUrl'] as String,
      notes: [for (final n in (v['notes'] as List?) ?? const []) '$n'],
      sizeMb: (v['sizeMb'] as num?)?.toDouble(),
      date: v['date'] as String?,
    );
  }
}

Future<AppRelease?> latestRelease(SettingsQueries q) async => AppRelease.fromJson(await q.raw('appVersion'));

/// Canvas Update. `direct` APK: the new APK opens in the browser and Android installs it over the old one
/// (same signing key, data kept). Play: the Play page. Web: a reload loads the new version.
class UpdateScreen extends StatefulWidget {
  const UpdateScreen({super.key});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

class _UpdateScreenState extends State<UpdateScreen> {
  Stream<AppRelease?>? _stream;

  Future<void> _download(AppRelease r) async {
    final url = appFlavor == 'play' ? playStoreUrl : r.apkUrl;
    final ok = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    if (!ok && mounted) showErrorSnack(context, 'ما انفتح الرابط');
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.tokens;
    _stream ??= watchLoad(app.db, () => latestRelease(app.settings.queries));
    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<AppRelease?>(
          stream: _stream,
          builder: (context, snap) {
            final r = snap.data;
            final newer = r != null && r.isNewer;
            return ListView(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 24),
              children: [
                const BackHeader(title: 'تحديث التطبيق'),
                const SizedBox(height: 24),
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(color: t.primary, borderRadius: BorderRadius.circular(24)),
                    child: Icon(Icons.system_update_rounded, color: t.onPrimary, size: 40),
                  ),
                ),
                const SizedBox(height: 16),
                Text(newer ? 'تحديث جديد متاح' : 'التطبيق محدّث ✓', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                Text(
                  newer
                      ? ['الإصدار ${r.version}', if (r.sizeMb != null) '${r.sizeMb!.toStringAsFixed(1)} م.ب', ?r.date].join(' · ')
                      : 'الإصدار الحالي $appVersion',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: t.textSecondary),
                ),
                if (newer && r.notes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Panel(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      const Text('الجديد في هالإصدار', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      for (final n in r.notes) Text('• $n', style: const TextStyle(fontSize: 14, height: 1.6)),
                    ]),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsetsDirectional.all(12),
                  decoration: BoxDecoration(color: t.tonalBg, borderRadius: BorderRadius.circular(14)),
                  child: Text(
                    kIsWeb
                        ? 'نسخة المتصفح بتتحدّث لحالها: إعادة فتح الصفحة بتجيب آخر نسخة.'
                        : 'بياناتك محفوظة ومش رح تتأثر بالتحديث. العمليات اللي لسا ما وصلت بتضل وبتنبعت بعده.',
                    style: TextStyle(fontSize: 13, color: t.info, height: 1.6),
                  ),
                ),
                const SizedBox(height: 20),
                if (newer && !kIsWeb) AppButton(appFlavor == 'play' ? 'التحديث من Google Play' : 'تنزيل التحديث', height: 54, expand: true, icon: Icons.download_rounded, onPressed: () => _download(r)),
                if (app.user.isAdmin) ...[
                  const SizedBox(height: 24),
                  AppButton('نشر إصدار جديد للموظفين', kind: AppButtonKind.outline, height: 48, expand: true, onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => PublishReleaseScreen(current: r)))),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Admin: tells every phone that a new APK is ready (version, build number, link, what's new).
class PublishReleaseScreen extends StatefulWidget {
  const PublishReleaseScreen({super.key, this.current});
  final AppRelease? current;

  @override
  State<PublishReleaseScreen> createState() => _PublishReleaseScreenState();
}

class _PublishReleaseScreenState extends State<PublishReleaseScreen> {
  late final _version = TextEditingController(text: widget.current?.version ?? appVersion);
  late final _build = TextEditingController(text: '${(widget.current?.build ?? appBuild) + 1}');
  late final _url = TextEditingController(text: widget.current?.apkUrl ?? 'https://your-firebase-project.web.app/app.apk');
  late final _notes = TextEditingController(text: '');
  bool _busy = false;

  @override
  void dispose() {
    for (final c in [_version, _build, _url, _notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    final app = AppScope.of(context);
    setState(() => _busy = true);
    try {
      await app.settings.setSetting('appVersion', {
        'version': _version.text.trim(),
        'build': int.parse(_build.text),
        'apkUrl': _url.text.trim(),
        'notes': [for (final l in _notes.text.split('\n')) if (l.trim().isNotEmpty) l.trim()],
        'date': DateTime.now().toIso8601String().substring(0, 10),
      });
      app.syncSoon();
      if (!mounted) return;
      final nav = Navigator.of(context);
      nav.pop();
      if (nav.context.mounted) showUndoSnack(nav.context, 'انتشر الإصدار ${_version.text.trim()} · الجوالات بتشوفه مع المزامنة');
    } catch (e) {
      if (mounted) {
        setState(() => _busy = false);
        showErrorSnack(context, '$e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ok = _version.text.trim().isNotEmpty && (int.tryParse(_build.text) ?? 0) > 0 && _url.text.trim().startsWith('https://');
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 24),
          children: [
            const BackHeader(title: 'نشر إصدار جديد'),
            const SizedBox(height: 14),
            TextField(controller: _version, textDirection: TextDirection.ltr, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'رقم الإصدار (مثلًا 1.1.0)')),
            const SizedBox(height: 8),
            TextField(
              controller: _build,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'رقم البناء (أكبر من الحالي)'),
            ),
            const SizedBox(height: 8),
            TextField(controller: _url, textDirection: TextDirection.ltr, onChanged: (_) => setState(() {}), decoration: const InputDecoration(labelText: 'رابط ملف APK (https)')),
            const SizedBox(height: 8),
            TextField(controller: _notes, minLines: 3, maxLines: 6, decoration: const InputDecoration(labelText: 'الجديد (كل سطر نقطة)')),
            const SizedBox(height: 14),
            AppButton('نشر', height: 52, expand: true, busy: _busy, onPressed: ok ? _save : null),
          ],
        ),
      ),
    );
  }
}
