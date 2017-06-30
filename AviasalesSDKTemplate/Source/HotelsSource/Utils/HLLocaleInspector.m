#import "HLLocaleInspector.h"

@implementation HLLocaleInspector

+ (HLLocaleInspector *)sharedInspector
{
	static HLLocaleInspector *sharedInspector;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInspector = [HLLocaleInspector new];
    });

	return sharedInspector;
}

+ (BOOL)shouldUseMetricSystem
{
	return [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
}

- (BOOL)isLanguageRussian:(NSString *)lang
{
	return ([lang isEqualToString:@"ru"]);
}

- (BOOL)isLanguageEnglish:(NSString *)lang
{
	return([lang isEqualToString:@"en"]);
}

- (BOOL)isCurrentLanguageRussian
{
    return [self isLanguageRussian:self.uiLanguage];
}

- (BOOL)isCurrentLanguageEnglish
{
    return [self isLanguageEnglish:self.uiLanguage];
}

+ (NSString *)localizedUserReviewLangNameForLang:(NSString *)lang
{
    NSString *locKey = [@"HL_HOTEL_DETAIL_LANGUAGE_" stringByAppendingString:[lang uppercaseString]];
    NSString *localizedString = NSLS(locKey);
    BOOL localizationNotFound = [localizedString isEqualToString:locKey];
    if (localizationNotFound) {
        return @"";
    } else {
        return localizedString;
    }
}

+ (NSString *)userReviewLangName
{
    NSString *language = [HLLocaleInspector sharedInspector].uiLanguage;
    NSString *locale = [[[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] lowercaseString];

    if (![language isEqualToString:@"en"]) {
        return language;
    }

    if (![locale isEqualToString:@"en"]) {
        return locale;
    }

    return nil;
}

- (NSString *)uiLanguage
{
	NSString *localeLang = [[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2];
	return localeLang;
}

- (NSString *)countryCode
{
    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode] ?: @"US";
}

- (NSString *)localeString
{
    NSLocale *locale = [NSLocale currentLocale];

    NSString *lang = [locale objectForKey:NSLocaleLanguageCode];
    NSString *scriptCode = [locale objectForKey:NSLocaleScriptCode];
    NSString *region = [locale objectForKey:NSLocaleCountryCode];

    NSMutableString *result = [lang mutableCopy];
    if (scriptCode.length > 0) {
        [result appendFormat:@"-%@", scriptCode];
    }
    if (region.length > 0) {
        [result appendFormat:@"_%@", region];
    }
    return [result copy];
}

@end
