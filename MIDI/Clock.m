#import "Clock.h"

@implementation Clock

@synthesize clockStartBlock;
@synthesize clockStopBlock;
@synthesize clockTickBlock;

- (id)initWithStartBlock:(ClockBlock)start clock:(ClockBlock)clock stop:(ClockBlock)stop;
{
    self = [super init];
    if( self )
    {
        [self setClockStartBlock:start];
        [self setClockStopBlock:stop];
        [self setClockTickBlock:clock];
    }

    return self;
}

- (void)stopInternalClock
{
    if (timer)
    {
        [timer invalidate];
        timer = nil;
        
        self.clockStopBlock();
    }
}

- (NSTimer *)generateTimerForInterval:(NSTimeInterval)timeInterval
{
    return [NSTimer scheduledTimerWithTimeInterval: timeInterval
                                            target: self
                                          selector:@selector(onTick:)
                                          userInfo: nil repeats:YES];
}

- (void)runInternalClock:(NSTimeInterval)timeInterval
{
    if (timer)
    {
        [timer invalidate];
        timer = nil;
    }
    
    self.clockStartBlock();
    
    timer = [self generateTimerForInterval:timeInterval];
}

- (void)adjustInternalClock:(NSTimeInterval)timeInterval
{
    if (timer)
    {
        [timer invalidate];
        timer = [self generateTimerForInterval:timeInterval];
    }
}

- (void)onTick:(NSTimer *)source
{
    self.clockTickBlock();
}

@end
