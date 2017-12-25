#import "HLNearbyCitiesSearchCardCell.h"
#import <HotellookSDK/HotellookSDK.h>

@interface HLNearbyCitiesSearchCardCell ()

@property (weak, nonatomic) IBOutlet UIButton *nearbyCitiesSearchButton;
@property (weak, nonatomic) IBOutlet UILabel *nearbySearchDescriptionLabel;

@end

@implementation HLNearbyCitiesSearchCardCell

- (IBAction)nearbyCitiesSearchButtonPressed
{
    [self.item.delegate nearbyCitiesSearchItemApplied:self.item];
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    self.nearbyCitiesSearchButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [self.nearbyCitiesSearchButton setTitleColor:[JRColorScheme actionColor] forState:UIControlStateNormal];
    [self.nearbyCitiesSearchButton setTitle:NSLS(@"HL_NEARBY_CITIES_SEARCH_CELL_BUTTON") forState:UIControlStateNormal];
}

-(void)setupWithFilter:(Filter *)filter
{
    [super setupWithFilter:filter];

    self.nearbySearchDescriptionLabel.text = [filter.searchResult hasAnyRoomWithPrice] ? NSLS(@"HL_NEARBY_CITIES_SEARCH_CELL_FEW_DESCRIPTION") : NSLS(@"HL_NEARBY_CITIES_SEARCH_CELL_NOTHING_DESCRIPTION");
}

@end
