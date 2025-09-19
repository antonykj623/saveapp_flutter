# Add these rules to android/app/proguard-rules.pro

# Auto-generated missing rules from Android Gradle plugin
-dontwarn com.nsdl.egov.esignaar.NsdlEsignActivity
-dontwarn com.weipl.checkout.R$anim
-dontwarn com.weipl.checkout.R$id

# Google Play Core Library - Missing classes for deferred components
-dontwarn com.google.android.play.core.splitcompat.SplitCompatApplication
-dontwarn com.google.android.play.core.splitinstall.SplitInstallException
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManager
-dontwarn com.google.android.play.core.splitinstall.SplitInstallManagerFactory
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest$Builder
-dontwarn com.google.android.play.core.splitinstall.SplitInstallRequest
-dontwarn com.google.android.play.core.splitinstall.SplitInstallSessionState
-dontwarn com.google.android.play.core.splitinstall.SplitInstallStateUpdatedListener
-dontwarn com.google.android.play.core.tasks.OnFailureListener
-dontwarn com.google.android.play.core.tasks.OnSuccessListener
-dontwarn com.google.android.play.core.tasks.Task

# Keep Flutter deferred components classes
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }

# Keep WEIPL Checkout classes
-keep class com.weipl.checkout.** { *; }
-keep class com.nsdl.egov.esignaar.** { *; }

# Keep R classes for WEIPL
-keep class com.weipl.checkout.R$* { *; }

# Keep WebView interface classes
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Additional dontwarn rules for WEIPL checkout
-dontwarn com.nsdl.egov.esignaar.**
-dontwarn com.weipl.checkout.**

# General rules for Flutter plugins
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }