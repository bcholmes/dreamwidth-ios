//
//  BCHDWFormData.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-12.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWFormData.h"

@interface BCHDWFormData()

@property (nonatomic, strong) NSMutableDictionary* internalProperties;

@end

@implementation BCHDWFormData

+(BCHDWFormData*) fromHtml:(HTMLElement*) formElement button:(NSString*) buttonName {
    BCHDWFormData* result = [BCHDWFormData new];
    result.submitUrl = formElement.attributes[@"action"];
    NSMutableDictionary* properties = [NSMutableDictionary new];
    [BCHDWFormData collectProperties:properties element:formElement button:buttonName];
    result.internalProperties = properties;
    return result;
}

-(NSDictionary*) properties {
    return [NSDictionary dictionaryWithDictionary:self.internalProperties];
}

-(void) addFormProperties:(NSDictionary*) properties {
    [self.internalProperties addEntriesFromDictionary:properties];
}

+(void) collectProperties:(NSMutableDictionary*) properties element:(HTMLElement*) parent button:(NSString*) buttonName {
    for (HTMLNode* node = parent.firstChild; node != nil; node = node.nextSibling) {
        if ([node isKindOfClass:[HTMLElement class]]) {
            HTMLElement* element = (HTMLElement*) node;
            if ([element.tagName isEqualToString:@"input"]) {
                NSString* type = element.attributes[@"type"];
                NSString* name = element.attributes[@"name"];
                if (name == nil) {
                    // skip it
                } else if ([type isEqualToString:@"hidden"]) {
                    [properties setObject:element.attributes[@"value"] forKey:name];
                } else if ([type isEqualToString:@"submit"] && [name isEqualToString:buttonName]) {
                    [properties setObject:element.attributes[@"value"] forKey:name];
                } else if ([type isEqualToString:@"radio"] && [element.attributes[@"checked"] isEqualToString:@"checked"]) {
                    [properties setObject:element.attributes[@"value"] forKey:name];
                }
            } else {
                [self collectProperties:properties element:element button:buttonName];
            }
        }
    }
}

@end
