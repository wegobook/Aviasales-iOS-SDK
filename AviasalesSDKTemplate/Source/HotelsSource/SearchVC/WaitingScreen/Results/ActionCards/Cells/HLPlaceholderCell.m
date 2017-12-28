#import "HLPlaceholderCell.h"

@interface HLPlaceholderCell ()

@property (nonatomic, weak) IBOutlet UIButton *resetButton;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;

@end

@implementation HLPlaceholderCell

- (void)awakeFromNib
{
    [super awakeFromNib];

//    self.resetButton.titleLabel.font = [UIFont appMediumFontWithSize:14.0];
//    [self.resetButton setTitleColor:[[ColorScheme current] mainAppColor] forState:UIControlStateNormal];
//    self.titleLabel.font = [UIFont appMediumFontWithSize:18.0];
}

- (IBAction)dropFilters
{
    [self.item.filter dropFilters];
}

@end
