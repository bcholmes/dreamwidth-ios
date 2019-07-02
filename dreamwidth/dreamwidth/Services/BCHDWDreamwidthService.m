//
//  BCHDWDreamwidthService.m
//  dreamwidth
//
//  Created by BC Holmes on 2016-12-29.
//  Copyright © 2016 Ayizan Studios. All rights reserved.
//

#import "BCHDWDreamwidthService.h"

#import <AFNetworking/AFNetworking.h>
#import <UYLPasswordManager/UYLPasswordManager.h>
#import <HTMLKit/HTMLKit.h>
#import <NSDate-Additions/NSDate+Additions.h>

#import "BCHDWEntryOld.h"

@interface BCHDWEntryHandle : NSObject

@property (nonatomic, strong) NSString* url;
@property (nonatomic, strong) NSString* text;

@end

@implementation BCHDWEntryHandle

@end


@interface BCHDWDreamwidthService()

@property (nonatomic, strong) DreamwidthApi* api;
@property (nonatomic, strong) BCHDWPersistenceService* persistenceService;
@property (nonnull, nonatomic, strong) AFHTTPSessionManager* htmlManager;
@property (nonnull, strong) NSDateFormatter* dateFormatter;
@end

@implementation BCHDWDreamwidthService

-(instancetype) initWithApi:(DreamwidthApi*) api persistence:(BCHDWPersistenceService*) persistenceService {
    if (self = [super init]) {
        self.persistenceService = persistenceService;
        self.api = api;
        
        self.dateFormatter = [NSDateFormatter new];
        self.dateFormatter.dateFormat = @"yyyy-MM-dd hh:mm a";
        self.dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
        
        self.htmlManager = [AFHTTPSessionManager manager];
        self.htmlManager.requestSerializer = [AFHTTPRequestSerializer serializer];
        [self.htmlManager.requestSerializer setValue:@"application/x-www-form-urlencoded; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
        self.htmlManager.responseSerializer = [AFHTTPResponseSerializer serializer];
        self.htmlManager.completionQueue = dispatch_queue_create("org.ayizan.dreamballoon.html", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(BOOL) isLoggedIn {
    return self.api.currentUser != nil || [self isUseridAndPasswordStoredInKeychain];
}

-(BOOL) isUseridAndPasswordStoredInKeychain {
    UYLPasswordManager* manager = [UYLPasswordManager sharedInstance];
    NSString* userid = [manager keyForIdentifier:@"userid"];
    NSString* password = [manager keyForIdentifier:@"password"];
    return userid != nil && password != nil;
}

- (void) setAuthenticationCookie:(NSString * _Nullable) session {
    NSString* loggedIn = session;
    NSRange first = [session rangeOfString:@":"];
    NSRange last = [session rangeOfString:@":" options:NSBackwardsSearch];
    
    if (first.location != NSNotFound && last.location != NSNotFound) {
        loggedIn = [session substringWithRange:NSMakeRange(first.location + 1, last.location - first.location - 1)];
    }
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:[NSHTTPCookie cookieWithProperties:@{NSHTTPCookieDomain: @"www.dreamwidth.org", NSHTTPCookiePath: @"/", NSHTTPCookieName: @"ljmastersession", NSHTTPCookieValue: session }]];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:[NSHTTPCookie cookieWithProperties:@{NSHTTPCookieDomain: @".dreamwidth.org", NSHTTPCookiePath: @"/", NSHTTPCookieName: @"ljloggedin", NSHTTPCookieValue: loggedIn }]];
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:[NSHTTPCookie cookieWithProperties:@{NSHTTPCookieDomain: @".dreamwidth.org", NSHTTPCookiePath: @"/", NSHTTPCookieName: @"BMLschemepref", NSHTTPCookieValue: @"tropo-red" }]];
}

- (void) fetchReadingPageLight:(NSUInteger) skip friends:(NSMutableSet*) friendSet {
    [self.htmlManager GET:[NSString stringWithFormat:@"https://www.dreamwidth.org/mobile/read?skip=%lu", skip] parameters:nil progress:nil success:^(NSURLSessionTask* task, id responseObject) {

        NSArray* urls = [self findAllFriends:(NSData*) responseObject friends:friendSet];
        
        if (skip == 0) {
            [self fetchReadingPageLight:50 friends:friendSet];
        }
        for (NSString* url in urls) {
            [self fetchEntry:url];
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

-(NSArray*) findAllFriends:(NSData*) htmlData friends:(NSMutableSet*) friendSet {

    NSMutableArray* result = [NSMutableArray new];
    HTMLParser* parser = [[HTMLParser alloc] initWithString:[[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding]];
    HTMLDocument* document = [parser parseDocument];
    NSArray* links = [document querySelectorAll:@"a"];
    for (HTMLElement* anchor in links) {
        NSString* href = anchor.attributes[@"href"];
        if ([href rangeOfString:@".html?"].location != NSNotFound) {
            BCHDWEntryHandle* handle = [BCHDWEntryHandle new];
            handle.text = anchor.textContent;
            handle.url = [href substringToIndex:[href rangeOfString:@"?"].location];
            if (![friendSet containsObject:handle.url]) {
                [friendSet addObject:handle.url];
                [result addObject:handle.url];
            }
        }
    }
    return [NSArray arrayWithArray:result];
}

-(void) fetchEntry:(NSString*) entryUrl {
    [self.htmlManager GET:[NSString stringWithFormat:@"%@?format=light&expand_all=1", entryUrl] parameters:nil progress:nil success:^(NSURLSessionTask* task, id responseObject) {

        HTMLParser* parser = [[HTMLParser alloc] initWithString:[[NSString alloc] initWithData:(NSData*) responseObject encoding:NSUTF8StringEncoding]];
        HTMLDocument* document = [parser parseDocument];
        
        NSString* author = [document querySelector:@".poster-info .ljuser"].textContent;
        if (author != nil && author.length > 0) {
            BCHDWEntry* entry = [self.persistenceService entryByUrl:entryUrl];
            [entry.managedObjectContext performBlock:^{
                NSDate* newestComment = nil;
                entry.subject = [document querySelector:@".entry-title"].textContent;
                HTMLElement* avatarAnchor = [document querySelector:@".userpic img"];
                entry.avatarUrl = avatarAnchor.attributes[@"src"];
                entry.author = author;

                NSString* entryDate = [document querySelector:@".poster-info .datetime"].textContent;
                entry.creationDate = [self.dateFormatter dateFromString:entryDate];
                if (entry.updateDate == nil) {
                    entry.updateDate = entry.creationDate;
                }
                
                NSArray* comments = [document querySelectorAll:@".comment-thread"];
                NSUInteger count = 0;
                for (HTMLElement* comment in comments) {
                    NSString* commentId = [comment querySelector:@".dwexpcomment"].attributes[@"id"];
                    if (commentId != nil && [commentId rangeOfString:@"cmt"].location == 0) {
                        commentId = [commentId substringFromIndex:3];
                    }
                    
                    NSString* author = [comment querySelector:@".ljuser"].textContent;
                    BCHDWComment* commentRecord = [self.persistenceService commentById:commentId author:author];
                    commentRecord.entry = entry;
                    
                    NSString* depth = comment.attributes[@"class"];
                    NSRange depthRange = [depth rangeOfString:@"comment-depth-"];
                    if (depth != nil && depthRange.location != NSNotFound) {
                        depth = [depth substringFromIndex:depthRange.location + depthRange.length];
                    }
                    commentRecord.depth = [NSNumber numberWithInteger:[depth integerValue]];
                    
                    NSString* date = [comment querySelector:@".comment-date-text"].textContent;
                    if ([date rangeOfString:@" (local)"].location != NSNotFound) {
                        date = [date substringToIndex:[date rangeOfString:@" (local)"].location];
                    }
                    commentRecord.creationDate = [self.dateFormatter dateFromString:date];

                    HTMLElement* title = [comment querySelector:@".comment-title span"];
                    NSString* titleClass = title.attributes[@"class"];
                    if ([titleClass rangeOfString:@"invisible"].location == NSNotFound) {
                        commentRecord.subject = title.textContent;
                    }
                    
                    // BCH: - this is wrong if there's any formatting, but let's just stick with it for now
                    commentRecord.commentText = [comment querySelector:@".comment-content"].textContent;
                    
                    if (newestComment == nil || [newestComment isEarlierThanDate:commentRecord.creationDate]) {
                        newestComment = commentRecord.creationDate;
                    }
                    
                    count++;
                }
                
                entry.numberOfComments = [NSNumber numberWithUnsignedInteger:count];
                if (newestComment != nil && [newestComment isLaterThanDate:entry.updateDate]) {
                    entry.updateDate = newestComment;
                }
                
                [entry.managedObjectContext save:nil];
            }];
        } else {
 //           NSLog(@"HTML >>>> %@", [[NSString alloc] initWithData:(NSData*) responseObject encoding:NSUTF8StringEncoding]);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"fetch entry: %@", error);
    }];
}

-(void) fetchRecentReadingPageActivity {
    [self.api performFunctionWithWebSession:^(NSError * _Nullable error, NSString * _Nullable session) {
        if (error == nil) {
            [self setAuthenticationCookie:session];
            [self fetchReadingPageLight:0 friends:[NSMutableSet new]];
        } else {
            NSLog(@"session error: %@", error);
        }
    }];
}

-(void) loginUsingStoredCredentials:(void (^)(NSError*, BCHDWUser*))callback {
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
        UYLPasswordManager* manager = [UYLPasswordManager sharedInstance];
        NSString* userid = [manager keyForIdentifier:@"userid"];
        NSString* password = [manager keyForIdentifier:@"password"];

        [self.api loginWithUser:userid password:password andCompletion:^(NSError* error, BCHDWUser* user) {
            if (error == nil) {
                self.currentUser = user;
            }
            callback(error, user);
        }];
    });
}

-(void) loginWithUser:(NSString*) userid password:(NSString*) password andCompletion:(void (^)(NSError*, BCHDWUser*))callback {
    [self.api loginWithUser:userid password:password andCompletion:^(NSError* error, BCHDWUser* user) {
        if (error == nil) {
            UYLPasswordManager* manager = [UYLPasswordManager sharedInstance];
            [manager registerKey:userid forIdentifier:@"userid"];
            [manager registerKey:password forIdentifier:@"password"];
            self.currentUser = user;
            
            [self synchWithServer];
        }
        callback(error, user);
    }];
}

-(void) postEntry:(NSString*) entryText completion:(void (^)(NSError* error, NSString* url)) callback {
    [self.api postEntry:entryText asUser:self.api.currentUser completion:callback];
}

-(void) getEvents:(void (^)(NSError *, NSArray *))callback {
    if ([self isLoggedIn] && self.currentUser == nil) {
        [self loginUsingStoredCredentials:^(NSError* error, BCHDWUser* user) {
            if (error) {
                callback(error, nil);
            } else {
                [self.api getEvents:self.currentUser completion:callback];
            }
        }];
    } else {
        [self.api getEvents:self.currentUser completion:callback];
    }
}

-(void) synchWithServer {
    if ([self isLoggedIn] && self.currentUser == nil) {
        [self loginUsingStoredCredentials:^(NSError* error, BCHDWUser* user) {
            if (error == nil) {
                NSLog(@"fetching user's events");
                [self.api getEvents:self.currentUser completion:^(NSError * _Nullable error, NSArray * _Nullable entries) {
                    if (error) {
                        NSLog(@"error: %@", error);
                    } else {
                        [self processEntries:entries];
                    }
                }];
                NSLog(@"fetching reading page");
                [self fetchRecentReadingPageActivity];
            }
        }];
    } else if (self.currentUser != nil) {
        [self.api getEvents:self.currentUser completion:^(NSError * _Nullable error, NSArray * _Nullable entries) {
            if (error) {
                NSLog(@"error: %@", error);
            } else {
                [self processEntries:entries];
            }
        }];
        [self fetchRecentReadingPageActivity];
    }
}

-(void) processEntries:(NSArray*) entries {
    [self.api performFunctionWithWebSession:^(NSError * _Nullable error, NSString * _Nullable session) {
        if (error == nil) {
            [self setAuthenticationCookie:session];
            for (BCHDWEntryOld* entry in entries) {
                [self fetchEntry:entry.url];
            }
        }
    }];
}

@end
