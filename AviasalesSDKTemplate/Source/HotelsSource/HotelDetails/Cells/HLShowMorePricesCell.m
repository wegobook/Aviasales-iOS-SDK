#import "HLShowMorePricesCell.h"

@interface HLShowMorePricesCell()
@property (strong, nonatomic) SeparatorView *separatorView;
@end

@implementation HLShowMorePricesCell

-(void)awakeFromNib
{
    [super awakeFromNib];

    self.titleLabel.font = [UIFont systemFontOfSize:17.0];
    self.titleLabel.textColor = [JRColorScheme actionColor];
    self.separatorView = [SeparatorView new];
    [self.separatorView attachToView:self edge:ALEdgeBottom insets:UIEdgeInsetsMake(0, 15, 0, 15)];
}

- (void)setShouldShowSeparator:(BOOL)shouldShowSeparator
{
    self.separatorView.hidden = !shouldShowSeparator;
}

@end
