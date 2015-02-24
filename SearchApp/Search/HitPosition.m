//
//  HitPosition.m
//  SearchTest
//
//  Created by Sergey Yuryev on 17.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import "HitPosition.h"

@implementation HitPosition

-(id)initWithStart:(NSUInteger)start andEnd:(NSUInteger)end
{
    if (!(self = [super init]))
        return nil;
    
    self.start = start;
    self.end = end;
    return self;
}

- (NSComparisonResult)compare:(HitPosition *)otherObject
{
    NSNumber *one = [NSNumber numberWithUnsignedInteger:self.start];
    NSNumber *two = [NSNumber numberWithUnsignedInteger:otherObject.start];
    return [one compare:two];
}

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToHitPosition:other];
}

- (BOOL)isEqualToHitPosition:(HitPosition *)aHitPosition
{
    if (self == aHitPosition)
        return YES;
    if (!(self.start == aHitPosition.start && self.end == aHitPosition.end))
        return NO;
    return YES;
}


@end
