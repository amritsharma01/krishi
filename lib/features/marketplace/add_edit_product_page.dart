import 'dart:io';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/components/app_text.dart';
import 'package:krishi/features/components/selection_dialog.dart';
import 'package:krishi/models/category.dart';
import 'package:krishi/models/product.dart';
import 'package:krishi/models/unit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  Category? selectedCategory;
  Unit? selectedUnit;

  List<Category> categories = [];
  List<Unit> units = [];
  bool isLoadingCategories = true;
  bool isLoadingUnits = true;
  bool isSaving = false;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    _loadData();

    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price;
      _descriptionController.text = widget.product!.description;
      _phoneController.text = widget.product!.sellerPhoneNumber ?? '';
      _isAvailable = widget.product!.isAvailable;
    } else {
      _isAvailable = true;
    }
  }

  Future<void> _loadData() async {
    await Future.wait([_loadCategories(), _loadUnits()]);

    // Set selected category and unit if editing
    if (widget.product != null) {
      selectedCategory = categories.firstWhere(
        (cat) => cat.id == widget.product!.category,
        orElse: () => categories.first,
      );
      selectedUnit = units.firstWhere(
        (unit) => unit.id == widget.product!.unit,
        orElse: () => units.first,
      );
    } else {
      // Set defaults for new product
      if (categories.isNotEmpty) selectedCategory = categories.first;
      if (units.isNotEmpty) selectedUnit = units.first;
    }
    setState(() {});
  }

  Future<void> _loadCategories() async {
    setState(() => isLoadingCategories = true);
    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final cats = await apiService.getCategories();
      if (mounted) {
        setState(() {
          categories = cats;
          isLoadingCategories = false;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      if (mounted) {
        setState(() {
          // Set default "general" category when loading fails
          categories = [
            Category(id: 0, name: 'general', createdAt: DateTime.now()),
          ];
          selectedCategory = categories.first;
          isLoadingCategories = false;
        });
        Get.snackbar(
          'error_loading_categories'.tr(Get.context),
          color: Colors.red,
        );
      }
    }
  }

  Future<void> _loadUnits() async {
    setState(() => isLoadingUnits = true);
    try {
      final apiService = ref.read(krishiApiServiceProvider);
      final uts = await apiService.getUnits();
      if (mounted) {
        setState(() {
          units = uts;
          isLoadingUnits = false;
        });
      }
    } catch (e) {
      print('Error loading units: $e');
      if (mounted) {
        setState(() {
          // Set default "general" unit when loading fails
          units = [Unit(id: 0, name: 'general', createdAt: DateTime.now())];
          selectedUnit = units.first;
          isLoadingUnits = false;
        });
        Get.snackbar('error_loading_units'.tr(Get.context), color: Colors.red);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    super.dispose();
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
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
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

  void _showCategoryDialog() {
    SelectionDialog.show<Category>(
      context: context,
      title: 'select_category'.tr(context),
      items: categories,
      selectedItem: selectedCategory,
      getItemName: (category) => category.name,
      getItemId: (category) => category.id,
      onItemSelected: (category) {
        setState(() {
          selectedCategory = category;
        });
      },
    );
  }

  void _showUnitDialog() {
    SelectionDialog.show<Unit>(
      context: context,
      title: 'select_unit'.tr(context),
      items: units,
      selectedItem: selectedUnit,
      getItemName: (unit) => unit.name,
      getItemId: (unit) => unit.id,
      onItemSelected: (unit) {
        setState(() {
          selectedUnit = unit;
        });
      },
    );
  }

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCategory == null) {
        Get.snackbar('select_category'.tr(context));
        return;
      }

      if (selectedUnit == null) {
        Get.snackbar('select_unit'.tr(context));
        return;
      }

      setState(() => isSaving = true);

      try {
        final apiService = ref.read(krishiApiServiceProvider);

        if (widget.product == null) {
          // Create new product
          await apiService.createProduct(
            name: _nameController.text,
            sellerPhoneNumber: _phoneController.text,
            category: selectedCategory!.id,
            price: _priceController.text,
            description: _descriptionController.text,
            unit: selectedUnit!.id,
            isAvailable: _isAvailable,
            imagePath: _selectedImage?.path,
          );
        } else {
          // Update existing product
          await apiService.updateProduct(
            id: widget.product!.id,
            name: _nameController.text,
            sellerPhoneNumber: _phoneController.text,
            category: selectedCategory!.id,
            price: _priceController.text,
            description: _descriptionController.text,
            unit: selectedUnit!.id,
            isAvailable: _isAvailable,

            imagePath: _selectedImage?.path,
          );
        }

        if (mounted) {
          setState(() => isSaving = false);

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
          setState(() => isSaving = false);
          Get.snackbar(
            'error_saving_product'.tr(Get.context),
            color: Colors.red,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      backgroundColor: Get.scaffoldBackgroundColor,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Get.scaffoldBackgroundColor,
        elevation: 0,
        title: AppText(
          isEdit ? 'edit_product'.tr(context) : 'add_new_product'.tr(context),
          style: Get.bodyLarge.px22.w700.copyWith(color: Get.disabledColor),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Get.disabledColor),
          onPressed: () => Get.pop(),
        ),
      ),
      body: isLoadingCategories || isLoadingUnits
          ? Center(child: CircularProgressIndicator(color: AppColors.primary))
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16).rt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Selector
                    AppText(
                      'product_image'.tr(context),
                      style: Get.bodyMedium.px15.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                    ),
                    12.verticalGap,
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
                            child: _selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14).rt,
                                    child: Image.file(
                                      _selectedImage!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                                  )
                                : (widget.product?.image != null
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ).rt,
                                          child: Image.network(
                                            Get.baseUrl +
                                                widget.product!.image!,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                            height: double.infinity,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .add_photo_alternate_outlined,
                                                        size: 48.st,
                                                        color: AppColors.primary
                                                            .withValues(
                                                              alpha: 0.5,
                                                            ),
                                                      ),
                                                      12.verticalGap,
                                                      AppText(
                                                        'tap_to_add_image'.tr(
                                                          context,
                                                        ),
                                                        style: Get
                                                            .bodyMedium
                                                            .px14
                                                            .copyWith(
                                                              color: Get
                                                                  .disabledColor
                                                                  .withValues(
                                                                    alpha: 0.6,
                                                                  ),
                                                            ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                            loadingBuilder:
                                                (
                                                  context,
                                                  child,
                                                  loadingProgress,
                                                ) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  }
                                                  return Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                          color:
                                                              AppColors.primary,
                                                        ),
                                                  );
                                                },
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons
                                                  .add_photo_alternate_outlined,
                                              size: 48.st,
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.5),
                                            ),
                                            12.verticalGap,
                                            AppText(
                                              'tap_to_add_image'.tr(context),
                                              style: Get.bodyMedium.px14
                                                  .copyWith(
                                                    color: Get.disabledColor
                                                        .withValues(alpha: 0.6),
                                                  ),
                                            ),
                                          ],
                                        )),
                          ),
                        ),
                        if (_selectedImage != null)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedImage = null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8).rt,
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.white,
                                  size: 18.st,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    24.verticalGap,

                    // Product Name
                    AppText(
                      'product_name'.tr(context),
                      style: Get.bodyMedium.px15.w700.copyWith(
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
                    16.verticalGap,

                    // Phone Number
                    AppText(
                      'contact_phone'.tr(context),
                      style: Get.bodyMedium.px15.w700.copyWith(
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
                    16.verticalGap,

                    // Category
                    AppText(
                      'category'.tr(context),
                      style: Get.bodyMedium.px15.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                    ),
                    8.verticalGap,
                    GestureDetector(
                      onTap: () => _showCategoryDialog(),
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
                                selectedCategory?.name ??
                                    'select_category'.tr(context),
                                style: Get.bodyMedium.px15.copyWith(
                                  color: selectedCategory != null
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
                    16.verticalGap,

                    // Price and Unit in Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                'price'.tr(context),
                                style: Get.bodyMedium.px15.w700.copyWith(
                                  color: Get.disabledColor,
                                ),
                              ),
                              8.verticalGap,
                              TextFormField(
                                controller: _priceController,
                                decoration: InputDecoration(
                                  hintText: '0.00',
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
                        16.horizontalGap,
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText(
                                'unit'.tr(context),
                                style: Get.bodyMedium.px15.w700.copyWith(
                                  color: Get.disabledColor,
                                ),
                              ),
                              8.verticalGap,
                              GestureDetector(
                                onTap: () => _showUnitDialog(),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ).rt,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Get.disabledColor.withValues(
                                        alpha: 0.2,
                                      ),
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
                                          style: Get.bodyMedium.px15.copyWith(
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
                                        color: Get.disabledColor.withValues(
                                          alpha: 0.5,
                                        ),
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
                    16.verticalGap,

                    // Description
                    AppText(
                      'description'.tr(context),
                      style: Get.bodyMedium.px15.w700.copyWith(
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
                    24.verticalGap,

                    // Availability Toggle
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16).rt,
                      decoration: BoxDecoration(
                        color: Get.cardColor,
                        borderRadius: BorderRadius.circular(14).rt,
                        border: Border.all(
                          color: Get.disabledColor.withValues(alpha: 0.15),
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
                                      'available_for_sale'.tr(context),
                                      style: Get.bodyMedium.px15.w700.copyWith(
                                        color: Get.disabledColor,
                                      ),
                                    ),
                                    4.verticalGap,
                                    AppText(
                                      'available_for_sale_hint'.tr(context),
                                      style: Get.bodySmall.copyWith(
                                        color: Get.disabledColor
                                            .withValues(alpha: 0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Switch.adaptive(
                                value: _isAvailable,
                                onChanged: (value) =>
                                    setState(() => _isAvailable = value),
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    24.verticalGap,

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
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : AppText(
                                isEdit
                                    ? 'update'.tr(context)
                                    : 'save'.tr(context),
                                style: Get.bodyMedium.px16.w700.copyWith(
                                  color: AppColors.white,
                                ),
                              ),
                      ),
                    ),
                    20.verticalGap,
                  ],
                ),
              ),
            ),
    );
  }
}
