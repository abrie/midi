#import <SenTestingKit/SenTestingKit.h>
#import "Clock.h"

@interface ClockTests : SenTestCase

@property (nonatomic, strong) Clock *clock;
@property BOOL started;
@property BOOL stopped;
@property NSUInteger ticks;

@end
