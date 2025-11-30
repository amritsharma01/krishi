import 'dart:io';
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/color_extensions.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/selection_dialog.dart';
import 'package:krishi/features/marketplace/providers/marketplace_providers.dart';
import 'package:krishi/models/category.dart';
import 'package:krishi/models/product.dart';
import 'package:krishi/models/unit.dart';
import 'package:krishi/models/user_profile.dart';

class AddEditProductPage extends ConsumerStatefulWidget {
  final Product? product; // null for add, existing product for edit

  const AddEditProductPage({super.key, this.product});

  @override
  ConsumerState<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends ConsumerState<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  Product? _prefillSourceProduct;

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _initializeForm() async {
    if (widget.product != null) {
      _prefillSourceProduct = widget.product;
      _applyProductTextFields(widget.product!);
      ref.read(isAvailableProvider.notifier).state = widget.product!.isAvailable;
      await _prefillFromProductDetail();
    } else {
      ref.read(isAvailableProvider.notifier).state = true;
      await _prefillFromAccountDetails();
    }
  }

  Category? _findCategoryById(List<Category> categories, int id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (_) {
      return null;
    }
  }

  Unit? _findUnitById(List<Unit> units, int id) {
    try {
      return units.firstWhere((unit) => unit.id == id);
    } catch (_) {
      return null;
    }
  }

  void _applyProductTextFields(Product product) {
    _nameController.text = product.name;
    _priceController.text = product.basePrice;
    _descriptionController.text = product.description;
    _phoneController.text = product.sellerPhoneNumber ?? '';
    _addressController.text = product.sellerAddress ?? '';
  }

