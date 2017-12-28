#import "HLVariantCollectionViewCell.h"
#import "StringUtils.h"

CGFloat const kStarsOffset = 2.0;
CGFloat const kPriceTextFontSize = 16.0;
CGFloat const kPriceValueFontSize = 20.0;

@interface HLVariantCollectionViewCell()

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *lightningConstraint;
@property (nonatomic, weak) IBOutlet HLHotelInfoView *hotelInfoView;
@property (nonatomic, weak) IBOutlet UILabel *oldPriceView;
@property (nonatomic, weak) IBOutlet UIView  *selectionView;
@property (nonatomic, weak) IBOutlet UILabel *priceLabel;
@property (nonatomic, weak) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIView *redPriceBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *lightningView;
@property (nonatomic, assign) BOOL lockTapGesture;
@property (nonatomic, strong, readwrite) HLVariantItem *item;
@property (nonatomic, strong) UILabel *bookingsCountLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *priceLabelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *durationLabelBottomConstraint;

@end


@implementation HLVariantCollectionViewCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    
    return self;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    [self resetContent];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self initialize];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    self.contentView.frame = bounds;
    
    [self drawBadges];
}

#pragma mark - Public

- (void)initialize
{
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    self.lockTapGesture = NO;
    self.badgesEnabled = YES;

    _tapRecognizer = [HLTapGestureRecognizer new];
    self.tapRecognizer.stateDelegate = self;
    self.tapRecognizer.delegate = self;
    self.tapRecognizer.minimumPressDuration = 0.1;
    [self addGestureRecognizer:self.tapRecognizer];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(containerCollectionWillStartScroll) name:@"HLVariantsCollectionContentNotificationWillStartScroll" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(containerCollectionDidStopScroll) name:@"HLVariantsCollectionContentNotificationDidStopScroll" object:nil];
}

- (void)setupWithItem:(HLVariantItem *)item
{
    self.item = item;
    self.hotelInfoView.hotel = item.variant.hotel;
    [self updateDiscountViews];
    [self drawBadges];
    [self updatePrice];
}

- (void)resetContent
{
    // implement in subclass
}

-(void)setBadgesEnabled:(BOOL)badgesEnabled
{
    _badgesEnabled = badgesEnabled;

    if (!_badgesEnabled) {
        [self removeTextBadges];
    }
}

- (void)drawBadges
{
    if (!self.badgesEnabled) {
        return;
    }

    [self layoutIfNeeded];

    CGPoint badgesOrigin = CGPointMake(15.0, 15.0);
    CGFloat leftInset = 15.0;
    [self drawTextBadges:self.variant.badges widthLimit:CGRectGetWidth(self.bounds) - leftInset startOrigin:badgesOrigin];
}

#pragma mark - Private methods

- (void)addBookingsCountLabel
{
    if (!self.bookingsCountLabel) {
        self.bookingsCountLabel = [UILabel new];
        self.bookingsCountLabel.font = [UIFont systemFontOfSize:10];
        self.bookingsCountLabel.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.8];
        self.bookingsCountLabel.numberOfLines = 0;
        [self addSubview:self.bookingsCountLabel];
        [self.bookingsCountLabel autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.redPriceBackgroundView withOffset:-10.0];
        [self.bookingsCountLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.redPriceBackgroundView withOffset:-10.0];
    }
    self.bookingsCountLabel.text = [NSString stringWithFormat:@"id: %@\nrank: %li\norders: %li", self.variant.hotel.hotelId, (long)self.variant.hotel.rank, (long)self.variant.hotel.popularity2];
}

- (HLResultVariant *)variant
{
    return self.item.variant;
}

- (void)updatePrice
{
    HLRoomsAvailability roomsAvailability = self.variant.roomsAvailability;
    self.priceLabel.font = [UIFont boldSystemFontOfSize:kPriceTextFontSize];
    self.priceLabelTopConstraint.constant = 4.0f;
    self.durationLabelBottomConstraint.constant = 5.0f;

    if (roomsAvailability == HLRoomsAvailabilityHasRooms) {
        self.priceLabel.font = [UIFont systemFontOfSize:kPriceValueFontSize weight:UIFontWeightBold];
        self.priceLabel.attributedText = [self priceString];
    } else if (roomsAvailability == HLRoomsAvailabilitySold) {
        self.priceLabel.text = NSLS(@"HL_LOC_ROOMS_SOLD");
        self.durationLabel.text = NSLS(@"HL_LOC_ROOMS_SOLD_SUBTITLE");
        self.priceLabelTopConstraint.constant = 7.0f;
        self.durationLabelBottomConstraint.constant = 4.0f;
    } else if (roomsAvailability == HLRoomsAvailabilityNoRooms) {
        self.priceLabel.text = NSLS(@"HL_LOC_NO_ROOMS");
        self.durationLabel.text = NSLS(@"HL_LOC_NO_ROOMS_SUBTITLE");
        self.priceLabelTopConstraint.constant = 8.0f;
        self.durationLabelBottomConstraint.constant = 7.0f;
    }

    [self setupPriceBackgroundForVariant:self.variant];
}

