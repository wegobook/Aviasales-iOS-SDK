#import "HLRangeSlider.h"

#define HL_THUMB_IMAGE_OFFSET 2.0f
#define HL_RANGE_SLIDER_WIDTH_EXTENSION 100.0f
#define HL_RANGE_SLIDER_HEIGHT_EXTENSION 80.0f

@interface HLRangeSlider ()
{
    float _lowerTouchOffset;
    float _upperTouchOffset;
    float _stepValueInternal;
    BOOL _haveAddedSubviews;
}

@property (retain, nonatomic) UIImageView* track;
@property (retain, nonatomic) UIImageView* trackBackground;

@end

@implementation HLRangeSlider

#pragma mark Constructors

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureView];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureView];
    }

    return self;
}


- (void)configureView
{
    _minimumValue = 0.0;
    _maximumValue = 1.0;
    _minimumRange = 0.0;
    _stepValue = 0.0;
    _stepValueInternal = 0.0;
    
    _continuous = YES;
    
    _lowerValue = 0.0;
    _upperValue = 1.0;

    _rangeSliderHorizontalOffset = 15.0;
}

#pragma mark - Properties

- (CGPoint)lowerCenter
{
    return _lowerHandle.center;
}

- (CGPoint)upperCenter
{
    return _upperHandle.center;
}

- (void)setLowerValue:(CGFloat)lowerValue
{
    float value = lowerValue;
    if (_stepValueInternal > 0) {
        value = roundf(value / _stepValueInternal) * _stepValueInternal;
    }
    
    value = MAX(value, _minimumValue);
    value = MIN(value, _upperValue - _minimumRange);
    
    _lowerValue = value;
    
    [self setNeedsLayout];
}

- (void)setUpperValue:(CGFloat)upperValue
{
    float value = upperValue;
    if (_stepValueInternal > 0) {
        value = roundf(value / _stepValueInternal) * _stepValueInternal;
    }
    
    value = MIN(value, _maximumValue);
    value = MAX(value, _lowerValue+_minimumRange);
    
    _upperValue = value;
    
    [self setNeedsLayout];
}


- (void)setLowerValue:(float) lowerValue upperValue:(float) upperValue animated:(BOOL)animated
{
    if((!animated) && (isnan(lowerValue) || lowerValue==_lowerValue) && (isnan(upperValue) || upperValue==_upperValue))
    {
        //nothing to set
        return;
    }
    
    __block void (^setValuesBlock)(void) = ^ {
        
        if(!isnan(lowerValue))
        {
            [self setLowerValue:lowerValue];
        }
        if(!isnan(upperValue))
        {
            [self setUpperValue:upperValue];
        }
        
    };
    
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             setValuesBlock();
                             [self layoutSubviews];
                         } completion:nil];
        
    } else {
        setValuesBlock();
        [self layoutSubviews];
    }
}

- (void)setLowerValue:(float)lowerValue animated:(BOOL)animated
{
    [self setLowerValue:lowerValue upperValue:NAN animated:animated];
}

- (void)setUpperValue:(float)upperValue animated:(BOOL) animated
{
    [self setLowerValue:NAN upperValue:upperValue animated:animated];
}

#pragma mark - Math

//Returns the lower value based on the X potion
//The return value is automatically adjust to fit inside the valid range
- (float)lowerValueForCenterX:(float)x
{
    float _padding = _lowerHandle.frame.size.width/2.0f;
    float value = _minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (_maximumValue - _minimumValue);
    
    value = MAX(value, _minimumValue);
    value = MIN(value, _upperValue - _minimumRange);
    
    return value;
}

//Returns the upper value based on the X potion
//The return value is automatically adjust to fit inside the valid range
- (float)upperValueForCenterX:(float)x
{
    float _padding = _upperHandle.frame.size.width/2.0;
    
    float value = _minimumValue + (x-_padding) / (self.frame.size.width-(_padding*2)) * (_maximumValue - _minimumValue);
    
    value = MIN(value, _maximumValue);
    value = MAX(value, _lowerValue+_minimumRange);
    
    return value;
}

//returns the rect for the track image between the lower and upper values based on the trackimage object
- (CGRect)trackRect
{
    CGRect retValue;
    
    retValue.size = CGSizeMake(_trackImage.size.width, _trackImage.size.height);
    
    float xLowerValue = ((self.bounds.size.width - _lowerHandle.frame.size.width) * (_lowerValue - _minimumValue) / (_maximumValue - _minimumValue))+(_lowerHandle.frame.size.width/3.0f);
    float xUpperValue = ((self.bounds.size.width - _upperHandle.frame.size.width) * (_upperValue - _minimumValue) / (_maximumValue - _minimumValue))+(_upperHandle.frame.size.width/1.5f);
    
    retValue.origin = CGPointMake(xLowerValue, (self.bounds.size.height/2.0f) - (retValue.size.height/2.0f));
    retValue.size.width = xUpperValue-xLowerValue;
    
    retValue.origin = CGPointMake(_lowerHandle.center.x, (self.bounds.size.height/2.0f) - (retValue.size.height/2.0f));
    retValue.size.width = _upperHandle.frame.origin.x - _lowerHandle.frame.origin.x;
    
    return retValue;
}

