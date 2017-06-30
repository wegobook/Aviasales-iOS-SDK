#import <Foundation/Foundation.h>

@interface NSString (HLSizeCalculation)

- (CGFloat)hl_heightWithAttributes:(NSDictionary *)attributes width:(CGFloat)width maxHeight:(CGFloat)maxHeight;
- (CGFloat)hl_heightWithAttributes:(NSDictionary *)attributes width:(CGFloat)width;
- (CGFloat)hl_widthWithAttributes:(NSDictionary *)attributes height:(CGFloat)height;

@end

@interface NSAttributedString (HLSizeCalculation)

- (CGFloat)hl_heightWithWidth:(CGFloat)width maxHeight:(CGFloat)maxHeight;
- (CGFloat)hl_widthWithHeight:(CGFloat)height;
- (CGFloat)hl_heightWithWidth:(CGFloat)width;

@end
