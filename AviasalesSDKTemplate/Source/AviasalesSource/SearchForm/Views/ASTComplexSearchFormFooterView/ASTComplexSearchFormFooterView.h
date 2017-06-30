//
//  ASTComplexSearchFormFooterView.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>

@interface ASTComplexSearchFormFooterView : UIView

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;

@property (nonatomic, copy) void (^addAction)(UIButton *sender);
@property (nonatomic, copy) void (^removeAction)(UIButton *sender);

@end
