#import "HLNoSearchResultsPlaceholderView.h"

@implementation HLNoSearchResultsPlaceholderView

- (void)updateConstraints
{
    [super updateConstraints];

    if (iPhone35Inch()) {
        self.topImageConstraint.constant = 85.0;
    } else if (iPhone4Inch()) {
        self.topImageConstraint.constant = 128.0;
    } else if (iPhone47Inch()) {
        self.topImageConstraint.constant = 178.0;
    } else if (iPhone55Inch()) {
        self.topImageConstraint.constant = 212.0;
    } else if (iPad()) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        self.topImageConstraint.constant = UIInterfaceOrientationIsPortrait(orientation) ? 200 : 130;
    }

    self.titleLabel.text = NSLS(@"HL_NO_RESULTS_TITLE");
    self.descriptionLabel.text = NSLS(@"HL_NO_RESULTS_DESCRIPTION");
    [self.button setTitle:NSLS(@"HL_NEW_SEARCH_BUTTON") forState:UIControlStateNormal];
    [self.button setTitleColor:[JRColorScheme actionColor] forState:UIControlStateNormal];
}

@end
