//
//  NSError+HLCustomErrors.m
//  HotelLook
//
//  Created by Anton Chebotov on 06/02/14.
//  Copyright (c) 2014 Anton Chebotov. All rights reserved.
//

#import "NSError+HLCustomErrors.h"

NSString * const kHLServerErrorDomain = @"HLServerErrorDomain";
NSString * const kHLURLResponseErrorDomain = @"HLURLResponseErrorDomain";
NSString * const kHLNetworkErrorDomain = @"HLNetworErrorDomain";
NSString * const kHLErrorDomain = @"HLErrorDomain";
NSString * const kHLNonCriticalErrorDomain = @"HLNonCriticalErrorDomain";
NSString * const kHLMigrationErrorDomain = @"kHLMigrationErrorDomain";

@implementation NSError (HLCustomErrors)

+ (NSError *)errorWithCode:(HLErrorCode)code
{
	return [NSError errorWithDomain:[NSError hlErrorDomain] code:code userInfo:nil];
}

+ (NSError *)errorServerWithCode:(HLErrorCode)code
{
    return [NSError errorWithDomain:[NSError hlServerErrorDomain] code:code userInfo:nil];
}

+ (NSError *)errorURLResponseWithCode:(HLErrorCode)code
{
    return [NSError errorWithDomain:[NSError hlURLResponseErrorDomain] code:code userInfo:nil];
}

+ (NSError *)errorNonCriticalWithCode:(HLErrorCode)code
{
    return [NSError errorWithDomain:[NSError hlNonCriticalErrorDomain] code:code userInfo:nil];
}

+ (NSError *)errorMigrationWithCode:(HLErrorCode)code description:(NSString *)description
{
    NSDictionary *userInfo = description ? @{NSLocalizedDescriptionKey: description} : nil;

    return [NSError errorWithDomain:[NSError hlMigrationErrorDomain] code:code userInfo:userInfo];
}

+ (NSString *)hlServerErrorDomain
{
    return kHLServerErrorDomain;
}

+ (NSString *)hlNetworkErrorDomain
{
    return kHLNetworkErrorDomain;
}

+ (NSString *)hlErrorDomain
{
	return kHLErrorDomain;
}

+ (NSString *)hlURLResponseErrorDomain
{
    return kHLURLResponseErrorDomain;
}

+ (NSString *)hlNonCriticalErrorDomain
{
    return kHLNonCriticalErrorDomain;
}

+ (NSString *)hlMigrationErrorDomain
{
    return kHLMigrationErrorDomain;
}

@end
