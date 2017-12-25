#import "HLDatePickerVC.h"
#import "HLDatePickerMonthItem.h"
#import "JRDatePickerDayCell.h"
#import "JRDatePickerMonthHeaderReusableView.h"
#import "DateUtil.h"
#import "HLAlertsFabric.h"

static NSString *kDayCellIdentifier = @"JRDatePickerDayCell";
static NSString *kMonthReusableHeaderViewIdentifier = @"JRDatePickerMonthHeaderReusableView";

@interface HLDatePickerVC ()<UITableViewDataSource, UITableViewDelegate, HLDatePickerStateObjectActionDelegate>

@property (nonatomic, assign) BOOL needsToScrollToSelectedDates;

@end

@implementation HLDatePickerVC

- (void)viewDidLoad
{
	[super viewDidLoad];

    [self.searchInfo updateExpiredDates];
    
	[self registerNibs];
	self.title = NSLS(@"HL_LOC_DATE_PICKER_TITLE");
	
	self.stateObject = [[HLDatePickerStateObject alloc] initWithDelegate:self];
	self.stateObject.firstSelectedDate = self.searchInfo.checkInDate;
	self.stateObject.secondSelectedDate = self.searchInfo.checkOutDate;
	[self buildTable];

    self.needsToScrollToSelectedDates = YES;
    [self disableScrollForInteractivePopGesture:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
    [self.tableView reloadData];
    
    if (self.needsToScrollToSelectedDates) {
        [self.tableView scrollToRowAtIndexPath:self.stateObject.indexPathToScroll atScrollPosition:UITableViewScrollPositionTop animated:NO];
        self.needsToScrollToSelectedDates = NO;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    [_tableView flashScrollIndicators];
}

#pragma mark - Private methods

- (void)registerNibs
{
    [_tableView registerClass:[JRDatePickerDayCell class] forCellReuseIdentifier:kDayCellIdentifier];

    UINib *headerNib = [UINib nibWithNibName:kMonthReusableHeaderViewIdentifier bundle:nil];
    [_tableView registerNib:headerNib forHeaderFooterViewReuseIdentifier:kMonthReusableHeaderViewIdentifier];
}

- (void)buildTable
{
	NSMutableArray *datesToRepresent = [NSMutableArray new];
    
	if (!_stateObject.borderDate) {
        _stateObject.borderDate = [DateUtil borderDate];
	}

    NSUInteger counter = [DateUtil isFirstDayOfMonth:_stateObject.lastAvalibleForSearchDate] ? 11 : 12;

    NSDate *firstMonth = [DateUtil firstDayOfMonth:[DateUtil resetTimeForDate:[DateUtil borderDate]]];

	[datesToRepresent addObject:firstMonth];
	for (NSUInteger i = 1; i <= counter; i++) {
		NSDate *prevMonth = datesToRepresent[i - 1];
		
		[datesToRepresent addObject:[DateUtil firstDayOfNextMonthForDate:prevMonth]];
	}
    
	for (NSDate *date in datesToRepresent) {
		[_stateObject.monthItems addObject:[HLDatePickerMonthItem monthItemWithFirstDateOfMonth:date stateObject:_stateObject]];
	}
	[_stateObject updateSelectedDatesRange];
}

#pragma mark - JRDatePickerStateObjectActionDelegate Methods

- (void)dateWasSelected:(NSDate *)date
{
    [self.stateObject selectDate:date];
	[self.stateObject updateSelectedDatesRange];
    [self.tableView reloadData];

	if ([self.stateObject areDatesSelectedProperly]) {
        self.tableView.userInteractionEnabled = NO;
        HLDatePickerStateObject *savedState = [self.stateObject copy];

        @weakify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            [self goBackWithStateObject:savedState];
		});
    } else {
        [self.stateObject restrictCheckoutDate];
    }
}

- (void)showRestrictionToast
{
    HLToastView * toast = [HLAlertsFabric datesRestrictionToast];
    [self showToast:toast animated:YES];
}

#pragma mark - UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return self.stateObject.monthItems.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	JRDatePickerMonthItem *monthItem = (_stateObject.monthItems)[section];
	
    return monthItem.weeks.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JRDatePickerDayCell *cell = [tableView dequeueReusableCellWithIdentifier:kDayCellIdentifier];
	JRDatePickerMonthItem *monthItem = (_stateObject.monthItems)[indexPath.section];
	NSArray *dates = (monthItem.weeks)[indexPath.row];
	[cell setDatePickerItem:monthItem dates:dates];
	
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
	JRDatePickerMonthHeaderReusableView *sectionHeaderView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kMonthReusableHeaderViewIdentifier];
	[sectionHeaderView setMonthItem:(_stateObject.monthItems)[section]];
	
    return sectionHeaderView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 13.0;
}

- (UIView *) tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	return [UIView new];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
	return 60.0;
}

- (void)goBackWithStateObject:(HLDatePickerStateObject *)state
{
    if ([state areDatesSelectedProperly]) {
        self.searchInfo.checkInDate = state.firstSelectedDate;
        self.searchInfo.checkOutDate = state.secondSelectedDate;
    }

    [self.delegate datesSelected:self];

    [super goBack];
}

#pragma mark - IBActions

- (void)goBack
{
    [self goBackWithStateObject:self.stateObject];
}

@end