  Future<void> _prefillFromProductDetail() async {
    if (widget.product == null) return;
    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final latest = await apiService.getProduct(widget.product!.id);
      if (!mounted) return;

      _prefillSourceProduct = latest;
      _applyProductTextFields(latest);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to preload product detail: $e');
      }
    }
  }

  Future<void> _prefillFromAccountDetails() async {
    try {
      final apiService = ref.read(krishiApiServiceProvider);

      // Fetch fresh data from API
      final user = await apiService.getCurrentUser();

      if (!mounted) return;
      _applyAccountDetails(user);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to prefill from account details: $e');
      }
    }
  }

  void _applyAccountDetails(User user) {
    if (!mounted) return;

    final profile = user.profile;

    // Fill phone number from account if empty
    if (_phoneController.text.isEmpty) {
      final phone = profile?.phoneNumber?.trim();
      if (phone != null && phone.isNotEmpty) {
        _phoneController.text = phone;
      }
    }

    // Fill address from account if empty
    if (_addressController.text.isEmpty) {
      final address = profile?.address?.trim();
      if (address != null && address.isNotEmpty) {
        _addressController.text = address;
      }
    }

    // Note: Price is not available in account details, so we leave it empty
    // User will need to enter the price manually
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final compressedFile = await _compressImage(File(pickedFile.path));
        ref.read(selectedImageProvider.notifier).state = compressedFile;
      }
    } catch (e) {
      Get.snackbar('error_picking_image'.tr(Get.context), color: Colors.red);
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Get.cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24.rt),
            topRight: Radius.circular(24.rt),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20).rt,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40.rt,
                  height: 4.rt,
                  decoration: BoxDecoration(
                    color: Get.disabledColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2).rt,
                  ),
                ),
                20.verticalGap,
                AppText(
                  'select_image_source'.tr(context),
                  style: Get.bodyLarge.px18.w700.copyWith(
                    color: Get.disabledColor,
                  ),
                ),
                24.verticalGap,
                Row(
                  children: [
                    Expanded(
                      child: _buildImageSourceOption(
                        icon: Icons.camera_alt_rounded,
                        label: 'camera'.tr(context),
                        onTap: () {
                          Get.pop();
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                    16.horizontalGap,
                    Expanded(
                      child: _buildImageSourceOption(
                        icon: Icons.photo_library_rounded,
                        label: 'gallery'.tr(context),
                        onTap: () {
                          Get.pop();
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                  ],
                ),
                20.verticalGap,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20).rt,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.1),
              AppColors.primary.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16).rt,
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12).rt,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 32.st),
            ),
            12.verticalGap,
            AppText(
              label,
              style: Get.bodyMedium.px14.w600.copyWith(
                color: Get.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog(List<Category> categories) {
    final selectedCategory = ref.read(selectedCategoryProvider);
    SelectionDialog.show<Category>(
      context: context,
      title: 'select_category'.tr(context),
      items: categories,
      selectedItem: selectedCategory,
      getItemName: (category) => category.name,
      getItemId: (category) => category.id,
      onItemSelected: (category) {
        ref.read(selectedCategoryProvider.notifier).state = category;
      },
    );
  }

  void _showUnitDialog(List<Unit> units) {
    final selectedUnit = ref.read(selectedUnitProvider);
    SelectionDialog.show<Unit>(
      context: context,
      title: 'select_unit'.tr(context),
      items: units,
      selectedItem: selectedUnit,
      getItemName: (unit) => unit.name,
      getItemId: (unit) => unit.id,
      onItemSelected: (unit) {
        ref.read(selectedUnitProvider.notifier).state = unit;
      },
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final selectedCategory = ref.read(selectedCategoryProvider);
      final selectedUnit = ref.read(selectedUnitProvider);
      
      if (selectedCategory == null) {
        Get.snackbar('select_category'.tr(context));
        return;
      }

      if (selectedUnit == null) {
        Get.snackbar('select_unit'.tr(context));
        return;
      }

      ref.read(isSavingProductProvider.notifier).state = true;

      try {
        final apiService = ref.read(krishiApiServiceProvider);
        final selectedImage = ref.read(selectedImageProvider);
        final isAvailable = ref.read(isAvailableProvider);

        if (widget.product == null) {
          // Create new product
          await apiService.createProduct(
            name: _nameController.text.trim(),
            sellerPhoneNumber: _phoneController.text.trim(),
            sellerAddress: _addressController.text.trim(),
            category: selectedCategory.id,
            basePrice: _priceController.text.trim(),
            description: _descriptionController.text.trim(),
            unit: selectedUnit.id,
            isAvailable: isAvailable,
            imagePath: selectedImage?.path,
          );
        } else {
          // Update existing product
          await apiService.updateProduct(
            id: widget.product!.id,
            name: _nameController.text.trim(),
            sellerPhoneNumber: _phoneController.text.trim(),
            sellerAddress: _addressController.text.trim(),
            category: selectedCategory.id,
            basePrice: _priceController.text.trim(),
            description: _descriptionController.text.trim(),
            unit: selectedUnit.id,
            isAvailable: isAvailable,
            imagePath: selectedImage?.path,
          );
        }

        if (mounted) {
          ref.read(isSavingProductProvider.notifier).state = false;
          // Show success message
          Get.snackbar(
            widget.product == null
                ? 'product_added'.tr(Get.context)
                : 'product_updated'.tr(Get.context),
            color: Colors.green,
          );

          // Pop after a short delay to let the snackbar show
          Future.delayed(const Duration(milliseconds: 500), () {
            Navigator.of(
              Get.context,
            ).pop(true); // Return true to indicate success
          });
        }
      } catch (e) {
        print('Error saving product: $e');
        if (mounted) {
          ref.read(isSavingProductProvider.notifier).state = false;
          Get.snackbar(
            'error_saving_product'.tr(Get.context),
            color: Colors.red,
          );
        }
      }
    }
  }

  Future<File> _compressImage(File file) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath =
          '${tempDir.path}/krishi_product_${DateTime.now().millisecondsSinceEpoch}.jpg';

      int quality = 80;
      File? compressedFile;
      while (quality >= 45) {
        final compressed = await FlutterImageCompress.compressAndGetFile(
          file.absolute.path,
          targetPath,
          quality: quality,
          minWidth: 256,
          minHeight: 256,
          format: CompressFormat.jpeg,
        );

        if (compressed == null) {
          break;
        }

        compressedFile = File(compressed.path);
        final sizeInKb = compressedFile.lengthSync() / 1024;
        if (sizeInKb <= 400 || quality <= 50) {
          break;
        }
        quality -= 10;
      }

      return compressedFile ?? file;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Image compression failed: $e\n$stackTrace');
      }
      return file;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final categoriesAsync = ref.watch(categoriesProvider);
    final unitsAsync = ref.watch(unitsProvider);

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        title: AppText(
          isEdit ? 'edit_product'.tr(context) : 'add_new_product'.tr(context),
          style: Get.bodyLarge.px18.w700.copyWith(color: Get.disabledColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.disabledColor),
          onPressed: () => Get.pop(),
        ),
      ),
      body: categoriesAsync.isLoading || unitsAsync.isLoading
          ? Center(
              child: CircularProgressIndicator.adaptive(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : categoriesAsync.hasError || unitsAsync.hasError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppText(
                    'error_loading_data'.tr(context),
                    style: Get.bodyMedium.copyWith(color: Colors.red),
                  ),
                  16.verticalGap,
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(categoriesProvider);
                      ref.invalidate(unitsProvider);
                    },
                    child: AppText('retry'.tr(context)),
                  ),
                ],
              ),
            )
          : _buildForm(
              context,
              isEdit,
              categoriesAsync.value ?? [],
              unitsAsync.value ?? [],
            ),
    );
  }

  Widget _buildForm(
    BuildContext context,
    bool isEdit,
    List<Category> categories,
    List<Unit> units,
  ) {
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final selectedUnit = ref.watch(selectedUnitProvider);
    final selectedImage = ref.watch(selectedImageProvider);
    final isAvailable = ref.watch(isAvailableProvider);
    final isSaving = ref.watch(isSavingProductProvider);

    // Initialize selections if needed
    if (_prefillSourceProduct != null && selectedCategory == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(selectedCategoryProvider.notifier).state = _findCategoryById(
          categories,
          _prefillSourceProduct!.category,
        );
        ref.read(selectedUnitProvider.notifier).state = _findUnitById(
          units,
          _prefillSourceProduct!.unit,
        );
      });
    } else if (!isEdit && selectedCategory == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (categories.isNotEmpty) {
          ref.read(selectedCategoryProvider.notifier).state = categories.first;
        }
        if (units.isNotEmpty) {
          ref.read(selectedUnitProvider.notifier).state = units.first;
        }
      });
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16).rt,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Selector
            AppText(
              'product_image'.tr(context),
              style: Get.bodyMedium.px14.w600.copyWith(color: Get.disabledColor),
            ),
            7.verticalGap,
            Stack(
              children: [
                GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: Container(
                    width: double.infinity,
                    height: 200.rt,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16).rt,
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        width: 2,
                      ),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14).rt,
                            child: Image.file(
                              selectedImage,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          )
                        : (widget.product?.image != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(14).rt,
                                  child: Image.network(
                                    Get.imageUrl(widget.product!.image!),
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add_photo_alternate_outlined,
                                            size: 48.st,
                                            color: AppColors.primary.withValues(alpha: 0.5),
                                          ),
                                          12.verticalGap,
                                          AppText(
                                            'tap_to_add_image'.tr(context),
                                            style: Get.bodyMedium.px14.copyWith(
                                              color: Get.disabledColor.withValues(alpha: 0.6),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator.adaptive(
                                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add_photo_alternate_outlined,
                                      size: 48.st,
                                      color: AppColors.primary.withValues(alpha: 0.5),
                                    ),
                                    12.verticalGap,
                                    AppText(
                                      'tap_to_add_image'.tr(context),
                                      style: Get.bodyMedium.px14.copyWith(
                                        color: Get.disabledColor.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                )),
                  ),
                ),
                if (selectedImage != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        ref.read(selectedImageProvider.notifier).state = null;
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8).rt,
                        decoration: BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.close, color: AppColors.white, size: 18.st),
                      ),
                    ),
                  ),
              ],
            ),
            10.verticalGap,

            // Product Name
            AppText(
              'product_name'.tr(context),
              style: Get.bodyMedium.px14.w600.copyWith(
                color: Get.disabledColor,
              ),
            ),
            8.verticalGap,
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                hintText: 'enter_product_name'.tr(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12).rt,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'required_field'.tr(context);
                }
                return null;
              },
            ),
            8.verticalGap,

            // Phone Number
            AppText(
              'contact_phone'.tr(context),
              style: Get.bodyMedium.px14.w600.copyWith(
                color: Get.disabledColor,
              ),
            ),
            8.verticalGap,
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: 'enter_phone'.tr(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12).rt,
                ),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'required_field'.tr(context);
                }
                return null;
              },
            ),
            8.verticalGap,

            // Address
            AppText(
              'contact_address'.tr(context),
              style: Get.bodyMedium.px14.w600.copyWith(
                color: Get.disabledColor,
              ),
            ),
            8.verticalGap,
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                hintText: 'enter_address'.tr(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12).rt,
                ),
              ),
              minLines: 1,
              maxLines: 2,
              validator: (value) {
                final trimmed = value?.trim() ?? '';
                if (trimmed.isEmpty) {
                  return 'required_field'.tr(context);
                }
                if (trimmed.length < 5) {
                  return 'address_min_length'.tr(context);
                }
                return null;
              },
            ),
            8.verticalGap,

            // Category
            AppText(
              'category'.tr(context),
              style: Get.bodyMedium.px14.w600.copyWith(
                color: Get.disabledColor,
              ),
            ),
            8.verticalGap,
            GestureDetector(
              onTap: () => _showCategoryDialog(categories),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ).rt,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Get.disabledColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12).rt,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        selectedCategory?.name ?? 'select_category'.tr(context),
                        style: Get.bodyMedium.px13.w500.copyWith(
                          color: selectedCategory != null
                              ? Get.disabledColor
                              : Get.disabledColor.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: Get.disabledColor.withValues(alpha: 0.5),
                    ),
                  ],
                ),
              ),
            ),
            8.verticalGap,

            // Price and Unit in Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'base_price'.tr(context),
                        style: Get.bodyMedium.px14.w600.copyWith(
                          color: Get.disabledColor,
                        ),
                      ),
                      8.verticalGap,
                      TextFormField(
                        controller: _priceController,
                        decoration: InputDecoration(
                          hintText: 'enter_base_price'.tr(context),
                          prefixText: 'Rs. ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12).rt,
                          ),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'required'.tr(context);
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                8.horizontalGap,
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'unit'.tr(context),
                        style: Get.bodyMedium.px14.w600.copyWith(
                          color: Get.disabledColor,
                        ),
                      ),
                      8.verticalGap,
                      GestureDetector(
                        onTap: () => _showUnitDialog(units),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ).rt,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Get.disabledColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(12).rt,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: AppText(
                                  selectedUnit?.name ??
                                      'select_unit'.tr(context),
                                  style: Get.bodyMedium.px13.w500.copyWith(
                                    color: selectedUnit != null
                                        ? Get.disabledColor
                                        : Get.disabledColor.withValues(
                                            alpha: 0.5,
                                          ),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Get.disabledColor.withValues(alpha: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            8.verticalGap,

            // Description
            AppText(
              'description'.tr(context),
              style: Get.bodyMedium.px14.w600.copyWith(
                color: Get.disabledColor,
              ),
            ),
            8.verticalGap,
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                hintText: 'enter_description'.tr(context),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12).rt,
                ),
              ),
              maxLines: 4,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'required_field'.tr(context);
                }
                return null;
              },
            ),
            8.verticalGap,

            // Rejection Reason (only show when editing a rejected product)
            if (widget.product != null &&
                widget.product!.approvalStatus?.toLowerCase() == 'rejected' &&
                widget.product!.rejectionReason != null &&
                widget.product!.rejectionReason!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12).rt,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12).rt,
                  border: Border.all(
                    color: Colors.red.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 16.st,
                          color: Colors.red.shade700,
                        ),
                        8.horizontalGap,
                        AppText(
                          'rejection_reason'.tr(context),
                          style: Get.bodySmall.px13.w700.copyWith(
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                    8.verticalGap,
                    AppText(
                      widget.product!.rejectionReason!,
                      style: Get.bodySmall.px12.w500.copyWith(
                        color: Colors.red.shade800,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            if (widget.product != null &&
                widget.product!.approvalStatus?.toLowerCase() == 'rejected' &&
                widget.product!.rejectionReason != null &&
                widget.product!.rejectionReason!.isNotEmpty)
              8.verticalGap,

            // Availability Toggle
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16).rt,
              decoration: BoxDecoration(
                color: Get.cardColor.o2,
                borderRadius: BorderRadius.circular(12).rt,
                border: Border.all(
                  color: Get.disabledColor.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(
                              maxLines: 2,
                              'available_for_sale'.tr(context),
                              style: Get.bodyMedium.px14.w600.copyWith(
                                color: Get.disabledColor,
                              ),
                            ),
                            4.verticalGap,
                            AppText(
                              maxLines: 3,
                              'available_for_sale_hint'.tr(context),
                              style: Get.bodySmall.px12.copyWith(
                                color: Get.disabledColor.withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: isAvailable,
                        onChanged: (value) {
                          ref.read(isAvailableProvider.notifier).state = value;
                        },
                        activeColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            8.verticalGap,

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14).rt,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12).rt,
                  ),
                ),
                child: isSaving
                    ? SizedBox(
                        height: 20.st,
                        width: 20.st,
                        child: CircularProgressIndicator.adaptive(
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                          strokeWidth: 2,
                        ),
                      )
                    : AppText(
                        isEdit ? 'update'.tr(context) : 'save'.tr(context),
                        style: Get.bodyMedium.px16.w700.copyWith(color: AppColors.white),
                      ),
              ),
            ),
            20.verticalGap,
          ],
        ),
      ),
    );
  }
}
