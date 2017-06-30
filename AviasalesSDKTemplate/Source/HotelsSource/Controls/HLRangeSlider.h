#import <UIKit/UIKit.h>

@protocol HLRangeSliderDelegate <NSObject>

- (void)minValueChanged;
- (void)maxValueChanged;

@end

@interface HLRangeSlider : UIControl

@property (nonatomic, weak) id <HLRangeSliderDelegate> delegate;

@property (retain, nonatomic) UIImageView* lowerHandle;
@property (retain, nonatomic) UIImageView* upperHandle;

// default 0.0
@property(assign, nonatomic) CGFloat minimumValue;

// default 1.0
@property(assign, nonatomic) CGFloat maximumValue;

// default 0.0. This is the minimum distance between between the upper and lower values
@property(assign, nonatomic) float minimumRange;

// default 0.0 (disabled)
@property(assign, nonatomic) float stepValue;

// If NO the slider will move freely with the tounch. When the touch ends, the value will snap to the nearest step value
// If YES the slider will stay in its current position until it reaches a new step value.
// default NO
@property(assign, nonatomic) BOOL stepValueContinuously;

// defafult YES, indicating whether changes in the sliders value generate continuous update events.
@property(assign, nonatomic) BOOL continuous;

// default 0.0. this value will be pinned to min/max
@property(assign, nonatomic) CGFloat lowerValue;

// default 1.0. this value will be pinned to min/max
@property(assign, nonatomic) CGFloat upperValue;

// center location for the lower handle control
@property(readonly, nonatomic) CGPoint lowerCenter;

// center location for the upper handle control
@property(readonly, nonatomic) CGPoint upperCenter;

// thumb image offset. If not set, use 13.0f
@property (nonatomic) CGFloat thumbImageOffset;

// range slider horizontal offset. If not set, use 15.0f
@property (nonatomic) CGFloat rangeSliderHorizontalOffset;

// Images, these should be set before the control is displayed.
// If they are not set, then the default images are used.
// eg viewDidLoad


//Probably should add support for all control states... Anyone?

@property(retain, nonatomic) UIImage* lowerHandleImageNormal;
@property(retain, nonatomic) UIImage* lowerHandleImageHighlighted;

@property(retain, nonatomic) UIImage* upperHandleImageNormal;
@property(retain, nonatomic) UIImage* upperHandleImageHighlighted;

@property(retain, nonatomic) UIImage* trackImage;

@property(retain, nonatomic) UIImage* trackBackgroundImage;

- (void)setLowerValue:(float)lowerValue animated:(BOOL)animated;
- (void)setUpperValue:(float)upperValue animated:(BOOL)animated;
- (void)setLowerValue:(float)lowerValue upperValue:(float)upperValue animated:(BOOL)animated;
- (void) addSubviews;

@end
