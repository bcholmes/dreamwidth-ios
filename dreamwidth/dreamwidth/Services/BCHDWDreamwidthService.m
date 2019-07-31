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
#import <UserNotifications/UserNotifications.h>

#import "BCHDWEntryHandle.h"
#import "BCHDWCommentEntryData.h"
#import "BCHDWFormData.h"
#import "HTMLElement+DreamBalloon.h"
#import "BCHDWAtomParser.h"
#import "BCHDWEntrySummarizer.h"
#import "BCHDWHTMLUtilities.h"
@interface BCHDWDreamwidthService()

@property (nonatomic, strong) DreamwidthApi* api;
@property (nonatomic, strong) BCHDWPersistenceService* persistenceService;
@property (nonnull, nonatomic, strong) AFHTTPSessionManager* htmlManager;
@property (nonnull, strong) NSDateFormatter* dateFormatter;
@property (nonnull, strong) NSDate* lastSyncDate;
@property (nonnull, strong) NSDictionary* knownSocialMediaSites;
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
        
        self.knownSocialMediaSites = @{ @"ao3.org": @"ao3", @"archiveofourown.org": @"ao3", @"blogger.com" : @"blogger", @"facebook.com": @"facebook", @"github.com": @"github", @"livejournal.com": @"livejournal", @"tumblr.com": @"tumblr", @"twitter.com" : @"twitter" };
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

- (void) fetchReadingPageLight:(NSUInteger) skip max:(NSUInteger) max friends:(NSMutableDictionary*) friendSet completion:(void (^)(NSError* error, NSDictionary* readingList)) completion {
    [self.htmlManager GET:[NSString stringWithFormat:@"https://www.dreamwidth.org/mobile/read?skip=%lu", skip] parameters:nil progress:nil success:^(NSURLSessionTask* task, id responseObject) {

        NSArray* items = [self findAllFriends:(NSData*) responseObject friends:friendSet];
        
        if (skip < max && items.count > 0) {
            [self fetchReadingPageLight:skip + 50 max:max friends:friendSet completion:completion];
        } else {
            completion(nil, [NSDictionary dictionaryWithDictionary:friendSet]);
            
            
            for (NSString* author in friendSet) {
                [self getAtomFeed:author completion:^(NSError * _Nullable error, NSArray * _Nullable entries) {
                    if (error && [error.domain isEqualToString:@"org.ayizan.dreamballoon"]) {
                        [self processEntries:[friendSet objectForKey:author]];
                    } else if (error) {
                        NSLog(@"error: %@", error);
                    } else {
                        NSArray* filteredEntries = [self filterNewEntries:entries forUser:author];
                        self.lastSyncDate = [NSDate new];
                        [self processEntries:filteredEntries];
                    }
                }];
            }
        }
        
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        completion(error, nil);
    }];
}

