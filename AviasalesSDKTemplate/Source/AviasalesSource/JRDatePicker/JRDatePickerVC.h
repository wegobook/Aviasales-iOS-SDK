//
//  JRDatePickerVC.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRViewController.h"
#import "JRDatePickerEnums.h"

typedef void (^JRDatePickerVCSelecionBlock)(NSDate *selectedDate);

@interface JRDatePickerVC : JRViewController

- (instancetype)initWithMode:(JRDatePickerMode)mode
                  borderDate:(NSDate *)borderDate
                   firstDate:(NSDate *)firstDate
                  secondDate:(NSDate *)secondDate
              selectionBlock:(JRDatePickerVCSelecionBlock)selectionBlock;

@end
