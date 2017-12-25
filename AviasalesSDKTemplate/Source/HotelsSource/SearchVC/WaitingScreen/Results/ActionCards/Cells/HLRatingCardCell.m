#import "HLRatingCardCell.h"

@implementation HLRatingCardCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    self.descriptionLabel.text = NSLS(@"HL_LOC_FILTER_RATING_CRITERIA");

    [self.slider setMaximumTrackImage:[JRColorScheme sliderMaxImage] forState:UIControlStateNormal];
    [self.slider setMinimumTrackImage:[JRColorScheme sliderMinImage] forState:UIControlStateNormal];
}

- (IBAction)apply
{
    [super apply];
    
    CGFloat value = self.slider.value * 100;
    if (self.item.filter.currentMinRating != value) {
        self.item.filter.currentMinRating = value;
        [self.item.delegate filterUpdated:self.item.filter];
    }
}

- (void)setupWithFilter:(Filter *)filter
{
    [super setupWithFilter:filter];
    
    NSInteger value = self.item.filter.currentMinRating;
    self.slider.value = value / 100.0;
    [self updateValueLabel:value];
}

- (void)sliderValueChanged
{
    [super sliderValueChanged];
    
    CGFloat value = self.slider.value * 100.0;
    [self updateValueLabel:value];
}

- (void)updateValueLabel:(NSInteger)value
{
    self.valueLabel.attributedText = [StringUtils attributedRatingStringFor:value
                                                                  textColor:[JRColorScheme lightTextColor]
                                                                numberColor:[JRColorScheme lightTextColor]];
}

@end
