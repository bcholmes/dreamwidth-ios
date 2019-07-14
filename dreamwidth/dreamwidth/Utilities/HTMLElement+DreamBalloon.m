//
//  HTMLElement+DreamBalloon.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-13.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "HTMLElement+DreamBalloon.h"

@implementation HTMLElement (DreamBalloon)

-(BOOL) isBlockElement {
    NSArray* blockTags = @[ @"p", @"div", @"blockquote", @"ol", @"li", @"ul", @"h1", @"h2", @"h3", @"h4", @"h5", @"h6", @"section", @"table", @"pre", @"hr" ];
    return [blockTags containsObject:self.tagName];
}

-(BOOL) isHeader {
    NSArray* tags = @[ @"h1", @"h2", @"h3", @"h4", @"h5", @"h6" ];
    return [tags containsObject:self.tagName];
}


@end
