#import "DapiPlugin.h"
#if __has_include(<dapi/dapi-Swift.h>)
#import <dapi/dapi-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "dapi-Swift.h"
#endif

@implementation DapiPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftDapiPlugin registerWithRegistrar:registrar];
}
@end
