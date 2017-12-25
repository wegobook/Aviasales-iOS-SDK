#import "HLSearchTicketsCardCell.h"
#import <HotellookSDK/HotellookSDK.h>

@interface HLSearchTicketsCardCell ()

@property (weak, nonatomic) IBOutlet UIButton *searchTicketsButton;
@property (weak, nonatomic) IBOutlet UILabel *searchTicketsDescriptionLabel;

@end

@implementation HLSearchTicketsCardCell

- (IBAction)searchTicketsAction
{
    [self.item.delegate searchTickets];
    [self.item.delegate actionCardItemClosed:self.item];
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    self.searchTicketsButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.searchTicketsButton setTitleColor:[JRColorScheme actionColor] forState:UIControlStateNormal];
    [self.searchTicketsButton setTitle:NSLS(@"HL_TICKETS_SEARCH_CELL_BUTTON") forState:UIControlStateNormal];

    self.searchTicketsDescriptionLabel.text = NSLS(@"HL_TICKETS_SEARCH_CELL_TITLE");
}

@end
