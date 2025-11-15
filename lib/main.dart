import 'package:krishi/core/configs/app_theme.dart';
import 'package:krishi/core/services/auth_service.dart';
import 'package:krishi/core/services/get.dart';
import 'package:krishi/features/auth/login_page.dart';
import 'package:krishi/features/navigation/main_navigation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/configs/app_colors.dart';
import 'core/configs/app_theme_provider.dart';
import 'core/configs/language_provider.dart';
import 'core/core_service_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );

  try {
    final box = await Get.box.init();
    final themeProvider = await ThemeProvider(box).init();
    final langProvider = await LanguageProvider(box).init();
    final authService = await AuthService(box).init();

    runApp(
      ProviderScope(
        overrides: [
          storageServiceProvider.overrideWith((ref) => box),
          themeModeProvider.overrideWith((ref) => themeProvider),
          languageProvider.overrideWith((ref) => langProvider),
          authServiceProvider.overrideWith((ref) => authService),
        ],
        child: const Core(),
      ),
    );
  } catch (e) {
    print('Initialization error: $e');
  }
}

class Core extends ConsumerWidget {
  const Core({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final lang = ref.watch(languageProvider);
    final auth = ref.watch(authServiceProvider);
    
    // Create a unique key combining both theme and language for proper rebuilds
    final appKey = '${mode.themeMode.name}_${lang.index}';
    
    return ScreenUtilInit(
      key: Get.key("Krishi_$appKey"),
      minTextAdapt: true,
      ensureScreenSize: true,
      splitScreenMode: true,
      designSize: const Size(360, 640),
      child: ValueListenableBuilder(
        valueListenable: platformProvider,
        builder: (context, platform, child) => PlatformProvider(
          key: Get.key('${platform}_$appKey'),
          settings: PlatformSettingsData(
            iosUsesMaterialWidgets: true,
            matchMaterialCaseForPlatformText: false,
            legacyIosUsesMaterialWidgets: true,
            iosUseZeroPaddingForAppbarPlatformIcon: true,
            platformStyle: PlatformStyleData(android: platform),
          ),
          builder: (context) => PlatformTheme(
            themeMode: mode.themeMode,
            materialLightTheme: AppThemes.lightTheme,
            materialDarkTheme: AppThemes.darkTheme,
            cupertinoDarkTheme: AppThemes.iosdarkTheme,
            cupertinoLightTheme: AppThemes.ioslightTheme,
            builder: (context) => PlatformApp(
              key: Get.key('app_$appKey'),
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              scrollBehavior: Get.scrollBehaviour,
              color: AppColors.primary,
              localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
                DefaultMaterialLocalizations.delegate,
                DefaultCupertinoLocalizations.delegate,
                DefaultWidgetsLocalizations.delegate,
              ],
              home: auth.isAuthenticated ? const MainNavigation() : const LoginPage(),
            ),
          ),
        ),
      ),
    );
  }
}
