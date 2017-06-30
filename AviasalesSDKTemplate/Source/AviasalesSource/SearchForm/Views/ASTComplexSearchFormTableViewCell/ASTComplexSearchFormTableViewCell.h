//
//  ASTComplexSearchFormTableViewCell.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "ASTComplexSearchFormTableViewCellSegment.h"

@interface ASTComplexSearchFormTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet ASTComplexSearchFormTableViewCellSegment *origin;
@property (weak, nonatomic) IBOutlet ASTComplexSearchFormTableViewCellSegment *destination;
@property (weak, nonatomic) IBOutlet ASTComplexSearchFormTableViewCellSegment *departure;

@end
