import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:login2/core/app_colors.dart';
import 'package:login2/screens/leadManagement/addWork_page.dart';
import 'package:login2/service/service.dart';

class WorkTimerChip extends StatefulWidget {
  /// If the page already knows when the work started, pass it here and the
  /// chip will not call the API itself.
  final DateTime? startTime;

  /// Custom tap action. Default: open the running work (AddWorkPage).
  final VoidCallback? onTap;

  /// Called after the user comes back from the running work page
  /// (use it to refresh your own page).
  final VoidCallback? onReturn;

  /// true = translucent white style for gradient app bars.
  final bool onAppBar;

  final double height;

  // Any page can call WorkTimerChip.refreshAll() after starting / stopping a
  // work, and every chip on screen re-checks the server immediately.
  static final ValueNotifier<int> _changes = ValueNotifier<int>(0);
  static void refreshAll() => _changes.value++;

  const WorkTimerChip({
    super.key,
    this.startTime,
    this.onTap,
    this.onReturn,
    this.onAppBar = false,
    this.height = 40,
  });

  @override
  State<WorkTimerChip> createState() => WorkTimerChipState();
}

// Public so a page can refresh it:
//   final _timerKey = GlobalKey<WorkTimerChipState>();
//   WorkTimerChip(key: _timerKey)   ...   _timerKey.currentState?.refresh();
class WorkTimerChipState extends State<WorkTimerChip>
    with WidgetsBindingObserver {
  DateTime? _start;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WorkTimerChip._changes.addListener(_onExternalChange);
    _start = widget.startTime;
    if (_start == null) refresh();
  }

  void _onExternalChange() => refresh();

  @override
  void didUpdateWidget(covariant WorkTimerChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startTime != oldWidget.startTime) {
      if (widget.startTime != null) {
        setState(() => _start = widget.startTime);
      } else {
        refresh();
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && widget.startTime == null) {
      refresh();
    }
  }

  @override
  void dispose() {
    WorkTimerChip._changes.removeListener(_onExternalChange);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-check the server for a running work.
  Future<void> refresh() async {
    if (widget.startTime != null) return;
    try {
      final model = await HttpService.getWorkStatus();
      if (!mounted) return;
      DateTime? s;
      if (model != null && model.data.isNotEmpty) {
        s = DateTime.tryParse(model.data.first.createdAt);
      }
      setState(() => _start = s);
    } catch (_) {
      if (mounted) setState(() => _start = null);
    }
  }

  Future<void> _open() async {
    if (widget.onTap != null) {
      widget.onTap!();
      return;
    }
    final model = await HttpService.getWorkStatus();
    if (!mounted) return;
    final running =
        (model != null && model.data.isNotEmpty) ? model.data.first : null;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddWorkPage(
          workId: "",
          existingWork: running,
          isAssigned: 1,
          onSuccess: () {},
        ),
      ),
    );
    if (!mounted) return;
    refresh();
    widget.onReturn?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_start == null) return const SizedBox.shrink();

    const Color red = AppColors.danger;
    // In an app bar the chip is always compact (28px), even if the page
    // still passes height: 34 - so no page needs to be edited.
    final double h = widget.onAppBar
        ? (widget.height < 28 ? widget.height : 28)
        : widget.height;
    final bool compact = h <= 34;

    // Same white pill everywhere (also on the blue app bar):
    // glowing red dot + timer icon + live HH:MM:SS
    return Container(
      height: h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: red.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: widget.onAppBar
                ? Colors.black.withOpacity(0.15)
                : red.withOpacity(0.10),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: red.withOpacity(0.12),
          onTap: _open,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulseDot(color: red, size: compact ? 6 : 8),
                SizedBox(width: compact ? 5 : 6),
                Icon(Icons.timer_outlined, size: compact ? 13 : 16, color: red),
                SizedBox(width: compact ? 3 : 4),
                _LiveTimer(
                  start: _start!,
                  style: TextStyle(
                    fontSize: compact ? 11.5 : 14,
                    fontWeight: FontWeight.w800,
                    color: red,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------------
// Pulsing "recording" dot
// ----------------------------------------------------------------------------
class _PulseDot extends StatefulWidget {
  final Color color;
  final double size;
  const _PulseDot({required this.color, this.size = 8});

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) {
        final double v = Curves.easeInOut.transform(_c.value);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.color,
            shape: BoxShape.circle,
            // glow grows and fades with the pulse
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.35 + 0.45 * v),
                blurRadius: 2 + 5 * v,
                spreadRadius: 0.3 + 1.0 * v,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ----------------------------------------------------------------------------
// Ticks every second by itself (does not rebuild the page)
// ----------------------------------------------------------------------------
class _LiveTimer extends StatefulWidget {
  final DateTime start;
  final TextStyle style;
  const _LiveTimer({required this.start, required this.style});

  @override
  State<_LiveTimer> createState() => _LiveTimerState();
}

class _LiveTimerState extends State<_LiveTimer> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Duration diff = DateTime.now().difference(widget.start);
    if (diff.isNegative) diff = Duration.zero;
    String two(int n) => n.toString().padLeft(2, '0');
    final text =
        "${two(diff.inHours)}:${two(diff.inMinutes % 60)}:${two(diff.inSeconds % 60)}";
    return Text(text, style: widget.style);
  }
}
