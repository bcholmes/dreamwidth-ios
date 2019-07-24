//
//  BCHDWAtomParser.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-24.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWAtomParser.h"

#import <NSDate-Additions/NSDate+Additions.h>

@interface BCHDWXmlParser : NSObject<NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableArray* entries;
@property (nonatomic, strong) BCHDWEntryHandle* currentElement;
@property (nonatomic, strong) NSMutableString* text;
@property (nonatomic, strong) NSDateFormatter* isoDateFormatter;
@property (nonatomic, strong) NSString* journalName;
@property (nonatomic, strong) NSDate* window;

@end

@implementation BCHDWXmlParser

- (void)parserDidStartDocument:(NSXMLParser*) parser {
    self.entries = [NSMutableArray new];
    
    self.window = [[NSDate new] dateByAddingMonths:-3];
    self.isoDateFormatter = [[NSDateFormatter alloc] init];
    [self.isoDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    [self.isoDateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
}

-(void)parser:(NSXMLParser*) parser didStartElement:(NSString*) elementName namespaceURI:(NSString*) namespaceURI qualifiedName:(NSString*) qualifiedName attributes:(NSDictionary*) attributeDict {
    
    self.text = [NSMutableString new];
    if ([elementName isEqualToString:@"entry"]) {
        self.currentElement = [BCHDWEntryHandle new];
        self.currentElement.author = self.journalName;
    } else if (self.currentElement != nil && [elementName isEqualToString:@"link"] && [attributeDict[@"rel"] isEqualToString:@"alternate"]) {
        self.currentElement.url = attributeDict[@"href"];
    }
}

- (void)parser:(NSXMLParser*) parser didEndElement:(NSString*) elementName namespaceURI:(nullable NSString*) namespaceURI qualifiedName:(nullable NSString*) qName {
    if (self.currentElement != nil && [elementName isEqualToString:@"published"]) {
        self.currentElement.creationDate = [self.isoDateFormatter dateFromString:self.text];
    } else if (self.currentElement != nil && [elementName isEqualToString:@"updated"]) {
        self.currentElement.updateDate = [self.isoDateFormatter dateFromString:self.text];
    } else if (self.currentElement != nil && [elementName isEqualToString:@"reply-count"]) {
        self.currentElement.commentCount = [NSNumber numberWithInteger:[self.text integerValue]];
    } else if (self.currentElement != nil && [elementName isEqualToString:@"poster"]) {
        self.currentElement.author = [NSString stringWithString:self.text];
        if (![self.currentElement.author isEqualToString:self.journalName]) {
            self.currentElement.communityName = self.journalName;
        }
    } else if ([elementName isEqualToString:@"journal"]) {
        self.journalName = [NSString stringWithString:self.text];
    } else if ([elementName isEqualToString:@"entry"]) {
        if (self.currentElement != nil && [self.currentElement.creationDate isLaterThanDate:self.window]) {
            [self.entries addObject:self.currentElement];
        }
        self.currentElement = nil;
    }
}

- (void)parser:(NSXMLParser*) parser foundCharacters:(NSString*) string {
    [self.text appendString:string];
}
@end

@implementation BCHDWAtomParser

-(NSArray<BCHDWEntryHandle*>*) parse:(NSData*) data {
    NSXMLParser* parser = [[NSXMLParser alloc] initWithData:data];
    BCHDWXmlParser* parserDelegate = [BCHDWXmlParser new];
    parser.delegate = parserDelegate;
    [parser parse];
    return [NSArray arrayWithArray:parserDelegate.entries];
}

@end
