//
//  DatamiSDStateChangePlugin.m
//  GAIntegration
//
//  Created by Damandeep Singh on 09/10/17.
//

#import "DatamiSDStateChangePlugin.h"
#import "SmiSdk.h"
#import "SmiAnalytics.h"
#import "AppDelegate+datami.h"

@implementation DatamiSDStateChangePlugin


- (void)pluginInitialize {
    NSLog(@"DatamiSDStateChangePlugin Initialised");
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedStateChage:)
                                                 name:SDSTATE_CHANGE_NOTIF object:nil];
}

- (void)getSDState:(CDVInvokedUrlCommand*)command
{
    NSLog(@"DatamiSDStateChangePlugin - getSDState");
    _callbackId = command.callbackId;
    AppDelegate *app = [[UIApplication sharedApplication] delegate];
    if (app.smiResult.sdState == SD_AVAILABLE) {
        sdStatus = @"SD_AVAILABLE";
    }
    else if (app.smiResult.sdState == SD_WIFI) {
        sdStatus = @"SD_WIFI";
    }
    else {
        sdStatus = [NSString stringWithFormat:@"SD_NOT_AVAILABLE, Reason: %@",[self getSDReasonAsString:app.smiResult.sdReason]];
    }
    [self sendPluginResult];
}

- (void)getAnalytics:(CDVInvokedUrlCommand*)command
{
    NSLog(@"DatamiSDStateChangePlugin - getAnalytics Invoked");
    // _callbackId = command.callbackId;
    SmiAnalytics *analytics = [SmiSdk getAnalytics];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:3];
    NSNumber *tempNumber = [[NSNumber alloc] initWithDouble:analytics.fgCellularSessionTime];
    [dict setValue:tempNumber forKey:@"CellularSessionTime"];
    NSNumber *tempNumber1 = [[NSNumber alloc] initWithDouble:analytics.fgWifiSessionTime];
    [dict setValue:tempNumber1 forKey:@"WifiSessionTime"];
    NSNumber *tempNumber2 = [[NSNumber alloc] initWithDouble:analytics.sdDataUsage];
    [dict setValue:tempNumber2 forKey:@"SdDataUsage"];
    NSDictionary *dictFinal = [[NSDictionary alloc] initWithDictionary:dict];
    NSLog(@"DatamiSDStateChangePlugin - getAnalyticsSending");
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary: dictFinal];
    [result setKeepCallbackAsBool:NO];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)stopSponsoredData:(CDVInvokedUrlCommand*)command
{
    NSLog(@"DatamiSDStateChangePlugin - stopSponsoredData Invoked");
    // _callbackId = command.callbackId;
    [SmiSdk stopSponsorData];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [result setKeepCallbackAsBool:NO];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];

}

