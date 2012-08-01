#import <Foundation/Foundation.h>

typedef void (^ClockBlock)();

@interface Clock : NSObject {
    @private
      NSTimer *timer;
}

@property (atomic, strong) ClockBlock startBlock;
@property (atomic, strong) ClockBlock stopBlock;
@property (atomic, strong) ClockBlock clockBlock;

- (id)initWithStartBlock:(ClockBlock)start
                   clock:(ClockBlock)clock
                    stop:(ClockBlock)stop;

- (void)startAtInterval:(NSTimeInterval)timeInterval;
- (void)adjustToInterval:(NSTimeInterval)timeInterval;
- (void)stop;

@end
