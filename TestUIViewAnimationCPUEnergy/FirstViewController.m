//
//  FirstViewController.m
//  TestUIViewAnimationCPUEnergy
//
//  Created by ys on 2019/3/11.
//  Copyright © 2019 mg. All rights reserved.
//

#import "FirstViewController.h"

@interface FirstViewController ()

@property (weak, nonatomic) IBOutlet UIView *redView;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self startAction];
}

- (void)startAction
{
    CGFloat x = 0;
    if (self.redView.frame.origin.x != 375) {
        x = 375;
    }
    [UIView animateWithDuration:5 animations:^{
        self.redView.frame = CGRectMake(x, self.redView.frame.origin.y, self.redView.frame.size.width, self.redView.frame.size.height);
    } completion:^(BOOL finished) {
        if (finished) {
            [self startAction];
        }µ
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startAction];
}

- (void)dealloc
{
    NSLog(@"todo -- %@", self);
}

@end
