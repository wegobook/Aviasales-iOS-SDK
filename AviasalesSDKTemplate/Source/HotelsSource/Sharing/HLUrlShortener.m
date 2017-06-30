#import "HLUrlShortener.h"
#import "HLUrlUtils.h"

@interface HLUrlShortener()

@property (nonatomic, readwrite) NSString *shortenedUrlString;
@property (nonatomic, readwrite) NSString *longUrlString;

@end


@implementation HLUrlShortener

- (void)shortenUrlForVariant:(HLResultVariant *)variant completion:(void (^)(void))completion
{
    if (self.shortenedUrlString) {
        completion();
    } else {
        NSURLRequest *request = [self requestWithVariant:variant];
        [self sendRequest:request completion:completion];
    }
}

- (void)sendRequest:(NSURLRequest *)request completion:(void (^)(void))completion
{
    __weak HLUrlShortener *weakSelf = self;
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithRequest:request
                                    completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                        if (weakSelf) {
                                            HLUrlShortener *strongSelf = weakSelf;
                                            [strongSelf parseResult:data connectionError:error];
                                            if (completion) {
                                                completion();
                                            }
                                        }
                                    }];
    [task resume];
}

- (NSURLRequest *)requestWithVariant:(HLResultVariant *)variant
{
    NSMutableURLRequest * request = [[NSMutableURLRequest alloc] init];
    NSString * longUrlString = [HLUrlUtils sharingBookingUrlStringWithVariant:variant];
    self.longUrlString = longUrlString;
    longUrlString = [HLUrlUtils urlencodeString:longUrlString];
   
    NSString *requestString = [NSString stringWithFormat:@"%@username=%@&password=%@&action=shorturl&format=json&url=%@", HLUrlUtils.URLShortenerBaseURLString, HL_URL_SHORTENER_USERNAME, HL_URL_SHORTENER_PASSWORD, longUrlString];
    requestString = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    request.URL = [NSURL URLWithString:requestString];
    request.timeoutInterval = 5.0;
    
    return request;
}

- (void)parseResult:(NSData *)data connectionError:(NSError *)connectionError
{
    if (!connectionError) {
        NSError * error = nil;
        NSDictionary * dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
        
        if (!error) {
            self.shortenedUrlString = dict[@"shorturl"];
        }
    }
}

- (NSString *)shortenedUrl
{
    return self.shortenedUrlString ?: self.longUrlString;
}

@end
