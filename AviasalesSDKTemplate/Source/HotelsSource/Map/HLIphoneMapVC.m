#import "HLIphoneMapVC.h"
#import "HLFilter.h"
#import "HLSliderCalculatorFactory.h"
#import "HLSliderCalculator.h"

static CGFloat kFreeSpaceBetweenButtons = 15.0;

@interface HLIphoneMapVC () <UIGestureRecognizerDelegate, PriceFilterViewDelegate>

@property (nonatomic, weak) IBOutlet PriceFilterView *priceFilterView;
@property (nonatomic, weak) IBOutlet UIView *priceFilterViewContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *filterButtonWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locateMeViewBottomLayoutConstraint;

@end

@implementation HLIphoneMapVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.priceFilterViewContainer = self.priceFilterView.superview;
    self.mapView.gestureRecognizerDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.filter refreshPriceBounds];
    self.filter.delegate = self;
    self.filtersButton.selected = self.filter.canDropFilters;
    if (self.filter.allVariantsHaveSamePrice) {
        self.priceFilterViewContainer.hidden = YES;
    } else {
        self.priceFilterViewContainer.hidden = NO;
        [self.priceFilterView configureWithFilter:self.filter];
        self.priceFilterView.delegate = self;
    }
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.filterButtonWidth.constant = (self.view.bounds.size.width - 3 * kFreeSpaceBetweenButtons) / 2.0;
    self.locateMeViewBottomLayoutConstraint.constant = self.bottomLayoutGuide.length + 10.0;
}

#pragma mark - Override

- (UIEdgeInsets)mapEdgeInsets
{
    UIEdgeInsets insets = [super mapEdgeInsets];
    insets.top = CGRectGetMaxY(self.priceFilterViewContainer.frame);

    return insets;
}

#pragma mark - PriceFilterViewDelegate

- (void)filterApplied
{
    [self.filter filter];
}

#pragma mark - HLResultsVCDelegate methods

- (void)variantsFiltered:(NSArray *)variants animated:(BOOL)animated
{
    [super variantsFiltered:variants animated:animated];
    
    self.filtersButton.selected = self.filter.canDropFilters;
}

@end
