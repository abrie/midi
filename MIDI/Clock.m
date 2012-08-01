#import "Clock.h"

@implementation Clock

@synthesize startBlock;
@synthesize stopBlock;
@synthesize clockBlock;

- (id)initWithStartBlock:(ClockBlock)start clock:(ClockBlock)clock stop:(ClockBlock)stop;
{
    self = [super init];
    if( self )
    {
        [self setStartBlock:start];
        [self setStopBlock:stop];
        [self setClockBlock:clock];
    }

    return self;
}

- (NSTimer *)generateTimerForInterval:(NSTimeInterval)timeInterval
{
    return [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                            target: self
                                          selector:@selector(atEachInterval:)
                                          userInfo: nil repeats:YES];
}

- (void)stop
{
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
    
    self.stopBlock();
}

- (void)atEachInterval:(NSTimer *)source
{
    self.clockBlock();
}

- (void)adjustToInterval:(NSTimeInterval)timeInterval
{
    if (!timer)
    {
        return;
    }
    
    [timer invalidate];
    timer = [self generateTimerForInterval:timeInterval];
}

- (void)startAtInterval:(NSTimeInterval)timeInterval
{
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
    
    self.startBlock();
    timer = [self generateTimerForInterval:timeInterval];
}

@end
