//
//  JRViewController.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRViewController.h"
#import "UIImage+JRUIImage.h"
#import "JRColorScheme.h"

@interface JRViewController ()

@property (weak, nonatomic) UIButton *menuButton;

@end


@implementation JRViewController

- (void)viewDidLoad
{
	[super viewDidLoad];
    
	[self setTitle:NSStringFromClass(self.class)];
	[self updateBackgroundColor];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	[self.navigationController.navigationBar setTranslucent:NO];
	[self.navigationController.navigationBar.layer removeAllAnimations];
    
    if (UIAccessibilityIsVoiceOverRunning()) {
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
        if (self.navigationItem.titleView) {
            UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.navigationItem.titleView.accessibilityLabel);
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    
    _viewIsVisible = NO;
    
    if (iPhone()) {
        [self.navigationController.navigationBar.layer removeAllAnimations];
    }
}

- (void)updateBackgroundColor
{
	[self.view setBackgroundColor:[JRColorScheme mainBackgroundColor]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    _viewIsVisible = YES;
}

- (BOOL)shouldShowNavigationBar {
    return YES;
}

@end
