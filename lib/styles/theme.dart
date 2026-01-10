import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';
import 'app_dimensions.dart';

/// Complete Material Theme Configuration
/// Provides light and dark themes with consistent styling across the app
class AppTheme {
  AppTheme._();

  /// Light Theme Configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.textOnPrimary,
        primaryContainer: AppColors.primaryLight,
        onPrimaryContainer: AppColors.textPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textOnSecondary,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.textPrimary,
        tertiary: AppColors.warning,
        onTertiary: AppColors.textOnPrimary,
        error: AppColors.error,
        onError: AppColors.textOnPrimary,
        errorContainer: AppColors.errorLight,
        onErrorContainer: AppColors.error,
        background: AppColors.background,
        onBackground: AppColors.textPrimary,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceVariant: AppColors.surfaceVariant,
        onSurfaceVariant: AppColors.textSecondary,
        outline: AppColors.border,
        outlineVariant: AppColors.borderLight,
        shadow: AppColors.shadowMedium,
        scrim: AppColors.overlay,
        inverseSurface: AppColors.textPrimary,
        onInverseSurface: AppColors.textOnPrimary,
        inversePrimary: AppColors.primaryLight,
        surfaceTint: AppColors.primary,
      ),

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: AppDimensions.appBarElevation,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
        iconTheme: IconThemeData(
          color: AppColors.iconPrimary,
          size: AppDimensions.iconM,
        ),
        actionsIconTheme: IconThemeData(
          color: AppColors.iconPrimary,
          size: AppDimensions.iconM,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge,
        displayMedium: AppTextStyles.displayMedium,
        displaySmall: AppTextStyles.displaySmall,
        headlineLarge: AppTextStyles.headlineLarge,
        headlineMedium: AppTextStyles.headlineMedium,
        headlineSmall: AppTextStyles.headlineSmall,
        titleLarge: AppTextStyles.titleLarge,
        titleMedium: AppTextStyles.titleMedium,
        titleSmall: AppTextStyles.titleSmall,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelLarge: AppTextStyles.labelLarge,
        labelMedium: AppTextStyles.labelMedium,
        labelSmall: AppTextStyles.labelSmall,
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          disabledBackgroundColor: AppColors.borderLight,
          disabledForegroundColor: AppColors.textTertiary,
          elevation: 0,
          shadowColor: AppColors.shadowLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
          minimumSize: Size(double.infinity, AppDimensions.buttonHeight),
          textStyle: AppTextStyles.buttonMedium,
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.buttonPadding,
            vertical: AppDimensions.paddingM,
          ),
        ),
      ),

      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textTertiary,
          backgroundColor: Colors.transparent,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
          minimumSize: Size(double.infinity, AppDimensions.buttonHeight),
          textStyle: AppTextStyles.buttonMedium.copyWith(
            color: AppColors.primary,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.buttonPadding,
            vertical: AppDimensions.paddingM,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          disabledForegroundColor: AppColors.textTertiary,
          textStyle: AppTextStyles.buttonMedium.copyWith(
            color: AppColors.primary,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.borderLight),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.inputPadding,
          vertical: AppDimensions.paddingM,
        ),
        hintStyle: AppTextStyles.inputHint,
        labelStyle: AppTextStyles.inputLabel,
        errorStyle: AppTextStyles.inputError,
        floatingLabelStyle: AppTextStyles.inputLabel,
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.surface,
        shadowColor: AppColors.shadowLight,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: AppColors.iconPrimary,
        size: AppDimensions.iconM,
      ),

      // Primary Icon Theme
      primaryIconTheme: IconThemeData(
        color: AppColors.iconOnPrimary,
        size: AppDimensions.iconM,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.divider,
        thickness: AppDimensions.dividerThickness,
        indent: AppDimensions.dividerIndent,
        endIndent: AppDimensions.dividerIndent,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceVariant,
        disabledColor: AppColors.borderLight,
        selectedColor: AppColors.primaryLight,
        secondarySelectedColor: AppColors.secondaryLight,
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        labelStyle: AppTextStyles.labelMedium,
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textOnSecondary,
        ),
        brightness: Brightness.light,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.iconSecondary,
        selectedLabelStyle: AppTextStyles.navLabelActive,
        unselectedLabelStyle: AppTextStyles.navLabel,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
        ),
        titleTextStyle: AppTextStyles.headlineSmall,
        contentTextStyle: AppTextStyles.bodyMedium,
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.snackbarText,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.snackbarRadius),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textSecondary,
        labelStyle: AppTextStyles.labelLarge,
        unselectedLabelStyle: AppTextStyles.labelMedium,
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.primary,
            width: AppDimensions.tabIndicatorHeight,
          ),
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.borderDark;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primaryLight;
          }
          return AppColors.borderLight;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return AppColors.borderDark;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.borderLight,
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primaryLight.withValues(alpha: 0.2),
        valueIndicatorColor: AppColors.primary,
        valueIndicatorTextStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textOnPrimary,
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.borderLight,
        circularTrackColor: AppColors.borderLight,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.listItemPadding,
          vertical: AppDimensions.paddingS,
        ),
        titleTextStyle: AppTextStyles.titleMedium,
        subtitleTextStyle: AppTextStyles.bodySmall,
        leadingAndTrailingTextStyle: AppTextStyles.labelMedium,
        iconColor: AppColors.iconSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),

      // Expansion Tile Theme
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: AppColors.surface,
        collapsedBackgroundColor: AppColors.surface,
        textColor: AppColors.textPrimary,
        collapsedTextColor: AppColors.textPrimary,
        iconColor: AppColors.iconSecondary,
        collapsedIconColor: AppColors.iconSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.textPrimary,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        textStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textOnPrimary,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
      ),

      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Material Tap Target Size
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Splash Color
      splashColor: AppColors.primaryLight.withValues(alpha: 0.2),
      highlightColor: AppColors.primaryLight.withValues(alpha: 0.1),

      // Focus Color
      focusColor: AppColors.primary.withValues(alpha: 0.12),
      hoverColor: AppColors.primary.withValues(alpha: 0.04),
    );
  }

  /// Dark Theme Configuration
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkPrimary, // #3F51B6
        onPrimary: AppColors.darkTextPrimary, // #FFFFFF
        primaryContainer: AppColors.darkPrimaryLight,
        onPrimaryContainer: AppColors.darkTextPrimary,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textOnSecondary,
        secondaryContainer: AppColors.secondaryLight,
        onSecondaryContainer: AppColors.darkTextPrimary,
        tertiary: AppColors.warning,
        onTertiary: AppColors.darkTextPrimary,
        error: AppColors.error,
        onError: AppColors.darkTextPrimary,
        errorContainer: AppColors.errorLight,
        onErrorContainer: AppColors.error,
        background: AppColors.darkBackground,
        onBackground: AppColors.darkTextPrimary, // #FFFFFF
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary, // #FFFFFF
        surfaceVariant: AppColors.darkSurfaceVariant,
        onSurfaceVariant: AppColors.darkTextSecondary,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkBorderLight,
        shadow: AppColors.shadowMedium,
        scrim: AppColors.overlay,
        inverseSurface: AppColors.darkTextPrimary,
        onInverseSurface: AppColors.darkBackground,
        inversePrimary: AppColors.darkPrimaryLight,
        surfaceTint: AppColors.darkPrimary,
      ),

      // Scaffold Background
      scaffoldBackgroundColor: AppColors.darkBackground,

      // App Bar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.darkTextPrimary, // #FFFFFF
        elevation: AppDimensions.appBarElevation,
        centerTitle: true,
        titleTextStyle: AppTextStyles.appBarTitle.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        iconTheme: IconThemeData(
          color: AppColors.darkIconPrimary, // #FFFFFF
          size: AppDimensions.iconM,
        ),
        actionsIconTheme: IconThemeData(
          color: AppColors.darkIconPrimary, // #FFFFFF
          size: AppDimensions.iconM,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTextStyles.displayLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        displayMedium: AppTextStyles.displayMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        displaySmall: AppTextStyles.displaySmall.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        headlineLarge: AppTextStyles.headlineLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        headlineMedium: AppTextStyles.headlineMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        headlineSmall: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        titleLarge: AppTextStyles.titleLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        titleMedium: AppTextStyles.titleMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        titleSmall: AppTextStyles.titleSmall.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        bodyLarge: AppTextStyles.bodyLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        bodyMedium: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        bodySmall: AppTextStyles.bodySmall.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        labelLarge: AppTextStyles.labelLarge.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        labelMedium: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        labelSmall: AppTextStyles.labelSmall.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkPrimary, // #3F51B6
          foregroundColor: AppColors.darkTextPrimary, // #FFFFFF
          disabledBackgroundColor: AppColors.darkBorder,
          disabledForegroundColor: AppColors.darkTextTertiary,
          elevation: 0,
          shadowColor: AppColors.shadowLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
          minimumSize: Size(double.infinity, AppDimensions.buttonHeight),
          textStyle: AppTextStyles.buttonMedium.copyWith(
            color: AppColors.darkTextPrimary,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.buttonPadding,
            vertical: AppDimensions.paddingM,
          ),
        ),
      ),

      // Outlined Button Theme (for social login buttons)
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary, // #FFFFFF
          disabledForegroundColor: AppColors.darkTextTertiary,
          backgroundColor: AppColors.darkSurfaceVariant, // Dark grey background
          side: const BorderSide(color: AppColors.darkBorder),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.buttonRadius),
          ),
          minimumSize: Size(double.infinity, AppDimensions.buttonHeight),
          textStyle: AppTextStyles.buttonMedium.copyWith(
            color: AppColors.darkTextPrimary, // #FFFFFF
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.buttonPadding,
            vertical: AppDimensions.paddingM,
          ),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkPrimary, // #3F51B6
          disabledForegroundColor: AppColors.darkTextTertiary,
          textStyle: AppTextStyles.buttonMedium.copyWith(
            color: AppColors.darkPrimary,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingM,
            vertical: AppDimensions.paddingS,
          ),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurfaceVariant, // Dark grey input fields
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.inputRadius),
          borderSide: const BorderSide(color: AppColors.darkBorderLight),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.inputPadding,
          vertical: AppDimensions.paddingM,
        ),
        hintStyle: AppTextStyles.inputHint.copyWith(
          color: AppColors.darkTextPrimary, // White hint text in dark mode
        ),
        labelStyle: AppTextStyles.inputLabel.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        errorStyle: AppTextStyles.inputError,
        floatingLabelStyle: AppTextStyles.inputLabel.copyWith(
          color: AppColors.darkTextSecondary,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        shadowColor: AppColors.shadowLight,
        elevation: AppDimensions.cardElevation,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        ),
        margin: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: AppColors.darkIconPrimary, // #FFFFFF
        size: AppDimensions.iconM,
      ),

      // Primary Icon Theme
      primaryIconTheme: IconThemeData(
        color: AppColors.darkTextPrimary, // #FFFFFF
        size: AppDimensions.iconM,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: AppColors.darkDivider,
        thickness: AppDimensions.dividerThickness,
        indent: AppDimensions.dividerIndent,
        endIndent: AppDimensions.dividerIndent,
      ),

      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.darkSurfaceVariant,
        disabledColor: AppColors.darkBorderLight,
        selectedColor: AppColors.darkPrimaryLight,
        secondarySelectedColor: AppColors.secondaryLight,
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        labelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        secondaryLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.textOnSecondary,
        ),
        brightness: Brightness.dark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        selectedItemColor: AppColors.darkPrimary, // #3F51B6
        unselectedItemColor: AppColors.darkIconSecondary,
        selectedLabelStyle: AppTextStyles.navLabelActive.copyWith(
          color: AppColors.darkPrimary,
        ),
        unselectedLabelStyle: AppTextStyles.navLabel.copyWith(
          color: AppColors.darkIconSecondary,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Floating Action Button Theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkPrimary, // #3F51B6
        foregroundColor: AppColors.darkTextPrimary, // #FFFFFF
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXL),
        ),
      ),

      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.dialogRadius),
        ),
        titleTextStyle: AppTextStyles.headlineSmall.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        contentTextStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),

      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkSurface,
        contentTextStyle: AppTextStyles.snackbarText.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.snackbarRadius),
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Tab Bar Theme
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.darkPrimary, // #3F51B6
        unselectedLabelColor: AppColors.darkTextSecondary,
        labelStyle: AppTextStyles.labelLarge.copyWith(
          color: AppColors.darkPrimary,
        ),
        unselectedLabelStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(
            color: AppColors.darkPrimary,
            width: AppDimensions.tabIndicatorHeight,
          ),
        ),
      ),

      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimary; // #3F51B6
          }
          return AppColors.darkBorder;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimaryLight;
          }
          return AppColors.darkBorderLight;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimary; // #3F51B6
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(AppColors.darkTextPrimary), // #FFFFFF
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusXS),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.darkPrimary; // #3F51B6
          }
          return AppColors.darkBorder;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.darkPrimary, // #3F51B6
        inactiveTrackColor: AppColors.darkBorderLight,
        thumbColor: AppColors.darkPrimary,
        overlayColor: AppColors.darkPrimaryLight.withValues(alpha: 0.2),
        valueIndicatorColor: AppColors.darkPrimary,
        valueIndicatorTextStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.darkTextPrimary,
        ),
      ),

      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.darkPrimary, // #3F51B6
        linearTrackColor: AppColors.darkBorderLight,
        circularTrackColor: AppColors.darkBorderLight,
      ),

      // List Tile Theme
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppDimensions.listItemPadding,
          vertical: AppDimensions.paddingS,
        ),
        titleTextStyle: AppTextStyles.titleMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        subtitleTextStyle: AppTextStyles.bodySmall.copyWith(
          color: AppColors.darkTextSecondary,
        ),
        leadingAndTrailingTextStyle: AppTextStyles.labelMedium.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        iconColor: AppColors.darkIconSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),

      // Expansion Tile Theme
      expansionTileTheme: ExpansionTileThemeData(
        backgroundColor: AppColors.darkSurface,
        collapsedBackgroundColor: AppColors.darkSurface,
        textColor: AppColors.darkTextPrimary,
        collapsedTextColor: AppColors.darkTextPrimary,
        iconColor: AppColors.darkIconSecondary,
        collapsedIconColor: AppColors.darkIconSecondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(AppDimensions.radiusS),
        ),
        textStyle: AppTextStyles.labelSmall.copyWith(
          color: AppColors.darkTextPrimary,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
      ),

      // Visual Density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Material Tap Target Size
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

      // Page Transitions
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),

      // Splash Color
      splashColor: AppColors.darkPrimaryLight.withValues(alpha: 0.2),
      highlightColor: AppColors.darkPrimaryLight.withValues(alpha: 0.1),

      // Focus Color
      focusColor: AppColors.darkPrimary.withValues(alpha: 0.12),
      hoverColor: AppColors.darkPrimary.withValues(alpha: 0.04),
    );
  }
}
