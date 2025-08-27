import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../controllers/cart_controller.dart';

class LocalCartItemCard extends StatefulWidget {
  final LocalCartItem cartItem;
  final int index;
  final VoidCallback? onRemove;
  final Function(int)? onQuantityChanged;

  const LocalCartItemCard({
    super.key,
    required this.cartItem,
    required this.index,
    this.onRemove,
    this.onQuantityChanged,
  });

  @override
  State<LocalCartItemCard> createState() => _LocalCartItemCardState();
}

class _LocalCartItemCardState extends State<LocalCartItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.7,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onQuantityChange(int newQuantity) async {
    if (_isUpdating) return;

    setState(() {
      _isUpdating = true;
    });

    _animationController.forward();

    try {
      widget.onQuantityChanged?.call(newQuantity);

      // Small delay for smooth animation
      await Future.delayed(const Duration(milliseconds: 150));
    } finally {
      if (mounted) {
        _animationController.reverse();
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _opacityAnimation.value,
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Artwork Image
                  Container(
                    width: 80.w,
                    height: 80.h,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      color: AppColors.greyLight,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: CachedNetworkImage(
                        imageUrl: widget.cartItem.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppColors.greyLight,
                          child: Center(
                            child: Icon(
                              Iconsax.image,
                              color: AppColors.grey,
                              size: 24.sp,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          print(
                              '🖼️ Local cart image loading error for: ${widget.cartItem.imageUrl}');
                          print('🖼️ Error: $error');
                          return Container(
                            color: AppColors.greyLight,
                            child: Center(
                              child: Icon(
                                Iconsax.image,
                                color: AppColors.grey,
                                size: 24.sp,
                              ),
                            ),
                          );
                        },
                        imageBuilder: (context, imageProvider) {
                          print(
                              '🖼️ Local cart image loaded successfully: ${widget.cartItem.imageUrl}');
                          return Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: imageProvider,
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  SizedBox(width: 16.w),

                  // Item Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.cartItem.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Digital Art', // Since we don't have artist name in LocalCartItem
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _formatPrice(widget.cartItem.price,
                                    widget.cartItem.currency),
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Flexible(
                              child: Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: AppColors.greyLight),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        if (widget.cartItem.quantity > 1) {
                                          _onQuantityChange(
                                              widget.cartItem.quantity - 1);
                                        } else {
                                          widget.onRemove?.call();
                                        }
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(6.w),
                                        child: Icon(
                                          widget.cartItem.quantity > 1
                                              ? Iconsax.minus
                                              : Iconsax.trash,
                                          size: 14.sp,
                                          color: widget.cartItem.quantity > 1
                                              ? AppColors.textSecondary
                                              : AppColors.error,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 6.h,
                                      ),
                                      child: AnimatedSwitcher(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        transitionBuilder: (child, animation) {
                                          return ScaleTransition(
                                            scale: animation,
                                            child: child,
                                          );
                                        },
                                        child: Text(
                                          '${widget.cartItem.quantity}',
                                          key: ValueKey(
                                              widget.cartItem.quantity),
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        _onQuantityChange(
                                            widget.cartItem.quantity + 1);
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(6.w),
                                        child: Icon(
                                          Iconsax.add,
                                          size: 14.sp,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatPrice(double price, String currency) {
    final symbol = AppConstants.currencySymbols[currency] ?? currency;

    // Use whole number formatting for TZS (Tanzanian Shilling)
    if (currency == AppConstants.defaultCurrency) {
      final formatter = price.toStringAsFixed(0);
      final priceStr = formatter.replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (Match m) => '${m[1]},',
      );
      return '$symbol $priceStr';
    } else {
      return '$symbol ${price.toStringAsFixed(2)}';
    }
  }
}
