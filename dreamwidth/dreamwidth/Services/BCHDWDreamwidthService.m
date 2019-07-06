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
@property (nonnull, strong) NSDate* lastSyncDate;
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

- (void) processComments:(HTMLDocument*) document entry:(BCHDWEntry*) entry {
    NSMutableArray* depthList = [NSMutableArray new];
    NSDate* newestComment = nil;
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
        NSRange depthRange = [depth rangeOfString:@"comment-depth-" options:NSBackwardsSearch];
        if (depth != nil && depthRange.location != NSNotFound) {
            depth = [depth substringFromIndex:depthRange.location + depthRange.length];
        }
        commentRecord.depth = [NSNumber numberWithInteger:[depth integerValue]];
        NSInteger depthValue = [commentRecord.depth integerValue];
        
        if (depthValue == (depthList.count + 1)) {
            if (depthValue > 1) {
                BCHDWComment* parent = [depthList lastObject];
                commentRecord.replyToCommentId = parent.commentId;
                commentRecord.orderKey = [NSString stringWithFormat:@"%@.0001", parent.orderKey];
            } else {
                commentRecord.orderKey = @"0001";
            }
            [depthList addObject:commentRecord];
        } else if (depthValue > 0 && depthValue <= depthList.count) {
            BCHDWComment* peer = depthList[depthValue-1];
            [depthList removeObjectsInRange:NSMakeRange(depthValue-1, depthList.count - depthValue + 1)];

            if (depthValue > 1) {
                BCHDWComment* parent = [depthList lastObject];
                commentRecord.replyToCommentId = parent.commentId;
                commentRecord.orderKey = [NSString stringWithFormat:@"%@.%04ld", parent.orderKey, peer.lastOrderPart + 1];
            } else {
                commentRecord.orderKey = [NSString stringWithFormat:@"%04ld", peer.lastOrderPart + 1];
            }
            [depthList addObject:commentRecord];
        } else {
            NSLog(@"Wrong depth: %ld, count = %lu", depthValue, depthList.count);
        }
        
        NSString* date = [comment querySelector:@".datetime"].textContent;
        if ([date rangeOfString:@" (local)"].location != NSNotFound) {
            date = [date substringToIndex:[date rangeOfString:@" (local)"].location];
        }
        commentRecord.creationDate = [self.dateFormatter dateFromString:date];
        
        HTMLElement* title = [comment querySelector:@".comment-title"];
        NSString* titleClass = [title querySelector:@"span"].attributes[@"class"];
        if (titleClass == nil || [titleClass rangeOfString:@"invisible"].location == NSNotFound) {
            commentRecord.subject = title.textContent;
        }
        
        commentRecord.commentText = [self collectTextContent:[comment querySelector:@".comment-content"]];
        
        if (newestComment == nil || [newestComment isEarlierThanDate:commentRecord.creationDate]) {
            newestComment = commentRecord.creationDate;
        }
        
        HTMLElement* avatarAnchor = [comment querySelector:@".userpic img"];
        commentRecord.avatarUrl = avatarAnchor.attributes[@"src"];
        
        count++;
    }
    
    entry.numberOfComments = [NSNumber numberWithUnsignedInteger:count];
    if (newestComment != nil && [newestComment isLaterThanDate:entry.updateDate]) {
        entry.updateDate = newestComment;
    }
}


-(NSString*) collectTextContent:(HTMLElement*) content {
    NSMutableString* result = [NSMutableString new];
    for (HTMLNode* node in content.childNodes) {
        if ([node isKindOfClass:[HTMLElement class]]) {
            HTMLElement* element = (HTMLElement*) node;
            if ([element.tagName isEqualToString:@"br"]) {
                [result appendString:@"\n"];
            } else if ([self isExcluded:element]) {
                // skip it
            } else {
                [result appendFormat:@"<%@", element.tagName];
                [element.attributes enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSString *value, BOOL *stop) {
                    NSMutableString *escaped = [value mutableCopy];
                    [escaped replaceOccurrencesOfString:@"&" withString:@"&amp;" options:0 range:NSMakeRange(0, escaped.length)];
                    [escaped replaceOccurrencesOfString:@"0x00A0" withString:@"&nbsp;" options:0 range:NSMakeRange(0, escaped.length)];
                    [escaped replaceOccurrencesOfString:@"\"" withString:@"&quot;" options:0 range:NSMakeRange(0, escaped.length)];
                    
                    [result appendFormat:@" %@=\"%@\"", key, escaped];
                }];
                
                [result appendString:@">"];
                [result appendString:[self collectTextContent:element]];
                
                if (![element.tagName isEqualToAny:@"area", @"base", @"basefont", @"bgsound", @"br", @"col", @"embed",
                     @"frame", @"hr", @"img", @"input", @"keygen", @"link", @"menuitem", @"meta", @"param", @"source",
                     @"track", @"wbr", nil]) {
                    [result appendFormat:@"</%@>", element.tagName];
                }
            }
        } else if ([node isKindOfClass:[HTMLText class]]) {
            [result appendString:node.outerHTML];
        }
    }
    return [NSString stringWithString:result];
}

-(BOOL) isExcluded:(HTMLElement*) element {
    if (([element.tagName isEqualToString:@"div"]) && [element.attributes[@"class"] rangeOfString:@"edittime"].location != NSNotFound) {
        return YES;
    } else {
        return NO;
    }
}

-(void) fetchEntry:(NSString*) entryUrl {
    [self.htmlManager GET:[NSString stringWithFormat:@"%@?format=light&expand_all=1", entryUrl] parameters:nil progress:nil success:^(NSURLSessionTask* task, id responseObject) {

        HTMLParser* parser = [[HTMLParser alloc] initWithString:[[NSString alloc] initWithData:(NSData*) responseObject encoding:NSUTF8StringEncoding]];
        HTMLDocument* document = [parser parseDocument];
        
        NSString* author = [document querySelector:@".poster-info .ljuser"].textContent;
        if (author != nil && author.length > 0) {
            BCHDWEntry* entry = [self.persistenceService entryByUrl:entryUrl];
            [entry.managedObjectContext performBlock:^{
                entry.subject = [document querySelector:@".entry-title"].textContent;
                HTMLElement* avatarAnchor = [document querySelector:@".userpic img"];
                entry.avatarUrl = avatarAnchor.attributes[@"src"];
                entry.author = author;

                NSString* entryDate = [document querySelector:@".poster-info .datetime"].textContent;
                entry.creationDate = [self.dateFormatter dateFromString:entryDate];
                if (entry.updateDate == nil) {
                    entry.updateDate = entry.creationDate;
                }
                
                [self processComments:document entry:entry];
                
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
