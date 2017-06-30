//
//  JRAirportSearchResultVC.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

@class JRAirportPickerItem;

@interface JRAirportSearchResultVC : UIViewController <UISearchResultsUpdating>

- (instancetype)initWithSelectionBlock:(void (^)(JRAirportPickerItem *))selectionBlock;

@end
