#import "HLNoFilterResultsPlaceholderView.h"

@implementation HLNoFilterResultsPlaceholderView

- (void)layoutSubviews
{
    CGFloat navbarHeight = 64;
    if (iPhone35Inch()) {
        self.topImageConstraint.constant = 50.0 + navbarHeight;
    } else if (iPhone4Inch()) {
        self.topImageConstraint.constant = 134.0 + navbarHeight;
    } else if (iPhone47Inch()) {
        self.topImageConstraint.constant = 183.0 + navbarHeight;
    } else if (iPhone55Inch()) {
        self.topImageConstraint.constant = 211.0 + navbarHeight;
    }

    [super layoutSubviews];
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    self.titleLabel.font = [UIFont systemFontOfSize:20.0];
    self.button.titleLabel.font = [UIFont systemFontOfSize:14.0];

    self.titleLabel.text = NSLS(@"HL_NO_FILTER_RESULTS_TITLE");
    self.descriptionLabel.text = NSLS(@"HL_NO_FILTER_RESULTS_DESCRIPTION");
    [self.button setTitle:NSLS(@"HL_NO_FILTER_RESULTS_BUTTON") forState:UIControlStateNormal];

    [self.button setTitleColor:[JRColorScheme actionColor] forState:UIControlStateNormal];
}

@end
