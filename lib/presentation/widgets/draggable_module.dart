import 'package:flutter/material.dart';

class DraggableModule extends StatefulWidget {
  final Widget child;
  final Offset initialPosition;

  const DraggableModule({
    super.key,
    required this.child,
    this.initialPosition = Offset.zero,
  });

  @override
  State<DraggableModule> createState() => _DraggableModuleState();
}

class _DraggableModuleState extends State<DraggableModule> {
  late Offset _position;
  Offset? _dragStart;
  Offset? _posStart;

  @override
  void initState() {
    super.initState();
    _position = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (event) {
          if (event.buttons != 1) return;
          _dragStart = event.position;
          _posStart = _position;
        },
        onPointerMove: (event) {
          if (_dragStart != null && _posStart != null) {
            setState(() {
              _position = _posStart! + (event.position - _dragStart!);
            });
          }
        },
        onPointerUp: (_) {
          _dragStart = null;
          _posStart = null;
        },
        child: widget.child,
      ),
    );
  }
}
