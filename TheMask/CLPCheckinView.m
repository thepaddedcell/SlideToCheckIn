//
//  CLPCheckinView.m
//  Clipp
//
//  Created by Craig Stanford on 17/12/12.
//  Copyright (c) 2012 Clipp Pty Ltd. All rights reserved.
//

#import "CLPCheckinView.h"
#import <QuartzCore/QuartzCore.h>
#import "CAKeyframeAnimation+AHEasing.h"
#import "easing.h"

#define kViewGutter 7
#define kCheckInText @"Slide to Check In"
#define kCheckOutText @"Slide to Check Out"

@interface CLPCheckinView ()

@property (nonatomic, strong) UIImageView* slidingImageView;
@property (nonatomic, strong) UIImageView* backgroundImageView;
@property (nonatomic, strong) UIImageView* glowView;
@property (nonatomic, strong) UILabel* checkInLabel;
@property (nonatomic, strong) UILabel* checkInWhiteLabel;

@property (nonatomic, strong) CAAnimation* maskAnimation;


@property (nonatomic) CGFloat startX;
@property (nonatomic) CGFloat endX;

@property (nonatomic) BOOL checkedIn;

@end

@implementation CLPCheckinView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kViewGutter, 0, 306, 55)];
        self.backgroundImageView.backgroundColor = [UIColor clearColor];
        self.backgroundImageView.image = [UIImage imageNamed:@"check-in_groove"];
        [self addSubview:self.backgroundImageView];
        
        
        self.checkInWhiteLabel = [[UILabel alloc] initWithFrame:self.backgroundImageView.frame];
        self.checkInWhiteLabel.font = [UIFont systemFontOfSize:20.f];
        self.checkInWhiteLabel.textAlignment = NSTextAlignmentCenter;
        self.checkInWhiteLabel.text = kCheckInText;
        self.checkInWhiteLabel.backgroundColor = [UIColor clearColor];
        self.checkInWhiteLabel.textColor = [UIColor colorWithWhite:.76f alpha:1.f];
        [self addSubview:self.checkInWhiteLabel];

        self.checkInLabel = [[UILabel alloc] initWithFrame:self.backgroundImageView.frame];
        CALayer* maskingLayer = [CALayer layer];
        CGRect maskFrame = CGRectMake(0, 55, 640, 55);
        maskingLayer.frame = maskFrame;
        [maskingLayer setContents:(id)[[UIImage imageNamed:@"check-in_text-mask"] CGImage]];
        self.checkInLabel.layer.mask = maskingLayer;
        
        self.checkInLabel.font = [UIFont systemFontOfSize:20.f];
        self.checkInLabel.textAlignment = NSTextAlignmentCenter;
        self.checkInLabel.text = kCheckInText;
        self.checkInLabel.backgroundColor = [UIColor clearColor];
        self.checkInLabel.textColor = [UIColor grayColor];
        [self addSubview:self.checkInLabel];
        
        self.slidingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kViewGutter, 0, 56, 56)];
        self.glowView = [[UIImageView alloc] initWithFrame:self.slidingImageView.frame];
        
        self.glowView.image = [UIImage imageNamed:@"check-in_disc"];
        self.glowView.clipsToBounds = NO;
        self.glowView.backgroundColor = [UIColor clearColor];
        self.glowView.layer.shadowOffset = CGSizeMake(0, 0);
        self.glowView.layer.masksToBounds = NO;
        self.glowView.layer.shadowRadius = 6.f;
        self.glowView.layer.shadowOpacity = 0.5f;
        self.glowView.alpha = 0.f;
        self.glowView.layer.shadowColor = [[UIColor colorWithRed:40.f/255.f green:137.f/255.f blue:180.f/255.f alpha:1.f] CGColor];
        [self addSubview:self.glowView];
        
        
        self.slidingImageView.backgroundColor = [UIColor clearColor];
        self.slidingImageView.userInteractionEnabled = YES;
        self.slidingImageView.image = [UIImage imageNamed:@"check-in_disc"];
        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panSlidingView:)];
        [self.slidingImageView addGestureRecognizer:panGesture];
        [self addSubview:self.slidingImageView];
        
        //For panning
        self.startX = self.slidingImageView.frame.origin.x;
        self.endX = self.backgroundImageView.frame.size.width + self.backgroundImageView.frame.origin.x - self.slidingImageView.frame.size.width;
    }
    return self;
}

- (void)startAnimatingCheckin
{
    CALayer *layer= self.checkInLabel.layer.mask;
    [CATransaction begin];
    [CATransaction setValue:[NSNumber numberWithFloat:1.75f]
                     forKey:kCATransactionAnimationDuration];
    
    CGPoint fromPoint = CGPointMake(layer.frame.origin.x, layer.frame.origin.y/2);
    CGPoint toPoint = CGPointMake(self.checkInLabel.frame.origin.x + self.checkInLabel.frame.size.width,
                                  layer.frame.origin.y/2);
    
    self.maskAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"
                                                                  function:LinearInterpolation
                                                                 fromPoint:fromPoint
                                                                   toPoint:toPoint];
    [self.maskAnimation setRepeatCount:HUGE_VALF];
    [self.maskAnimation setDelegate:self];
    
    [layer addAnimation:self.maskAnimation forKey:@"position"];
    
    [CATransaction commit];
}

