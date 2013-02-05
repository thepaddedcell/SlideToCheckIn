//
//  MOBViewController.m
//  TheMask
//
//  Created by Craig Stanford on 5/02/13.
//  Copyright (c) 2013 Craig Stanford. All rights reserved.
//

#import "MOBViewController.h"
#import "CLPCheckinView.h"

@interface MOBViewController ()

@property (nonatomic, strong) CLPCheckinView* checkinView;

@end

@implementation MOBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.checkinView = [[CLPCheckinView alloc] initWithFrame:CGRectMake(0,
                                                                        self.view.bounds.size.height / 2 - 50,
                                                                        self.view.bounds.size.width,
                                                                        self.view.bounds.size.height)];
    [self.view addSubview:self.checkinView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.checkinView startAnimatingCheckin];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
