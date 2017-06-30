#import "HLProfileVC.h"
#import "AviasalesSDKTemplate-Swift.h"
#import "UIViewCell+ReuseIdentifier.h"
#import "Collections+HLNibLoading.h"
#import "UIViewController+UIScrollView.h"

#import "HLEmailSender.h"
#import "HLAlertsFabric.h"
#import "HLAboutFooterView.h"

#import "HLProfileTableItem.h"
#import "HLProfileCurrencyItem.h"
#import "HLProfileCell.h"
#import "HLProfileCurrencyCell.h"
#import "Config.h"

static CGFloat kDefaultHeaderHeight = 20.0f;

@interface HLProfileVC () <UITableViewDataSource, UITableViewDelegate, ProfileTableItemDelegate>

@property (nonatomic, strong) id <ProfileCellFactoryProtocol> cellFactory;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ProfileSections *profileSections;
@property (nonatomic, strong) HLEmailSender *emailSender;

@end

@implementation HLProfileVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLS(@"LOC_SETTINGS_TITLE");

    self.cellFactory =[ProfileCellsFactory new];

    HLAboutFooterView * tableFooterView = LOAD_VIEW_FROM_NIB_NAMED(@"HLAboutFooterView");
    tableFooterView.autoresizingMask = UIViewAutoresizingNone;
    self.tableView.tableFooterView = tableFooterView;

    [self.tableView hl_registerNibWithName:[HLProfileSelectableCell hl_reuseIdentifier]];
    [self.tableView hl_registerNibWithName:[HLProfileCell hl_reuseIdentifier]];
    [self.tableView hl_registerNibWithName:[HLProfileCurrencyCell hl_reuseIdentifier]];

    if (iPad()) {
        [self setScrollViewTouchableArea:self.tableView];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self reloadData];
    [self centerTableViewVertically];
}

- (void)reloadData
{
    self.profileSections = [self.cellFactory createSections:self];
    [self.tableView reloadData];
}

- (void)centerTableViewVertically
{
    if (iPad()) {
        CGFloat footerEmptySpace = 20.0f;
        UIEdgeInsets contentInset = self.tableView.contentInset;
        CGFloat inset = (self.view.frame.size.height - self.tableView.contentSize.height - self.bottomLayoutGuide.length + footerEmptySpace) / 2.0;
        contentInset.top = inset;
        self.tableView.contentInset = contentInset;
    }
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willAnimateRotationToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self centerTableViewVertically];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.profileSections.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    AboutTableSection *sectionObject = self.profileSections.sections[section];
    return sectionObject.items.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AboutTableSection *sectionObject = self.profileSections.sections[indexPath.section];
    HLProfileTableItem *item = sectionObject.items[indexPath.row];

    return item.height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section == 0 ? kDefaultHeaderHeight : ZERO_HEADER_HEIGHT;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    CGFloat result;
    if (section < self.profileSections.sections.count - 1) {
        result = kDefaultHeaderHeight;
        
        AboutTableSection *sectionObject = self.profileSections.sections[section];
        NSString *footerTitle = sectionObject.descriptionTitle;
        if (footerTitle) {
            CGFloat width = tableView.frame.size.width;
            result += [HLSectionFooterView calculateHeight:footerTitle width:width];
        }
    } else {
        result = ZERO_HEADER_HEIGHT;
    }
    
    return result;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView *result = nil;
    AboutTableSection *sectionObject = self.profileSections.sections[section];
    NSString *footerTitle = sectionObject.descriptionTitle;
    if (footerTitle) {
        HLSectionFooterView *footerView = (HLSectionFooterView *)loadViewFromNibNamed(@"HLSectionFooterView");
        footerView.footerLabel.text = footerTitle;
        
        CGFloat width = tableView.frame.size.width;
        CGFloat height = [HLSectionFooterView calculateHeight:footerTitle width:width];
        footerView.frame = CGRectMake(0.0, 0.0, width, height);
        result = footerView;
    } else {
        result = [UIView new];
        result.backgroundColor = [UIColor clearColor];
    }
    
    return result;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AboutTableSection *sectionObject = self.profileSections.sections[indexPath.section];
    HLProfileTableItem *item = sectionObject.items[indexPath.row];
    UITableViewCell <HLProfileCellProtocol> *cell = [tableView dequeueReusableCellWithIdentifier:item.cellIdentifier];
    [cell setupWithItem:item];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AboutTableSection *sectionObject = self.profileSections.sections[indexPath.section];
    HLProfileTableItem *item = sectionObject.items[indexPath.row];
    if (item.action != nil) {
        item.action();
    }

    item.active = !item.active;
    UITableViewCell <HLProfileCellProtocol> *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell setupWithItem:item];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - ProfileTableItemDelegate

- (BOOL)canSendEmail
{
    return [kContactUsEmail containsString:@"@"];
}

- (void)sendEmail
{
    if ([HLEmailSender canSendEmail]) {
        self.emailSender = [HLEmailSender new];
        [self.emailSender sendFeedbackEmailTo:kContactUsEmail];
        [self presentViewController:self.emailSender.mailer animated:YES completion:nil];
    } else {
        [HLEmailSender showUnavailableAlertInController:self];
    }
}

- (void)showDevSettings
{
    ASTDevSettingsVC *settingsVC = [[ASTDevSettingsVC alloc] initWithNibName:@"ASTDevSettingsVC" bundle:nil];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

- (void)openCurrencySelector
{
    HLCurrencyVC *currencyVC = [[HLCurrencyVC alloc] initWithNibName:@"ASTGroupedSearchVC" bundle:nil];
    [self.navigationController pushViewController:currencyVC animated:YES];
}

- (void)rateApp
{
    NSURL *url = [NSURL URLWithString:kAppStoreRateLink];
    [[UIApplication sharedApplication] openURL:url];
}

- (BOOL)canRateApp
{
    return [kAppStoreRateLink length] > 0;
}

@end
