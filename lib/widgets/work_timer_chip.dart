

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
    _start = widget.startTime;
    if (_start == null) refresh();
  }

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

    final bool dark = widget.onAppBar;
    final Color fg = dark ? Colors.white : AppColors.danger;

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.20) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark
              ? Colors.white.withOpacity(0.35)
              : AppColors.danger.withOpacity(0.25),
        ),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: AppColors.danger.withOpacity(0.10),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: fg.withOpacity(0.12),
          onTap: _open,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _PulseDot(color: dark ? Colors.white : AppColors.danger),
                const SizedBox(width: 7),
                _LiveTimer(
                  start: _start!,
                  style: TextStyle(
                    fontSize: widget.height < 38 ? 13 : 14,
                    fontWeight: FontWeight.w800,
                    color: fg,
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
  const _PulseDot({required this.color});

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
    return FadeTransition(
      opacity: Tween<double>(begin: 0.3, end: 1.0).animate(_c),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: widget.color, shape: BoxShape.circle),
      ),
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