- (NSAttributedString *)priceString
{
    return [StringUtils attributedPriceStringWithVariant:self.variant
                                                currency:self.variant.searchInfo.currency
                                                    font:self.priceLabel.font];
}

- (NSAttributedString *)oldPriceString
{
    NSAttributedString *priceAttrStr = [StringUtils attributedPriceStringWithPrice:self.variant.oldMinPrice
                                                                          currency:self.variant.searchInfo.currency
                                                                              font:self.oldPriceView.font];
    return [StringUtils strikethroughAttributedString:priceAttrStr];
}

- (void)updateDiscountViews
{
    [self setupPriceBackgroundForVariant:self.variant];
    BOOL shouldShowLighting = NO;
    self.oldPriceView.text = nil;

    HDKHighlightType type = self.variant.highlightType;
    switch (type) {
        case HDKHighlightTypeNone: {
            self.durationLabel.text = [StringUtils durationDescriptionWithDays:self.variant.duration];
        } break;
        case HDKHighlightTypeMobile:
        case HDKHighlightTypePrivate: {
            shouldShowLighting = YES;
            self.durationLabel.text = NSLS(@"HL_SPECIAL_PRICE_TITLE");
        } break;
        case HDKHighlightTypeDiscount: {
            self.durationLabel.text = @"";
            self.oldPriceView.attributedText = [self oldPriceString];
        } break;
    }

    self.lightningView.hidden = !shouldShowLighting;
    self.lightningConstraint.active = shouldShowLighting;
}

- (void)setupPriceBackgroundForVariant:(HLResultVariant *)variant
{
    self.redPriceBackgroundView.backgroundColor = [self priceBackgroundColorForVariant:variant];
}

- (UIColor *)priceBackgroundColorForVariant:(HLResultVariant *)variant
{
    CGFloat alpha = 0.7;
    CGFloat discountAlpha = 1.0;
    if ([self shouldPriceHaveGrayBackground:variant]) {
        return [[JRColorScheme priceBackgroundColor] colorWithAlphaComponent:alpha];
    } else if (variant.highlightType == HDKHighlightTypeDiscount) {
        return [[JRColorScheme discountColor] colorWithAlphaComponent:discountAlpha];
    } else {
        return [UIColor colorWithRed:208.0/255 green:2.0/255 blue:27.0/255 alpha:alpha];
    }
}

- (BOOL)shouldPriceHaveGrayBackground:(HLResultVariant *)variant
{
    return (variant.roomsAvailability == HLRoomsAvailabilitySold) ||
    (variant.roomsAvailability == HLRoomsAvailabilityNoRooms) ||
    ((variant.roomsAvailability == HLRoomsAvailabilityHasRooms) && (variant.highlightType == HDKHighlightTypeNone));
}

- (void)deselectAnimation
{
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.selectionView.alpha = 0.0;
                     }
                     completion:nil];
}

- (void)selectAnimation
{
    [UIView animateWithDuration:0.1
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.selectionView.alpha = 0.3;
                     }
                     completion:nil];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.lockTapGesture) {
        return NO;
    }
    
    CGPoint point  = [gestureRecognizer locationInView:self];
    UIView *subview = [self hitTest:point withEvent:nil];
    
    return ![subview isKindOfClass:[UIButton class]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    if (self.lockTapGesture) {
        return NO;
    }
    
    CGPoint point  = [touch locationInView:self];
    UIView *subview = [self hitTest:point withEvent:nil];

    return ![subview isKindOfClass:[UIButton class]];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - HLGestureRecognizerDelegate methods

- (void)recognizerCancelled
{
    [self.tapRecognizer removeTarget:self action:@selector(selectAnimation)];
    [self deselectAnimation];
}

- (void)recognizerFinished
{
    [self.tapRecognizer removeTarget:self action:@selector(selectAnimation)];
    [self deselectAnimation];
}

- (void)recognizerStarted
{
    [self.tapRecognizer addTarget:self action:@selector(selectAnimation)];
}

@end


@implementation HLVariantCollectionViewCell (ScrollNotifications)

- (void)containerCollectionWillStartScroll
{
    self.tapRecognizer.enabled = NO;
    self.lockTapGesture = YES;
}

- (void)containerCollectionDidStopScroll
{
    self.tapRecognizer.enabled = YES;
    self.lockTapGesture = NO;
}

@end
