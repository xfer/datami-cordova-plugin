#import "AppDelegate.h"
#import "SmiSdk.h"

@interface AppDelegate (notification)
	- (id) getCommandInstance:(NSString*)className;
@property (strong, nonatomic) SmiResult *smiResult;
@property (strong, nonatomic) NSString *apiKey;
@end
