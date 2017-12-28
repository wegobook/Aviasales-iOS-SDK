#import "HLCommonVC.h"

@class HLSearchInfo;
@class HLSearchForm;
@class HDKCity;
@class HLCityPickerVC;

@interface HLSearchVC : HLCommonVC

@property (nonatomic, weak) HLSearchForm *searchForm;
@property (nonatomic, strong) HLSearchInfo *searchInfo;

- (void)updateControls;
- (void)tryToStartSearchWithSearchInfo:(HLSearchInfo *)searchInfo;
- (void)performSearchWithSearchInfo:(HLSearchInfo *)searchInfo;
- (void)presentCityPicker:(HLCityPickerVC *)cityPickerVC animated:(BOOL)animated;

- (void)showCityPickerWithText:(NSString *)searchText animated:(BOOL)animated;
- (void)setCityToSearchForm:(HDKCity *)city;

@end
