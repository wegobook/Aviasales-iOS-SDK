#import <UIKit/UIKit.h>

#import "TBMapViewController.h"
#import "HLSingleAnnotationView.h"
#import "FiltersVCDelegate.h"

@class HLSearchInfo;
@class Filter;
@protocol HLResultsViewControllerProtocol;

@interface HLMapVC : TBMapViewController <HLShowHotelProtocol, HLMapViewDelegate, FiltersVCDelegate>

@property (nonatomic, strong) HLSearchInfo *searchInfo;
@property (nonatomic, strong) Filter *filter;
@property (nonatomic, assign) BOOL clusteringEnabled;
@property (nonatomic, weak) IBOutlet UIButton *filtersButton;

- (UIEdgeInsets)mapEdgeInsets;
- (void)variantsFiltered:(NSArray *)variants animated:(BOOL)animated;
- (IBAction)showFullFilters;

@end
