#import <UIKit/UIKit.h>

@class HLActionCardItem;
@class Filter;

@interface HLResultCardCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIButton *applyButton;
@property (nonatomic, weak) IBOutlet UISlider *slider;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *valueLabel;

@property (nonatomic, strong) HLActionCardItem *item;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIColor *numberColor;

- (void)setupWithFilter:(Filter *)filter;
- (IBAction)close;
- (IBAction)apply;
- (IBAction)sliderValueChanged;

@end
