//
//  NSArray+FT.h
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 Javier Fuchs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (FT)

- (NSArray*)arrayIfTrue:(BOOL(^)(id object))block;
- (id)firstObject;
- (BOOL)isFirst:(id)object;
- (id)firstIfTrue:(BOOL(^)(id object))trueBlock;

@end

