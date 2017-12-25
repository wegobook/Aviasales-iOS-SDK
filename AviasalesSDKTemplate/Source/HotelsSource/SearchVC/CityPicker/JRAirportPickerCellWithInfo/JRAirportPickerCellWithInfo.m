//
//  JRAirportPickerCellWithInformation.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRAirportPickerCellWithInfo.h"

#define kJRAirportPickerCellWithInfoDisabledActivityIndicatorHorizontalSpace 20
#define kJRAirportPickerCellWithInfoEnabledActivityIndicatorHorizontalSpace 48

@interface JRAirportPickerCellWithInfo ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelHorizontConstaint;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;

@end

@implementation JRAirportPickerCellWithInfo

- (void)awakeFromNib {
    [super awakeFromNib];

    self.locationInfoLabel.text = NSLS(@"JR_AIRPORT_PICKER_SEARCHING_ON_SERVER_TEXT");
}

- (void)startActivityIndicator {
    [_activityIndicatorView startAnimating];
    [_labelHorizontConstaint setConstant:kJRAirportPickerCellWithInfoEnabledActivityIndicatorHorizontalSpace];
}

- (void)stopActivityIndicator {
    [_activityIndicatorView stopAnimating];
    [_labelHorizontConstaint setConstant:kJRAirportPickerCellWithInfoDisabledActivityIndicatorHorizontalSpace];
}

@end
