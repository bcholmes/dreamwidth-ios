//
//  BCHDWCardView.m
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-13.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#import "BCHDWCardView.h"

#import <Colours/Colours.h>
#import <MaterialComponents/MaterialInk.h>

@interface BCHDWCardView()

@property(strong, nonatomic, nonnull) MDCInkView *inkView;
@property(nonatomic, assign) CGPoint lastTouch;

@end

@implementation BCHDWCardView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void) commonInit {
    if (!self.inkView) {
        self.inkView = [[MDCInkView alloc] initWithFrame:self.bounds];
    }
    [self addSubview:_inkView];
}

- (void)startInk {
    [self.inkView startTouchBeganAtPoint:_lastTouch animated:YES withCompletion:nil];
}

- (void)endInk {
    [self.inkView startTouchEndAtPoint:_lastTouch animated:YES withCompletion:nil];
}


- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        [self startInk];
    } else {
        [self endInk];
    }
}

#pragma mark - UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    self.lastTouch = location;
    // Call super only after -lastTouch has been recorded, since super can call -setHighlighted:.
    [super touchesBegan:touches withEvent:event];
}

-(void) layoutSubviews {
    [super layoutSubviews];
    self.layer.cornerRadius = 4.0;
    self.layer.shadowPath = [[UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:4.0] CGPath];
    self.layer.shadowOpacity = 0.5;
    self.layer.shadowColor =  [UIColor colorFromHexString:@"#000000"].CGColor;
    self.layer.shadowOffset = CGSizeMake(0,3);
    self.layer.masksToBounds = NO;
    
    self.inkView.inkColor = self.inkColor;
    self.inkView.frame = self.bounds;
    self.inkView.layer.cornerRadius = 4.0;
}


@end
