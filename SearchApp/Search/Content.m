//
//  Content.m
//  SearchTest
//
//  Created by Sergey Yuryev on 17.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import "Content.h"

@implementation Content


-(id)initWithFilename: (NSString *) filename
{
    if (!(self = [super init]))
        return nil;
    
    NSString *searchtestFilePath = [[NSBundle mainBundle] pathForResource:filename ofType:nil];
    NSError *error;
    self.content = [[NSString alloc] initWithContentsOfFile: searchtestFilePath encoding: NSUTF8StringEncoding error: &error];
    return self;
}

-(id)initWithString: (NSString *) string
{
    if (!(self = [super init]))
        return nil;
    
    self.content = [[NSString alloc] initWithString:string];
    return self;
}

@end