//returns the rect for the background image
- (CGRect)trackBackgroundRect
{
    CGRect trackBackgroundRect;
    
    trackBackgroundRect.size = CGSizeMake(_trackBackgroundImage.size.width, _trackBackgroundImage.size.height);
    
    if(_trackBackgroundImage.capInsets.top || _trackBackgroundImage.capInsets.bottom)
    {
        trackBackgroundRect.size.height=self.bounds.size.height;
    }
    
    trackBackgroundRect.size.width = self.bounds.size.width - 2 * self.rangeSliderHorizontalOffset;
    trackBackgroundRect.origin = CGPointMake(self.rangeSliderHorizontalOffset,
                                             self.bounds.size.height/2.0f - trackBackgroundRect.size.height/2.0f);
    
    return trackBackgroundRect;
}

//returns the rect of the thumb image for a given track rect and value
- (CGRect)thumbRectForValue:(float)value image:(UIImage*) thumbImage
{
    CGRect thumbRect;
    thumbRect.size = thumbImage.size;
    
    float b = - HL_THUMB_IMAGE_OFFSET + self.rangeSliderHorizontalOffset;
    float k = self.frame.size.width - thumbImage.size.width + 2 * HL_THUMB_IMAGE_OFFSET - 2 * self.rangeSliderHorizontalOffset;
    
    float xValue = k * value + b;
    thumbRect.origin = CGPointMake(xValue, self.bounds.size.height/2.0f - thumbRect.size.height/2.0f);
    
    return thumbRect;
}


#pragma mark - Layout

- (void)addSubviews
{
    self.trackBackground = [[UIImageView alloc] initWithImage:self.trackBackgroundImage];
    self.trackBackground.frame = [self trackBackgroundRect];
    
    self.track = [[UIImageView alloc] initWithImage:self.trackImage];
    self.track.frame = [self trackRect];
    
    self.lowerHandle = [[UIImageView alloc] initWithImage:self.lowerHandleImageNormal highlightedImage:self.lowerHandleImageHighlighted];
    [self.lowerHandle setContentMode:UIViewContentModeCenter];
    if ((self.lowerHandleImageNormal.size.height < self.lowerHandleImageHighlighted.size.height) || (self.lowerHandleImageNormal.size.width < self.lowerHandleImageHighlighted.size.width)) {
        self.lowerHandle.frame = [self thumbRectForValue:_lowerValue image:self.lowerHandleImageHighlighted];
    } else {
        self.lowerHandle.frame = [self thumbRectForValue:_lowerValue image:self.lowerHandleImageNormal];
    }
    
    self.upperHandle = [[UIImageView alloc] initWithImage:self.upperHandleImageNormal highlightedImage:self.upperHandleImageHighlighted];
    [self.upperHandle setContentMode:UIViewContentModeCenter];
    if ((self.upperHandleImageNormal.size.height < self.upperHandleImageHighlighted.size.height) || (self.upperHandleImageNormal.size.width < self.upperHandleImageHighlighted.size.width)) {
        self.lowerHandle.frame = [self thumbRectForValue:_upperValue image:self.upperHandleImageHighlighted];
    } else {
        self.lowerHandle.frame = [self thumbRectForValue:_upperValue image:self.upperHandleImageNormal];
    }
    
    [self addSubview:self.trackBackground];
    [self addSubview:self.track];
    [self addSubview:self.lowerHandle];
    [self addSubview:self.upperHandle];
}


- (void)layoutSubviews
{
    if (_haveAddedSubviews==NO) {
        _haveAddedSubviews=YES;
        [self addSubviews];
    }
    
    self.trackBackground.frame = [self trackBackgroundRect];
    self.lowerHandle.frame = [self thumbRectForValue:_lowerValue image:self.lowerHandleImageNormal];
    self.upperHandle.frame = [self thumbRectForValue:_upperValue image:self.upperHandleImageNormal];
    self.track.frame = [self trackRect];
    [super layoutSubviews];
}

- (CGSize)intrinsicContentSize
{
    return CGSizeMake(UIViewNoIntrinsicMetric, MAX(self.lowerHandleImageNormal.size.height, self.upperHandleImageNormal.size.height));
}

