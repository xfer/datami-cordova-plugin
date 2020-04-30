//
//  DatamiSDStateChangePlugin.h
//  GAIntegration
//
//  Created by Damandeep Singh on 09/10/17.
//

#import <Cordova/CDV.h>
#import <Cordova/CDVPlugin.h>

@interface DatamiSDStateChangePlugin : CDVPlugin {
    
    NSString* sdStatus;
    NSString* prevSdStatus;
    NSString* _callbackId;

}
- (void)getSDState:(CDVInvokedUrlCommand*)command;
- (void)getAnalytics:(CDVInvokedUrlCommand*)command;
- (void)updateUserId:(CDVInvokedUrlCommand*)command;
- (void)updateUserTag:(CDVInvokedUrlCommand*)command;
- (void)getSDAuth:(CDVInvokedUrlCommand*)command;
- (void)startSponsoredData:(CDVInvokedUrlCommand*)command;
- (void)stopSponsoredData:(CDVInvokedUrlCommand*)command;

@end
