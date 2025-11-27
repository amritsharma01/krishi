// Centralized translations for the app

class AppTranslations {
  static const Map<String, Map<String, String>> _translations = {
    // Common
    'app_name': {'en': 'Jaljala Connect', 'ne': 'जलजला कनेक्ट'},
    'welcome_back': {'en': 'Welcome back', 'ne': 'फिर्ता स्वागत छ'},
    'login': {'en': 'Login', 'ne': 'लगइन'},
    'signup': {'en': 'Sign Up', 'ne': 'साइन अप'},
    'sign_in': {'en': 'Sign In', 'ne': 'साइन इन'},
    'logout': {'en': 'Logout', 'ne': 'लगआउट'},
    'logout_confirmation': {
      'en': 'Are you sure you want to logout?',
      'ne': 'के तपाईं निश्चित रूपमा लगआउट गर्न चाहनुहुन्छ?',
    },

    // Form Fields
    'phone_number': {'en': 'Phone Number', 'ne': 'फोन नम्बर'},
    'password': {'en': 'Password', 'ne': 'पासवर्ड'},
    'confirm_password': {
      'en': 'Confirm Password',
      'ne': 'पासवर्ड पुष्टि गर्नुहोस्',
    },
    'full_name': {'en': 'Full Name', 'ne': 'पूरा नाम'},
    'email_address': {'en': 'Email Address', 'ne': 'इमेल ठेगाना'},

    // Auth Page
    'dont_have_account': {
      'en': "Don't have an account?  ",
      'ne': 'खाता छैन?  ',
    },
    'already_have_account': {
      'en': 'Already have an account?  ',
      'ne': 'पहिले नै खाता छ?  ',
    },
    'create_account': {'en': 'Create Account', 'ne': 'खाता सिर्जना गर्नुहोस्'},
    'join_community': {
      'en': 'Join our community today',
      'ne': 'आज हाम्रो समुदायमा सामेल हुनुहोस्',
    },
    'auth_info': {
      'en':
          'Your information will be used to auto-fill seller details and connect you with buyers through our admin system.',
      'ne':
          'तपाईंको जानकारी विक्रेता विवरण स्वतः भर्न र हाम्रो प्रशासन प्रणाली मार्फत खरीददारहरूसँग जडान गर्न प्रयोग गरिनेछ।',
    },
    'terms_info': {
      'en':
          'By signing up, you agree to our Terms of Service and Privacy Policy. Your information will be securely stored.',
      'ne':
          'साइन अप गरेर, तपाईं हाम्रो सेवा सर्तहरू र गोपनीयता नीतिमा सहमत हुनुहुन्छ। तपाईंको जानकारी सुरक्षित रूपमा भण्डारण गरिनेछ।',
    },

    // Home Page
    'welcome_to': {'en': 'Welcome to', 'ne': 'स्वागत छ'},
    'marketplace_tagline': {
      'en': 'Your marketplace for connecting buyers and sellers',
      'ne': 'खरीददार र विक्रेताहरू जडान गर्ने तपाईंको बजार',
    },
    'quick_overview': {'en': 'Quick Overview', 'ne': 'द्रुत अवलोकन'},
    'products': {'en': 'Products', 'ne': 'उत्पादनहरू'},
    'orders': {'en': 'Orders', 'ne': 'आदेशहरू'},
    'customers': {'en': 'Customers', 'ne': 'ग्राहकहरू'},
    'revenue': {'en': 'Revenue', 'ne': 'राजस्व'},
    'recent_activity': {'en': 'Recent Activity', 'ne': 'हालको गतिविधि'},
    'no_activity_yet': {'en': 'No Activity Yet', 'ne': 'अझै कुनै गतिविधि छैन'},
    'start_adding_products': {
      'en': 'Start adding products to see your activity here',
      'ne': 'यहाँ तपाईंको गतिविधि हेर्न उत्पादनहरू थप्न सुरु गर्नुहोस्',
    },
    'welcome_notification': {'en': 'Welcome!', 'ne': 'स्वागत छ!'},
    'logged_in_successfully': {
      'en': 'You have successfully logged into the system',
      'ne': 'तपाईंले प्रणालीमा सफलतापूर्वक लगइन गर्नुभयो',
    },
    'just_now': {'en': 'Just now', 'ne': 'अहिले'},
    'today': {'en': 'Today', 'ne': 'आज'},

    // Account Page
    'account': {'en': 'Account', 'ne': 'खाता'},
    'guest_user': {'en': 'Guest User', 'ne': 'अतिथि प्रयोगकर्ता'},
    'app_settings': {'en': 'App Settings', 'ne': 'एप सेटिङहरू'},
    'theme_mode': {'en': 'Theme Mode', 'ne': 'थिम मोड'},
    'choose_theme': {
      'en': 'Choose your preferred theme',
      'ne': 'आफ्नो मनपर्ने थिम छान्नुहोस्',
    },
    'language': {'en': 'Language', 'ne': 'भाषा'},
    'select_language': {
      'en': 'Select your language',
      'ne': 'आफ्नो भाषा छान्नुहोस्',
    },
    'light': {'en': 'Light', 'ne': 'उज्यालो'},
    'dark': {'en': 'Dark', 'ne': 'अँध्यारो'},
    'system': {'en': 'System', 'ne': 'प्रणाली'},
    'english': {'en': 'English', 'ne': 'अंग्रेजी'},
    'nepali': {'en': 'नेपाली', 'ne': 'नेपाली'},
    'developer_settings': {
      'en': 'Developer Settings',
      'ne': 'विकासकर्ता सेटिङहरू',
    },
    'platform_dev': {'en': 'Platform (Dev)', 'ne': 'प्लेटफर्म (डेभ)'},
    'test_platform': {
      'en': 'Test Android & iOS UI',
      'ne': 'एन्ड्रोइड र iOS UI परीक्षण गर्नुहोस्',
    },
    'android': {'en': 'Android', 'ne': 'एन्ड्रोइड'},
    'ios': {'en': 'iOS', 'ne': 'आईओएस'},
    'account_actions': {'en': 'Account Actions', 'ne': 'खाता कार्यहरू'},
    'edit_profile': {'en': 'Edit Profile', 'ne': 'प्रोफाइल सम्पादन गर्नुहोस्'},
    'update_information': {
      'en': 'Update your information',
      'ne': 'तपाईंको जानकारी अपडेट गर्नुहोस्',
    },
    'notifications': {'en': 'Notifications', 'ne': 'सूचनाहरू'},
    'manage_notifications': {
      'en': 'Manage notification settings',
      'ne': 'सूचना सेटिङहरू व्यवस्थापन गर्नुहोस्',
    },
    'no_notifications': {
      'en': 'No notifications yet',
      'ne': 'अहिलेसम्म कुनै सूचना छैन',
    },
    'no_notifications_subtitle': {
      'en': 'You are all caught up. Check back later for updates.',
      'ne': 'तपाईं सबै अपडेटमा हुनुहुन्छ। पछि फेरि जाँच गर्नुहोस्।',
    },
    'mark_all_as_read': {
      'en': 'Mark all as read',
      'ne': 'सबैलाई पढिएको चिन्ह लगाउनुहोस्',
    },
    'delete_read_notifications': {
      'en': 'Delete read notifications',
      'ne': 'पढिएका सूचनाहरू हटाउनुहोस्',
    },
    'delete_all_notifications': {
      'en': 'Delete all notifications',
      'ne': 'सबै सूचनाहरू हटाउनुहोस्',
    },
    'delete_all_notifications_warning': {
      'en': 'This will permanently remove all notifications. Continue?',
      'ne': 'यसले सबै सूचनाहरू स्थायी रूपमा हटाउँछ। जारी राख्नुहुन्छ?',
    },
    'notifications_marked_read': {
      'en': 'All notifications marked as read',
      'ne': 'सबै सूचनाहरू पढिएको रूपमा चिन्हित गरियो',
    },
    'notification_marked_read': {
      'en': 'Notification marked as read',
      'ne': 'सूचना पढिएको रूपमा चिन्हित गरियो',
    },
    'notifications_cleared': {
      'en': 'Read notifications cleared',
      'ne': 'पढिएका सूचनाहरू हटाइयो',
    },
    'notification_deleted': {
      'en': 'Notification deleted',
      'ne': 'सूचना हटाइयो',
    },
    'failed_to_load_notifications': {
      'en': 'Failed to load notifications',
      'ne': 'सूचनाहरू लोड गर्न असफल',
    },
    'failed_to_mark_notification': {
      'en': 'Failed to mark notification as read',
      'ne': 'सूचना पढिएको चिन्ह लगाउन असफल',
    },
    'failed_to_delete_notification': {
      'en': 'Failed to delete notification',
      'ne': 'सूचना हटाउन असफल',
    },
    'mark_as_read': {
      'en': 'Mark as read',
      'ne': 'पढिएको चिन्ह लगाउनुहोस्',
    },
    'load_more': {'en': 'Load more', 'ne': 'अझ थप लोड गर्नुहोस्'},
    'help_support': {'en': 'Help & Support', 'ne': 'मद्दत र समर्थन'},
    'get_help': {
      'en': 'Get help with the app',
      'ne': 'एपसँग मद्दत प्राप्त गर्नुहोस्',
    },
    'about': {'en': 'About', 'ne': 'बारेमा'},
    'version': {'en': 'Version', 'ne': 'संस्करण'},
    'appbar': {'en': 'Appbar', 'ne': 'एपबार'},

    // Homepage New
    'krishi': {'en': 'Krishi', 'ne': 'कृषि'},
    'good_morning': {'en': 'Good Morning', 'ne': 'शुभ प्रभात'},
    'good_afternoon': {'en': 'Good Afternoon', 'ne': 'शुभ दिउँसो'},
    'good_evening': {'en': 'Good Evening', 'ne': 'शुभ साँझ'},
    'welcome_user': {'en': 'Welcome', 'ne': 'स्वागत छ'},
    'kishan_gyaan': {'en': 'Kishan Gyaan', 'ne': 'किसान ज्ञान'},
    'farming_knowledge': {
      'en': 'Farming tips & knowledge',
      'ne': 'खेती सुझाव र ज्ञान',
    },
    'your_activity': {'en': 'Your Activity', 'ne': 'तपाईंको गतिविधि'},
    'track_activity': {
      'en': 'Track your activities',
      'ne': 'आफ्नो गतिविधि ट्र्याक गर्नुहोस्',
    },
    'news_information': {'en': 'News & Information', 'ne': 'समाचार र जानकारी'},
    'latest_updates': {
      'en': 'Latest agricultural updates',
      'ne': 'ताजा कृषि अपडेटहरू',
    },
    'trending_products': {
      'en': 'Trending Products',
      'ne': 'ट्रेन्डिङ उत्पादनहरू',
    },
    'view_all': {'en': 'View All', 'ne': 'सबै हेर्नुहोस्'},
    'per_kg': {'en': '/kg', 'ne': '/के.जी.'},
    'per_unit': {'en': '/unit', 'ne': '/इकाई'},
    'add_to_cart': {'en': 'Add to Cart', 'ne': 'कार्टमा थप्नुहोस्'},
    'view_cart': {'en': 'View Cart', 'ne': 'कार्ट हेर्नुहोस्'},
    'items_in_cart': {'en': 'items in cart', 'ne': 'कार्टमा वस्तुहरू'},

    // Marketplace
    'buy': {'en': 'Buy', 'ne': 'किन्नुहोस्'},
    'sell': {'en': 'Sell', 'ne': 'बेच्नुहोस्'},
    'buying': {'en': 'Buying', 'ne': 'किन्ने'},
    'selling': {'en': 'Selling', 'ne': 'बेच्ने'},
    'search_products': {
      'en': 'Search for products...',
      'ne': 'उत्पादनहरू खोज्नुहोस्...',
    },
    'filter_categories': {
      'en': 'Filter by category',
      'ne': 'श्रेणीबाट छनोट गर्नुहोस्',
    },
    'all_categories': {'en': 'All categories', 'ne': 'सबै श्रेणीहरू'},
    'add_new_product': {
      'en': 'Add New Product',
      'ne': 'नयाँ उत्पादन थप्नुहोस्',
    },
    'your_listings': {'en': 'Your Listings', 'ne': 'तपाईंको सूची'},
    'edit': {'en': 'Edit', 'ne': 'सम्पादन'},
    'remove': {'en': 'Remove', 'ne': 'हटाउनुहोस्'},
    'no_products_found': {
      'en': 'No products found',
      'ne': 'कुनै उत्पादन फेला परेन',
    },
    'cart': {'en': 'Cart', 'ne': 'कार्ट'},
    'my_cart': {'en': 'My Cart', 'ne': 'मेरो कार्ट'},
    'empty_cart': {'en': 'Your cart is empty', 'ne': 'तपाईंको कार्ट खाली छ'},
    'start_shopping': {
      'en': 'Start shopping to add items',
      'ne': 'वस्तुहरू थप्न किनमेल सुरु गर्नुहोस्',
    },
    'subtotal': {'en': 'Subtotal', 'ne': 'उपयोग'},
    'total': {'en': 'Total', 'ne': 'जम्मा'},
    'checkout': {'en': 'Checkout', 'ne': 'चेकआउट'},
    'quantity': {'en': 'Quantity', 'ne': 'परिमाण'},
    'remove_from_cart': {'en': 'Remove from cart', 'ne': 'कार्टबाट हटाउनुहोस्'},
    'reviews': {'en': 'Reviews', 'ne': 'समीक्षा'},
    'add_review': {'en': 'Add Review', 'ne': 'समीक्षा थप्नुहोस्'},
    'error_loading_reviews': {
      'en': 'Unable to load reviews. Tap to retry.',
      'ne': 'समीक्षा लोड हुन सकेन। पुन: प्रयास गर्न ट्याप गर्नुहोस्।',
    },
    'no_reviews_yet': {
      'en': 'No reviews yet',
      'ne': 'अहिलेसम्म कुनै समीक्षा छैन',
    },
    'comments': {'en': 'Comments', 'ne': 'टिप्पणीहरू'},
    'error_loading_comments': {
      'en': 'Unable to load comments. Tap to retry.',
      'ne': 'टिप्पणीहरू लोड हुन सकेन। पुन: प्रयास गर्न ट्याप गर्नुहोस्।',
    },
    'no_comments_yet': {
      'en': 'No comments yet',
      'ne': 'अहिलेसम्म कुनै टिप्पणी छैन',
    },
    'add_comment': {'en': 'Add a comment...', 'ne': 'टिप्पणी थप्नुहोस्...'},
    'rating': {'en': 'Rating', 'ne': 'रेटिङ'},
    'write_review': {
      'en': 'Write your review...',
      'ne': 'तपाईंको समीक्षा लेख्नुहोस्...',
    },
    'submit_review': {'en': 'Submit Review', 'ne': 'समीक्षा पठाउनुहोस्'},
    'comment_added': {'en': 'Comment added', 'ne': 'टिप्पणी थपियो'},
    'error_adding_comment': {
      'en': 'Failed to add comment',
      'ne': 'टिप्पणी थप्दा त्रुटि भयो',
    },
    'review_too_short': {
      'en': 'Please write a short review before submitting.',
      'ne': 'पठाउनुअघि कृपया छोटो समीक्षा लेख्नुहोस्।',
    },
    'review_added': {'en': 'Review added', 'ne': 'समीक्षा थपियो'},
    'must_purchase_to_review': {
      'en': 'You must purchase before leaving a review',
      'ne': 'समीक्षा गर्नुअघि तपाईंले खरिद गर्नुपर्छ',
    },
    'error_adding_review': {
      'en': 'Failed to add review',
      'ne': 'समीक्षा थप्दा त्रुटि भयो',
    },

    // Add/Edit Product
    'product_name': {'en': 'Product Name', 'ne': 'उत्पादन नाम'},
    'product_price': {'en': 'Product Price', 'ne': 'उत्पादन मूल्य'},
    'product_description': {'en': 'Product Description', 'ne': 'उत्पादन विवरण'},
    'product_category': {'en': 'Category', 'ne': 'श्रेणी'},
    'save_product': {'en': 'Save Product', 'ne': 'उत्पादन बचत गर्नुहोस्'},
    'update_product': {'en': 'Update Product', 'ne': 'उत्पादन अपडेट गर्नुहोस्'},
    'edit_product': {'en': 'Edit Product', 'ne': 'उत्पादन सम्पादन गर्नुहोस्'},
    'delete_product': {'en': 'Delete Product', 'ne': 'उत्पादन मेटाउनुहोस्'},
    'available_for_sale': {
      'en': 'Available for sale',
      'ne': 'बिक्रीका लागि उपलब्ध',
    },
    'available_for_sale_hint': {
      'en': 'Toggle off to hide this product when it is out of stock.',
      'ne': 'स्टक नभएका बेला उत्पादन लुकाउन टगल गर्नुहोस्।',
    },
    'delete_confirmation': {
      'en': 'Are you sure you want to delete this product?',
      'ne': 'के तपाईं यो उत्पादन मेटाउन चाहनुहुन्छ?',
    },
    'cancel': {'en': 'Cancel', 'ne': 'रद्द गर्नुहोस्'},
    'delete': {'en': 'Delete', 'ne': 'मेटाउनुहोस्'},
    'product_image': {'en': 'Product Image', 'ne': 'उत्पादन छवि'},
    'select_emoji': {'en': 'Select Emoji', 'ne': 'इमोजी छान्नुहोस्'},
    'select_image_source': {
      'en': 'Select Image Source',
      'ne': 'छवि स्रोत छान्नुहोस्',
    },
    'camera': {'en': 'Camera', 'ne': 'क्यामेरा'},
    'gallery': {'en': 'Gallery', 'ne': 'ग्यालरी'},
    'tap_to_add_image': {
      'en': 'Tap to add image',
      'ne': 'छवि थप्न ट्याप गर्नुहोस्',
    },
    'change_image': {'en': 'Change', 'ne': 'परिवर्तन'},
    'remove_image': {'en': 'Remove', 'ne': 'हटाउनुहोस्'},
    'or_select_emoji': {
      'en': 'Or select an emoji',
      'ne': 'वा इमोजी छान्नुहोस्',
    },
    'contact_address': {'en': 'Pickup address', 'ne': 'पिकअप ठेगाना'},
    'base_price': {'en': 'Base price', 'ne': 'आधार मूल्य'},
    'enter_base_price': {
      'en': 'Enter base price',
      'ne': 'आधार मूल्य प्रविष्ट गर्नुहोस्',
    },
    'base_price_hint': {
      'en': 'Commission is added on top of this amount before buyers pay.',
      'ne': 'खरीददारले तिर्नु अघि यस रकममा कमिसन थपिन्छ।',
    },
    'final_price': {'en': 'Final price', 'ne': 'अन्तिम मूल्य'},

    // Bottom Navigation
    'home': {'en': 'Home', 'ne': 'होम'},
    'marketplace': {'en': 'Marketplace', 'ne': 'बजार'},
    'support': {'en': 'Support', 'ne': 'समर्थन'},

    // Support Page
    'help_center': {'en': 'Help Center', 'ne': 'मद्दत केन्द्र'},
    'how_can_we_help': {
      'en': 'How can we help you?',
      'ne': 'हामी तपाईंलाई कसरी मद्दत गर्न सक्छौं?',
    },
    'faq': {'en': 'FAQ', 'ne': 'सामान्य प्रश्नहरू'},
    'common_questions': {
      'en': 'Common questions and answers',
      'ne': 'सामान्य प्रश्नहरू र जवाफहरू',
    },
    'contact_us': {'en': 'Contact Us', 'ne': 'सम्पर्क गर्नुहोस्'},
    'get_in_touch': {
      'en': 'Get in touch with our team',
      'ne': 'हाम्रो टोलीसँग सम्पर्कमा रहनुहोस्',
    },
    'report_issue': {'en': 'Report an Issue', 'ne': 'समस्या रिपोर्ट गर्नुहोस्'},
    'report_problem': {
      'en': 'Report a problem or bug',
      'ne': 'समस्या वा त्रुटि रिपोर्ट गर्नुहोस्',
    },
    'user_guide': {'en': 'User Guide', 'ne': 'प्रयोगकर्ता गाइड'},
    'learn_how_to_use': {
      'en': 'Learn how to use the app',
      'ne': 'एप कसरी प्रयोग गर्ने सिक्नुहोस्',
    },

    // Account Page
    'my_account': {'en': 'My Account', 'ne': 'मेरो खाता'},
    'profile_settings': {'en': 'Profile Settings', 'ne': 'प्रोफाइल सेटिङहरू'},

    // New Translation Keys
    'loading_weather': {'en': 'Loading weather...', 'ne': 'मौसम लोड हुँदैछ...'},
    'weather_error': {'en': 'Weather unavailable', 'ne': 'मौसम उपलब्ध छैन'},
    'error_loading_products': {
      'en': 'Error loading products',
      'ne': 'उत्पादनहरू लोड गर्दा त्रुटि',
    },
    'error_loading_products_subtitle': {
      'en':
          'Unable to load products. Please check your connection and try again.',
      'ne':
          'उत्पादनहरू लोड गर्न सकिएन। कृपया आफ्नो जडान जाँच गर्नुहोस् र पुनः प्रयास गर्नुहोस्।',
    },
    'no_products_available': {
      'en': 'No products available',
      'ne': 'कुनै उत्पादन उपलब्ध छैन',
    },
    'no_products_subtitle': {
      'en':
          'There are no products available at the moment. Pull down to refresh or tap retry.',
      'ne':
          'यस समयमा कुनै उत्पादनहरू उपलब्ध छैनन्। ताजा पार्न तल खिच्नुहोस् वा पुनः प्रयास गर्नुहोस्।',
    },
    'added_to_cart': {'en': 'Added to cart', 'ne': 'कार्टमा थपियो'},
    'error_adding_to_cart': {
      'en': 'Error adding to cart',
      'ne': 'कार्टमा थप्दा त्रुटि',
    },
    'error_loading_listings': {
      'en': 'Error loading your listings',
      'ne': 'तपाईंको सूची लोड गर्दा त्रुटि',
    },
    'error_loading_listings_subtitle': {
      'en':
          'Unable to load your listings. Please check your connection and try again.',
      'ne':
          'तपाईंको सूची लोड गर्न सकिएन। कृपया आफ्नो जडान जाँच गर्नुहोस् र पुनः प्रयास गर्नुहोस्।',
    },
    'no_listings_yet': {'en': 'No listings yet', 'ne': 'अझै कुनै सूची छैन'},
    'no_listings_subtitle': {
      'en':
          'You haven\'t added any products yet. Start selling by adding your first product!',
      'ne':
          'तपाईंले अहिलेसम्म कुनै उत्पादनहरू थप्नुभएको छैन। आफ्नो पहिलो उत्पादन थपेर बिक्री सुरु गर्नुहोस्!',
    },
    'seller_id': {'en': 'Seller ID', 'ne': 'विक्रेता आईडी'},
    'rejection_reason': {'en': 'Rejection reason', 'ne': 'अस्वीकारको कारण'},
    'approval_status': {'en': 'Approval status', 'ne': 'अनुमोदन स्थिति'},
    'all_statuses': {'en': 'All statuses', 'ne': 'सबै स्थिति'},
    'approved': {'en': 'Approved', 'ne': 'स्वीकृत'},
    'rejected': {'en': 'Rejected', 'ne': 'अस्वीकृत'},
    'product_deleted': {
      'en': 'Product deleted successfully',
      'ne': 'उत्पादन सफलतापूर्वक मेटाइयो',
    },
    'error_deleting_product': {
      'en': 'Error deleting product',
      'ne': 'उत्पादन मेट्दा त्रुटि',
    },
    'error_loading_profile': {
      'en': 'Error loading profile',
      'ne': 'प्रोफाइल लोड गर्दा त्रुटि',
    },
    'retry': {'en': 'Retry', 'ne': 'पुन: प्रयास गर्नुहोस्'},
    'problem_fetching_data': {
      'en': 'Problem fetching data',
      'ne': 'डाटा ल्याउँदा समस्या',
    },
    'error_loading_cart': {
      'en': 'Error loading cart',
      'ne': 'कार्ट लोड गर्दा त्रुटि',
    },
    'error_updating_quantity': {
      'en': 'Error updating quantity',
      'ne': 'परिमाण अपडेट गर्दा त्रुटि',
    },
    'item_removed': {
      'en': 'Item removed from cart',
      'ne': 'कार्टबाट वस्तु हटाइयो',
    },
    'error_removing_item': {
      'en': 'Error removing item',
      'ne': 'वस्तु हटाउँदा त्रुटि',
    },
    'fill_all_fields': {
      'en': 'Please fill all fields',
      'ne': 'कृपया सबै फिल्डहरू भर्नुहोस्',
    },
    'checkout_success': {
      'en': 'Order placed successfully',
      'ne': 'अर्डर सफलतापूर्वक राखियो',
    },
    'checkout_error': {
      'en': 'Error processing checkout',
      'ne': 'चेकआउट प्रशोधन गर्दा त्रुटि',
    },
    'confirm': {'en': 'Confirm', 'ne': 'पुष्टि गर्नुहोस्'},
    'ok': {'en': 'OK', 'ne': 'ठीक छ'},
    'address': {'en': 'Address', 'ne': 'ठेगाना'},
    'order_summary': {'en': 'Order Summary', 'ne': 'अर्डर सारांश'},
    'delivery_information': {
      'en': 'Delivery Information',
      'ne': 'डेलिभरी जानकारी',
    },
    'enter_full_name': {
      'en': 'Enter full name',
      'ne': 'पूरा नाम प्रविष्ट गर्नुहोस्',
    },
    'enter_address': {'en': 'Enter address', 'ne': 'ठेगाना प्रविष्ट गर्नुहोस्'},
    'contact_information': {
      'en': 'Contact Information',
      'ne': 'सम्पर्क जानकारी',
    },
    'enter_phone_number': {
      'en': 'Enter phone number',
      'ne': 'फोन नम्बर प्रविष्ट गर्नुहोस्',
    },
    'total_amount': {'en': 'Total Amount', 'ne': 'कुल रकम'},
    'confirm_order': {'en': 'Confirm Order', 'ne': 'अर्डर पुष्टि गर्नुहोस्'},
    'error_loading_categories': {
      'en': 'Error loading categories',
      'ne': 'श्रेणीहरू लोड गर्दा त्रुटि',
    },
    'error_loading_units': {
      'en': 'Error loading units',
      'ne': 'इकाइहरू लोड गर्दा त्रुटि',
    },
    'error_picking_image': {
      'en': 'Error picking image',
      'ne': 'छवि छान्दा त्रुटि',
    },
    'select_category': {
      'en': 'Please select a category',
      'ne': 'कृपया श्रेणी छान्नुहोस्',
    },
    'select_unit': {
      'en': 'Please select a unit',
      'ne': 'कृपया इकाइ छान्नुहोस्',
    },
    'product_added': {
      'en': 'Product added successfully',
      'ne': 'उत्पादन सफलतापूर्वक थपियो',
    },
    'product_updated': {
      'en': 'Product updated successfully',
      'ne': 'उत्पादन सफलतापूर्वक अपडेट गरियो',
    },
    'error_saving_product': {
      'en': 'Error saving product',
      'ne': 'उत्पादन बचत गर्दा त्रुटि',
    },
    'required_field': {
      'en': 'This field is required',
      'ne': 'यो फिल्ड आवश्यक छ',
    },
    'contact_phone': {'en': 'Contact Phone', 'ne': 'सम्पर्क फोन'},
    'enter_phone': {
      'en': 'Enter phone number',
      'ne': 'फोन नम्बर प्रविष्ट गर्नुहोस्',
    },
    'category': {'en': 'Category', 'ne': 'श्रेणी'},
    'price': {'en': 'Price', 'ne': 'मूल्य'},
    'unit': {'en': 'Unit', 'ne': 'इकाइ'},
    'required': {'en': 'Required', 'ne': 'आवश्यक'},
    'units_available': {'en': 'Units Available', 'ne': 'उपलब्ध इकाइहरू'},
    'invalid_number': {'en': 'Invalid number', 'ne': 'अमान्य नम्बर'},
    'description': {'en': 'Description', 'ne': 'विवरण'},
    'enter_description': {
      'en': 'Enter product description',
      'ne': 'उत्पादन विवरण प्रविष्ट गर्नुहोस्',
    },
    'update': {'en': 'Update', 'ne': 'अपडेट गर्नुहोस्'},
    'save': {'en': 'Save', 'ne': 'बचत गर्नुहोस्'},
    'enter_product_name': {
      'en': 'Enter product name',
      'ne': 'उत्पादन नाम प्रविष्ट गर्नुहोस्',
    },
    'no_articles_available': {
      'en': 'No articles available',
      'ne': 'कुनै लेखहरू उपलब्ध छैन',
    },
    'no_articles_subtitle': {
      'en':
          'There are no articles available at the moment. Pull down to refresh or tap retry.',
      'ne':
          'यस समयमा कुनै लेखहरू उपलब्ध छैनन्। ताजा पार्न तल खिच्नुहोस् वा पुनः प्रयास गर्नुहोस्।',
    },
    'no_news_available': {
      'en': 'No news available',
      'ne': 'कुनै समाचार उपलब्ध छैन',
    },
    'no_news_subtitle': {
      'en':
          'There are no news available at the moment. Pull down to refresh or tap retry.',
      'ne':
          'यस समयमा कुनै समाचार उपलब्ध छैनन्। ताजा पार्न तल खिच्नुहोस् वा पुनः प्रयास गर्नुहोस्।',
    },
    'error_loading_articles': {
      'en': 'Error loading articles',
      'ne': 'लेखहरू लोड गर्दा त्रुटि',
    },
    'error_loading_articles_subtitle': {
      'en':
          'Unable to load articles. Please check your connection and try again.',
      'ne':
          'लेखहरू लोड गर्न सकिएन। कृपया आफ्नो जडान जाँच गर्नुहोस् र पुनः प्रयास गर्नुहोस्।',
    },
    'error_loading_news': {
      'en': 'Error loading news',
      'ne': 'समाचार लोड गर्दा त्रुटि',
    },
    'error_loading_news_subtitle': {
      'en': 'Unable to load news. Please check your connection and try again.',
      'ne':
          'समाचार लोड गर्न सकिएन। कृपया आफ्नो जडान जाँच गर्नुहोस् र पुनः प्रयास गर्नुहोस्।',
    },
    'error_loading_cart_subtitle': {
      'en': 'Unable to load cart. Please check your connection and try again.',
      'ne':
          'कार्ट लोड गर्न सकिएन। कृपया आफ्नो जडान जाँच गर्नुहोस् र पुनः प्रयास गर्नुहोस्।',
    },
    'yesterday': {'en': 'Yesterday', 'ne': 'हिजो'},
    'days_ago': {'en': 'days ago', 'ne': 'दिन अघि'},
    'no_categories_available': {
      'en': 'No categories available',
      'ne': 'कुनै श्रेणीहरू उपलब्ध छैन',
    },
    'no_units_available': {
      'en': 'No units available',
      'ne': 'कुनै इकाइहरू उपलब्ध छैन',
    },
    'sign_in_with_google': {
      'en': 'Sign in with Google',
      'ne': 'Google सँग साइन इन गर्नुहोस्',
    },
    'sign_up_with_google': {
      'en': 'Sign up with Google',
      'ne': 'Google सँग साइन अप गर्नुहोस्',
    },
    'or': {'en': 'OR', 'ne': 'वा'},
    'loading': {'en': 'Loading...', 'ne': 'लोड हुँदैछ...'},
    'google_signin_cancelled': {
      'en': 'Google sign in cancelled',
      'ne': 'Google साइन इन रद्द गरियो',
    },
    'google_signin_failed': {
      'en': 'Google sign in failed',
      'ne': 'Google साइन इन असफल भयो',
    },
    'passwords_dont_match': {
      'en': 'Passwords do not match',
      'ne': 'पासवर्डहरू मेल खाँदैनन्',
    },
    'google_signin_info': {
      'en': 'Sign in with your Google account to access Krishi marketplace',
      'ne': 'कृषि बजारमा पहुँच गर्न आफ्नो Google खाताद्वारा साइन इन गर्नुहोस्',
    },
    'google_signup_info': {
      'en': 'Create your account using Google to join Krishi community',
      'ne':
          'कृषि समुदायमा सामेल हुन Google प्रयोग गरेर आफ्नो खाता सिर्जना गर्नुहोस्',
    },
    'auth_failed_backend': {
      'en': 'Authentication failed. Please try again.',
      'ne': 'प्रमाणीकरण असफल भयो। कृपया पुन: प्रयास गर्नुहोस्।',
    },
    'signin_success': {
      'en': 'Sign in successful! Welcome back.',
      'ne': 'साइन इन सफल भयो! फेरि स्वागत छ।',
    },
    'signup_success': {
      'en': 'Account created successfully! Welcome to Krishi.',
      'ne': 'खाता सफलतापूर्वक सिर्जना गरियो! कृषिमा स्वागत छ।',
    },
    'profile_updated': {
      'en': 'Profile updated successfully',
      'ne': 'प्रोफाइल सफलतापूर्वक अद्यावधिक भयो',
    },
    'profile_update_failed': {
      'en': 'Failed to update profile',
      'ne': 'प्रोफाइल अद्यावधिक गर्न असफल भयो',
    },
    'full_name_min': {
      'en': 'Full name must be at least 2 characters',
      'ne': 'पूरा नाम कम्तीमा २ अक्षरको हुनुपर्छ',
    },
    'phone_min_length': {
      'en': 'Phone number must be at least 10 digits',
      'ne': 'फोन नम्बर कम्तीमा १० अङ्कको हुनुपर्छ',
    },
    'address_min_length': {
      'en': 'Address must be at least 10 characters',
      'ne': 'ठेगाना कम्तीमा १० अक्षरको हुनुपर्छ',
    },
    'saving': {'en': 'Saving...', 'ne': 'बचत हुँदैछ...'},

    // Home Page - Orders
    'received_orders': {'en': 'Received Orders', 'ne': 'प्राप्त अर्डरहरू'},
    'orders_as_seller': {'en': 'As seller', 'ne': 'बिक्रेताको रूपमा'},
    'placed_orders': {'en': 'Placed Orders', 'ne': 'राखिएको अर्डरहरू'},
    'orders_as_buyer': {'en': 'As buyer', 'ne': 'क्रेताको रूपमा'},
    'showing_orders_as_seller': {
      'en': 'Showing orders where you are the seller',
      'ne': 'तपाईं बिक्रेता हुनुहुन्छ जहाँ अर्डरहरू देखाउँदै',
    },
    'showing_orders_as_buyer': {
      'en': 'Showing orders where you are the buyer',
      'ne': 'तपाईं क्रेता हुनुहुन्छ जहाँ अर्डरहरू देखाउँदै',
    },
    'no_sales': {
      'en': 'No received orders yet',
      'ne': 'अहिलेसम्म कुनै प्राप्त अर्डर छैन',
    },
    'no_sales_message': {
      'en':
          'You have not received any orders. Once buyers purchase your products, they will appear here.',
      'ne':
          'तपाईंले कुनै अर्डर प्राप्त गर्नुभएको छैन। खरीददारहरूले तपाईंका उत्पादनहरू खरिद गरेपछि यहाँ देखिनेछन्।',
    },
    'no_purchases': {
      'en': 'No placed orders yet',
      'ne': 'अहिलेसम्म कुनै राखिएको अर्डर छैन',
    },
    'no_purchases_message': {
      'en':
          'You have not placed any orders. Start shopping in the marketplace to see them here.',
      'ne':
          'तपाईंले कुनै अर्डर राख्नुभएको छैन। बजारमा किनमेल सुरु गर्नुहोस् र यहाँ अर्डरहरू देख्नुहोस्।',
    },
    'pending': {'en': 'Pending', 'ne': 'बाँकी'},
    'completed': {'en': 'Completed', 'ne': 'पूरा भयो'},
    'add_phone_hint': {'en': 'Add phone number', 'ne': 'फोन नम्बर थप्नुहोस्'},
    'add_address_hint': {'en': 'Add address', 'ne': 'ठेगाना थप्नुहोस्'},
    'seller_information': {
      'en': 'Seller Information',
      'ne': 'विक्रेता जानकारी',
    },
    'seller_public_listings': {
      'en': 'Seller listings',
      'ne': 'विक्रेता सूचीहरू',
    },
    'buyer_public_listings': {
      'en': 'Buyer listings',
      'ne': 'क्रेताको सूचीहरू',
    },
    'seller_no_listings': {
      'en': 'This seller has no other listings yet.',
      'ne': 'यस विक्रेताको अहिले अन्य सूचीहरू छैनन्।',
    },
    'error_loading_seller': {
      'en': 'Unable to load seller information.',
      'ne': 'विक्रेता जानकारी लोड गर्न सकिएन।',
    },
    'seller_id_unavailable': {
      'en': 'Seller ID unavailable',
      'ne': 'विक्रेता आईडी उपलब्ध छैन',
    },
    'seller_contact_hidden': {
      'en': 'Seller contact info is hidden for privacy.',
      'ne': 'गोपनीयताका लागि विक्रेता सम्पर्क जानकारी लुकाइएको छ।',
    },
    'buyer_contact_hidden': {
      'en': 'Buyer contact info is hidden for privacy.',
      'ne': 'गोपनीयताका लागि क्रेताको सम्पर्क जानकारी लुकाइएको छ।',
    },
    'seller_id_label': {'en': 'Seller ID', 'ne': 'विक्रेता आईडी'},
    'buyer_id_label': {'en': 'Buyer ID', 'ne': 'क्रेता आईडी'},
    'mark_as_complete': {
      'en': 'Mark as complete',
      'ne': 'पुरा भएको चिन्ह लगाउनुहोस्',
    },
    'order_marked_complete': {
      'en': 'Order marked as complete',
      'ne': 'अर्डर पूरा भएको रूपमा चिन्ह लगाइयो',
    },
    'order_complete_failed': {
      'en': 'Failed to mark order as complete',
      'ne': 'अर्डर पूरा भएको चिन्ह लगाउन असफल',
    },
    'edit_order': {'en': 'Edit order', 'ne': 'अर्डर सम्पादन गर्नुहोस्'},
    'update_contact_details': {
      'en': 'Update contact details',
      'ne': 'सम्पर्क विवरण अद्यावधिक गर्नुहोस्',
    },
    'buyer_name_label': {'en': 'Buyer name', 'ne': 'क्रेताको नाम'},
    'buyer_address_label': {'en': 'Delivery address', 'ne': 'डेलिभरी ठेगाना'},
    'buyer_phone_label': {'en': 'Phone number', 'ne': 'फोन नम्बर'},
    'save_changes': {'en': 'Save changes', 'ne': 'परिवर्तनहरू सुरक्षित गर्नुहोस्'},
    'contact_update_success': {
      'en': 'Order contact details updated',
      'ne': 'अर्डरको सम्पर्क विवरण अद्यावधिक भयो',
    },
    'contact_update_failed': {
      'en': 'Could not update contact details',
      'ne': 'सम्पर्क विवरण अद्यावधिक गर्न सकिएन',
    },

    // Order Status and Actions
    'order_details': {'en': 'Order Details', 'ne': 'अर्डर विवरण'},
    'order_status': {'en': 'Order Status', 'ne': 'अर्डर स्थिति'},
    'order_information': {'en': 'Order Information', 'ne': 'अर्डर जानकारी'},
    'buyer_information': {'en': 'Buyer Information', 'ne': 'क्रेता जानकारी'},
    'seller_info': {'en': 'Seller Information', 'ne': 'विक्रेता जानकारी'},
    'order_id': {'en': 'Order ID', 'ne': 'अर्डर ID'},
    'order_date': {'en': 'Order Date', 'ne': 'अर्डर मिति'},
    'unit_price': {'en': 'Unit Price', 'ne': 'एकाइ मूल्य'},
    'view_details': {'en': 'View Details', 'ne': 'विवरण हेर्नुहोस्'},
    'order_not_found': {'en': 'Order not found', 'ne': 'अर्डर फेला परेन'},
    'processing': {'en': 'Processing...', 'ne': 'प्रशोधन हुँदैछ...'},

    // Order Actions
    'accept_order': {'en': 'Accept Order', 'ne': 'अर्डर स्वीकार गर्नुहोस्'},
    'cancel_order': {'en': 'Cancel Order', 'ne': 'अर्डर रद्द गर्नुहोस्'},
    'mark_in_transit': {
      'en': 'Mark In Transit',
      'ne': 'ट्रान्जिटमा चिन्ह लगाउनुहोस्',
    },
    'mark_delivered': {
      'en': 'Mark Delivered',
      'ne': 'डेलिभर भएको चिन्ह लगाउनुहोस्',
    },
    'cancel_order_confirm': {
      'en': 'Are you sure you want to cancel this order?',
      'ne': 'के तपाईं यो अर्डर रद्द गर्न निश्चित हुनुहुन्छ?',
    },
    'yes': {'en': 'Yes', 'ne': 'हो'},
    'no': {'en': 'No', 'ne': 'होइन'},

    // Order Status Messages
    'order_accepted': {
      'en': 'Order accepted successfully',
      'ne': 'अर्डर सफलतापूर्वक स्वीकार गरियो',
    },
    'order_accept_failed': {
      'en': 'Failed to accept order',
      'ne': 'अर्डर स्वीकार गर्न असफल',
    },
    'order_marked_in_transit': {
      'en': 'Order marked as in transit',
      'ne': 'अर्डर ट्रान्जिटमा रहेको चिन्ह लगाइयो',
    },
    'order_transit_failed': {
      'en': 'Failed to mark order as in transit',
      'ne': 'अर्डर ट्रान्जिटमा चिन्ह लगाउन असफल',
    },
    'order_delivered': {
      'en': 'Order marked as delivered',
      'ne': 'अर्डर डेलिभर भएको चिन्ह लगाइयो',
    },
    'order_deliver_failed': {
      'en': 'Failed to mark order as delivered',
      'ne': 'अर्डर डेलिभर भएको चिन्ह लगाउन असफल',
    },
    'order_completed': {
      'en': 'Order completed successfully',
      'ne': 'अर्डर सफलतापूर्वक पूरा भयो',
    },
    'order_cancelled': {
      'en': 'Order cancelled successfully',
      'ne': 'अर्डर सफलतापूर्वक रद्द गरियो',
    },
    'order_cancel_failed': {
      'en': 'Failed to cancel order',
      'ne': 'अर्डर रद्द गर्न असफल',
    },

    // Order Statuses
    'accepted': {'en': 'Accepted', 'ne': 'स्वीकृत'},
    'in_transit': {'en': 'In Transit', 'ne': 'ट्रान्जिटमा'},
    'delivered': {'en': 'Delivered', 'ne': 'डेलिभर भयो'},
    'cancelled': {'en': 'Cancelled', 'ne': 'रद्द गरियो'},

    // Contact Actions
    'call_buyer': {'en': 'Call Buyer', 'ne': 'खरीददारलाई कल गर्नुहोस्'},
    'call_seller': {'en': 'Call Seller', 'ne': 'विक्रेतालाई कल गर्नुहोस्'},
    'whatsapp': {'en': 'WhatsApp', 'ne': 'व्हाट्सएप'},
    'call_failed': {'en': 'Unable to make call', 'ne': 'कल गर्न असमर्थ'},
    'whatsapp_failed': {
      'en': 'Unable to open WhatsApp',
      'ne': 'व्हाट्सएप खोल्न असमर्थ',
    },

    // Status Reversal
    'revert_to_accepted': {
      'en': 'Revert to Accepted',
      'ne': 'स्वीकृतमा फर्कनुहोस्',
    },
    'mark_pending': {'en': 'Revert to Pending', 'ne': 'पेन्डिङमा फर्कनुहोस्'},
    'cannot_revert_pending': {
      'en': 'Cannot revert to pending status',
      'ne': 'पेन्डिङ स्थितिमा फर्कन सकिँदैन',
    },
    'no_phone': {'en': 'No phone', 'ne': 'फोन छैन'},
    'all': {'en': 'All', 'ne': 'सबै'},

    // Soil Testing
    'soil_testing': {'en': 'Soil Testing', 'ne': 'माटो परीक्षण'},
    'test_soil_quality': {
      'en': 'Test your soil quality',
      'ne': 'आफ्नो माटोको गुणस्तर परीक्षण गर्नुहोस्',
    },
    'soil_testing_title': {
      'en': 'Soil Testing Service',
      'ne': 'माटो परीक्षण सेवा',
    },
    'soil_testing_description': {
      'en':
          'Get detailed analysis of your soil to improve crop yields and make informed farming decisions. Our comprehensive soil testing service helps you understand your soil\'s health.',
      'ne':
          'बाली उत्पादन सुधार गर्न र सूचित खेती निर्णयहरू गर्न आफ्नो माटोको विस्तृत विश्लेषण प्राप्त गर्नुहोस्। हाम्रो व्यापक माटो परीक्षण सेवाले तपाईंलाई आफ्नो माटोको स्वास्थ्य बुझ्न मद्दत गर्दछ।',
    },
    'soil_testing_features': {
      'en': 'What We Test',
      'ne': 'हामी के परीक्षण गर्छौं',
    },
    'ph_level': {'en': 'pH Level', 'ne': 'पीएच स्तर'},
    'ph_level_description': {
      'en': 'Measure soil acidity or alkalinity to determine ideal crops',
      'ne': 'आदर्श बाली निर्धारण गर्न माटोको अम्लता वा क्षारता मापन गर्नुहोस्',
    },
    'nutrients': {'en': 'Nutrients', 'ne': 'पोषक तत्वहरू'},
    'nutrients_description': {
      'en': 'Test for NPK and other essential minerals',
      'ne': 'NPK र अन्य आवश्यक खनिजहरूको लागि परीक्षण',
    },
    'moisture': {'en': 'Moisture', 'ne': 'नमी'},
    'moisture_description': {
      'en': 'Check soil moisture content and water retention',
      'ne': 'माटो नमी सामग्री र पानी प्रतिधारण जाँच गर्नुहोस्',
    },
    'recommendations': {'en': 'Recommendations', 'ne': 'सिफारिसहरू'},
    'recommendations_description': {
      'en': 'Get personalized crop and fertilizer recommendations',
      'ne': 'व्यक्तिगत बाली र मल सिफारिसहरू प्राप्त गर्नुहोस्',
    },
    'start_soil_test': {
      'en': 'Start Soil Test',
      'ne': 'माटो परीक्षण सुरु गर्नुहोस्',
    },
    'soil_testing_coming_soon': {
      'en': 'Soil testing feature coming soon!',
      'ne': 'माटो परीक्षण सुविधा छिट्टै आउँदैछ!',
    },

    // Videos Page
    'educational_videos': {
      'en': 'Educational Videos',
      'ne': 'शैक्षिक भिडियोहरू',
    },
    'all_videos': {'en': 'All Videos', 'ne': 'सबै भिडियोहरू'},
    'farming': {'en': 'Farming', 'ne': 'खेती'},
    'pest_control': {'en': 'Pest Control', 'ne': 'कीट नियन्त्रण'},
    'irrigation': {'en': 'Irrigation', 'ne': 'सिँचाइ'},
    'harvesting': {'en': 'Harvesting', 'ne': 'कटाइ'},
    'storage': {'en': 'Storage', 'ne': 'भण्डारण'},
    'marketing': {'en': 'Marketing', 'ne': 'विपणन'},
    'filter_videos': {'en': 'Filter videos', 'ne': 'भिडियो फिल्टर गर्नुहोस्'},
    'no_videos_available': {
      'en': 'No videos available',
      'ne': 'कुनै भिडियो उपलब्ध छैन',
    },
    'check_back_later_videos': {
      'en': 'Check back later for new content',
      'ne': 'नयाँ सामग्रीको लागि पछि फेरि जाँच गर्नुहोस्',
    },
    'video_url_empty': {'en': 'Video URL is empty', 'ne': 'भिडियो URL खाली छ'},
    'invalid_video_url': {
      'en': 'Invalid video URL format',
      'ne': 'अमान्य भिडियो URL ढाँचा',
    },
    'could_not_open_video': {
      'en': 'Could not open video. Please check your internet connection',
      'ne': 'भिडियो खोल्न सकिएन। कृपया आफ्नो इन्टरनेट जडान जाँच गर्नुहोस्',
    },
    'error_opening_video': {
      'en': 'Error opening video',
      'ne': 'भिडियो खोल्दा त्रुटि',
    },
    'views': {'en': 'views', 'ne': 'हेराइहरू'},

    // Emergency Contacts Page
    'emergency_contacts': {
      'en': 'Emergency Contacts',
      'ne': 'आपतकालीन सम्पर्कहरू',
    },
    'all_contacts': {'en': 'All Contacts', 'ne': 'सबै सम्पर्कहरू'},
    'emergency': {'en': 'Emergency', 'ne': 'आपतकालीन'},
    'technical': {'en': 'Technical', 'ne': 'प्राविधिक'},
    'sales': {'en': 'Sales', 'ne': 'बिक्री'},
    'general_contact': {'en': 'General', 'ne': 'सामान्य'},
    'quick_filters': {'en': 'Quick filters', 'ne': 'द्रुत फिल्टरहरू'},
    'no_contacts_available': {
      'en': 'No contacts available',
      'ne': 'कुनै सम्पर्क उपलब्ध छैन',
    },
    'check_back_later': {
      'en': 'Check back later',
      'ne': 'पछि फेरि जाँच गर्नुहोस्',
    },
    'could_not_make_call': {
      'en': 'Could not make phone call',
      'ne': 'फोन कल गर्न सकिएन',
    },
    'no_email_available': {'en': 'No email available', 'ne': 'इमेल उपलब्ध छैन'},
    'could_not_send_email': {
      'en': 'Could not send email',
      'ne': 'इमेल पठाउन सकिएन',
    },

    // Service Providers Page
    'service_providers': {'en': 'Service Providers', 'ne': 'सेवा प्रदायकहरू'},
    'all_services': {'en': 'All Services', 'ne': 'सबै सेवाहरू'},
    'seeds': {'en': 'Seeds', 'ne': 'बीउहरू'},
    'fertilizer': {'en': 'Fertilizer', 'ne': 'मल'},
    'pesticide': {'en': 'Pesticide', 'ne': 'कीटनाशक'},
    'equipment': {'en': 'Equipment', 'ne': 'उपकरण'},
    'veterinary': {'en': 'Veterinary', 'ne': 'पशु चिकित्सा'},
    'transport': {'en': 'Transport', 'ne': 'यातायात'},
    'filter_services': {
      'en': 'Filter services',
      'ne': 'सेवाहरू फिल्टर गर्नुहोस्',
    },
    'no_service_providers_available': {
      'en': 'No service providers available',
      'ne': 'कुनै सेवा प्रदायक उपलब्ध छैन',
    },
    'delivery_available': {'en': 'Delivery Available', 'ne': 'डेलिभरी उपलब्ध'},
    'alt_call': {'en': 'Alt. Call', 'ne': 'वैकल्पिक कल'},

    // Experts Page
    'agri_experts': {'en': 'Agri Experts', 'ne': 'कृषि विशेषज्ञहरू'},
    'no_experts_available': {
      'en': 'No experts available',
      'ne': 'कुनै विशेषज्ञ उपलब्ध छैन',
    },
    'call': {'en': 'Call', 'ne': 'कल'},
    'email': {'en': 'Email', 'ne': 'इमेल'},

    // Home Page
    'unknown': {'en': 'Unknown', 'ne': 'अज्ञात'},
    'programs': {'en': 'Programs', 'ne': 'कार्यक्रमहरू'},
    'agricultural_development_programs': {
      'en': 'Agricultural development programs',
      'ne': 'कृषि विकास कार्यक्रमहरू',
    },
    'programs_intro': {
      'en':
          'Discover active government programs and submit your interest via official forms.',
      'ne':
          'सक्रिय सरकारी कार्यक्रमहरू खोज्नुहोस् र आधिकारिक फारम मार्फत आफ्नो रुचि पठाउनुहोस्।',
    },
    'search_programs': {
      'en': 'Search programs',
      'ne': 'कार्यक्रम खोज्नुहोस्',
    },
    'no_programs_available': {
      'en': 'No programs available right now',
      'ne': 'हाल कुनै कार्यक्रम उपलब्ध छैन',
    },
    'programs_empty_state_subtitle': {
      'en': 'Check back soon for upcoming opportunities.',
      'ne': 'आउँदै गरेका अवसरहरूका लागि छिट्टै फेरि जाँच्च गर्नुहोस्।',
    },
    'failed_to_load_programs': {
      'en': 'Failed to load programs',
      'ne': 'कार्यक्रम लोड गर्न असफल',
    },
    'apply_now': {
      'en': 'Apply now',
      'ne': 'अहिले आवेदन दिनुहोस्',
    },
    'failed_to_open_form': {
      'en': 'Could not open form link',
      'ne': 'फारम लिङ्क खोल्न सकिएन',
    },
    'krishi_gyaan': {'en': 'Krishi Gyan', 'ne': 'कृषि ज्ञान'},
    'farming_knowledge_home': {'en': 'Farming Knowledge', 'ne': 'खेती ज्ञान'},
    'videos': {'en': 'Videos', 'ne': 'भिडियोहरू'},
    'watch_learn': {'en': 'Watch & Learn', 'ne': 'हेर्नुहोस् र सिक्नुहोस्'},
    'crop_calendar': {'en': 'Crop Calendar', 'ne': 'बाली पात्रो'},
    'planting_guide': {'en': 'Planting Guide', 'ne': 'रोपाइँ गाइड'},
    'market_prices': {'en': 'Market Prices', 'ne': 'बजार मूल्य'},
    'market_prices_overview': {
      'en': 'Daily updates on regional market rates',
      'ne': 'क्षेत्रीय बजार दरहरूको दैनिक अद्यावधिक',
    },
    'market_prices_intro': {
      'en':
          'Track the latest buying prices shared by cooperatives and marketplaces.',
      'ne': 'सहकारी र बजारले साझेदारी गरेका पछिल्ला खरिद मूल्यहरू ट्र्याक गर्नुहोस्।',
    },
    'search_market_prices': {
      'en': 'Search market prices',
      'ne': 'बजार मूल्य खोज्नुहोस्',
    },
    'no_market_prices': {
      'en': 'No market prices available right now',
      'ne': 'हाल बजार मूल्य उपलब्ध छैन',
    },
    'market_prices_empty_state_subtitle': {
      'en': 'New price updates will appear here soon.',
      'ne': 'नयाँ मूल्य अद्यावधिकहरू छिट्टै यहाँ देखिनेछन्।',
    },
    'failed_to_load_market_prices': {
      'en': 'Failed to load market prices',
      'ne': 'बजार मूल्य लोड गर्न असफल',
    },
    'market_prices_error': {
      'en': 'Unable to load prices. Please try again.',
      'ne': 'मूल्य लोड गर्न सकिएन। कृपया फेरि प्रयास गर्नुहोस्।',
    },
    'market_category_other': {'en': 'Other', 'ne': 'अन्य'},
    'updated_on': {'en': 'Updated on', 'ne': 'अद्यावधिक मिति'},
    'soil_testing_centers': {
      'en': 'Nearby soil testing centers',
      'ne': 'नजिकैका माटो परीक्षण केन्द्रहरू',
    },
    'soil_testing_centers_subtitle': {
      'en': 'Book a visit or call the municipal lab to schedule testing.',
      'ne': 'माटो परीक्षणका लागि नगरपालिका प्रयोगशालासँग सम्पर्क वा भेट तय गर्नुहोस्।',
    },
    'search_soil_tests': {
      'en': 'Search by municipality or name',
      'ne': 'नगरपालिका वा नामबाट खोज्नुहोस्',
    },
    'failed_to_load_soil_tests': {
      'en': 'Failed to load soil test centers',
      'ne': 'माटो परीक्षण केन्द्रहरू लोड गर्न असफल',
    },
    'no_soil_tests': {
      'en': 'No soil testing centers found',
      'ne': 'माटो परीक्षण केन्द्र फेला परेन',
    },
    'soil_tests_empty_state_subtitle': {
      'en': 'Try adjusting your search or check back later.',
      'ne': 'तपाईंको खोज बदल्नुहोस् वा पछि फेरि प्रयास गर्नुहोस्।',
    },
    'contact_person': {'en': 'Contact person', 'ne': 'सम्पर्क व्यक्ति'},
    'not_available': {'en': 'Not available', 'ne': 'उपलब्ध छैन'},
    'testing_cost': {'en': 'Testing cost', 'ne': 'परीक्षण लागत'},
    'duration_label': {'en': 'Duration', 'ne': 'अवधि'},
    'requirements_label': {'en': 'Requirements', 'ne': 'आवश्यक सामग्री'},
    'call_now': {'en': 'Call now', 'ne': 'अहिल्यै कल गर्नुहोस्'},
    'rice': {'en': 'Rice', 'ne': 'चामल'},
    'wheat': {'en': 'Wheat', 'ne': 'गहुँ'},
    'tomato': {'en': 'Tomato', 'ne': 'गोलभेडा'},
    'potato': {'en': 'Potato', 'ne': 'आलु'},
    'main_services': {'en': 'Main Services', 'ne': 'मुख्य सेवाहरू'},
    'services_directory': {
      'en': 'Services & Directory',
      'ne': 'सेवा र निर्देशिका',
    },
    'knowledge_base': {'en': 'Knowledge Base', 'ne': 'ज्ञान आधार'},
    'notices': {'en': 'Notices', 'ne': 'सूचनाहरू'},
    'important_announcements': {
      'en': 'Important announcements',
      'ne': 'महत्वपूर्ण घोषणाहरू',
    },
    'coming_soon': {'en': 'Coming soon!', 'ne': 'छिट्टै आउँदैछ!'},

    // Notices Page
    'notices_announcements': {
      'en': 'Notices & Announcements',
      'ne': 'सूचना र घोषणाहरू',
    },
    'all_notices': {'en': 'All Notices', 'ne': 'सबै सूचनाहरू'},
    'important': {'en': 'Important', 'ne': 'महत्वपूर्ण'},
    'urgent': {'en': 'Urgent', 'ne': 'तत्काल'},
    'events': {'en': 'Events', 'ne': 'घटनाहरू'},
    'training': {'en': 'Training', 'ne': 'प्रशिक्षण'},
    'filter_notices': {
      'en': 'Filter notices',
      'ne': 'सूचनाहरू फिल्टर गर्नुहोस्',
    },
    'no_notices_available': {
      'en': 'No notices available',
      'ne': 'कुनै सूचना उपलब्ध छैन',
    },
    'check_back_later_updates': {
      'en': 'Check back later for updates',
      'ne': 'अपडेटहरूको लागि पछि फेरि जाँच गर्नुहोस्',
    },
    'pdf_attached': {'en': 'PDF Attached', 'ne': 'PDF संलग्न'},
    'image_attached': {'en': 'Image Attached', 'ne': 'छवि संलग्न'},

    // Notice Detail Page
    'notice_details': {'en': 'Notice Details', 'ne': 'सूचना विवरण'},
    'could_not_open_pdf': {'en': 'Could not open PDF', 'ne': 'PDF खोल्न सकिएन'},
    'open_pdf_document': {
      'en': 'Open PDF Document',
      'ne': 'PDF कागजात खोल्नुहोस्',
    },
    'posted_by': {'en': 'Posted By', 'ne': 'द्वारा पोस्ट गरियो'},

    // Expert Detail Page
    'qualifications': {'en': 'Qualifications', 'ne': 'योग्यताहरू'},
    'office': {'en': 'Office', 'ne': 'कार्यालय'},
    'available_days': {'en': 'Available Days', 'ne': 'उपलब्ध दिनहरू'},
    'available_hours': {'en': 'Available Hours', 'ne': 'उपलब्ध घण्टाहरू'},
    'consultation_fee': {'en': 'Consultation Fee', 'ne': 'परामर्श शुल्क'},

    // Crop Detail Page
    'growing_duration': {'en': 'Growing Duration', 'ne': 'बढ्दो अवधि'},
    'planting_season': {'en': 'Planting Season', 'ne': 'रोपाइँ मौसम'},
    'harvesting_season': {'en': 'Harvesting Season', 'ne': 'कटाइ मौसम'},
    'climate_requirement': {
      'en': 'Climate Requirement',
      'ne': 'जलवायु आवश्यकता',
    },
    'soil_type': {'en': 'Soil Type', 'ne': 'माटो प्रकार'},
    'water_requirement': {'en': 'Water Requirement', 'ne': 'पानी आवश्यकता'},
    'best_practices': {'en': 'Best Practices', 'ne': 'उत्तम अभ्यासहरू'},
    'common_pests_diseases': {
      'en': 'Common Pests & Diseases',
      'ne': 'सामान्य कीट र रोगहरू',
    },

    // Crop Calendar Page
    'all_crops': {'en': 'All Crops', 'ne': 'सबै बालीहरू'},
    'cereals': {'en': 'Cereals', 'ne': 'अनाजहरू'},
    'vegetables': {'en': 'Vegetables', 'ne': 'तरकारीहरू'},
    'fruits': {'en': 'Fruits', 'ne': 'फलफूलहरू'},
    'pulses': {'en': 'Pulses', 'ne': 'दालहरू'},
    'cash_crops': {'en': 'Cash Crops', 'ne': 'नगदे बालीहरू'},
    'filter_crops': {'en': 'Filter crops', 'ne': 'बालीहरू फिल्टर गर्नुहोस्'},
    'no_crops_available': {
      'en': 'No crops available',
      'ne': 'कुनै बाली उपलब्ध छैन',
    },
    'check_back_later_info': {
      'en': 'Check back later for information',
      'ne': 'जानकारीको लागि पछि फेरि जाँच गर्नुहोस्',
    },

    // Support Page
    'quick_contact': {'en': 'Quick Contact', 'ne': 'द्रुत सम्पर्क'},
    'no_manuals_available': {
      'en': 'No manuals available',
      'ne': 'कुनै म्यानुअल उपलब्ध छैन',
    },
    'watch_video': {'en': 'Watch Video', 'ne': 'भिडियो हेर्नुहोस्'},

    // Account Page
    'user': {'en': 'User', 'ne': 'प्रयोगकर्ता'},
    'profile_picture': {'en': 'Profile Picture', 'ne': 'प्रोफाइल तस्बिर'},
    'upload_image': {'en': 'Upload', 'ne': 'अपलोड गर्नुहोस्'},
    'profile_picture_updated': {
      'en': 'Profile picture updated successfully',
      'ne': 'प्रोफाइल तस्बिर सफलतापूर्वक अपडेट भयो',
    },
    'profile_picture_update_failed': {
      'en': 'Failed to update profile picture',
      'ne': 'प्रोफाइल तस्बिर अपडेट गर्न असफल भयो',
    },
    'app_tagline': {
      'en': 'Empowering farmers with technology',
      'ne': 'प्रविधिको साथ किसानहरूलाई सशक्त बनाउँदै',
    },
    'about_app': {'en': 'About App', 'ne': 'एपको बारेमा'},
    'about_app_description': {
      'en':
          'Krishi is a comprehensive agricultural platform designed to connect farmers, buyers, and sellers. Access expert advice, crop information, weather updates, marketplace services, and more to enhance your farming experience.',
      'ne':
          'कृषि एक व्यापक कृषि प्लेटफर्म हो जुन किसानहरू, खरीददारहरू र विक्रेताहरू जडान गर्न डिजाइन गरिएको छ। विशेषज्ञ सल्लाह, बाली जानकारी, मौसम अपडेट, बजार सेवाहरू र थप पहुँच गर्नुहोस् ताकि तपाईंको खेती अनुभवलाई बढाउन सकुन्।',
    },

    // Navigation
    'market': {'en': 'Market', 'ne': 'बजार'},
  };

  static String translate(String key, String languageCode) {
    final translations = _translations[key];
    if (translations == null) return key;
    return translations[languageCode] ?? translations['en'] ?? key;
  }
}
