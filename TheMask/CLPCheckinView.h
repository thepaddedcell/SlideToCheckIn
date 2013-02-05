//
//  CLPCheckinView.h
//  Clipp
//
//  Created by Craig Stanford on 17/12/12.
//  Copyright (c) 2012 Clipp Pty Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CLPCheckinViewDelegate;

@interface CLPCheckinView : UIView

@property (nonatomic, weak) id <CLPCheckinViewDelegate> delegate;

- (void)startAnimatingCheckin;
- (void)resetToCheckedIn;
- (void)resetToCheckedOut;

@end

@protocol CLPCheckinViewDelegate <NSObject>

- (void)checkinViewRequestCheckin:(CLPCheckinView*)view;
- (void)checkinViewRequestCheckout:(CLPCheckinView*)view;

@end
