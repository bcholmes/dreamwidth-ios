//
//  DreamwidthApi.m
//  dreamwidth
//
//  Created by BC Holmes on 2015-03-12.
//  Copyright (c) 2015 Ayizan Studios. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "DreamwidthApi.h"

#define DREAMWIDTH_URL [NSURL URLWithString:@"http://www.dreamwidth.org/interface/flat"]

@implementation DreamwidthApi

- (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, (int) strlen(cStr), digest );
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return  output;
}

-(NSDictionary*) createResponseMap:(NSData*) data {
    NSString* stringData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
    NSArray* lines = [stringData componentsSeparatedByString:@"\n"];
    for (NSUInteger i = 0; i < (lines.count - 1); i += 2) {
        [dictionary setObject:lines[i+1] forKey:lines[i]];
    }
    
    return dictionary;
}

-(NSString*) convertToString:(NSDictionary*) requestParameters {
    NSMutableString* output = [[NSMutableString alloc] init];
    for (NSString* key in requestParameters.allKeys) {
        NSString* value = [requestParameters objectForKey:key];
        if (output.length > 0) {
            [output appendString:@"&"];
        }
        [output appendString:key];
        [output appendString:@"="];
        [output appendString:[value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return output;
}

-(NSDictionary*) postHttpRequest:(NSDictionary*) requestParameters {
    NSMutableURLRequest* post = [NSMutableURLRequest requestWithURL:DREAMWIDTH_URL];
    [post setHTTPMethod: @"POST"];
    [post setHTTPBody:[[self convertToString:requestParameters] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLResponse* response;
    NSError* error;
    NSData *data = [NSURLConnection sendSynchronousRequest:post returningResponse:&response error:&error];
    if (data != nil) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"http status code for request mode %@: %lu", [requestParameters objectForKey:@"mode"], (unsigned long)httpResponse.statusCode);
        NSLog(@"http content type: %@", [httpResponse.allHeaderFields objectForKey:@"Content-Type"]);
        if (httpResponse.statusCode == 200) {
            
            return [self createResponseMap:data];
        } else {
            return nil;
        }
    } else if (error != nil) {
        NSLog(@"Must be an error %@ ", error.description);
        return nil;
    } else {
        return nil;
    }
}

-(NSDictionary*) getChallengeMap {
    return [self postHttpRequest:@{ @"mode" : @"getchallenge", @"ver" : @"1" }];
}

-(void) loginWithUser:(NSString*) userid password:(NSString*) password andCompletion:(void (^)(NSError*)) callback {
    if ([NSThread isMainThread]) {

        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [self loginWithUser:userid password:password andCompletion:callback];
        });
    } else {
        NSDictionary* challengeMap = [self getChallengeMap];
        if (challengeMap != nil) {
            NSLog(@"Result is %@", [challengeMap objectForKey:@"success"]);
            NSString* challenge = [challengeMap objectForKey:@"challenge"];
            NSLog(@"challenge is : %@", challenge);
            NSString* encodedPassword = [self md5:password];
            NSString* response = [self md5:[challenge stringByAppendingString:encodedPassword]];
            
            NSDictionary* parameters = @{ @"mode": @"login",
                                                 @"user": userid,
                                                 @"auth_method": @"challenge",
                                                 @"auth_challenge": challenge,
                                                 @"auth_response": response};
            
            NSDictionary* result = [self postHttpRequest:parameters];
            NSLog(@"Result is %@", result);
            
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                callback([[NSError alloc] initWithDomain:@"org.ayizan.http" code:400 userInfo:@{@"Error reason": @"getchallenge failed."}]);
            });
        }
    }
    
}

@end
