import 'package:flutter/material.dart';
import 'package:login2/widgets/work_timer_chip.dart';

/// Wrap a page's Scaffold `body` with this:
///   `body: WorkTimerOverlay(child: existingBody)`
class WorkTimerOverlay extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTimerReturn; // refresh the page after returning from the running work

  const WorkTimerOverlay({super.key, required this.child, this.onTimerReturn});

  @override
  State<WorkTimerOverlay> createState() => _WorkTimerOverlayState();
}

class _WorkTimerOverlayState extends State<WorkTimerOverlay> {
  // Remembered in memory so the chip stays where the user dropped it
  // when moving between work pages. null = default bottom-left.
  static Offset? _lastPos;
  static bool? _snappedToRight;

  static const double _margin = 12;
  static double _chipW = 128; // initial approx size, updated after measurement
  static double _chipH = 36;

  final GlobalKey _chipKey = GlobalKey();
  Offset? _pos;

  void _checkSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final renderBox = _chipKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null && renderBox.hasSize) {
        final size = renderBox.size;
        if (size.width > 20 && size.height > 10) {
          if ((_chipW - size.width).abs() > 1 || (_chipH - size.height).abs() > 1) {
            setState(() {
              _chipW = size.width;
              _chipH = size.height;
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _checkSize();

    return LayoutBuilder(builder: (context, c) {
      final double maxX = (c.maxWidth - _chipW - _margin).clamp(_margin, double.infinity);
      final double maxY = (c.maxHeight - _chipH - _margin).clamp(_margin, double.infinity);

      Offset pos = _pos ??
          (_lastPos != null
              ? Offset(_snappedToRight == true ? maxX : _margin, _lastPos!.dy)
              : Offset(_margin, maxY)); // default: bottom-left
      pos = Offset(pos.dx.clamp(_margin, maxX), pos.dy.clamp(_margin, maxY));

      return Stack(
        children: [
          widget.child,
          Positioned(
            left: pos.dx,
            top: pos.dy,
            child: GestureDetector(
              behavior: HitTestBehavior.deferToChild,
              onPanUpdate: (d) {
                final current = _pos ?? pos;
                setState(() {
                  _pos = Offset(
                    (current.dx + d.delta.dx).clamp(_margin, maxX),
                    (current.dy + d.delta.dy).clamp(_margin, maxY),
                  );
                });
              },
              onPanEnd: (_) {
                final p = _pos ?? pos;
                final isRight = (p.dx + _chipW / 2) >= c.maxWidth / 2;
                final snapX = isRight ? maxX : _margin;
                setState(() {
                  _pos = Offset(snapX, p.dy);
                  _lastPos = _pos;
                  _snappedToRight = isRight;
                });
              },
              onPanCancel: () {
                final p = _pos ?? pos;
                final isRight = (p.dx + _chipW / 2) >= c.maxWidth / 2;
                final snapX = isRight ? maxX : _margin;
                setState(() {
                  _pos = Offset(snapX, p.dy);
                  _lastPos = _pos;
                  _snappedToRight = isRight;
                });
              },
              child: KeyedSubtree(
                key: _chipKey,
                child: WorkTimerChip(height: 36, onReturn: widget.onTimerReturn),
              ),
            ),
          ),
        ],
      );
    });
  }
}
