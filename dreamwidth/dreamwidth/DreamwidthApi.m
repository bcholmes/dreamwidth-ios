//
//  DreamwidthApi.m
//  dreamwidth
//
//  Created by BC Holmes on 2015-03-12.
//  Copyright (c) 2015 Ayizan Studios. All rights reserved.
//

#import "DreamwidthApi.h"

#import <AFNetworking/AFNetworking.h>
#import <CommonCrypto/CommonDigest.h>
#import <NSDate-Additions/NSDate+Additions.h>

#import "BCHDWEntry.h"

#define DREAMWIDTH_FLAT_API_URL @"https://www.dreamwidth.org/interface/flat"
#define DREAMWIDTH_URL [NSURL URLWithString:@"https://www.dreamwidth.org/interface/flat"]

@interface BCHDWSession : NSObject

@property (nonatomic, strong) NSString* sessionId;
@property (nonatomic, strong) NSDate* expiry;
@property (nonatomic, readonly) BOOL isExpired;

@end

@implementation BCHDWSession

-(BOOL) isExpired {
    return [[NSDate new] isLaterThanDate:self.expiry];
}

@end

@interface DreamwidthApi()

@property (nonatomic, readonly) NSString* version;
@property (nonatomic, strong) BCHDWSession* session;
@property (nonnull, nonatomic, strong) AFHTTPSessionManager* manager;

@end

@implementation DreamwidthApi

-(instancetype) init {
    if (self = [super init]) {
        self.manager = [AFHTTPSessionManager manager];
        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [self.manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manager.responseSerializer.acceptableContentTypes = [self.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
        self.manager.completionQueue = dispatch_queue_create("org.ayizan.dreamballoon.flat", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

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
        [output appendString:[value stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
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

-(void) performFunctionWithWebSession:(void (^)(NSError*, NSString*)) callback {
    if (self.session != nil && !self.session.isExpired) {
        callback(nil, self.session.sessionId);
    } else {
        [self performWithChallenge:^(NSError* error, NSString* challenge) {
            if (error == nil) {
                NSDate* now = [NSDate new];
                NSDictionary* parameters = @{ @"mode": @"sessiongenerate",
                                              @"user": self.currentUser.username,
                                              @"auth_method": @"challenge",
                                              @"auth_challenge": challenge,
                                              @"auth_response": [self generateChallengeResponse:challenge user:self.currentUser],
                                              @"expiration": @"short",
                                              @"clientversion": [NSString stringWithFormat:@"DreamBalloon/%@", self.version],
                                              @"ver": @"1"
                                              };
                
                [self.manager POST:DREAMWIDTH_FLAT_API_URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                    
                    NSDictionary* result = [self createResponseMap:(NSData*) responseObject];
                    NSString* success = [result objectForKey:@"success"];
                    if ([success isEqualToString:@"OK"]) {
                        BCHDWSession* session = [BCHDWSession new];
                        session.expiry = [now dateByAddingHours:22]; // "short" expiration is good for 24 hours. Let's be conservative.
                        session.sessionId = [result objectForKey:@"ljsession"];
                        self.session = session;
                        callback(nil, session.sessionId);
                    } else {
                        callback([NSError errorWithDomain:DWErrorDomain code:DWSessionError userInfo:@{ NSLocalizedDescriptionKey : [result objectForKey:@"errmsg"] }], nil);
                    }
                    
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                    callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"sessiongenerate failed."}], nil);
                }];
            } else {
                callback(error, nil);
            }
        }];
    }
}

-(NSDictionary*) getChallengeMap {
    return [self postHttpRequest:@{ @"mode" : @"getchallenge", @"ver" : @"1" }];
}

-(void) performWithChallenge:(void (^) (NSError* error, NSString* challenge)) callback {
    [self.manager POST:DREAMWIDTH_FLAT_API_URL parameters:@{ @"mode" : @"getchallenge", @"ver" : @"1" } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary* result = [self createResponseMap:(NSData*) responseObject];
        if (result != nil) {
            callback(nil, [result objectForKey:@"challenge"]);
        } else {
            callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
    }];
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
                                        @"clientversion": [NSString stringWithFormat:@"DreamBalloon/%@", self.version]
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
        callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
    }
}

- (NSString*) generateChallengeResponse:(NSString*) challenge user:(BCHDWUser*) user {
    return [self md5:[challenge stringByAppendingString:user.encodedPassword]];
}

-(void) getEvents:(BCHDWUser*) user completion:(void (^)(NSError* error, NSArray* entries)) callback {
    NSDictionary* challengeMap = [self getChallengeMap];
    if (challengeMap != nil) {
        NSString* challenge = [challengeMap objectForKey:@"challenge"];
        
        NSDictionary* parameters = @{ @"mode": @"getevents",
                                      @"user": user.username,
                                      @"auth_method": @"challenge",
                                      @"auth_challenge": challenge,
                                      @"auth_response": [self generateChallengeResponse:challenge user:user],
                                      @"selecttype": @"lastn",
                                      @"howmany": @"20",
                                      @"clientversion": [NSString stringWithFormat:@"DreamBalloon/%@", self.version],
                                      @"ver": @"1"
                                      };
        
        NSDictionary* result = [self postHttpRequest:parameters];
        NSLog(@"Result is %@", result);
        callback(nil, [BCHDWEntry parseMap:result user:user.username]);
        
    } else {
        callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
    }
}

-(void) getReadingList:(void (^)(NSError* error, NSArray* entries)) callback {
    [self performWithChallenge:^(NSError* error, NSString* challenge) {
        if (error == nil) {
            NSDictionary* parameters = @{ @"mode": @"syncitems",
                                          @"user": self.currentUser.username,
                                          @"auth_method": @"challenge",
                                          @"auth_challenge": challenge,
                                          @"auth_response": [self generateChallengeResponse:challenge user:self.currentUser],
                                          @"clientversion": [NSString stringWithFormat:@"DreamBalloon/%@", self.version],
                                          @"ver": @"1"
                                          };
            
            [self.manager POST:DREAMWIDTH_FLAT_API_URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                NSDictionary* result = [self createResponseMap:(NSData*) responseObject];
                NSString* success = [result objectForKey:@"success"];
                if ([success isEqualToString:@"OK"]) {

                    NSLog(@"sync items result: %@", result);
                    callback(nil, nil);

                } else {
                    callback([NSError errorWithDomain:DWErrorDomain code:DWSessionError userInfo:@{ NSLocalizedDescriptionKey : [result objectForKey:@"errmsg"] }], nil);
                }
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"sessiongenerate failed."}], nil);
            }];
            NSDictionary* result = [self postHttpRequest:parameters];
            NSLog(@"Result is %@", result);
            callback(nil, nil);
            
        } else {
            callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
        }
    }];
}

