import 'dart:io';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/core_service_providers.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/widgets/app_text.dart';
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
  ConsumerState<AddEditProductPage> createState() =>
      _AddEditProductPageState();
}

class _AddEditProductPageState extends ConsumerState<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _unitsAvailableController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  File? _selectedImage;
  Category? selectedCategory;
  Unit? selectedUnit;
  
  List<Category> categories = [];
  List<Unit> units = [];
  bool isLoadingCategories = true;
  bool isLoadingUnits = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    if (widget.product != null) {
      _nameController.text = widget.product!.name;
      _priceController.text = widget.product!.price;
      _descriptionController.text = widget.product!.description;
      _phoneController.text = widget.product!.sellerPhoneNumber ?? '';
      _unitsAvailableController.text = widget.product!.unitsAvailable.toString();
    }
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadCategories(),
      _loadUnits(),
    ]);
    
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
          categories = [];
          isLoadingCategories = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load categories: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
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
          units = [];
          isLoadingUnits = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load units: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _unitsAvailableController.dispose();
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('error_picking_image'.tr(context)),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                          Navigator.pop(context);
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
                          Navigator.pop(context);
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
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 32.st,
              ),
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

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      if (selectedCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('select_category'.tr(context)),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (selectedUnit == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('select_unit'.tr(context)),
            backgroundColor: Colors.red,
          ),
        );
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
            unitsAvailable: int.parse(_unitsAvailableController.text),
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
            unitsAvailable: int.parse(_unitsAvailableController.text),
            imagePath: _selectedImage?.path,
          );
        }

        if (mounted) {
          Navigator.pop(context, true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.product == null
                    ? 'product_added'.tr(context)
                    : 'product_updated'.tr(context),
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => isSaving = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('error_saving_product'.tr(context)),
              backgroundColor: Colors.red,
            ),
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoadingCategories || isLoadingUnits
          ? Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
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
                                ),
                              )
                            : (widget.product?.image != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(14).rt,
                                    child: Image.network(
                                      Get.baseUrl + widget.product!.image!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.add_photo_alternate_outlined,
                                              size: 48.st,
                                              color: AppColors.primary
                                                  .withValues(alpha: 0.5),
                                            ),
                                            12.verticalGap,
                                            AppText(
                                              'tap_to_add_image'.tr(context),
                                              style:
                                                  Get.bodyMedium.px14.copyWith(
                                                color: Get.disabledColor
                                                    .withValues(alpha: 0.6),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Center(
                                          child: CircularProgressIndicator(
                                            color: AppColors.primary,
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
                                        color: AppColors.primary
                                            .withValues(alpha: 0.5),
                                      ),
                                      12.verticalGap,
                                      AppText(
                                        'tap_to_add_image'.tr(context),
                                        style: Get.bodyMedium.px14.copyWith(
                                          color: Get.disabledColor
                                              .withValues(alpha: 0.6),
                                        ),
                                      ),
                                    ],
                                  )),
                      ),
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
                    DropdownButtonFormField<Category>(
                      value: selectedCategory,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12).rt,
                        ),
                        hintText: categories.isEmpty
                            ? 'no_categories_available'.tr(context)
                            : 'select_category'.tr(context),
                      ),
                      items: categories.isEmpty
                          ? null
                          : categories
                              .map((cat) => DropdownMenuItem(
                                    value: cat,
                                    child: Text(cat.name),
                                  ))
                              .toList(),
                      onChanged: categories.isEmpty
                          ? null
                          : (value) {
                              setState(() => selectedCategory = value);
                            },
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
                                    decimal: true),
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
                              DropdownButtonFormField<Unit>(
                                value: selectedUnit,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12).rt,
                                  ),
                                  hintText: units.isEmpty
                                      ? 'no_units_available'.tr(context)
                                      : 'select_unit'.tr(context),
                                ),
                                items: units.isEmpty
                                    ? null
                                    : units
                                        .map((unit) => DropdownMenuItem(
                                              value: unit,
                                              child: Text(unit.name),
                                            ))
                                        .toList(),
                                onChanged: units.isEmpty
                                    ? null
                                    : (value) {
                                        setState(() => selectedUnit = value);
                                      },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    16.verticalGap,

                    // Units Available
                    AppText(
                      'units_available'.tr(context),
                      style: Get.bodyMedium.px15.w700.copyWith(
                        color: Get.disabledColor,
                      ),
                    ),
                    8.verticalGap,
                    TextFormField(
                      controller: _unitsAvailableController,
                      decoration: InputDecoration(
                        hintText: '0',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12).rt,
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'required_field'.tr(context);
                        }
                        if (int.tryParse(value) == null) {
                          return 'invalid_number'.tr(context);
                        }
                        return null;
                      },
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
                                isEdit ? 'update'.tr(context) : 'save'.tr(context),
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
