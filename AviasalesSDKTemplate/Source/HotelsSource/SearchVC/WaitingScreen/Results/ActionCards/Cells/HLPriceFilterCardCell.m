#import "HLPriceFilterCardCell.h"
#import "NSArray+Functional.h"

@interface HLPriceFilterCardCell () <PriceFilterViewDelegate>
@property (weak, nonatomic) IBOutlet PriceFilterView *priceFilterView;
@end

@implementation HLPriceFilterCardCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.priceFilterView.delegate = self;
}

- (void)setupWithFilter:(Filter *)filter
{
    [super setupWithFilter:filter];

    [self.priceFilterView configureWithFilter:filter];
}

#pragma mark - PriceFilterViewDelegate

-(void)filterApplied
{
    [self.item.delegate filterUpdated:self.item.filter];
}

@end
