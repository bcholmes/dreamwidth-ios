//
//  BCHDWCommentComposer.h
//  dreamwidth
//
//  Created by BC Holmes on 2019-07-08.
//  Copyright © 2019 Ayizan Studios. All rights reserved.
//

#ifndef BCHDWCommentComposer_h
#define BCHDWCommentComposer_h

#import "BCHDWComment.h"

@protocol BCHDWCommentComposer <NSObject>

-(void) like;
-(void) reply:(BCHDWComment*) comment;

@end

#endif /* BCHDWCommentComposer_h */
