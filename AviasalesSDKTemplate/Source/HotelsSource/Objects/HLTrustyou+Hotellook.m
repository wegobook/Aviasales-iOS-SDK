#import "HLTrustyou+Hotellook.h"
#import "NSDictionary+Parsing.h"
//#import "HLLocaleInspector.h"

@implementation HDKTrustyou (HL)

#pragma mark - Target Language Visitors Percent

- (NSInteger)userReviewLanguageVisitorsPercent
{
    NSInteger result = -1;
    NSString *userReviewLangName = [HLLocaleInspector userReviewLangName];
    for (NSDictionary *dict in self.languageDistribution) {
        NSString *langName = dict[@"name"];
        if ([userReviewLangName isEqualToString:langName]) {
            NSInteger percentage = [dict integerForKey:@"percentage" defaultValue:-1];
            if (percentage >= 0) {
                result = percentage;
                break;
            }
        }
    }
    
    return result;
}

@end
