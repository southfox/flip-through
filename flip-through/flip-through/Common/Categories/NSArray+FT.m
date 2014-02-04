//
//  NSArray+FT.m
//  flip-through
//
//  Created by Javier Fuchs on 2/4/14.
//  Copyright (c) 2014 Javier Fuchs. All rights reserved.
//

#import "NSArray+FT.h"


@implementation NSArray (FT)


- (NSArray*)arrayIfTrue:(BOOL(^)(id object))block {
	
    int numberOfObjects = (int)[self count];
    
	NSMutableArray* array = [NSMutableArray arrayWithCapacity:numberOfObjects];

	for (id object in self)
	{
		BOOL conditionIsTrue = block(object);
		if (conditionIsTrue) {
            // add object to the array
            FTAssert(object);
			[array addObject:object];
		}
	}
	
	return array;
}

- (id)firstObject
{
    FTAssert(self.count);
    return self[0];
}

- (BOOL)isFirst:(id)object
{
    return [self firstObject] == object;
}


- (id)firstIfTrue:(BOOL(^)(id object))trueBlock {
    id anObject = nil;
	for (id object in self) {
		BOOL conditionIsTrue = trueBlock(object);
		if (conditionIsTrue) {
			anObject = object;
            break;
		}
	}
    return anObject;

}


@end



