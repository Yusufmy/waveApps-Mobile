import 'package:flutter/material.dart';

void showAlert(
  BuildContext context, {
  required String text,
  required bool isSuccess,
}) {
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) {
      return _AnimatedAlert(
        text: text,
        isSuccess: isSuccess,
        onDismiss: () {
          overlayEntry.remove();
        },
      );
    },
  );

  Overlay.of(context).insert(overlayEntry);
}

class _AnimatedAlert extends StatefulWidget {
  final String text;
  final bool isSuccess;
  final VoidCallback onDismiss;

  const _AnimatedAlert({
    required this.text,
    required this.isSuccess,
    required this.onDismiss,
  });

  @override
  State<_AnimatedAlert> createState() => _AnimatedAlertState();
}

class _AnimatedAlertState extends State<_AnimatedAlert>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  double dragOffset = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      dismiss();
    });
  }

  void dismiss() async {
    if (!_controller.isAnimating) {
      await _controller.reverse();
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Align(
          alignment: Alignment.topCenter,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              dragOffset += details.delta.dy;

              // swipe ke atas
              if (dragOffset < -30) {
                dismiss();
              }
            },
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, (-100) + (_controller.value * 120)),
                  child: Opacity(opacity: _controller.value, child: child),
                );
              },
              child: Container(
                margin: const EdgeInsets.only(top: 0, left: 16, right: 16),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: widget.isSuccess
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: widget.isSuccess
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: widget.isSuccess
                            ? Colors.green.shade100
                            : Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: widget.isSuccess
                          ? const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 22,
                            )
                          : const Icon(
                              Icons.error,
                              color: Colors.red,
                              size: 22,
                            ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.isSuccess ? Colors.green : Colors.red,
                        ),
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
}
