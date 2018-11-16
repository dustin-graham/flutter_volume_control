#import "VolumeControlPlugin.h"
#import <volume_control/volume_control-Swift.h>

@implementation VolumeControlPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftVolumeControlPlugin registerWithRegistrar:registrar];
}
@end
