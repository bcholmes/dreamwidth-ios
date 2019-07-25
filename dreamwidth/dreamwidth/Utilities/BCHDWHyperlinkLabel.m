//
//  BCHDWHyperlinkLabel.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-24.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWHyperlinkLabel.h"

#import <CoreText/CoreText.h>

@interface BCHDWHyperlinkLabel()

@property (nonatomic) NSMutableDictionary* handlerDictionary;
@property (nonatomic) CGRect boundingBox;

@end

@implementation BCHDWHyperlinkLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInitialization];
    }
    return self;
}

- (void) commonInitialization {
    if (!self.handlerDictionary) {
        self.handlerDictionary = [NSMutableDictionary new];
    }
    if (!self.userInteractionEnabled) {
        self.userInteractionEnabled = YES;
    }
}

- (void)clearActionDictionary {
    [self.handlerDictionary removeAllObjects];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setLink:(NSString*) link forRange:(NSRange)range {
    [self.handlerDictionary setObject:link forKey:[NSValue valueWithRange:range]];
}

#pragma mark - Event Handler

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    self.backupAttributedText = self.attributedText;
    for (UITouch *touch in touches) {
        CGPoint touchPoint = [touch locationInView:self];
        NSValue *rangeValue = [self attributedTextRangeForPoint:touchPoint];
        if (rangeValue) {
            NSRange range = [rangeValue rangeValue];
            NSLog(@"rangeValue => %lu,%lu", range.location, range.length );
//            NSMutableAttributedString* attributedString = [[NSMutableAttributedString alloc]initWithAttributedString:self.attributedText];
//            [attributedString addAttributes:self.linkAttributeHighlight range:range];
/*
            [UIView transitionWithView:self duration:highLightAnimationTime options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
                self.attributedText = attributedString;
            } completion:nil];
            return;
 */
        } else {
            NSLog(@"No range");
        }
 
    }
    [super touchesBegan:touches withEvent:event];
}

/*

- (void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [UIView transitionWithView:self duration:highLightAnimationTime options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
        self.attributedText = self.backupAttributedText;
    } completion:nil];
    [super touchesCancelled:touches withEvent:event];
}
 */

 
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    [UIView transitionWithView:self duration:highLightAnimationTime options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
//        self.attributedText = self.backupAttributedText;
//    } completion:nil];
    
    for (UITouch *touch in touches) {
        NSValue *rangeValue = [self attributedTextRangeForPoint:[touch locationInView:self]];
        if (rangeValue) {
            NSString* link = self.handlerDictionary[rangeValue];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:link] options:@{} completionHandler:nil];
            return;
        }
    }
    [super touchesEnded:touches withEvent:event];
}

- (NSInteger) characterIndexForPoint:(CGPoint) point {
    CGRect boundingBox = [self attributedTextBoundingBox];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, boundingBox);
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attributedText);
    CTFrameRef ctFrame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, self.attributedText.length), path, NULL);
    
    CGFloat verticalPadding = 0; //(CGRectGetHeight(self.frame) - CGRectGetHeight(boundingBox)) / 2;
    CGFloat horizontalPadding = 0; //(CGRectGetWidth(self.frame) - CGRectGetWidth(boundingBox)) / 2;
    CGFloat ctPointX = point.x - horizontalPadding;
    CGFloat ctPointY = CGRectGetHeight(boundingBox) - (point.y - verticalPadding);
    CGPoint ctPoint = CGPointMake(ctPointX, ctPointY);
    
    CFArrayRef lines = CTFrameGetLines(ctFrame);
    
    CGPoint* lineOrigins = malloc(sizeof(CGPoint)*CFArrayGetCount(lines));
    CTFrameGetLineOrigins(ctFrame, CFRangeMake(0,0), lineOrigins);
    
    NSInteger indexOfCharacter = -1;
    
    for(CFIndex i = 0; i < CFArrayGetCount(lines); i++) {
        CTLineRef line = CFArrayGetValueAtIndex(lines, i);
        
        CGFloat ascent, descent, leading;
        CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
        
        CGPoint origin = lineOrigins[i];
        
        if (ctPoint.y > origin.y - descent) {
            indexOfCharacter = CTLineGetStringIndexForPosition(line, ctPoint);
            break;
        }
    }
    
    free(lineOrigins);
    CFRelease(ctFrame);
    CFRelease(path);
    CFRelease(framesetter);
    
    return indexOfCharacter;
}

- (NSValue*) attributedTextRangeForPoint:(CGPoint) point {
    NSInteger indexOfCharacter = [self characterIndexForPoint:point];
    NSLog(@"index of character %ld", indexOfCharacter);
    for (NSValue *rangeValue in self.handlerDictionary) {
        NSRange range = [rangeValue rangeValue];
        if (NSLocationInRange(indexOfCharacter, range)) {
            return rangeValue;
        }
    }
    
    return nil;
}

- (CGRect)attributedTextBoundingBox {
    if (CGRectGetWidth(_boundingBox) != 0) {
        return _boundingBox;
    }
    
    NSLayoutManager *layoutManager = [NSLayoutManager new];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeZero];
    
    textContainer.lineFragmentPadding = 0.0;
    textContainer.lineBreakMode = self.lineBreakMode;
    textContainer.maximumNumberOfLines = self.numberOfLines;
    textContainer.size = self.bounds.size;
    [layoutManager addTextContainer:textContainer];
    
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self.attributedText];
    [textStorage addLayoutManager:layoutManager];
    
    CGRect textBoundingBox = [layoutManager usedRectForTextContainer:textContainer];
    
    
    CGFloat H = 0;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString( (CFMutableAttributedStringRef) self.attributedText);
    CGRect box = CGRectMake(0,0, CGRectGetWidth(textBoundingBox), CGFLOAT_MAX);
    CFIndex startIndex = 0;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, box);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(startIndex, 0), path, NULL);
    
    CFArrayRef lineArray = CTFrameGetLines(frame);
    CFIndex j = 0;
    CFIndex lineCount = CFArrayGetCount(lineArray);
    if (lineCount > self.numberOfLines && self.numberOfLines != 0) {
        lineCount = self.numberOfLines;
    }
    
    CGFloat h, ascent, descent, leading;
    
    for (j = 0; j < lineCount; j++) {
        CTLineRef currentLine = (CTLineRef)CFArrayGetValueAtIndex(lineArray, j);
        CTLineGetTypographicBounds(currentLine, &ascent, &descent, &leading);
        h = ascent + descent + leading;
        H += h;
    }
    
    CFRelease(frame);
    CFRelease(path);
    CFRelease(framesetter);
    
    box.size.height = H;
    
    _boundingBox = box;
    
    return box;
}

@end
