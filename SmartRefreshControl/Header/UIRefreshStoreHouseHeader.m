//
//  UIRefreshStoreHouseHeader.m
//  Refresh
//
//  Created by Teeyun on 2021/2/1.
//  Copyright © 2021 Teeyun. All rights reserved.
//

#import "UIRefreshStoreHouseHeader.h"

#import "ValueAnimator.h"
#import "StoreHousePath.h"

#define toAlpha                     0.4f
#define fromAlpha                   1.0f
#define darkAlpha                   0.4f
#define internalAnimationFactor     0.7f
#define loadingAniItemDuration      0.4f
#define DEFAULT_SCALE               1.0f
#define DEFAULT_PADDING             1.5f

@interface UIRefreshStoreHouseHeader ()

@property (nonatomic, assign) CGFloat scale;
//@property (nonatomic, assign) CGFloat dropHeight;
@property (nonatomic, assign) CGFloat horzontalRandomness;

//@property (nonatomic, assign) CGFloat progress;
@property (nonatomic, assign) CGFloat padding;
@property (nonatomic, assign) CGRect linesRect;

@property (nonatomic, strong) UIColor *colorText;

//@property (nonatomic, assign) BOOL isInLoading;

@property (nonatomic, strong) NSTimer *timerLoading;
@property (nonatomic, strong) ValueAnimator *animatorLoading;
@property (nonatomic, strong) ValueAnimator *animatorFinishing;

@property (nonatomic, copy) NSArray<StoreHouseLine*> *lines;
@end

@implementation UIRefreshStoreHouseHeader

+ (instancetype)newWithString:(NSString *)string {
    return [self newWithString:string scale:DEFAULT_SCALE];
}

+ (instancetype)newWithString:(NSString *)string scale:(CGFloat)scale {
    UIRefreshStoreHouseHeader* header = [self new];
    if (header) {
        [header initLinesWithString:string scale:scale];
    }
    return header;
}

+ (instancetype)newWithString:(NSString *)string scale:(CGFloat)scale padding:(CGFloat)padding {
    UIRefreshStoreHouseHeader* header = [self new];
    if (header) {
        [header initLinesWithString:string scale:scale padding:padding];
    }
    return header;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initLinesWithString:@"store house"];
    }
    return self;
}

- (void)initLinesWithString:(NSString *)string {
    [self initLinesWithString:string scale:DEFAULT_SCALE];
}

- (void)initLinesWithString:(NSString *)string scale:(CGFloat)scale {
    [self initLinesWithString:string scale:scale padding:DEFAULT_PADDING];
}

- (void)initLinesWithString:(NSString *)string scale:(CGFloat)scale padding:(CGFloat)padding {
    [self setLines:[StoreHousePath linesFrom:string scale:scale space:10]];
    [self setPadding:padding];
    [self updateLinesRect];
}

- (void)initLinesWithArray:(NSArray<NSString *> *)array {
    [self initLinesWithArray:array padding:0.5];
}

- (void)initLinesWithArray:(NSArray<NSString *> *)array padding:(CGFloat)padding {
    [self setLines:[StoreHousePath linesFromArray:array]];
    [self setPadding:padding];
    [self updateLinesRect];
}

- (void)updateLinesRect {
    CGRect linesRect = CGRectZero;
    for (StoreHouseLine* line in self.lines) {
        linesRect.size.width = MAX(linesRect.size.width, line.end.x);
        linesRect.size.width = MAX(linesRect.size.width, line.start.x);
        linesRect.size.height = MAX(linesRect.size.height, line.end.y);
        linesRect.size.height = MAX(linesRect.size.height, line.start.y);
    }
    CGFloat padding = self.padding > 5 ? self.padding : self.padding * linesRect.size.height;
    
    linesRect.origin.y = padding;
    linesRect.origin.x = self.width / 2 - linesRect.size.width / 2;
    
    self.linesRect = linesRect;
    self.height = padding * 2 + linesRect.size.height;
//    self.dropHeight = self.height;
}

/**
 * 初始化参数
 */
- (void)setUpComponent {
    [super setUpComponent];

    self.opaque = FALSE;
    
    self.scrollMode = UISmartScrollModeStretch;
    self.colorText = [UIColor whiteColor];
    self.colorAccent = [UIColor whiteColor];
    self.colorPrimary = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0];
    
//    self.loadingAniDuration = 1.f;
//    self.loadingAniSegDuration = 1.f;
    
    self.lineWidth = 2;
    
    self.enableFadeAnimation = TRUE;
    self.enableReverseFlash = FALSE;
    
    self.padding = DEFAULT_PADDING;
}

- (void)setEnableFadeAnimation:(BOOL)enableFadeAnimation {
    _enableFadeAnimation = enableFadeAnimation;
    self.finishDuration = enableFadeAnimation * 0.5;
}

