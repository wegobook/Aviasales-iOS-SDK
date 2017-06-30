//
//  ASTSearchFormPassengersView.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

@interface ASTSearchFormPassengersView : UIView

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *icons;

@property (weak, nonatomic) IBOutlet UILabel *adultsLabel;
@property (weak, nonatomic) IBOutlet UILabel *childrenLabel;
@property (weak, nonatomic) IBOutlet UILabel *infantsLabel;
@property (weak, nonatomic) IBOutlet UILabel *travelClassLabel;

@property (nonatomic, copy) void (^tapAction)(UIView *sender);

@end
