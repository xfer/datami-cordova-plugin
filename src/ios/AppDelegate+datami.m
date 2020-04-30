#import "AppDelegate+datami.h"
#import "SmiSdk.h"
#import "AppDelegate.h"
#import "DatamiCordovaPlugin.h"
#import <objc/runtime.h>

@implementation AppDelegate (notification)
static char UIB_PROPERTY_KEY;
static char UIB_PROPERTY_KEY1;
@dynamic smiResult;


-(void) setSmiResult:(SmiResult *)smiResult {
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY, smiResult, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (SmiResult *)smiResult {
    return objc_getAssociatedObject(self, &UIB_PROPERTY_KEY);
}

-(void) setApiKey:(NSString *)apiKey {
    objc_setAssociatedObject(self, &UIB_PROPERTY_KEY1, apiKey, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)apiKey {
    return objc_getAssociatedObject(self, &UIB_PROPERTY_KEY1);
}

- (id) getCommandInstance:(NSString*)className
{
    return [self.viewController getCommandInstance:className];
}

+ (void)load
{
    Method original, swizzled;

    original = class_getInstanceMethod(self, @selector(init));
    swizzled = class_getInstanceMethod(self, @selector(swizzled_init));
    method_exchangeImplementations(original, swizzled);
}

- (AppDelegate *)swizzled_init
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(finishLaunching:)
               name:@"UIApplicationDidFinishLaunchingNotification" object:nil];

    // This actually calls the original init method over in AppDelegate. Equivilent to calling super
    // on an overrided method, this is not recursive, although it appears that way. neat huh?
    return [self swizzled_init];
}

- (void)finishLaunching:(NSNotification *)notification
{
    // Call the Datami API at the beginning of didFinishLaunchingWithOptions, before other initializations.
    // IMPORTANT: If Datami API is not the first API called in the application then any network
    // connection made before Datami SDK initialization will be non-sponsored and will be
    // charged to the user.

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedStateChage:)
                                                 name:SDSTATE_CHANGE_NOTIF object:nil];

    DatamiCordovaPlugin *datamiPlugin = [self getCommandInstance:@"DatamiCordovaPlugin"];

    
    self.apiKey = [datamiPlugin.commandDelegate.settings objectForKey:[@"api_key" lowercaseString]];
    NSString* useSdkMessagin = [datamiPlugin.commandDelegate.settings objectForKey:[@"sdk_messaging" lowercaseString]];

    if([self.apiKey length] == 0) {
        self.apiKey = @"noApiKeySpecified";
    }

    if([useSdkMessagin length] == 0) {
        useSdkMessagin = @"NO";
    }

    Boolean sdkMessaging;

    if ([useSdkMessagin isEqualToString:@"YES"]){
        sdkMessaging = YES;
    }else {
        sdkMessaging = NO;
    }

    NSString* myUserId = @"";

    [SmiSdk initSponsoredData: self.apiKey userId: myUserId showSDMessage:sdkMessaging];
}

-(void)receivedStateChage:(NSNotification*)notif {
   // SmiResult* sr =  notif.object;
    self.smiResult = notif.object;
    NSLog(@"receivedStateChage, sdState: %ld", (long)self.smiResult.sdState);
    if(self.smiResult.sdState == SD_AVAILABLE) {
        // TODO: show a banner or message to user, indicating that the data usage is sponsored and charges do not apply to user data plan
    } else if(self.smiResult.sdState == SD_NOT_AVAILABLE) {
        // TODO: show a banner or message to user, indicating that the data usage is NOT sponsored and charges apply to user data plan
        NSLog(@"receivedStateChage, sdReason %ld", (long)self.smiResult.sdReason);
    } else if(self.smiResult.sdState == SD_WIFI) {
        // wifi connection
    }
}

@end
