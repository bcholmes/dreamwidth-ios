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
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Entry"];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"url == %@", url];
    NSError* error = nil;
    NSArray* results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error == nil && results.count != 0) {
        NSLog(@"Entry record id=%@ found.", url);
        return (BCHDWEntry*) results[0];
    } else {
        NSLog(@"Creating new Entry record for url=%@.", url);
        BCHDWEntry* result = [NSEntityDescription insertNewObjectForEntityForName:@"Entry" inManagedObjectContext:self.managedObjectContext];
        result.url = url;
        return result;
    }
}

-(BCHDWComment*) commentById:(NSString*) commentId author:(NSString*) author {
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Comment"];
    fetchRequest.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[ [NSPredicate predicateWithFormat:@"commentId == %@", commentId], [NSPredicate predicateWithFormat:@"author == %@", author] ]];
    NSError* error = nil;
    NSArray* results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error == nil && results.count != 0) {
        NSLog(@"Comment record id=%@ found.", commentId);
        return (BCHDWComment*) results[0];
    } else {
        NSLog(@"Creating new Comment record for commentId=%@.", commentId);
        BCHDWComment* result = [NSEntityDescription insertNewObjectForEntityForName:@"Comment" inManagedObjectContext:self.managedObjectContext];
        result.commentId = commentId;
        result.author = author;
        return result;
    }
}
@end
