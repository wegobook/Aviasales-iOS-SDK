#import "NSString+HLSizeCalculation.h"

@implementation NSString (HLSizeCalculation)

- (CGFloat)hl_heightWithAttributes:(NSDictionary *)attributes width:(CGFloat)width
{
    return [self hl_heightWithAttributes:attributes width:width maxHeight:CGFLOAT_MAX];
}

- (CGFloat)hl_widthWithAttributes:(NSDictionary *)attributes height:(CGFloat)height
{
    CGRect rect = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                     options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                  attributes:attributes
                                     context:nil];

    return ceil(rect.size.width);
}

- (CGFloat)hl_heightWithAttributes:(NSDictionary *)attributes width:(CGFloat)width maxHeight:(CGFloat)maxHeight
{
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, maxHeight)
                                     options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                  attributes:attributes
                                     context:nil];

    return ceil(rect.size.height);
}

@end

@implementation NSAttributedString (HLSizeCalculation)

- (CGFloat)hl_heightWithWidth:(CGFloat)width
{
    return [self hl_heightWithWidth:width maxHeight:CGFLOAT_MAX];
}

- (CGFloat)hl_widthWithHeight:(CGFloat)height
{
    CGRect rect = [self boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, height)
                                     options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                     context:nil];

    return ceil(rect.size.width);
}

- (CGFloat)hl_heightWithWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight
{
    CGRect rect = [self boundingRectWithSize:CGSizeMake(width, maxHeight)
                                     options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                     context:nil];

    return ceil(rect.size.height);
}

@end
