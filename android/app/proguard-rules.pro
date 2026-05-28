# Flutter Engine rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.embedding.** { *; }
-keep class io.flutter.provider.** { *; }

# Prevent pruning on plugin bindings
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.plugins.**

# Ignore missing Play Core deferred component references
-dontwarn com.google.android.play.core.**

# Support generic serialization/reflection layers
-keepattributes Signature, *Annotation*, InnerClasses, EnclosingMethod
-dontwarn javax.annotation.**
