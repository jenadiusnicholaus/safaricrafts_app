import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FlyingCartAnimationService extends GetxService {
  OverlayEntry? _overlayEntry;

  /// Triggers the flying cart animation from source to target
  void startFlyingAnimation({
    required BuildContext context,
    required GlobalKey sourceKey,
    required GlobalKey targetKey,
    required String imageUrl,
    VoidCallback? onAnimationComplete,
  }) {
    _removeExistingOverlay();

    final sourceBox =
        sourceKey.currentContext?.findRenderObject() as RenderBox?;
    final targetBox =
        targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (sourceBox == null || targetBox == null) return;

    final sourcePosition = sourceBox.localToGlobal(Offset.zero);
    final targetPosition = targetBox.localToGlobal(Offset.zero);
    final sourceSize = sourceBox.size;
    final targetSize = targetBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => FlyingCartWidget(
        startPosition: sourcePosition,
        endPosition: targetPosition,
        startSize: sourceSize,
        endSize: targetSize,
        imageUrl: imageUrl,
        onAnimationComplete: () {
          _removeExistingOverlay();
          onAnimationComplete?.call();
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeExistingOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  void onClose() {
    _removeExistingOverlay();
    super.onClose();
  }
}

class FlyingCartWidget extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final Size startSize;
  final Size endSize;
  final String imageUrl;
  final VoidCallback onAnimationComplete;

  const FlyingCartWidget({
    super.key,
    required this.startPosition,
    required this.endPosition,
    required this.startSize,
    required this.endSize,
    required this.imageUrl,
    required this.onAnimationComplete,
  });

  @override
  State<FlyingCartWidget> createState() => _FlyingCartWidgetState();
}

class _FlyingCartWidgetState extends State<FlyingCartWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _scaleController;
  late AnimationController _bounceController;

  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();

    // Main animation controller (for position and rotation)
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Scale animation controller
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Bounce animation controller for cart icon
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    // Position animation with custom curve for natural movement
    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition +
          const Offset(12, 12), // Slight offset to center on cart icon
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    ));

    // Scale animation - starts normal, shrinks as it flies
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.3,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInQuart,
    ));

    // Rotation animation for dynamic effect
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.5, // Half rotation
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Opacity animation - fades out near the end
    _opacityAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.0),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 30,
      ),
    ]).animate(_animationController);

    // Bounce animation for cart icon
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Start animations
    _startAnimation();
  }

  void _startAnimation() async {
    // Start position and scale animations simultaneously
    _animationController.forward();
    _scaleController.forward();

    // Listen for animation completion
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Start bounce animation for cart icon
        _bounceController.forward().then((_) {
          _bounceController.reverse().then((_) {
            widget.onAnimationComplete();
          });
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _animationController,
        _scaleController,
        _bounceController,
      ]),
      builder: (context, child) {
        return Stack(
          children: [
            // Flying artwork image
            Positioned(
              left: _positionAnimation.value.dx,
              top: _positionAnimation.value.dy,
              child: Transform.rotate(
                angle: _rotationAnimation.value * 3.14159, // Convert to radians
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      width: widget.startSize.width *
                          0.6, // Slightly smaller than original
                      height: widget.startSize.height * 0.6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: widget.imageUrl.isNotEmpty
                            ? Image.network(
                                widget.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.image,
                                      color: Colors.grey,
                                    ),
                                  );
                                },
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image,
                                  color: Colors.grey,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Cart icon bounce effect
            if (_bounceController.isAnimating)
              Positioned(
                left: widget.endPosition.dx - 8,
                top: widget.endPosition.dy - 8,
                child: Transform.scale(
                  scale: _bounceAnimation.value,
                  child: Container(
                    width: widget.endSize.width + 16,
                    height: widget.endSize.height + 16,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
