//
//  HitPosition.h
//  SearchTest
//
//  Created by Sergey Yuryev on 17.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import <Foundation/Foundation.h>

/* 
 * Little helper class to start start and end of a match.
 */
@interface HitPosition : NSObject

-(id)initWithStart:(NSUInteger)start andEnd:(NSUInteger)end;

@property (nonatomic) NSUInteger start;
@property (nonatomic) NSUInteger end;
@property (nonatomic) NSRegularExpression *regex;

@end
