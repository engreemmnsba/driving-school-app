import 'package:flutter/material.dart';

import 'money_text.dart';
import 'tokens.dart';

/// White rounded block (the canvas "card").
class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.padding = const EdgeInsetsDirectional.all(14), this.radius = 16, this.color, this.border, this.onTap});
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final BoxBorder? border;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final shape = BorderRadius.circular(radius);
    final box = Container(
      padding: padding,
      decoration: BoxDecoration(color: color ?? t.card, borderRadius: shape, border: border),
      child: child,
    );
    if (onTap == null) return box;
    return Material(color: Colors.transparent, borderRadius: shape, child: InkWell(borderRadius: shape, onTap: onTap, child: box));
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700))),
        ?trailing,
      ],
    );
  }
}

class Pill extends StatelessWidget {
  const Pill(this.text, {super.key, required this.bg, required this.fg, this.icon});
  final String text;
  final Color bg;
  final Color fg;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: 14, color: fg), const SizedBox(width: 4)],
        Text(text, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

enum AppButtonKind { primary, accent, tonal, outline, success, danger }

/// The canvas buttons: 44+ touch height, radius 12–14, bold label.
class AppButton extends StatelessWidget {
  const AppButton(this.label, {super.key, required this.onPressed, this.kind = AppButtonKind.primary, this.icon, this.height = 48, this.busy = false, this.expand = false, this.child});
  final String label;
  final VoidCallback? onPressed;
  final AppButtonKind kind;
  final IconData? icon;
  final double height;
  final bool busy;
  final bool expand;

  /// Optional custom content (e.g. text + MoneyText) instead of [label].
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final (bg, fg, side) = switch (kind) {
      AppButtonKind.primary => (t.primary, t.onPrimary, BorderSide.none),
      AppButtonKind.accent => (t.accent, t.onAccent, BorderSide.none),
      AppButtonKind.tonal => (t.tonalBg, t.info, BorderSide.none),
      AppButtonKind.outline => (t.card, t.text, BorderSide(color: t.border)),
      AppButtonKind.success => (t.money, t.card, BorderSide.none),
      AppButtonKind.danger => (Colors.transparent, t.problem, BorderSide.none),
    };
    final content = busy
        ? SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
        : Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 6)],
            Flexible(child: child ?? Text(label, overflow: TextOverflow.ellipsis)),
          ]);
    final button = TextButton(
      onPressed: busy ? null : onPressed,
      style: TextButton.styleFrom(
        backgroundColor: onPressed == null ? t.divider : bg,
        foregroundColor: fg,
        disabledForegroundColor: t.textSecondary,
        minimumSize: Size(height, height),
        padding: const EdgeInsetsDirectional.symmetric(horizontal: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(height >= 54 ? 14 : 12), side: side),
        textStyle: TextStyle(fontFamily: Theme.of(context).textTheme.bodyMedium?.fontFamily, fontSize: height >= 54 ? 16 : 14, fontWeight: FontWeight.w700),
      ),
      child: content,
    );
    return expand ? SizedBox(width: double.infinity, height: height, child: button) : SizedBox(height: height, child: button);
  }
}

/// A row of mutually exclusive choices (license, car, account, amount) — canvas on/off style.
class ChoiceRow<T> extends StatelessWidget {
  const ChoiceRow({super.key, required this.options, required this.selected, required this.onSelect, required this.label, this.height = 44});
  final List<T> options;
  final T? selected;
  final ValueChanged<T> onSelect;
  final String Function(T) label;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Row(
      children: [
        for (final (i, o) in options.indexed) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: Semantics(
              selected: o == selected,
              button: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => onSelect(o),
                child: Container(
                  height: height,
                  alignment: Alignment.center,
                  padding: const EdgeInsetsDirectional.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: o == selected ? t.tonalBg : t.card,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: o == selected ? t.primary : t.border, width: o == selected ? 2 : 1),
                  ),
                  child: Text(label(o),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: o == selected ? t.info : t.text)),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Header with a back button (points the right way in RTL and LTR).
class BackHeader extends StatelessWidget {
  const BackHeader({super.key, required this.title, this.subtitle, this.trailing, this.dark = false});
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final fg = dark ? Colors.white : t.text;
    return Row(
      children: [
        Material(
          color: dark ? Colors.white12 : t.card,
          borderRadius: BorderRadius.circular(12),
          // A labelled button for screen readers (the icon alone isn't announced as one).
          child: Semantics(
            button: true,
            label: 'رجوع',
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).maybePop(),
              child: SizedBox.square(dimension: 44, child: Icon(Icons.arrow_back_rounded, color: fg)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: fg), maxLines: 1, overflow: TextOverflow.ellipsis),
              if (subtitle != null) Text(subtitle!, style: TextStyle(fontSize: 12, color: dark ? Colors.white70 : t.textSecondary)),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class ProgressLine extends StatelessWidget {
  const ProgressLine(this.value, {super.key, this.height = 8});
  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(value: value.clamp(0, 1), minHeight: height, backgroundColor: t.divider, color: t.primary),
    );
  }
}

class InitialBox extends StatelessWidget {
  const InitialBox(this.name, {super.key, this.size = 40});
  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: t.tonalBg, borderRadius: BorderRadius.circular(12)),
      child: Text(name.isEmpty ? '؟' : name.characters.first, style: TextStyle(color: t.primary, fontWeight: FontWeight.w700, fontSize: 16)),
    );
  }
}

