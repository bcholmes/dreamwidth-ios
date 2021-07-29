//
//  DreamwidthApi.m
//  dreamwidth
//
//  Created by BC Holmes on 2015-03-12.
//  Copyright (c) 2015 Ayizan Studios. All rights reserved.
//

#import "DreamwidthApi.h"

#import <AFNetworking/AFNetworking.h>
#import <NSDate-Additions/NSDate+Additions.h>

#import "BCHDWEntryHandle.h"

#define DREAMWIDTH_FLAT_API_URL @"https://www.dreamwidth.org/interface/flat"
#define DREAMWIDTH_URL [NSURL URLWithString:@"https://www.dreamwidth.org/interface/flat"]

@interface BCHDWSession : NSObject<NSCoding>

@property (nonatomic, strong) NSString* sessionId;
@property (nonatomic, strong) NSDate* expiry;
@property (nonatomic, readonly) BOOL isExpired;

@end

@implementation BCHDWSession

- (id) initWithCoder:(NSCoder*)decoder {
    if ((self = [super init])) {
        self.sessionId = [decoder decodeObjectForKey:@"sessionId"];
        self.expiry = [decoder decodeObjectForKey:@"expiry"];
    }
    return self;
}

-(BOOL) isExpired {
    return [[NSDate new] isLaterThanDate:self.expiry];
}

- (void) encodeWithCoder:(NSCoder*)encoder {
    [encoder encodeObject:self.sessionId forKey:@"sessionId"];
    [encoder encodeObject:self.expiry forKey:@"expiry"];
}
@end

@interface DreamwidthApi()

@property (nonatomic, readonly) NSString* version;
@property (nonatomic, strong) BCHDWSession* session;
@property (nonnull, nonatomic, strong) AFHTTPSessionManager* manager;
@property (nonnull, nonatomic, strong) NSDateFormatter* dateFormatter;

@end

@implementation DreamwidthApi

@synthesize session = _session;

-(instancetype) init {
    if (self = [super init]) {
        self.dateFormatter = [NSDateFormatter new];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm:ss";
        self.manager = [AFHTTPSessionManager manager];
        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [self.manager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.manager.responseSerializer.acceptableContentTypes = [self.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/plain"];
        self.manager.completionQueue = dispatch_queue_create("org.ayizan.dreamballoon.flat", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void) setSession:(BCHDWSession*) session {
    _session = session;
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:session] forKey:@"session"];
}

-(BCHDWSession*) session {
    if (_session == nil) {
        BCHDWSession* session = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:@"session"]];
        if (session != nil) {
            _session = session;
        }
    }
    return _session;
}

-(BOOL) isSessionReady {
    return self.session != nil && !self.session.isExpired;
}

-(NSString*) version {
    return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
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

-(void) performFunctionWithWebSession:(void (^)(NSError*, NSString*)) callback {
    if (self.isSessionReady) {
        callback(nil, self.session.sessionId);
    } else {
        NSDate* now = [NSDate new];
        NSDictionary* parameters = @{ @"mode": @"sessiongenerate",
                                      @"user": self.currentUser.username,
                                      @"auth_method": @"clear",
                                      @"password": self.currentUser.password,
                                      @"expiration": @"long",
                                      @"clientversion": [NSString stringWithFormat:@"DreamBalloon/%@", self.version],
                                      @"ver": @"1"
                                      };
        
        [self.manager POST:DREAMWIDTH_FLAT_API_URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            NSDictionary* result = [self createResponseMap:(NSData*) responseObject];
            NSLog(@"Web session response map %@", result);
            NSString* success = [result objectForKey:@"success"];
            if ([success isEqualToString:@"OK"]) {
                BCHDWSession* session = [BCHDWSession new];
                session.expiry = [now dateByAddingDays:27];
                session.sessionId = [result objectForKey:@"ljsession"];
                self.session = session;
                callback(nil, session.sessionId);
            } else {
                callback([NSError errorWithDomain:DWErrorDomain code:DWSessionError userInfo:@{ NSLocalizedDescriptionKey : [result objectForKey:@"errmsg"] }], nil);
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"sessiongenerate failed."}], nil);
        }];
    }
}

-(void) performWithChallenge:(void (^) (NSError* error, NSString* challenge)) callback {
    [self.manager POST:DREAMWIDTH_FLAT_API_URL parameters:@{ @"mode" : @"getchallenge", @"ver" : @"1" } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary* result = [self createResponseMap:(NSData*) responseObject];
        if (result != nil) {
            NSString* success = [result objectForKey:@"success"];
            NSString* challenge = [result objectForKey:@"challenge"];
            if ([success isEqualToString:@"OK"] && challenge != nil) {
                callback(nil, challenge);
            } else {
                NSString* message = [result objectForKey:@"errmsg"];
                callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": message ? message : @"getchallenge failed" }], nil);
            }
        } else {
            callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Challenge error: %@", error);
        callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
    }];
}

