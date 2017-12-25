#import "HLResultCardCell.h"
#import "HLSliderCalculator.h"
#import "StringUtils.h"

@implementation HLResultCardCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.textColor = [JRColorScheme lightTextColor];
    self.numberColor = [JRColorScheme darkTextColor];
    [self.applyButton setTitleColor:[JRColorScheme darkTextColor] forState:UIControlStateNormal];
    [self.applyButton setTitleColor:[JRColorScheme lightTextColor] forState:UIControlStateDisabled];
    [self.applyButton setTitle:NSLS(@"HL_LOC_ACTION_CARD_APPLY_BUTTON") forState:UIControlStateNormal];

    [self.slider setMaximumTrackImage:[JRColorScheme sliderMinImage] forState:UIControlStateNormal];
    [self.slider setMinimumTrackImage:[JRColorScheme sliderMaxImage] forState:UIControlStateNormal];
    [self.slider setThumbImage:[UIImage imageNamed:@"JRSliderImg"] forState:UIControlStateNormal];
}

- (void)setItem:(HLActionCardItem *)item
{
    [self.slider removeTarget:self action:nil forControlEvents:UIControlEventAllEvents];
    
    _item = item;
    if (self.item.topItem) {
        self.closeButton.hidden = YES;
        self.applyButton.hidden = YES;
        [self.slider addTarget:self action:@selector(apply) forControlEvents:UIControlEventTouchCancel];
        [self.slider addTarget:self action:@selector(apply) forControlEvents:UIControlEventTouchUpInside];
        [self.slider addTarget:self action:@selector(apply) forControlEvents:UIControlEventTouchUpOutside];
        [self.slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    } else {
        self.closeButton.hidden = NO;
        self.applyButton.hidden = NO;
        [self.slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    }
    
    [self setupWithFilter:item.filter];
}

- (void)setupWithFilter:(Filter *)filter
{
}

- (void)sliderValueChanged
{
}

- (IBAction)close
{
    [self.item.delegate actionCardItemClosed:self.item];
}

- (IBAction)apply
{
}

@end
