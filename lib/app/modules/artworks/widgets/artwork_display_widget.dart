import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../data/models/artwork_model.dart';
import '../../../controllers/artwork_controller.dart';
import 'artwork_card.dart';
import 'artwork_list_tile.dart';

class ArtworkDisplayWidget extends StatelessWidget {
  final List<ArtworkList> artworks;
  final ArtworkDisplayType displayType;
  final VoidCallback? onDisplayTypeChanged;
  final bool isLoading;
  final VoidCallback? onLoadMore;
  final bool hasMoreData;

  const ArtworkDisplayWidget({
    super.key,
    required this.artworks,
    this.displayType = ArtworkDisplayType.grid,
    this.onDisplayTypeChanged,
    this.isLoading = false,
    this.onLoadMore,
    this.hasMoreData = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display Type Toggle
        if (onDisplayTypeChanged != null)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${artworks.length} Artworks',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Row(
                  children: [
                    _buildDisplayToggle(
                      icon: Iconsax.element_3,
                      isSelected: displayType == ArtworkDisplayType.grid,
                      onTap: () => onDisplayTypeChanged?.call(),
                    ),
                    SizedBox(width: 8.w),
                    _buildDisplayToggle(
                      icon: Iconsax.menu_1,
                      isSelected: displayType == ArtworkDisplayType.list,
                      onTap: () => onDisplayTypeChanged?.call(),
                    ),
                  ],
                ),
              ],
            ),
          ),

        // Content
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildDisplayToggle({
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(Get.context!).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(Get.context!).primaryColor
                : Colors.grey.shade300,
          ),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: isSelected ? Colors.white : Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (artworks.isEmpty && !isLoading) {
      return const Center(
        child: Text('No artworks found'),
      );
    }

    if (displayType == ArtworkDisplayType.grid) {
      return _buildGridView();
    } else {
      return _buildListView();
    }
  }

  Widget _buildGridView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoading &&
            hasMoreData &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          onLoadMore?.call();
        }
        return false;
      },
      child: GridView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: artworks.length + (isLoading ? 2 : 0),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.55, // Adjusted for redesigned card
          crossAxisSpacing: 16.w,
          mainAxisSpacing: 16.h,
        ),
        itemBuilder: (context, index) {
          if (index >= artworks.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ArtworkCard(artwork: artworks[index]);
        },
      ),
    );
  }

  Widget _buildListView() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        if (!isLoading &&
            hasMoreData &&
            scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
          onLoadMore?.call();
        }
        return false;
      },
      child: ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: artworks.length + (isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= artworks.length) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return ArtworkListTile(artwork: artworks[index]);
        },
      ),
    );
  }
}
