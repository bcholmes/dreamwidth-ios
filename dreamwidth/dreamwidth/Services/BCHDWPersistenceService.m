//
//  BCHDWPersistenceService.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-06-30.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWPersistenceService.h"

@interface BCHDWPersistenceService()

@property (nonatomic, nonnull, strong) NSManagedObjectContext* managedObjectContext;

@end

@implementation BCHDWPersistenceService

-(instancetype) initWithManagedObjectContext:(NSManagedObjectContext*) managedObjectContext {
    if (self = [super init]) {
        self.managedObjectContext = managedObjectContext;
    }
    return self;
}

-(BCHDWEntry*) entryByUrl:(NSString*) url {
    NSMutableArray* result = [NSMutableArray new];
    [self.managedObjectContext performBlockAndWait:^{
        NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
        fetchRequest.predicate = [NSPredicate predicateWithFormat:@"url == %@", url];
        NSError* error = nil;
        NSArray* results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        if (error == nil && results.count != 0) {
            [result addObject:(BCHDWEntry*) results[0]];
        } else {
            BCHDWEntry* entry = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:self.managedObjectContext];
            entry.url = url;
            [result addObject:entry];
        }
    }];
    return result[0];
}

-(BCHDWComment*) commentById:(NSString*) commentId author:(NSString*) author {
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ [NSPredicate predicateWithFormat:@"commentId == %@", commentId], [NSPredicate predicateWithFormat:@"author == %@", author] ]];
    NSError* error = nil;
    NSArray* results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error == nil && results.count != 0) {
        return (BCHDWComment*) results[0];
    } else {
        BCHDWComment* result = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:self.managedObjectContext];
        result.commentId = commentId;
        result.author = author;
        return result;
    }
}
@end
