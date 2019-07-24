//
//  BCHDWAtomParser.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-24.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "BCHDWEntryHandle.h"

NS_ASSUME_NONNULL_BEGIN

@interface BCHDWAtomParser : NSObject

@property (nonatomic, strong) NSString* defaultJournalName;

-(NSArray<BCHDWEntryHandle*>*) parse:(NSData*) data;

@end

NS_ASSUME_NONNULL_END
