#import "HLDistanceFilterCardCell.h"
#import "NSString+HLSizeCalculation.h"

@interface HLDistanceFilterCardCell ()

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sliderToLabelConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *labelToSuperviewTrailingConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *sliderToSuperviewTrailingConstraint;

@end

@implementation HLDistanceFilterCardCell

- (IBAction)apply
{
    [super apply];
    
    CGFloat value = self.slider.value;
    HLDistanceFilterCardItem *distanceItem = self.distanceItem;
    value = [HLSliderCalculator calculateExpValueWithSliderValue:value minValue:distanceItem.minValue maxValue:distanceItem.maxValue];
    self.item.filter.distanceLocationPoint = [(HLDistanceFilterCardItem *)self.item originPoint];
    if (!IS_FLOAT_EQUALS_WITH_ACCURACY(self.item.filter.currentMaxDistance, value, 0.1)) {
        self.item.filter.currentMaxDistance = value;
        if (self.item.topItem) {
            [self.item.delegate filterUpdated:self.item.filter];
        } else {
            [self.item.delegate distanceItemApplied:self.distanceItem];
        }
    }
}

- (IBAction)close
{
    [self.item.delegate distanceItemClosed:self.distanceItem];
    [super close];
}

- (void)setupWithFilter:(Filter *)filter
{
    [super setupWithFilter:filter];
    HDKLocationPoint *point = [(HLDistanceFilterCardItem *)self.item originPoint];
    self.descriptionLabel.text = point.actionCardDescription;
    [self setPresetFilterValue:filter item:(HLDistanceFilterCardItem *)self.item point:point];
}

-(void)updateConstraints
{
    if (!self.sliderToSuperviewTrailingConstraint) {
        CGFloat sliderToSuperviewTrailingConstraintConstant = self.labelToSuperviewTrailingConstraint.constant + self.sliderToLabelConstraint.constant;
        sliderToSuperviewTrailingConstraintConstant += [[self attributedDistanceStringWithValue:1000000.0f] hl_widthWithHeight:CGFLOAT_MAX];
        self.sliderToSuperviewTrailingConstraint = [self.slider autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:sliderToSuperviewTrailingConstraintConstant];
    }

    [super updateConstraints];
}

- (void)sliderValueChanged
{
    [super sliderValueChanged];
    
    CGFloat value = self.slider.value;
    HLDistanceFilterCardItem *distanceItem = self.distanceItem;
    value = [HLSliderCalculator calculateExpValueWithSliderValue:value minValue:distanceItem.minValue maxValue:distanceItem.maxValue];
    [self updateValueLabel:value];
    ((HLDistanceFilterCardItem *)self.item).currentValue = value;

    [self updateApplyButton];
}

- (void)updateApplyButton
{
    CGFloat filterValue = self.distanceItem.filter.currentMaxDistance;
    CGFloat cardValue = self.distanceItem.currentValue;
    self.applyButton.enabled = !IS_FLOAT_EQUALS(cardValue, filterValue);
}

- (void)updateValueLabel:(CGFloat)value
{
    self.valueLabel.attributedText = [self attributedDistanceStringWithValue:value];
}

- (NSAttributedString *)attributedDistanceStringWithValue:(CGFloat)value
{
    return [StringUtils attributedDistanceString:value
                                       textColor:self.textColor
                                     numberColor:self.numberColor];
}

- (void)setPresetFilterValue:(Filter *)filter item:(HLDistanceFilterCardItem *)item point:(HDKLocationPoint *)point
{
    HLDistanceFilterCardItem *distanceItem = self.distanceItem;
    CGFloat presetFilterValue = distanceItem.currentValue;
    CGFloat value = [HLSliderCalculator calculateSliderLogValueWithValue:presetFilterValue minValue:distanceItem.minValue maxValue:distanceItem.maxValue];
    self.slider.value = value;
    [self updateValueLabel:presetFilterValue];

    [self updateApplyButton];
}

- (HLDistanceFilterCardItem *)distanceItem
{
    return (HLDistanceFilterCardItem *)self.item;
}

@end