-(NSArray*) findAllFriends:(NSData*) htmlData friends:(NSMutableDictionary*) friendSet {

    NSMutableArray* result = [NSMutableArray new];
    HTMLParser* parser = [[HTMLParser alloc] initWithString:[[NSString alloc] initWithData:htmlData encoding:NSUTF8StringEncoding]];
    HTMLDocument* document = [parser parseDocument];

    HTMLElement* body = [document body];
    BCHDWEntryHandle* handle = [BCHDWEntryHandle new];
    for (HTMLNode* node = body.firstChild; node != nil; node = node.nextSibling) {
        if ([node isKindOfClass:[HTMLElement class]]) {
            HTMLElement* e = (HTMLElement*) node;
            if ([e.tagName isEqualToString:@"br"]) {
                if (handle.url != nil) {
                    [result addObject:handle];
                }
                handle = [BCHDWEntryHandle new];
            } else if ([e.tagName isEqualToString:@"a"]) {
                NSString* href = e.attributes[@"href"];
                if ([href rangeOfString:@".html?"].location != NSNotFound) {
                    handle.url = [href substringToIndex:[href rangeOfString:@"?"].location];
                } else if (handle.author == nil) {
                    handle.author = e.textContent;
                } else if (handle.communityName == nil) {
                    handle.communityName = e.textContent;
                }
            }
        }
    }
    if (handle.url != nil) {
        [result addObject:handle];
    }
    
    for (BCHDWEntryHandle* handle in result) {
        NSString* journal = nil;
        if (handle.communityName != nil) {
            journal = handle.communityName;
        } else if (handle.author != nil) {
            journal = handle.author;
        } else {
            NSLog(@"can't figure out author of this item: %@", handle.url);
        }
        
        if (journal != nil) {
            NSMutableArray* pages = [friendSet objectForKey:journal];
            if (pages == nil) {
                pages = [NSMutableArray new];
                [friendSet setObject:pages forKey:journal];
            }
            [pages addObject:handle];
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
                commentRecord.replyTo = parent;
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
                commentRecord.replyTo = parent;
                commentRecord.orderKey = [NSString stringWithFormat:@"%@.%04ld", parent.orderKey, peer.lastOrderPart + 1];
            } else {
                commentRecord.orderKey = [NSString stringWithFormat:@"%04ld", peer.lastOrderPart + 1];
            }
            [depthList addObject:commentRecord];
        } else {
            NSLog(@"Wrong depth: %ld, count = %lu", (long)depthValue, depthList.count);
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
    if (newestComment != nil && [newestComment isLaterThanDate:entry.lastActivityDate]) {
        entry.lastActivityDate = newestComment;
    }
}

-(NSString*) extractUserReference:(HTMLElement*) element {
    
    NSString* user = element.textContent;
    
    NSArray* anchors = [element querySelectorAll:@"a"];
    HTMLElement* anchor = [anchors lastObject];
    NSString* site = nil;
    NSString* url = anchor.attributes[@"href"];
    for (NSString* domain in self.knownSocialMediaSites) {
        if ([url rangeOfString:domain].location != NSNotFound) {
            site = self.knownSocialMediaSites[domain];
            break;
        }
    }
    
    if (site != nil) {
        return [NSString stringWithFormat:@"%@.%@", user, site];
    } else {
        return user;
    }
}

-(NSString*) collectTextContent:(HTMLElement*) content {
    NSMutableString* result = [NSMutableString new];
    for (HTMLNode* node = content.firstChild; node != nil; node = node.nextSibling) {
        if ([node isKindOfClass:[HTMLElement class]]) {
            HTMLElement* element = (HTMLElement*) node;
            if ([element.tagName isEqualToString:@"br"]) {
                [result appendString:@"\n"];
            } else if ([BCHDWHTMLUtilities isExcluded:element]) {
                // skip it
            } else if ([BCHDWHTMLUtilities isUserReference:element]) {
                [result appendFormat:@"@%@", [self extractUserReference:element]];
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

-(BCHDWSummaryExtract*) collectSummaryExtract:(HTMLElement*) content {
    BCHDWSummaryExtract* result = [BCHDWSummaryExtract new];
    [self collectSummaryExtract:content buffer:result];
    return result;
}

-(BOOL) collectSummaryExtract:(HTMLElement*) content buffer:(BCHDWSummaryExtract*) extract {
    BOOL stop = NO;
    for (HTMLNode* node = content.firstChild; node != nil; node = node.nextSibling) {
        if ([node isKindOfClass:[HTMLElement class]]) {
            HTMLElement* element = (HTMLElement*) node;
            if ([element.tagName isEqualToString:@"br"]) {
                [extract.currentText appendString:@"\n"];
            } else if ([BCHDWHTMLUtilities isExcluded:element]) {
                // skip it
            } else if ([self isCut:element]) {
                stop = YES;
                break;
            } else if ([BCHDWHTMLUtilities isUserReference:element]) {
                [extract.currentText appendString:node.textContent];
            } else if ([element.tagName isEqualToString:@"img"]) {
                if (extract.summaryImageUrl != nil && extract.summaryImageUrl.length > 0) {
                    stop = YES;
                    break;
                } else {
                    extract.summaryImageUrl = element.attributes[@"src"];
                }
            } else {
                if (extract.currentText.length == 0) {
                    // don't do anything
                } else if ([element.tagName isEqualToString:@"p"] || element.isHeader) {
                    NSString* trimmed = [extract.currentText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    [extract.currentText replaceCharactersInRange:NSMakeRange(0, extract.currentText.length) withString:trimmed];
                    [extract.currentText appendString:@"\n\n"];
                } else if (element.isBlockElement) {
                    [extract.currentText appendString:@"\n"];
                }
                stop = [self collectSummaryExtract:element buffer:extract];
                if (stop) {
                    break;
                }
            }
        } else if ([node isKindOfClass:[HTMLText class]]) {
            [extract.currentText appendString:node.textContent];
            if ([extract isMaxLength]) {
                stop = YES;
                break;
            }
        }
    }
    return stop;
}

-(BOOL) isCut:(HTMLElement*) element {
    return [element.tagName isEqualToString:@"a"] && element.attributes[@"name"] != nil && [element.attributes[@"name"] rangeOfString:@"cutid"].location == 0;
}



-(void) fetchEntry:(BCHDWEntryHandle*) entryHandle {
    [self.htmlManager GET:[NSString stringWithFormat:@"%@?format=light&expand_all=1", entryHandle.url] parameters:nil progress:nil success:^(NSURLSessionTask* task, id responseObject) {

        BOOL isNew = NO;
        BCHDWEntry* entry = [self.persistenceService entryByUrl:entryHandle.url autocreate:NO];
        if (!entry) {
            isNew = YES;
            entry = [self.persistenceService entryByUrl:entryHandle.url autocreate:YES];
        }
        [entry.managedObjectContext performBlock:^{
            @try {
                HTMLParser* parser = [[HTMLParser alloc] initWithString:[[NSString alloc] initWithData:(NSData*) responseObject encoding:NSUTF8StringEncoding]];
                HTMLDocument* document = [parser parseDocument];
                
                NSString* author = [document querySelector:@".poster-info .ljuser"].textContent;
                if (author != nil && author.length > 0) {
                    entry.subject = [document querySelector:@".entry-title"].textContent;
                    HTMLElement* avatarAnchor = [document querySelector:@".userpic img"];
                    entry.avatarUrl = avatarAnchor.attributes[@"src"];
                    entry.author = author;

                    if (entryHandle.creationDate == nil && entryHandle.updateDate == nil) {
                        NSString* entryDate = [document querySelector:@".poster-info .datetime"].textContent;
                        entry.creationDate = [self.dateFormatter dateFromString:entryDate];
                        if (entry.updateDate == nil) {
                            entry.updateDate = entry.creationDate;
                        }
                    } else {
                        entry.creationDate = entryHandle.creationDate;
                        entry.updateDate = entryHandle.updateDate;
                    }
                    if (entry.lastActivityDate == nil) {
                        entry.lastActivityDate = entry.updateDate;
                    }
                    
                    HTMLElement* lock = [document querySelector:@".access-filter"];
                    if (lock != nil) {
                        entry.locked = YES;
                    }
                    
                    entry.entryText = [self collectTextContent:[document querySelector:@".entry-content"]];
                    BCHDWSummaryExtract* extract = [self collectSummaryExtract:[document querySelector:@".entry-content"]];
                    NSString* temp = [extract.summaryText1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    entry.summaryText = temp.length > 0 ? temp : nil;
                    temp = [extract.summaryText2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    entry.summaryText2 = temp.length > 0 ? temp : nil;
                    entry.summaryImageUrl = extract.summaryImageUrl;
                    
                    [self processComments:document entry:entry];
                }
                [entry.managedObjectContext save:nil];
                if (isNew) {
                    [self sendNotificationAboutNewEntry:entryHandle];
                }
            } @catch (NSException *exception) {
                NSLog(@"******************************************");
                NSLog(@"%@", exception.reason);
                NSLog(@"******************************************");
            }
        }];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"fetch entry: %@", error);
    }];
}

-(void) fetchRecentReadingPageActivity {
    [self.api performFunctionWithWebSession:^(NSError * _Nullable error, NSString * _Nullable session) {
        if (error == nil) {
            [self setAuthenticationCookie:session];
            [self fetchReadingPageLight:0 max:100 friends:[NSMutableDictionary new] completion:^(NSError* error, NSDictionary* readingList) {
                if (error) {
                    NSLog(@"fetch error: %@", error);
                } else {
                    for (NSString* author in readingList) {
                        [self getAtomFeed:author completion:^(NSError * _Nullable error, NSArray * _Nullable entries) {
                            if (error && [error.domain isEqualToString:@"org.ayizan.dreamballoon"]) {
                                [self processEntries:[readingList objectForKey:author]];
                            } else if (error) {
                                NSLog(@"error: %@", error);
                            } else {
                                NSArray* filteredEntries = [self filterNewEntries:entries forUser:author];
                                self.lastSyncDate = [NSDate new];
                                [self processEntries:filteredEntries];
                            }
                        }];
                    }
                }
            }];
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
            
            [self syncWithServer];
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

- (void) fullSyncWithServer {
    NSLog(@"Starting full sync with server.");
    [self getAtomFeed:self.currentUser.username completion:^(NSError * _Nullable error, NSArray * _Nullable entries) {
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            self.lastSyncDate = [NSDate new];
            [self processEntries:entries];
        }
    }];
    [self fetchRecentReadingPageActivity];
}

-(void) getAtomFeed:(NSString*) user completion:(void (^)(NSError* _Nullable error, NSArray* _Nullable entryHandles)) completion {
    [self.htmlManager GET:[NSString stringWithFormat:@"https://%@.dreamwidth.org/data/atom", user] parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*) task.response;
        if ([httpResponse.allHeaderFields[@"content-type"] rangeOfString:@"application/atom+xml"].location != NSNotFound || [httpResponse.allHeaderFields[@"content-type"] rangeOfString:@"text/xml"].location != NSNotFound) {
            NSArray* entries = [[BCHDWAtomParser new] parse:responseObject];
            completion(nil, entries);
        } else {
            NSLog(@"Can't download items for %@ (content type %@)", user, httpResponse.allHeaderFields[@"content-type"]);
            completion([NSError errorWithDomain:@"org.ayizan.dreamballoon" code:-999 userInfo:nil], nil);
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        completion(error, nil);
    }];
}

- (void) partialSyncWithServer {
    NSLog(@"Starting partial sync with server.");
    [self getAtomFeed:self.currentUser.username completion:^(NSError * _Nullable error, NSArray * _Nullable entries) {
        if (error) {
            NSLog(@"error: %@", error);
        } else {
            NSArray* newEntries = [self filterNewEntries:entries forUser:self.currentUser.username];
            if (newEntries.count > 0) {
                NSLog(@"%lu entries have been identified for %@", newEntries.count, self.currentUser.username);
                [self processEntries:newEntries];
            } else {
                NSLog(@"No new user entries to process");
            }
        }
    }];
    [self fetchRecentReadingPageActivity];
}

-(NSArray*) filterNewEntries:(NSArray*) entries forUser:(NSString*) username {
    NSMutableArray* result = [NSMutableArray new];
    
    for (BCHDWEntryHandle* handle in entries) {
        BCHDWEntry* entry = [self.persistenceService entryByUrl:handle.url autocreate:NO];
        if (!entry) {
            NSLog(@"handle %@ does not exist", handle.url);
            [result addObject:handle];
        } else if ([entry.updateDate isEarlierThanDate:handle.updateDate]) {
            NSLog(@"handle %@ (%@) has changed (%@)", handle.url, handle.updateDate, entry.updateDate);
            [result addObject:handle];
        } else if ([entry.numberOfComments integerValue] != [handle.commentCount integerValue]) {
            NSLog(@"handle %@ comment count has changed %@ -> %@", handle.url, entry.numberOfComments, handle.commentCount);
            [result addObject:handle];
        }
    }
    
    return [NSArray arrayWithArray:result];
}

-(void) fullOrPartialSyncWithServer {
    if (self.lastSyncDate == nil || [[self.lastSyncDate dateByAddingHours:4] isEarlierThanDate:[NSDate new]]) {
        [self fullSyncWithServer];
    } else {
        [self partialSyncWithServer];
    }
}

-(void) syncWithServer {
    if ([self isLoggedIn] && self.currentUser == nil) {
        [self loginUsingStoredCredentials:^(NSError* error, BCHDWUser* user) {
            if (error == nil) {
                [self fullOrPartialSyncWithServer];
            }
        }];
    } else if (self.currentUser != nil) {
        [self fullOrPartialSyncWithServer];
    }
}

-(void) processEntries:(NSArray*) entries {
    [self.api performFunctionWithWebSession:^(NSError * _Nullable error, NSString * _Nullable session) {
        if (error == nil) {
            [self setAuthenticationCookie:session];
            for (BCHDWEntryHandle* entry in entries) {
                NSLog(@"Fetch data for url: %@", entry.url);
                [self fetchEntry:entry];
            }
        }
    }];
}

-(void) postComment:(BCHDWCommentEntryData*) comment entry:(BCHDWEntry*) entry parentComment:(BCHDWComment*) parentComment callback:(void (^) (NSError*)) callback {
    [self.api performFunctionWithWebSession:^(NSError * _Nullable error, NSString * _Nullable session) {

        if (error == nil) {
            [self setAuthenticationCookie:session];
            [self fetchCommentForm:entry parentComment:parentComment callback:^(NSError* error, BCHDWFormData* formData) {
                if (error == nil) {
                    
                    [formData addFormProperties:comment.formProperties];
                    
                    [self submitForm:formData callback:^(NSError* error) {
                        if (error == nil) {
                            [self fetchEntry:entry.handle];
                            dispatch_async(dispatch_get_main_queue(), ^{
                                callback(nil);
                            });
                        } else {
                            NSLog(@"error %@", error);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                callback(error);
                            });
                        }
                    }];
                } else {
                    NSLog(@"error %@", error);
                    dispatch_async(dispatch_get_main_queue(), ^{
                        callback(error);
                    });
                }
            }];
        } else {
            NSLog(@"error %@", error);
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(error);
            });
        }
    }];
}


-(void) submitForm:(BCHDWFormData*) form callback:(void (^)(NSError*)) callback {
    [self.htmlManager POST:form.submitUrl parameters:form.properties progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        callback(nil);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"Error posting comment: %@", error);
        callback(error);
    }];
}

-(void) fetchCommentForm:(BCHDWEntry*) entry parentComment:(BCHDWComment*) comment callback:(void (^)(NSError*, BCHDWFormData*)) callback {
    NSString* url = [NSString stringWithFormat:@"%@?mode=reply&format=light", entry.url];
    if (comment != nil) {
        url = [NSString stringWithFormat:@"%@?replyto=%@&format=light", entry.url, comment.commentId];
    }
    [self.htmlManager GET:url parameters:nil progress:nil success:^(NSURLSessionTask* task, id responseObject) {
        
        HTMLParser* parser = [[HTMLParser alloc] initWithString:[[NSString alloc] initWithData:(NSData*) responseObject encoding:NSUTF8StringEncoding]];
        HTMLDocument* document = [parser parseDocument];
        HTMLElement* element = [document querySelector:@"form"];
        BCHDWFormData* formData = [BCHDWFormData fromHtml:element];
        
        callback(nil, formData);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        callback(error, nil);
    }];
}

-(void) scheduleBackgroundDownload:(backgroundFetchHandler)completionHandler {
    NSTimeInterval start = [[NSDate new] timeIntervalSince1970];
    [self.api performFunctionWithWebSession:^(NSError * _Nullable error, NSString * _Nullable session) {
        if (error == nil) {
            [self setAuthenticationCookie:session];
            [self fetchReadingPageLight:0 max:0 friends:[NSMutableDictionary new] completion:^(NSError* error, NSDictionary* readingList) {
                if (error) {
                    completionHandler(UIBackgroundFetchResultFailed);
                } else {
                    BOOL newEntry = NO;
                    BCHDWEntryHandle* itemToFetch = nil;
                    for (NSArray* handles in readingList.allValues) {
                        for (BCHDWEntryHandle* handle in handles) {
                            BCHDWEntry* entry = [self.persistenceService entryByUrl:handle.url autocreate:NO];
                            if (entry == nil) {
                                itemToFetch = handle;
                                newEntry = YES;
                            }
                        }
                    }
                    
                    NSTimeInterval now = [[NSDate new] timeIntervalSince1970];
                    if (newEntry) {
                        NSLog(@"New things. Let's see if we can fetch them.");
                        if (now - start < 15 * 60) {
                            [self getAtomFeed:itemToFetch.journal completion:^(NSError * _Nullable error, NSArray * _Nullable entryHandles) {

                                for (BCHDWEntryHandle* handle in entryHandles) {
                                    if ([itemToFetch.url isEqualToString:handle.url]) {
                                        [self fetchEntry:handle];
                                    }
                                }
                            }];
                            [NSTimer scheduledTimerWithTimeInterval:7*60 repeats:NO block:^(NSTimer * _Nonnull timer) {
                                completionHandler(UIBackgroundFetchResultNewData);
                            }];
                        } else {
                            completionHandler(UIBackgroundFetchResultNewData);
                        }
                    } else {
                        NSLog(@"No new items to report on.");
                        completionHandler(UIBackgroundFetchResultNoData);
                    }
                }
            }];
        } else {
            completionHandler(UIBackgroundFetchResultFailed);
        }
    }];
}

-(void) sendNotificationAboutNewEntry:(BCHDWEntryHandle*) handle {
    UNMutableNotificationContent* content = [[UNMutableNotificationContent alloc] init];
    content.title = [NSString localizedUserNotificationStringForKey:@"New DreamBalloon Post" arguments:nil];
    if (handle.author.length > 0 && handle.title.length > 0) {
        content.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"%@ has posted a new entry: %@", handle.author, handle.title]  arguments:nil];
    } else if (handle.author.length > 0) {
        content.body = [NSString localizedUserNotificationStringForKey:[NSString stringWithFormat:@"%@ has posted a new entry.", handle.author]  arguments:nil];
    } else {
        content.body = [NSString localizedUserNotificationStringForKey:@"Someone made a new post." arguments:nil];
    }
    content.sound = [UNNotificationSound defaultSound];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:[NSString stringWithFormat:@"%@%@", NEW_ENTRY_NOTIFICATION_ID, handle.journal]
                                                                          content:content trigger:nil];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            NSLog(@"New entry notification succeeded");
        } else {
            NSLog(@"New entry notification failed: %@", error);
        }
    }];
}

@end
