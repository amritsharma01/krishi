import 'dart:io';
import 'package:krishi/core/configs/app_colors.dart';
import 'package:krishi/core/extensions/border_radius.dart';
import 'package:krishi/core/extensions/int.dart';
import 'package:krishi/core/extensions/padding.dart';
import 'package:krishi/core/extensions/text_style_extensions.dart';
import 'package:krishi/core/extensions/translation_extension.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class AddEditProductPage extends StatefulWidget {
  final Map<String, dynamic>? product; // null for add, existing product for edit

  const AddEditProductPage({super.key, this.product});

  @override
  State<AddEditProductPage> createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  String selectedEmoji = '🌾';
  String selectedCategory = 'Vegetables';
  File? _selectedImage;
  String? _existingImagePath;
  
  final List<String> emojis = ['🌾', '🍅', '🥔', '🥬', '🧅', '🌶️', '🥕', '🌽', '🚜', '🌱'];
  final List<String> categories = ['Vegetables', 'Fruits', 'Grains', 'Equipment', 'Seeds'];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _nameController.text = widget.product!['name'];
      _priceController.text = widget.product!['price'].toString().replaceAll('Rs. ', '');
      selectedEmoji = widget.product!['image'];
      // Check if product has an image path (not emoji)
      if (widget.product!.containsKey('imagePath')) {
        _existingImagePath = widget.product!['imagePath'];
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
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
          _existingImagePath = null; // Clear existing image if new one is selected
        });
      }
    } catch (e) {
      Get.snackbar('Error picking image: $e');
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

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      // TODO: Upload image to backend and get URL
      final productData = {
        'name': _nameController.text,
        'price': 'Rs. ${_priceController.text}',
        'image': _selectedImage != null || _existingImagePath != null 
            ? 'image' // Use 'image' as placeholder when real image exists
            : selectedEmoji, // Use emoji if no image selected
        'imagePath': _selectedImage?.path ?? _existingImagePath,
        'description': _descriptionController.text,
        'category': selectedCategory,
      };
      
      Navigator.pop(context, productData);
      Get.snackbar(widget.product == null 
          ? 'Product added successfully!' 
          : 'Product updated successfully!');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;
    final hasImage = _selectedImage != null || _existingImagePath != null;
    
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16).rt,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image/Emoji Selector
              AppText(
                'product_image'.tr(context),
                style: Get.bodyMedium.px15.w700.copyWith(
                  color: Get.disabledColor,
                ),
              ),
              12.verticalGap,
              Container(
                padding: const EdgeInsets.all(16).rt,
                decoration: BoxDecoration(
                  color: Get.cardColor,
                  borderRadius: BorderRadius.circular(16).rt,
                  border: Border.all(
                    color: Get.disabledColor.withValues(alpha: 0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Image Display
                    GestureDetector(
                      onTap: _showImageSourceDialog,
                      child: Container(
                        width: double.infinity,
                        height: 200.rt,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12).rt,
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: hasImage
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(10).rt,
                                child: _selectedImage != null
                                    ? Image.file(
                                        _selectedImage!,
                                        fit: BoxFit.cover,
                                      )
                                    : _existingImagePath != null
                                        ? Image.file(
                                            File(_existingImagePath!),
                                            fit: BoxFit.cover,
                                          )
                                        : _buildImagePlaceholder(),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    selectedEmoji,
                                    style: TextStyle(fontSize: 64.st),
                                  ),
                                  12.verticalGap,
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    color: AppColors.primary.withValues(alpha: 0.5),
                                    size: 32.st,
                                  ),
                                  8.verticalGap,
                                  AppText(
                                    'tap_to_add_image'.tr(context),
                                    style: Get.bodySmall.px12.w500.copyWith(
                                      color: Get.disabledColor.withValues(alpha: 0.6),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    
                    if (hasImage) ...[
                      16.verticalGap,
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _showImageSourceDialog,
                              icon: Icon(Icons.edit, size: 18.st),
                              label: AppText(
                                'change_image'.tr(context),
                                style: Get.bodySmall.px12.w600,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8).rt,
                                ),
                              ),
                            ),
                          ),
                          12.horizontalGap,
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  _selectedImage = null;
                                  _existingImagePath = null;
                                });
                              },
                              icon: Icon(Icons.delete_outline, size: 18.st),
                              label: AppText(
                                'remove_image'.tr(context),
                                style: Get.bodySmall.px12.w600,
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8).rt,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    
                    16.verticalGap,
                    Divider(color: Get.disabledColor.withValues(alpha: 0.1)),
                    16.verticalGap,
                    
                    // Emoji Selector (backup option)
                    AppText(
                      'or_select_emoji'.tr(context),
                      style: Get.bodySmall.px13.w600.copyWith(
                        color: Get.disabledColor.withValues(alpha: 0.7),
                      ),
                    ),
                    12.verticalGap,
                    Wrap(
                      spacing: 8.rt,
                      runSpacing: 8.rt,
                      children: emojis.map((emoji) {
                        final isSelected = emoji == selectedEmoji && !hasImage;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedEmoji = emoji;
                            });
                          },
                          child: Container(
                            width: 50.rt,
                            height: 50.rt,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withValues(alpha: 0.2)
                                  : Get.disabledColor.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(10).rt,
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                emoji,
                                style: TextStyle(fontSize: 28.st),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
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
                  hintText: 'Enter product name',
                  filled: true,
                  fillColor: Get.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12).rt,
                    borderSide: BorderSide(
                      color: Get.disabledColor.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12).rt,
                    borderSide: BorderSide(
                      color: Get.disabledColor.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12).rt,
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              
              20.verticalGap,
              
              // Product Price
              AppText(
                'product_price'.tr(context),
                style: Get.bodyMedium.px15.w700.copyWith(
                  color: Get.disabledColor,
                ),
              ),
              8.verticalGap,
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Enter price',
                  prefixText: 'Rs. ',
                  filled: true,
                  fillColor: Get.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12).rt,
                    borderSide: BorderSide(
                      color: Get.disabledColor.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12).rt,
                    borderSide: BorderSide(
                      color: Get.disabledColor.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12).rt,
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter valid price';
                  }
                  return null;
                },
              ),
              
              20.verticalGap,
              
              // Category
              AppText(
                'product_category'.tr(context),
                style: Get.bodyMedium.px15.w700.copyWith(
                  color: Get.disabledColor,
                ),
              ),
              8.verticalGap,
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16).rt,
                decoration: BoxDecoration(
                  color: Get.cardColor,
                  borderRadius: BorderRadius.circular(12).rt,
                  border: Border.all(
                    color: Get.disabledColor.withValues(alpha: 0.1),
                  ),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: AppText(
                          category,
                          style: Get.bodyMedium.px14,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ),
              
              20.verticalGap,
              
              // Description
              AppText(
                'product_description'.tr(context),
                style: Get.bodyMedium.px15.w700.copyWith(
                  color: Get.disabledColor,
                ),
              ),
              8.verticalGap,
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter product description',
                  filled: true,
                  fillColor: Get.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12).rt,
                    borderSide: BorderSide(
                      color: Get.disabledColor.withValues(alpha: 0.1),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12).rt,
                    borderSide: BorderSide(
                      color: Get.disabledColor.withValues(alpha: 0.1),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12).rt,
                    borderSide: BorderSide(
                      color: AppColors.primary,
                      width: 2,
                    ),
                  ),
                ),
              ),
              
              32.verticalGap,
              
              // Save Button
              GestureDetector(
                onTap: _saveProduct,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16).rt,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primary.withValues(alpha: 0.85),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12).rt,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: AppText(
                      isEdit ? 'update_product'.tr(context) : 'save_product'.tr(context),
                      style: Get.bodyMedium.px16.w700.copyWith(
                        color: AppColors.white,
                      ),
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

  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 64.st,
        color: Get.disabledColor.withValues(alpha: 0.3),
      ),
    );
  }
}