-(void) postEntry:(NSString*) entryText asUser:(BCHDWUser*) user completion:(void (^)(NSError* error, NSString* url)) callback {
    NSDictionary* challengeMap = [self getChallengeMap];
    if (challengeMap != nil) {
        NSString* challenge = [challengeMap objectForKey:@"challenge"];
        NSString* response = [self md5:[challenge stringByAppendingString:user.encodedPassword]];
        NSDate* now = [NSDate new];
        NSDateComponents* dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:now];
        
        NSDictionary* parameters = @{ @"mode": @"postevent",
                                      @"user": self.currentUser.username,
                                      @"auth_method": @"challenge",
                                      @"auth_challenge": challenge,
                                      @"auth_response": response,
                                      @"subject": @"A test post",
                                      @"event": entryText,
                                      @"prop_picture_keyword": @"i had an accident",
                                      @"year": [NSString stringWithFormat:@"%ld", [dateComponents year]],
                                      @"mon": [NSString stringWithFormat:@"%ld", [dateComponents month]],
                                      @"day": [NSString stringWithFormat:@"%ld", [dateComponents day]],
                                      @"hour": [NSString stringWithFormat:@"%ld", [dateComponents hour]],
                                      @"min": [NSString stringWithFormat:@"%ld", [dateComponents minute]],
                                      @"clientversion": [NSString stringWithFormat:@"DreamBalloon/%@", self.version],
                                      @"ver": @"1"
                                      };
        
        NSLog(@"parameters: %@", parameters);
        NSDictionary* result = [self postHttpRequest:parameters];
        NSLog(@"Result is %@", result);
        if ([@"OK" isEqualToString:[result objectForKey:@"success"]]) {
            callback(nil, nil);
        } else {
            NSLog(@"Error: %@", [result objectForKey:@"errmsg"]);
            callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"fail fail."}], nil);
        }
    } else {
        callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
    }
    
}


-(BOOL) isLoggedIn {
    return self.currentUser != nil;
}

@end
