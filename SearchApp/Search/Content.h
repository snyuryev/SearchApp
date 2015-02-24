//
//  Content.h
//  SearchTest
//
//  Created by Sergey Yuryev on 17.08.13.
//  Copyright (c) 2013 syuryev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Content : NSObject

-(id)initWithFilename: (NSString *) filename;
-(id)initWithString: (NSString *) string;

@property (nonatomic, strong) NSString *content;

@end