- (void)onScrollingWithOffset:(CGFloat)offset percent:(CGFloat)percent drag:(BOOL)isDragging {
    [self setNeedsDisplay];
    if (self.status != UIRefreshStatusFinish) {
        [self updateLinesWithProgress:percent];
    }
}

- (void)onStartAnimationWhenRealeasing {
    [super onStartAnimationWhenRealeasing];
    
    [self setAnimatorLoading:[ValueAnimator newWithTarget:self selector:@selector(onAnimationLoading:)]];
    [self.animatorLoading setRepeatCount:INFINITY];
    [self.animatorLoading start];
    
    SEL action = @selector(onAnimationTimer);
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.075 target:self selector:action userInfo:nil repeats:TRUE];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [self setTimerLoading:timer];
}

- (CGFloat)onRefreshFinishing:(BOOL)success {
    if (!success) {
        return 0;
    }
    [self setAnimatorFinishing:[ValueAnimator newWithTarget:self selector:@selector(onAnimationFinishing:)]];
    [self.animatorFinishing setFrom:1 to:0];
    [self.animatorFinishing setDuration:self.finishDuration*3];
    [self.animatorFinishing start];
    return self.finishDuration;
}

- (void)onAnimationTimer {
    static NSUInteger index = 0;
    if (self.isRefreshing) {
        if (index < self.lines.count) {
            self.lines[_enableReverseFlash?(self.lines.count - ++index):index++].alpha = 1;
        } else if (++index - self.lines.count == 2){
            index = 0;
        }
    } else {
        index = 0;
        [self.timerLoading invalidate];
        [self setTimerLoading:nil];
    }
}

- (void)onAnimationLoading:(ValueAnimator*) animator {
    if (self.isRefreshing) {
        for (StoreHouseLine* line in self.lines) {
            if (line.alpha > darkAlpha) {
                line.alpha -= 0.01;
            }
        }
        [self setNeedsDisplay];
    } else {
        [animator stop];
    }
}

- (void)onAnimationFinishing:(ValueAnimator*) animator {
    if (self.status == UIRefreshStatusFinish) {
//        NSLog(@"onAnimationFinishing = %@", @(animator.value));
        [self updateLinesWithProgress:animator.value];
        [self setNeedsDisplay];
    } else {
        [animator stop];
    }
}

- (void)setFrame:(CGRect)frame {
    if (_lines.count && frame.size.width != self.frame.size.width) {
        _linesRect.origin.x = frame.size.width / 2 - _linesRect.size.width / 2;
    }
    [super setFrame:frame];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    const CGFloat width = self.width;
    const CGFloat height = self.dragOffset;
    const CGContextRef context = UIGraphicsGetCurrentContext();

    [self.colorPrimary setFill];
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    
    CGContextSetLineWidth(context, self.lineWidth);
    CGContextTranslateCTM(context, self.linesRect.origin.x , self.linesRect.origin.y);
    
    for (StoreHouseLine* line in self.lines) {
        [[self.colorAccent colorWithAlphaComponent:line.alpha] setStroke];
        CGContextSaveGState(context);
        CGContextConcatCTM(context, line.transform);
        CGContextMoveToPoint(context, line.start.x, line.start.y);
        CGContextAddLineToPoint(context, line.end.x, line.end.y);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
    }
    
    if (height <= 0) {
        NSLog(@"%@.drawRect.height=%@ !", self.class, @(height));
    }
}

- (void)updateLinesWithProgress:(CGFloat)progress
{
    for (NSUInteger i = 0, len = self.lines.count; i < len; i++) {
        CGFloat paddingStart = (1 - internalAnimationFactor) / len * i;
        CGFloat paddingEnd = 1 - internalAnimationFactor - paddingStart;
        
        StoreHouseLine* line = self.lines[i];
        if (progress == 1 || progress >= 1 - paddingEnd) {
            line.alpha = self.isRefreshing ? line.alpha:darkAlpha;
            line.transform = CGAffineTransformIdentity;
        } else if (progress == 0) {
            self.transform = CGAffineTransformMakeTranslation(line.offset*self.width, -self.expandHeight);
        } else if (!self.isRefreshing) {
            CGFloat realProgress;
            if (progress <= paddingStart)
                realProgress = 0;
            else
                realProgress = MIN(1, (progress - paddingStart)/internalAnimationFactor);
            line.transform = CGAffineTransformMakeTranslation(line.offset*self.width*(1-realProgress), -self.expandHeight*(1-realProgress));
            line.transform = CGAffineTransformTranslate(line.transform, line.middle.x, line.middle.y);
            line.transform = CGAffineTransformRotate(line.transform, M_PI*(realProgress));
            line.transform = CGAffineTransformScale(line.transform, realProgress, realProgress);
            line.transform = CGAffineTransformTranslate(line.transform, -line.middle.x, -line.middle.y);
            line.alpha = realProgress * darkAlpha;
        }
    }
}
@end
