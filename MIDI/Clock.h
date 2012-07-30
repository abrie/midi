#import <Foundation/Foundation.h>

typedef void (^ClockBlock)();

@interface Clock : NSObject {
    @private
      NSTimer *timer;
}

@property (atomic, strong) ClockBlock clockStartBlock;
@property (atomic, strong) ClockBlock clockStopBlock;
@property (atomic, strong) ClockBlock clockTickBlock;

- (id)initWithStartBlock:(ClockBlock)start clock:(ClockBlock)clock stop:(ClockBlock)stop;
- (void)runInternalClock:(NSTimeInterval)timeInterval;
- (void)adjustInternalClock:(NSTimeInterval)timeInterval;
- (void)stopInternalClock;

@end