/// Canvas "States": empty.
class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.icon, required this.title, this.body, this.action});
  final IconData icon;
  final String title;
  final String? body;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Panel(
      padding: const EdgeInsetsDirectional.symmetric(horizontal: 18, vertical: 28),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(color: t.tonalBg, shape: BoxShape.circle),
            child: Icon(icon, color: t.primary, size: 30),
          ),
          const SizedBox(height: 10),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(body!, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.6)),
          ],
          if (action != null) ...[const SizedBox(height: 12), action!],
        ],
      ),
    );
  }
}

/// Canvas "States": error — what happened, what to do, a support code.
class ErrorPanel extends StatelessWidget {
  const ErrorPanel({super.key, required this.title, required this.body, this.hint, this.code, this.actions = const []});
  final String title;
  final String body;
  final String? hint;
  final String? code;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Panel(
      border: Border.all(color: t.problem, width: 2),
      padding: const EdgeInsetsDirectional.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Icon(Icons.error_outline, color: t.problem),
            const SizedBox(width: 8),
            Expanded(child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: t.problem))),
          ]),
          const SizedBox(height: 8),
          Text(body, style: const TextStyle(fontSize: 14, height: 1.7)),
          if (hint != null) ...[const SizedBox(height: 6), Text(hint!, style: TextStyle(fontSize: 13, color: t.textSecondary, height: 1.6))],
          if (actions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(children: [for (final (i, a) in actions.indexed) ...[if (i > 0) const SizedBox(width: 8), Expanded(child: a)]]),
          ],
          if (code != null) ...[const SizedBox(height: 8), Text('رمز للدعم: $code', style: TextStyle(fontSize: 11, color: t.textSecondary))],
        ],
      ),
    );
  }
}

/// Canvas "States": loading skeleton (no shimmer when the phone asks for reduced motion).
class SkeletonCards extends StatefulWidget {
  const SkeletonCards({super.key, this.count = 5, this.height = 76});
  final int count;
  final double height;

  @override
  State<SkeletonCards> createState() => _SkeletonCardsState();
}

class _SkeletonCardsState extends State<SkeletonCards> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      label: 'بيحمّل',
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Column(
          children: [
            for (var i = 0; i < widget.count; i++)
              Padding(
                padding: const EdgeInsetsDirectional.only(bottom: 10),
                child: Container(
                  height: widget.height,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment(-1 + 2 * _c.value, 0),
                      end: Alignment(1 + 2 * _c.value, 0),
                      colors: [t.card, t.divider, t.card],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Canvas "SaveFlow": saved + Undo (dark bar, yellow action).
void showUndoSnack(BuildContext context, String message, {VoidCallback? onUndo, Duration duration = const Duration(seconds: 6)}) {
  final t = context.tokens;
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    duration: duration,
    // Newer Flutter keeps a snackbar with an action until tapped; the canvas wants it gone after a few seconds.
    persist: false,
    backgroundColor: const Color(0xFF14211F),
    content: Row(children: [
      const Icon(Icons.check_rounded, color: Color(0xFF7FD4A0)),
      const SizedBox(width: 10),
      Expanded(child: MoneyRichText(message, style: const TextStyle(color: Colors.white, fontSize: 14))),
    ]),
    action: onUndo == null ? null : SnackBarAction(label: 'تراجع', textColor: t.accent, onPressed: onUndo),
  ));
}

void showErrorSnack(BuildContext context, String message) {
  final t = context.tokens;
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(
    backgroundColor: t.problem,
    content: Row(children: [
      const Icon(Icons.error_outline, color: Colors.white),
      const SizedBox(width: 10),
      Expanded(child: MoneyRichText(message, style: const TextStyle(color: Colors.white, fontSize: 14))),
    ]),
  ));
}

/// Shown for screens that come in a later batch — honest, never fake data.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key, required this.title, required this.batch});
  final String title;
  final String batch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsetsDirectional.all(16),
          child: Column(children: [
            BackHeader(title: title),
            const SizedBox(height: 24),
            EmptyState(icon: Icons.construction_rounded, title: 'هالشاشة جاية', body: 'بتنبني ب$batch حسب التصميم'),
          ]),
        ),
      ),
    );
  }
}
