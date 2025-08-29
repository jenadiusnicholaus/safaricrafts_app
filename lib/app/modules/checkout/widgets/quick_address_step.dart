import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/checkout_controller.dart';
import '../../../core/theme/app_colors.dart';

class QuickAddressStep extends GetView<CheckoutController> {
  QuickAddressStep({super.key}) {
    // Initialize form observables with current controller values
    _fullNameController.addListener(() {
      controller.formFullName.value = _fullNameController.text;
      _checkAndLoadShippingMethods();
    });
    _phoneController.addListener(() {
      controller.formPhone.value = _phoneController.text;
      _checkAndLoadShippingMethods();
    });
    _addressController.addListener(() {
      controller.formAddress.value = _addressController.text;
      _checkAndLoadShippingMethods();
    });
    _cityController.addListener(() {
      controller.formCity.value = _cityController.text;
      _checkAndLoadShippingMethods();
    });
  }

  void _checkAndLoadShippingMethods() {
    final hasAllFields = _fullNameController.text.isNotEmpty &&
        _phoneController.text.isNotEmpty &&
        _addressController.text.isNotEmpty &&
        _cityController.text.isNotEmpty;

    if (hasAllFields && controller.availableShippingMethods.isEmpty) {
      // Create a temporary address to load shipping methods
      final tempAddress = controller.createQuickAddress(
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        city: _cityController.text,
        region: _regionController.text.isNotEmpty
            ? _regionController.text
            : 'Dar es Salaam',
      );
      controller.setShippingAddress(tempAddress);
      controller.loadShippingMethods();
    }
  }

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step title
          Text(
            'Delivery Details',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() {
            final hasData = controller.formFullName.value.isNotEmpty &&
                controller.formPhone.value.isNotEmpty &&
                controller.formAddress.value.isNotEmpty &&
                controller.formCity.value.isNotEmpty;

            return Text(
              hasData
                  ? 'Review your delivery information and select shipping method'
                  : 'Enter your delivery information quickly and easily',
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textSecondary,
              ),
            );
          }),
          SizedBox(height: 24.h),

          // Quick address form
          _buildQuickAddressForm(),
          SizedBox(height: 24.h),

          // Shipping methods
          _buildShippingMethodsSection(),
          SizedBox(height: 32.h),

          // Continue button
          _buildContinueButton(),
        ],
      ),
    );
  }

  Widget _buildQuickAddressForm() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.location,
                size: 24.sp,
                color: AppColors.primary,
              ),
              SizedBox(width: 12.w),
              Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Full name
          _buildTextField(
            label: 'Full Name',
            hint: 'John Doe',
            icon: Iconsax.user,
            controller: _fullNameController,
            onChanged: (value) => controller.formFullName.value = value,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Phone number
          _buildTextField(
            label: 'Phone Number',
            hint: '+255 712 345 678',
            icon: Iconsax.call,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\s\(\)]')),
            ],
            controller: _phoneController,
            onChanged: (value) => controller.formPhone.value = value,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              if (!controller.isValidPhoneNumber(value.trim())) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Address
          _buildTextField(
            label: 'Street Address',
            hint: 'Uhuru Street, House No. 123',
            icon: Iconsax.home,
            maxLines: 2,
            controller: _addressController,
            onChanged: (value) => controller.formAddress.value = value,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your address';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // City and Region row
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  label: 'City',
                  hint: 'Dar es Salaam',
                  icon: Iconsax.building,
                  controller: _cityController,
                  onChanged: (value) => controller.formCity.value = value,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter city';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildTextField(
                  label: 'Region',
                  hint: 'Dar es Salaam',
                  icon: Iconsax.map,
                  controller: _regionController,
                  onChanged: (value) {},
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter region';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Same as billing address checkbox
          Obx(() => Row(
                children: [
                  Checkbox(
                    value: controller.sameAsShipping.value,
                    onChanged: (value) =>
                        controller.toggleSameAsShipping(value ?? true),
                    activeColor: AppColors.primary,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Use same address for billing',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20.sp, color: AppColors.textSecondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: Colors.red, width: 1),
            ),
            filled: true,
            fillColor: AppColors.background,
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          ),
        ),
      ],
    );
  }

  Widget _buildShippingMethodsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Iconsax.truck,
              size: 24.sp,
              color: AppColors.primary,
            ),
            SizedBox(width: 12.w),
            Text(
              'Shipping Method',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Obx(() {
          if (controller.isLoading.value) {
            return _buildShippingLoadingState();
          }

          if (controller.availableShippingMethods.isEmpty) {
            return _buildNoShippingMethods();
          }

          return _buildShippingMethodsList();
        }),
      ],
    );
  }

  Widget _buildShippingLoadingState() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 12.h),
            Text(
              'Loading shipping options...',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoShippingMethods() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Iconsax.info_circle,
            size: 20.sp,
            color: Colors.orange,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              'Please enter your address to see available shipping options',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShippingMethodsList() {
    return Column(
      children: controller.availableShippingMethods.map((method) {
        final isSelected =
            controller.selectedShippingMethod.value?.id == method.id;
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          child: InkWell(
            onTap: () => controller.selectShippingMethod(method),
            borderRadius: BorderRadius.circular(12.r),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withOpacity(0.1)
                    : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.truck_fast,
                    size: 24.sp,
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.textSecondary,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          method.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          method.description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${method.minDeliveryDays}-${method.maxDeliveryDays} business days',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        method.formattedCost,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 14.sp,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContinueButton() {
    return Obx(() {
      final isLoading = controller.isLoading.value;
      final hasAddress = controller.formFullName.value.isNotEmpty &&
          controller.formPhone.value.isNotEmpty &&
          controller.formAddress.value.isNotEmpty &&
          controller.formCity.value.isNotEmpty;
      final canContinue = hasAddress && !isLoading;

      return SizedBox(
        width: double.infinity,
        height: 56.h,
        child: ElevatedButton(
          onPressed: canContinue ? _handleContinue : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            elevation: 0,
          ),
          child: isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.arrow_right_3,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Continue to Payment',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
        ),
      );
    });
  }

  void _handleContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      // Load shipping methods if not already loaded
      if (controller.availableShippingMethods.isEmpty) {
        controller.loadShippingMethods();
        return;
      }

      // Complete address and shipping step
      controller.completeAddressAndShipping(
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        city: _cityController.text,
        region: _regionController.text,
        selectedShipping: controller.selectedShippingMethod.value,
      );
    }
  }

  // Form field values - using controllers instead of instance variables
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController(text: 'Dar es Salaam');
  final _regionController = TextEditingController(text: 'Dar es Salaam');
}
