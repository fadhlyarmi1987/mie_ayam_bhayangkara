import 'package:flutter/material.dart';

class SwipeableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onDelete;

  const SwipeableCard({super.key, required this.child, required this.onDelete});

  @override
  State<SwipeableCard> createState() => _SwipeableCardState();
}

class _SwipeableCardState extends State<SwipeableCard> {
  double _offsetX = 0;
  final double _maxSlide = 80;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        setState(() {
          _offsetX += details.delta.dx;
          if (_offsetX < -_maxSlide) _offsetX = -_maxSlide;
          if (_offsetX > 0) _offsetX = 0;
        });
      },
      onHorizontalDragEnd: (_) {
        setState(() {
          _offsetX = (_offsetX < -_maxSlide / 2) ? -_maxSlide : 0;
        });
      },
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: widget.onDelete,
              child: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: widget.onDelete,
                ),
              ),
            ),
          ),
          Transform.translate(offset: Offset(_offsetX, 0), child: widget.child),
        ],
      ),
    );
  }
}