- (void)startSponsoredData:(CDVInvokedUrlCommand*)command
{
    NSLog(@"DatamiSDStateChangePlugin - startSponsoredData Invoked");
    // _callbackId = command.callbackId;
    [SmiSdk startSponsorData];
    CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
    [result setKeepCallbackAsBool:NO];
    [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
}

- (void)updateUserId:(CDVInvokedUrlCommand *)command
{
    NSLog(@"DatamiSDStateChangePlugin - updateUserId Invoked");
    // _callbackId = command.callbackId;
    NSString *userid = [command.arguments objectAtIndex:0];
    if(userid != nil  && userid.length > 0) {
        [SmiSdk updateUserId:userid];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [result setKeepCallbackAsBool:NO];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
    else {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [result setKeepCallbackAsBool:NO];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)updateUserTag:(CDVInvokedUrlCommand *)command
{
    NSLog(@"DatamiSDStateChangePlugin - updateUserTag Invoked");
    // _callbackId = command.callbackId;
    NSArray *tags = [command.arguments objectAtIndex:0];
    NSLog(@"NSARRAY %@",tags);
    if(tags != nil  && tags.count > 0) {
        [SmiSdk updateTag:tags];
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [result setKeepCallbackAsBool:NO];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
    else {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [result setKeepCallbackAsBool:NO];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)getSDAuth:(CDVInvokedUrlCommand *)command
{
    NSLog(@"DatamiSDStateChangePlugin - getSDAuth Invoked");
    // _callbackId = command.callbackId;
    NSString *url = [command.arguments objectAtIndex:0];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithCapacity:4];
    if(url != nil  && url.length > 0) {
        AppDelegate *app = [[UIApplication sharedApplication]delegate];
        SmiResult *resu = [SmiSdk getSDAuth:app.apiKey url:url userId:@""];
        [dict setObject:[self getSDStateAsString:resu.sdState] forKey:@"SdState"];
        [dict setObject:resu.url forKey:@"Url"];
        if(resu.carrierName != nil) {
            [dict setObject:resu.carrierName forKey:@"CarrierName"];
        }
        if(resu.clientIp != nil) {
            [dict setObject:resu.clientIp forKey:@"ClientIp"];
        }
        
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:dict];
        [result setKeepCallbackAsBool:NO];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
    else {
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [result setKeepCallbackAsBool:NO];
        [self.commandDelegate sendPluginResult:result callbackId:command.callbackId];
    }
}

- (void)sendPluginResult
{
    // if(![sdStatus isEqualToString:prevSdStatus]) {
        NSLog(@"DatamiSDStateChangePlugin - sendPluginResult");
        CDVPluginResult* result = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString: sdStatus];
        [result setKeepCallbackAsBool:YES];
        [self.commandDelegate sendPluginResult:result callbackId:_callbackId];
        prevSdStatus = sdStatus;
    // }
    // else {
    //     NSLog(@"SD Status is same as Previous SD Status");
    // }
}

-(void)receivedStateChage:(NSNotification*)notif {
    SmiResult* sr =  notif.object;
    NSLog(@"DatamiSDStateChangePlugin - sdState: %ld", (long)sr.sdState);
    if (sr.sdState == SD_AVAILABLE) {
        sdStatus = @"SD_AVAILABLE";
    }
    else if (sr.sdState == SD_WIFI) {
        sdStatus = @"SD_WIFI";
    }
    else {
        sdStatus = [NSString stringWithFormat:@"SD_NOT_AVAILABLE, Reason: %@",[self getSDReasonAsString:sr.sdReason]];
    }
    [self sendPluginResult];
}

-(NSString *)getSDStateAsString:(SdState) state {
    switch (state) {
        case SD_WIFI:
            return @"WIFI";
        case SD_AVAILABLE:
            return @"SD_AVAILABLE";
        case SD_NOT_AVAILABLE:
            return @"SD_NOT_AVAILABLE";
        default:
            return @"";
    }
}


- (NSString *) getSDReasonAsString:(SdReason) reason {
    switch (reason) {
        case SD_REASON_NONE:
            return @"SD_REASON_NONE";
        case SD_REASON_DUPLICATE_API_CALL:
            return @"SD_REASON_DUPLICATE_API_CALL";
        case SD_NOT_AVAILABLE_FOR_OPERATOR:
            return @"SD_NOT_AVAILABLE_FOR_OPERATOR";
        case SD_NOT_AVAILABLE_FOR_APPLICATION:
            return @"SD_NOT_AVAILABLE_FOR_APPLICATION";
        case SD_NOT_AVAILABLE_FOR_URL:
            return @"SD_NOT_AVAILABLE_FOR_URL";
        case SD_NOT_AVAILABLE_FOR_DEVICE_OR_USER:
            return @"SD_NOT_AVAILABLE_FOR_DEVICE_OR_USER";
        case SD_NOT_AVAILABLE_PROMOTION_EXPIRED:
            return @"SD_NOT_AVAILABLE_PROMOTION_EXPIRED";
        case SD_NOT_AVAILABLE_PROMOTION_SUSPENDED:
            return @"SD_NOT_AVAILABLE_PROMOTION_SUSPENDED";
        case SD_NOT_AVAILABLE_PROMOTION_LIMIT_EXCEEDED:
            return @"SD_NOT_AVAILABLE_PROMOTION_LIMIT_EXCEEDED";
        case SD_NOT_AVAILABLE_USER_LIMIT_EXCEEDED:
            return @"SD_NOT_AVAILABLE_USER_LIMIT_EXCEEDED";
        case SD_NOT_AVAILABLE_PROMOTION_NOT_FOUND:
            return @"SD_NOT_AVAILABLE_PROMOTION_NOT_FOUND";
        case SD_NOT_AVAILABLE_SDK_INTERNAL_ERROR:
            return @"SD_NOT_AVAILABLE_SDK_INTERNAL_ERROR";
        case SD_NOT_AVAILABLE_SDK_VERSION_NOT_SUPPORTED:
            return @"SD_NOT_AVAILABLE_SDK_VERSION_NOT_SUPPORTED";
        case SD_NOT_AVAILABLE_SDK_REGISTRATION_NOT_DONE:
            return @"SD_NOT_AVAILABLE_SDK_REGISTRATION_NOT_DONE";
        case SD_NOT_AVAILABLE_SDK_NOT_SUPPORTED_FOR_APP_OR_CARRIER:
            return @"SD_NOT_AVAILABLE_SDK_NOT_SUPPORTED_FOR_APP_OR_CARRIER";
        case SD_NOT_AVAILABLE_URAM_NO_HEADER_INJECTED:
            return @"SD_NOT_AVAILABLE_URAM_NO_HEADER_INJECTED";
        case SD_NOT_AVAILABLE_SD_NOT_SUPPORTED_IN_ROAMING:
            return @"SD_NOT_AVAILABLE_SD_NOT_SUPPORTED_IN_ROAMING";
        case SD_NOT_AVAILABLE_SD_TESTING:
            return @"SD_NOT_AVAILABLE_SD_TESTING";
        case SD_NOT_AVAILABLE_GW_CONNECTION_FAILURE:
            return @"SD_NOT_AVAILABLE_GW_CONNECTION_FAILURE";
        case SD_NOT_AVAILABLE_NO_DATA_CONNECTION:
            return @"SD_NOT_AVAILABLE_NO_DATA_CONNECTION";
        case SD_NOT_AVAILABLE_CONNECTION_TIMEOUT:
            return @"SD_NOT_AVAILABLE_CONNECTION_TIMEOUT";
        case SD_NOT_AVAILABLE_CONNECTION_LOST:
            return @"SD_NOT_AVAILABLE_CONNECTION_LOST";
        case SD_NOT_AVAILABLE_DNS_ERROR:
            return @"SD_NOT_AVAILABLE_DNS_ERROR";
        case SD_NOT_AVAILABLE_APP_TRANSPORT_SECURITY_ERROR:
            return @"SD_NOT_AVAILABLE_APP_TRANSPORT_SECURITY_ERROR";
        case SD_NOT_AVAILABLE_REASON_UNKNOWN:
            return @"SD_NOT_AVAILABLE_REASON_UNKNOWN";
        default:
            return @"SD_NOT_AVAILABLE_REASON_UNKNOWN";
    }
}

@end
