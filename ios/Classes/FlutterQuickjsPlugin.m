#import "FlutterQuickjsPlugin.h"
#if __has_include(<flutter_quickjs/flutter_quickjs-Swift.h>)
#import <flutter_quickjs/flutter_quickjs-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_quickjs-Swift.h"
#endif

@implementation FlutterQuickjsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterQuickjsPlugin registerWithRegistrar:registrar];
}
@end
