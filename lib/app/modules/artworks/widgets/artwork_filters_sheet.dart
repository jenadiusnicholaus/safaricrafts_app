import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/artwork_controller.dart';
import '../../../core/theme/app_colors.dart';

class ArtworkFiltersSheet extends GetView<ArtworkController> {
  const ArtworkFiltersSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Text(
                  'Filter Artworks',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(
                    Iconsax.close_circle,
                    color: AppColors.textSecondary,
                    size: 24.sp,
                  ),
                ),
              ],
            ),
          ),

          // Filter Content
          Expanded(
            child: Obx(() {
              print('🔍 Filter Sheet Debug:');
              print('🔍 hasFilterOptions: ${controller.hasFilterOptions}');
              print(
                  '🔍 filterOptions keys: ${controller.filterOptions.value.keys.toList()}');
              print('🔍 categories count: ${controller.categories.length}');
              print(
                  '🔍 availableTribes count: ${controller.availableTribes.length}');
              print(
                  '🔍 availableRegions count: ${controller.availableRegions.length}');
              print(
                  '🔍 availableMaterials count: ${controller.availableMaterials.length}');

              // Show content even if filter options haven't loaded yet
              // At minimum, we can show categories and basic options
              final hasBasicData = controller.categories.isNotEmpty;

              if (!hasBasicData && !controller.hasFilterOptions) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 16.h),
                      Text(
                        'Loading filter options...',
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Debug info (only show if we have actual filter data)
                    if (kDebugMode && controller.filterOptions.value.isNotEmpty)
                      Container(
                        padding: EdgeInsets.all(12.w),
                        margin: EdgeInsets.only(bottom: 16.h),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Debug Info:',
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            Text(
                              'Filter Options Loaded: ${controller.hasFilterOptions}',
                              style: TextStyle(
                                  fontSize: 10.sp, color: Colors.blue.shade600),
                            ),
                            Text(
                              'Available Filters: ${controller.filterOptions.value.keys.join(", ")}',
                              style: TextStyle(
                                  fontSize: 10.sp, color: Colors.blue.shade600),
                            ),
                          ],
                        ),
                      ),

                    // Categories (always show if available)
                    if (controller.categories.isNotEmpty)
                      _buildFilterSection(
                        'Categories',
                        controller.categories.map((c) => c.name).toList(),
                        controller.selectedCategory.value,
                        (value) => controller.selectedCategory.value = value,
                        Iconsax.category,
                      ),

                    // Basic hardcoded filters as fallback
                    if (!controller.hasFilterOptions) ...[
                      _buildFilterSection(
                        'Tribes',
                        [
                          'Maasai',
                          'Makonde',
                          'Chagga',
                          'Hadzabe',
                          'Sukuma'
                        ], // Common Tanzanian tribes
                        controller.selectedTribe.value,
                        (value) => controller.selectedTribe.value = value,
                        Iconsax.people,
                      ),
                      _buildFilterSection(
                        'Regions',
                        [
                          'Arusha',
                          'Kilimanjaro',
                          'Dar es Salaam',
                          'Zanzibar',
                          'Mwanza'
                        ],
                        controller.selectedRegion.value,
                        (value) => controller.selectedRegion.value = value,
                        Iconsax.location,
                      ),
                      _buildFilterSection(
                        'Materials',
                        ['Wood', 'Stone', 'Beads', 'Fabric', 'Metal', 'Clay'],
                        controller.selectedMaterial.value,
                        (value) => controller.selectedMaterial.value = value,
                        Iconsax.box,
                      ),
                    ] else ...[
                      // API-loaded filters
                      if (controller.availableTribes.isNotEmpty)
                        _buildFilterSection(
                          'Tribes',
                          controller.availableTribes,
                          controller.selectedTribe.value,
                          (value) => controller.selectedTribe.value = value,
                          Iconsax.people,
                        ),

                      if (controller.availableRegions.isNotEmpty)
                        _buildFilterSection(
                          'Regions',
                          controller.availableRegions,
                          controller.selectedRegion.value,
                          (value) => controller.selectedRegion.value = value,
                          Iconsax.location,
                        ),

                      if (controller.availableMaterials.isNotEmpty)
                        _buildFilterSection(
                          'Materials',
                          controller.availableMaterials,
                          controller.selectedMaterial.value,
                          (value) => controller.selectedMaterial.value = value,
                          Iconsax.box,
                        ),

                      if (controller.availableCollections.isNotEmpty)
                        _buildFilterSection(
                          'Collections',
                          controller.availableCollections,
                          controller.selectedCollection.value,
                          (value) =>
                              controller.selectedCollection.value = value,
                          Iconsax.gallery,
                        ),

                      // Price Range
                      if (controller.priceRange.isNotEmpty)
                        _buildPriceRangeSection(),
                    ],

                    // Other Options (always show)
                    _buildSwitchSection(
                      'Other Options',
                      [
                        {
                          'title': 'Featured Only',
                          'value': controller.showFeaturedOnly.value,
                          'onChanged': (value) =>
                              controller.showFeaturedOnly.value = value,
                        },
                        {
                          'title': 'Unique Pieces Only',
                          'value': controller.showUniqueOnly.value,
                          'onChanged': (value) =>
                              controller.showUniqueOnly.value = value,
                        },
                      ],
                    ),

                    SizedBox(height: 100.h), // Space for bottom buttons
                  ],
                ),
              );
            }),
          ),

          // Bottom Buttons
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      controller.clearFilters();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                    ),
                    child: Text(
                      'Clear All',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      controller.pagingController.refresh();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      elevation: 0,
                    ),
                    child: Text(
                      'Apply Filters',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onChanged,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            // All option
            _buildFilterChip(
              'All',
              selectedValue.isEmpty,
              () => onChanged(''),
            ),
            // Individual options
            ...options.map(
              (option) => _buildFilterChip(
                option,
                selectedValue == option,
                () => onChanged(option),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildEmptyFilterSection(String title, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          message,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRangeSection() {
    return Obx(() {
      final minLimit = controller.minPriceLimit ?? 0;
      final maxLimit = controller.maxPriceLimit ?? 10000;
      final currentMin = controller.minPrice.value ?? minLimit;
      final currentMax = controller.maxPrice.value ?? maxLimit;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.money, size: 20.sp, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                'Price Range (TZS)',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          RangeSlider(
            values: RangeValues(currentMin, currentMax),
            min: minLimit,
            max: maxLimit,
            divisions: 20,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.primary.withOpacity(0.2),
            labels: RangeLabels(
              'TZS ${currentMin.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
              'TZS ${currentMax.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
            ),
            onChanged: (RangeValues values) {
              controller.minPrice.value = values.start;
              controller.maxPrice.value = values.end;
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TZS ${minLimit.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'TZS ${maxLimit.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
        ],
      );
    });
  }

  Widget _buildSwitchSection(String title, List<Map<String, dynamic>> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.setting_2, size: 20.sp, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        ...options.map(
          (option) => SwitchListTile(
            title: Text(
              option['title'],
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
            ),
            value: option['value'],
            onChanged: option['onChanged'],
            activeColor: AppColors.primary,
            contentPadding: EdgeInsets.zero,
          ),
        ),
        SizedBox(height: 24.h),
      ],
    );
  }
}