-(void) loginWithUser:(NSString*) userid password:(NSString*) password andCompletion:(void (^)(NSError* error, BCHDWUser* user)) callback {
    NSDictionary* parameters = @{ @"mode": @"login",
                                    @"user": userid,
                                    @"auth_method": @"clear",
                                    @"password": password,
                                    @"getpickws": @"1",
                                    @"getpickwurls": @"1",
                                    @"clientversion": [NSString stringWithFormat:@"DreamBalloon/%@", self.version]
                                  };
    [self.manager POST:DREAMWIDTH_FLAT_API_URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSDictionary* result = [self createResponseMap:(NSData*) responseObject];
        NSString* success = [result objectForKey:@"success"];
        if ([success isEqualToString:@"OK"]) {
            BCHDWUser* user = [BCHDWUser parseMap:result];
            user.username = userid;
            user.password = password;
            self.currentUser = user;
            callback(nil, user);
        } else {
            callback([NSError errorWithDomain:DWErrorDomain code:DWAuthenticationFailedError userInfo:@{ NSLocalizedDescriptionKey : [result objectForKey:@"errmsg"] }], nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        self.currentUser = nil;
        callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
    }];
}

-(void) getEvents:(BCHDWUser*) user completion:(void (^)(NSError* error, NSArray* entries)) callback {
    [self performWithChallenge:^(NSError* error, NSString* challenge) {
        if (error == nil) {
            NSDictionary* parameters = @{ @"mode": @"getevents",
                                          @"user": user.username,
                                          @"auth_method": @"clear",
                                          @"password": user.password,
                                          @"selecttype": @"lastn",
                                          @"howmany": @"40",
                                          @"clientversion": [NSString stringWithFormat:@"DreamBalloon/%@", self.version],
                                          @"ver": @"1"
                                          };
            [self callGetEventsFlatApi:parameters callback:callback];
        } else {
            NSLog(@"Get events error: %@", error);
            callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
        }
    }];
}

- (void) callGetEventsFlatApi:(NSDictionary*) parameters callback:(void (^)(NSError*, NSArray*)) callback {
    [self.manager POST:DREAMWIDTH_FLAT_API_URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSDictionary* result = [self createResponseMap:(NSData*) responseObject];
        NSArray* entries = [BCHDWEntryHandle parseMap:result];
        NSLog(@"number of entries: %lu", entries.count);
        callback(nil, entries);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Get events flat API error: %@", error);
        callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"getevents failed."}], nil);
    }];
}

-(void) checkFriends:(NSDate*) date completion:(void (^)(NSError* error, BOOL newEntries)) callback {
    [self performWithChallenge:^(NSError* error, NSString* challenge) {
        if (error == nil) {
            NSDictionary* parameters = @{ @"mode": @"checkfriends",
                                          @"user": self.currentUser.username,
                                          @"auth_method": @"clear",
                                          @"password": self.currentUser.password,
                                          @"lastupdate": [self.dateFormatter stringFromDate:date],
                                          @"clientversion": [NSString stringWithFormat:@"DreamBalloon/%@", self.version],
                                          @"ver": @"1"
                                          };
            
            [self.manager POST:DREAMWIDTH_FLAT_API_URL parameters:parameters progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                NSDictionary* result = [self createResponseMap:(NSData*) responseObject];
                callback(nil, [result[@"new"] isEqualToString:@"1"]);
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"getevents failed."}], nil);
            }];
        } else {
            NSLog(@"Check friends error: %@", error);
            callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
        }
    }];
}

-(void) getEvents:(BCHDWUser*) user since:(NSDate*) date completion:(void (^)(NSError* error, NSArray* entries)) callback {
    [self performWithChallenge:^(NSError* error, NSString* challenge) {
        if (error == nil) {
            NSDictionary* parameters = @{ @"mode": @"getevents",
                                          @"user": user.username,
                                          @"auth_method": @"clear",
                                          @"password": user.password,
                                          @"selecttype": @"syncitems",
                                          @"lastsync": [self.dateFormatter stringFromDate:date],
                                          @"clientversion": [NSString stringWithFormat:@"DreamBalloon/%@", self.version],
                                          @"ver": @"1"
                                          };
            
            [self callGetEventsFlatApi:parameters callback:callback];
        } else {
            NSLog(@"Get events error: %@", error);
            callback([[NSError alloc] initWithDomain:DWErrorDomain code:400 userInfo:@{@"Error reason": @"getchallenge failed."}], nil);
        }
    }];
}


-(BOOL) isLoggedIn {
    return self.currentUser != nil;
}

@end