#pragma mark - Touch handling

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    return CGRectContainsPoint(CGRectInset(self.bounds, -10, -10), point);
}

- (CGRect)touchRectForLowerHandle:(UIImageView*) handleImageView
{
    CGRect rect = [self extendedRectForHandle:handleImageView];
    CGFloat deltaX = [self handlesCenter].x - handleImageView.center.x;

    rect.origin.x -= MAX(HL_RANGE_SLIDER_WIDTH_EXTENSION / 2, HL_RANGE_SLIDER_WIDTH_EXTENSION - deltaX);

    return rect;
}

- (CGRect)touchRectForUpperHandle:(UIImageView*) handleImageView
{
    CGRect rect = [self extendedRectForHandle:handleImageView];
    CGFloat deltaX = handleImageView.center.x - [self handlesCenter].x;

    rect.origin.x -= MIN(HL_RANGE_SLIDER_WIDTH_EXTENSION / 2, deltaX);

    return rect;
}

- (CGRect)extendedRectForHandle:(UIImageView*) handleImageView
{
    CGRect rect = handleImageView.frame;

    rect.size.width += HL_RANGE_SLIDER_WIDTH_EXTENSION;

    rect.origin.y -= HL_RANGE_SLIDER_HEIGHT_EXTENSION / 2;
    rect.size.height += HL_RANGE_SLIDER_HEIGHT_EXTENSION;

    return rect;
}

- (CGPoint)handlesCenter
{
    return CGPointMake((_lowerHandle.center.x + _upperHandle.center.x) / 2, (_lowerHandle.center.y + _upperHandle.center.y) / 2);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch * touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    //Check both buttons upper and lower thumb handles because
    //they could be on top of each other.
    
    CGRect rect = [self touchRectForLowerHandle:_lowerHandle];
    
    if(CGRectContainsPoint(rect, touchPoint))
    {
        _lowerHandle.highlighted = YES;
        _lowerTouchOffset = touchPoint.x - _lowerHandle.center.x;
    }
    
    if(CGRectContainsPoint([self touchRectForUpperHandle:_upperHandle], touchPoint))
    {
        _upperHandle.highlighted = YES;
        _upperTouchOffset = touchPoint.x - _upperHandle.center.x;
    }
    
    _stepValueInternal= _stepValueContinuously ? _stepValue : 0.0f;
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!_lowerHandle.highlighted && !_upperHandle.highlighted ) {
        return;
    }
    
    UITouch * touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];

    if (_lowerHandle.highlighted) {
        //get new lower value based on the touch location.
        //This is automatically contained within a valid range.
        float newValue = [self lowerValueForCenterX:(touchPoint.x - _lowerTouchOffset)];
        
        //if both upper and lower is selected, then the new value must be LOWER
        //otherwise the touch event is ignored.
        if (!_upperHandle.highlighted || newValue<_lowerValue) {
            _upperHandle.highlighted=NO;
            [self bringSubviewToFront:_lowerHandle];
            
            [self setLowerValue:newValue animated:_stepValueContinuously ? YES : NO];
        } else {
            _lowerHandle.highlighted=NO;
        }
    }
    
    if (_upperHandle.highlighted)
    {
        float newValue = [self upperValueForCenterX:(touchPoint.x - _upperTouchOffset)];
        
        //if both upper and lower is selected, then the new value must be HIGHER
        //otherwise the touch event is ignored.
        if (!_lowerHandle.highlighted || newValue>_upperValue)
        {
            _lowerHandle.highlighted=NO;
            [self bringSubviewToFront:_upperHandle];
            [self setUpperValue:newValue animated:_stepValueContinuously ? YES : NO];
        }
        else
        {
            _upperHandle.highlighted=NO;
        }
    }
    
    //send the control event
    if(_continuous)
    {
        [self sendActionsForControlEvents:UIControlEventValueChanged];
        
        if (_lowerHandle.highlighted) {
            [self.delegate minValueChanged];
        }
        if (_upperHandle.highlighted) {
            [self.delegate maxValueChanged];
        }
    }
    [self setNeedsLayout];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(_stepValue > 0)
    {
        _stepValueInternal=_stepValue;
        
        [self setLowerValue:_lowerValue animated:YES];
        [self setUpperValue:_upperValue animated:YES];
    }
    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    
    _lowerHandle.highlighted = NO;
    _upperHandle.highlighted = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _lowerHandle.highlighted = NO;
    _upperHandle.highlighted = NO;
    
    if (_stepValue > 0) {
        _stepValueInternal=_stepValue;
        
        [self setLowerValue:_lowerValue animated:YES];
        [self setUpperValue:_upperValue animated:YES];
    }
    [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
}

@end
