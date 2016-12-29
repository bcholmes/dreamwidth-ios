//
//  DreamwidthApi.m
//  dreamwidth
//
//  Created by BC Holmes on 2015-03-12.
//  Copyright (c) 2015 Ayizan Studios. All rights reserved.
//

#import <CommonCrypto/CommonDigest.h>
#import "DreamwidthApi.h"
#import "BCHDWEntry.h"

#define DREAMWIDTH_URL [NSURL URLWithString:@"http://www.dreamwidth.org/interface/flat"]

@interface DreamwidthApi()

@property (nonatomic, readonly) NSString* version;

@end

@implementation DreamwidthApi

-(NSString*) version {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
}

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

-(void) loginWithUser:(NSString*) userid password:(NSString*) password andCompletion:(void (^)(NSError* error, BCHDWUser* user)) callback {
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
                                        @"auth_response": response,
                                        @"getpickws": @"1",
                                        @"getpickwurls": @"1",
                                        @"clientversion": [NSString stringWithFormat:@"IosApiTest/%@", self.version]
                                      };
        
        NSDictionary* result = [self postHttpRequest:parameters];
        NSLog(@"Result is %@", result);
        NSString* success = [result objectForKey:@"success"];
        if ([success isEqualToString:@"OK"]) {
            BCHDWUser* user = [BCHDWUser parseMap:result];
            user.username = userid;
            user.encodedPassword = encodedPassword;
            self.currentUser = user;
            callback(nil, user);
        } else {
            callback([NSError errorWithDomain:DWErrorDomain code:DWAuthenticationFailedError userInfo:@{ NSLocalizedDescriptionKey : [result objectForKey:@"errmsg"] }], nil);
        }
        
    } else {
        self.currentUser = nil;
        callback([[NSError alloc] initWithDomain:@"org.ayizan.http" code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
    }
}

-(void) getEvents:(BCHDWUser*) notUsed completion:(void (^)(NSError* error, NSArray* entries)) callback {
    NSDictionary* challengeMap = [self getChallengeMap];
    if (challengeMap != nil) {
        NSString* challenge = [challengeMap objectForKey:@"challenge"];
        NSString* response = [self md5:[challenge stringByAppendingString:self.currentUser.encodedPassword]];
        
        NSDictionary* parameters = @{ @"mode": @"getevents",
                                      @"user": self.currentUser.username,
                                      @"auth_method": @"challenge",
                                      @"auth_challenge": challenge,
                                      @"auth_response": response,
                                      @"selecttype": @"lastn",
                                      @"howmany": @"20",
                                      @"clientversion": [NSString stringWithFormat:@"IosApiTest/%@", self.version],
                                      @"ver": @"1"
                                      };
        
        NSDictionary* result = [self postHttpRequest:parameters];
        NSLog(@"Result is %@", result);
        callback(nil, [BCHDWEntry parseMap:result user:self.currentUser.username]);
        
    } else {
        callback([[NSError alloc] initWithDomain:@"org.ayizan.http" code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
    }
}

-(void) getReadingList:(BCHDWUser*) user completion:(void (^)(NSError* error, NSArray* entries)) callback {
    NSDictionary* challengeMap = [self getChallengeMap];
    if (challengeMap != nil) {
        NSString* challenge = [challengeMap objectForKey:@"challenge"];
        NSString* response = [self md5:[challenge stringByAppendingString:user.encodedPassword]];
        
        NSDictionary* parameters = @{ @"mode": @"syncitems",
                                      @"user": user.username,
                                      @"auth_method": @"challenge",
                                      @"auth_challenge": challenge,
                                      @"auth_response": response,
                                      @"clientversion": [NSString stringWithFormat:@"IosApiTest/%@", self.version],
                                      @"ver": @"1"
                                      };
        
        NSDictionary* result = [self postHttpRequest:parameters];
        NSLog(@"Result is %@", result);
        callback(nil, nil);
        
    } else {
        callback([[NSError alloc] initWithDomain:@"org.ayizan.http" code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
    }
}

-(BOOL) isLoggedIn {
    return self.currentUser != nil;
}

@end