- (void)panSlidingView:(UIPanGestureRecognizer*)gesture
{
    //Don't do anything if we're checked in.
    if (self.checkedIn) {
        [self handlePanningLeft:gesture];
    } else {
        [self handlePanningRight:gesture];
    }
}

- (void)handlePanningRight:(UIPanGestureRecognizer*)gesture
{
    CGPoint translatedPoint = [gesture translationInView:self];
    
    CGRect frame = self.slidingImageView.frame;
    frame.origin.x = self.startX + translatedPoint.x;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.startX = self.slidingImageView.frame.origin.x;
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (frame.origin.x + frame.size.width >= self.backgroundImageView.frame.origin.x + self.backgroundImageView.frame.size.width - frame.size.width) {
                //we're locked in, so start pulsing animation or something
                self.checkedIn = YES;
                
                frame.origin.x = self.endX;
                [UIView animateWithDuration:0.5f animations:^{
                    self.slidingImageView.frame = frame;
                    self.checkInLabel.alpha = 1.f;
                }];
                
                self.glowView.frame = self.slidingImageView.frame;
                [UIView animateWithDuration:1.f delay:0.5f options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
                    self.glowView.alpha = fabsf(self.glowView.alpha - 1);
                } completion:nil]; //this animation never really completes until you push it off screen
                if ([self.delegate respondsToSelector:@selector(checkinViewRequestCheckin:)]) {
                    [self.delegate checkinViewRequestCheckin:self];
                }
                self.checkInLabel.text = kCheckOutText;
                self.checkInWhiteLabel.text = kCheckOutText;
            } else {
                //it's not locked in, so animate back
                [self resetToCheckedOut];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if (frame.origin.x + frame.size.width <= self.backgroundImageView.frame.origin.x + self.backgroundImageView.frame.size.width &&
                frame.origin.x > 0) {
                self.slidingImageView.frame = frame;
                self.checkInLabel.alpha = 0.f;
            }
        }
        default:
            break;
    }
}

- (void)handlePanningLeft:(UIPanGestureRecognizer*)gesture
{
    CGPoint translatedPoint = [gesture translationInView:self];
    
    CGRect frame = self.slidingImageView.frame;
    frame.origin.x = self.startX + translatedPoint.x;
    
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            self.startX = self.endX;
            self.glowView.hidden = YES;
            break;
        case UIGestureRecognizerStateEnded:
        {
            if (frame.origin.x <= self.backgroundImageView.frame.origin.x + frame.size.width) {
                self.checkedIn = NO;
                frame.origin.x = self.backgroundImageView.frame.origin.x;
                [UIView animateWithDuration:0.5f animations:^{
                    self.slidingImageView.frame = frame;
                    self.checkInLabel.alpha = 1.f;
                }];
                if ([self.delegate respondsToSelector:@selector(checkinViewRequestCheckout:)]) {
                    [self.delegate checkinViewRequestCheckout:self];
                }
                self.checkInLabel.text = kCheckInText;
                self.checkInWhiteLabel.text = kCheckInText;
            } else {
                //it's not locked in, so animate back
                [self resetToCheckedIn];
            }
            break;
        }
        case UIGestureRecognizerStateChanged:
        {
            if (frame.origin.x + frame.size.width <= self.backgroundImageView.frame.origin.x + self.backgroundImageView.frame.size.width &&
                frame.origin.x > 0) {
                self.slidingImageView.frame = frame;
                self.checkInLabel.alpha = 0.f;
            }
        }
        default:
            break;
    }
}

- (void)resetToCheckedIn
{
    CGRect frame = self.slidingImageView.frame;
    frame.origin.x = self.endX;
    [UIView animateWithDuration:0.3f animations:^{
        self.slidingImageView.frame = frame;
        self.checkInLabel.alpha = 1.f;
    } completion:^(BOOL finished) {
        self.glowView.hidden = NO;
        self.checkInLabel.text = kCheckOutText;
        self.checkInWhiteLabel.text = kCheckOutText;
    }];
}

- (void)resetToCheckedOut
{
    CGRect frame = self.slidingImageView.frame;
    frame.origin.x = self.backgroundImageView.frame.origin.x;
    [UIView animateWithDuration:0.3f animations:^{
        self.slidingImageView.frame = frame;
        self.checkInLabel.alpha = 1.f;
    } completion:^(BOOL finished) {
        self.checkInLabel.text = kCheckInText;
        self.checkInWhiteLabel.text = kCheckInText;
        self.glowView.hidden = YES;
    }];
}

@end
