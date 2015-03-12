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

-(NSDictionary*) getChallengeMap {
    NSMutableURLRequest* post = [NSMutableURLRequest requestWithURL:DREAMWIDTH_URL];
    [post setHTTPMethod: @"POST"];
    NSString* params = @"mode=getchallenge&ver=1";
    [post setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
    

    NSURLResponse* response;
    NSError* error;
    NSData *data = [NSURLConnection sendSynchronousRequest:post returningResponse:&response error:&error];
    if (data != nil) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"http status code: %lu", (unsigned long)httpResponse.statusCode);
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

-(void) loginWithUser:(NSString*) userid password:(NSString*) password andCompletion:(void (^)(BOOL, NSError*)) callback {
    if ([NSThread isMainThread]) {

        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
            [self loginWithUser:userid password:password andCompletion:callback];
        });
    } else {
        NSDictionary* challengeMap = [self getChallengeMap];
        NSLog(@"Result is %@", [challengeMap objectForKey:@"success"]);
    }
    
}

@end
