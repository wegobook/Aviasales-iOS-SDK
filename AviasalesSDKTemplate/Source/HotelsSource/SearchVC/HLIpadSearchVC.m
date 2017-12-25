#import "HLIpadSearchVC.h"
#import "DateUtil.h"
#import "HLDatePickerVC.h"

@interface HLIpadSearchVC () <UIPopoverPresentationControllerDelegate, UIPopoverControllerDelegate, KidsPickerDelegate>

@property (nonatomic, weak) IBOutlet UIView *shadowView;

@end

@implementation HLIpadSearchVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.shadowView.backgroundColor = [JRColorScheme searchFormBackgroundColor];
    
    [self.shadowView applyShadowLayer];
}

#pragma mark - Override

- (void)presentCityPicker:(HLCityPickerVC *)cityPickerVC animated:(BOOL)animated
{
    [self customPresentVC:cityPickerVC animated:animated];
}

- (CGSize) kidsPickerPopoverSize
{
    return CGSizeMake(320.0, 320.0);
}

#pragma mark - HLSearchFormDelegate

- (void)showKidsPicker
{
    HLIpadKidsPickerVC *kidsPickerVC = [[HLIpadKidsPickerVC alloc] initWithNibName:@"HLIpadKidsPickerVC" bundle:nil];
    kidsPickerVC.searchInfo = self.searchInfo;
    kidsPickerVC.delegate = self;
    [self presentPopover:kidsPickerVC above:self.searchForm.kidsButton distance:15.0 contentSize:[self kidsPickerPopoverSize] backgroundColor:UIColor.grayColor];
}

- (void)showDatePicker
{
    HLDatePickerVC *datePickerVC = [[HLDatePickerVC alloc] initWithNibName:@"HLDatePickerVC" bundle:nil];
    datePickerVC.searchInfo = self.searchInfo;
    
    [self customPresentVC:datePickerVC animated:YES];
}

#pragma mark - KidsPickerDelegate Methods

- (void)kidsSelected
{
    [self updateControls];
}

@end
