#import "HLPlaceholderView.h"

@implementation HLPlaceholderView

- (void)awakeFromNib
{
	[super awakeFromNib];
	
//    self.titleLabel.font = [UIFont appMediumFontWithSize:20.0];
//    self.descriptionLabel.font = [UIFont appRegularFontWithSize:14.0];
//    self.button.titleLabel.font = [UIFont appMediumFontWithSize:14.0];
//    [self.button setTitleColor:[[ColorScheme current] mainAppColor] forState:UIControlStateNormal];
}

- (void)updateConstraints
{
    [super updateConstraints];

    if (iPad()) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        self.topImageConstraint.constant = UIInterfaceOrientationIsPortrait(orientation) ? -5.0 : -75.0;
    }
}


#pragma mark - Actions

- (IBAction)dropFilters
{
    if ([self.delegate respondsToSelector:@selector(dropFilters)]) {
        [self.delegate dropFilters];
    }
}

- (IBAction)searchAction
{
    if ([self.delegate respondsToSelector:@selector(moveToNewSearch)]) {
        [self.delegate moveToNewSearch];
    }
}

@end
