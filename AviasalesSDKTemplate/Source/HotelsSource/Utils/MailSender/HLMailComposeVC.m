//
//  HLMailComposeVC.m
//  HotelLook
//
//  Created by Anton Chebotov on 23/04/14.
//  Copyright (c) 2014 Anton Chebotov. All rights reserved.
//

#import "HLMailComposeVC.h"

@implementation HLMailComposeVC

- (void) viewWillAppear:(BOOL)animated
{
    [self.parentViewController resignFirstResponder];
    [super viewWillAppear:animated];
	
	[self.view setNeedsLayout];
	[self.view layoutIfNeeded];
}

@end
