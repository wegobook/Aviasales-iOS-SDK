#import "HLDefaultCitiesFactory.h"
#import <HotellookSDK/HotellookSDK.h>
#import "NSDictionary+Parsing.h"

@implementation HLDefaultCitiesFactory

+ (HDKCity *)defaultCity
{
    NSString *country = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];

    return [self cityByCountry:country];
}

+ (HDKCity *)cityByCountry:(NSString *)country
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"HLDefaultCities" ofType:@"plist"];
    NSDictionary *cities = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSDictionary *cityDict = cities[country.lowercaseString] ?: cities[@"us"];
    HDKCity *city = [self cityFromDict:cityDict];

    return city;
}

+ (HDKCity *)cityFromDict:(NSDictionary *)dict
{
    NSString *cityId = [dict stringForKey:@"id"];
    NSString *name = [dict stringForKey:@"name"];
    NSString *countryName = [dict stringForKey:@"countryName"];
    NSInteger hotelsCount = [dict integerForKey:@"hotelsCount"];
    double latitude = [dict doubleForKey:@"latitude"];
    double longitude = [dict doubleForKey:@"longitude"];

    HDKCity *city = [[HDKCity alloc] initWithCityId:cityId
                                             name:NSLS(name)
                                        latinName:nil
                                         fullName:nil
                                      countryName:NSLS(countryName)
                                 countryLatinName:nil
                                      countryCode:nil
                                            state:nil
                                         latitude:latitude
                                        longitude:longitude
                                      hotelsCount:hotelsCount
                                         cityCode:nil
                                             points:@[]
                                            seasons:@[]];

    return city;
}

@end
