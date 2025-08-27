import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/checkout_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/checkout/address_model.dart';

class BillingAddressStep extends GetView<CheckoutController> {
  BillingAddressStep({super.key});

  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyController = TextEditingController();
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _regionController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController(text: 'TZ');

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // If same as shipping is enabled and we have a shipping address, auto-continue
      if (controller.sameAsShipping.value &&
          controller.shippingAddress.value != null) {
        return _buildSameAsShippingView();
      }

      // Pre-fill form if billing address exists
      if (controller.billingAddress.value != null) {
        final address = controller.billingAddress.value!;
        _firstNameController.text = address.firstName;
        _lastNameController.text = address.lastName;
        _companyController.text = address.company ?? '';
        _addressLine1Controller.text = address.addressLine1;
        _addressLine2Controller.text = address.addressLine2 ?? '';
        _cityController.text = address.city;
        _regionController.text = address.region;
        _postalCodeController.text = address.postalCode ?? '';
        _phoneController.text = address.phone;
        _countryController.text = address.country;
      }

      return _buildBillingForm();
    });
  }

  Widget _buildSameAsShippingView() {
    final shippingAddress = controller.shippingAddress.value!;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              Icon(
                Iconsax.receipt_edit,
                color: AppColors.primary,
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Billing Address',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Same as shipping info
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.success.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Iconsax.tick_circle,
                      color: AppColors.success,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Using shipping address for billing',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  shippingAddress.formattedAddress,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          // Option to use different billing address
          TextButton(
            onPressed: () => controller.toggleSameAsShipping(false),
            child: Text(
              'Use different billing address',
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          SizedBox(height: 24.h),

          // Navigation buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.previousStep(),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => controller.nextStep(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Continue to Payment',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingForm() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(
                  Iconsax.receipt_edit,
                  color: AppColors.primary,
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Billing Address',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Back to same as shipping option
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.info_circle,
                    color: AppColors.primary,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'You can use the same address as shipping',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => controller.toggleSameAsShipping(true),
                    child: Text(
                      'Use Same',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Form fields (same as shipping address form)
            // Name fields
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: _firstNameController,
                    label: 'First Name',
                    hint: 'Enter first name',
                    isRequired: true,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildTextFormField(
                    controller: _lastNameController,
                    label: 'Last Name',
                    hint: 'Enter last name',
                    isRequired: true,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Company (optional)
            _buildTextFormField(
              controller: _companyController,
              label: 'Company (Optional)',
              hint: 'Enter company name',
            ),

            SizedBox(height: 16.h),

            // Address Line 1
            _buildTextFormField(
              controller: _addressLine1Controller,
              label: 'Address Line 1',
              hint: 'Street address, P.O. Box, etc.',
              isRequired: true,
            ),

            SizedBox(height: 16.h),

            // Address Line 2 (optional)
            _buildTextFormField(
              controller: _addressLine2Controller,
              label: 'Address Line 2 (Optional)',
              hint: 'Apartment, suite, unit, building, floor, etc.',
            ),

            SizedBox(height: 16.h),

            // City and Region
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: _cityController,
                    label: 'City',
                    hint: 'Enter city',
                    isRequired: true,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildTextFormField(
                    controller: _regionController,
                    label: 'Region',
                    hint: 'Enter region',
                    isRequired: true,
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Postal Code and Country
            Row(
              children: [
                Expanded(
                  child: _buildTextFormField(
                    controller: _postalCodeController,
                    label: 'Postal Code',
                    hint: 'Enter postal code',
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildCountryDropdown(),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Phone Number
            _buildTextFormField(
              controller: _phoneController,
              label: 'Phone Number',
              hint: '+255712345678',
              keyboardType: TextInputType.phone,
              isRequired: true,
            ),

            SizedBox(height: 24.h),

            // Navigation buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.previousStep(),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.primary),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Back',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _saveAndContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'Continue to Payment',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool isRequired = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            if (isRequired)
              Text(
                ' *',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.red,
                ),
              ),
          ],
        ),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'This field is required';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildCountryDropdown() {
    final countries = [
      {'code': 'TZ', 'name': 'Tanzania'},
      {'code': 'KE', 'name': 'Kenya'},
      {'code': 'UG', 'name': 'Uganda'},
      {'code': 'RW', 'name': 'Rwanda'},
      {'code': 'BI', 'name': 'Burundi'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Country',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              ' *',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<String>(
          value: _countryController.text,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
          items: countries.map((country) {
            return DropdownMenuItem(
              value: country['code'],
              child: Text(
                country['name']!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                ),
              ),
            );
          }).toList(),
          onChanged: (value) {
            _countryController.text = value ?? 'TZ';
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a country';
            }
            return null;
          },
        ),
      ],
    );
  }

  void _saveAndContinue() {
    if (_formKey.currentState!.validate()) {
      final address = AddressModel(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
        addressLine1: _addressLine1Controller.text.trim(),
        addressLine2: _addressLine2Controller.text.trim().isEmpty
            ? null
            : _addressLine2Controller.text.trim(),
        city: _cityController.text.trim(),
        region: _regionController.text.trim(),
        postalCode: _postalCodeController.text.trim().isEmpty
            ? null
            : _postalCodeController.text.trim(),
        country: _countryController.text,
        phone: _phoneController.text.trim(),
      );

      controller.setBillingAddress(address);
      controller.nextStep();
    }
  }
}
