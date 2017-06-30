#import "HLCommonVC.h"
#import "HLDatePickerStateObject.h"

@class HLDatePickerVC, DayOfWeekView;

@protocol HLDatePickerVCDelegate <NSObject>
- (void)datesSelected:(HLDatePickerVC *)datePickerVC;
@end


@interface HLDatePickerVC : HLCommonVC

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) id<HLDatePickerVCDelegate> delegate;
@property (strong, nonatomic, readonly) DayOfWeekView *dayOfWeekView;
@property (weak, nonatomic) IBOutlet UIView *dayOfWeekBackgroundView;

@property (nonatomic, strong) HLSearchInfo *searchInfo;
@property (nonatomic, strong) HLDatePickerStateObject *stateObject;

@end
