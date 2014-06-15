//
//  BSDTransaction.m
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 15.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BSDTransaction.h"

@implementation BSDTransaction

//@property(nonatomic) uint32_t index;
//@property(nonatomic) NSString* label;
//@property(nonatomic) NSString* address;
//@property(nonatomic) NSData* scriptData;
//@property(nonatomic) NSArray* friends;

- (id) initWithPlist:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.index = [dict[@"index"] unsignedIntValue];
        self.label = dict[@"label"];
        self.address = dict[@"address"];
        self.scriptData = dict[@"scriptData"];
        self.friends = [BSDPerson peopleFromPlist:dict[@"friends"]];
    }
    return self;
}

- (NSDictionary*) plist
{
    return @{
             @"index": @(self.index),
             @"label": self.label ?: @"",
             @"address": self.address ?: @"",
             @"scriptData": self.scriptData ?: [NSData data],
             @"friends": [self.friends valueForKey:@"plist"],
             };
}

+ (NSArray*) txsFromPlist:(NSArray *)plist
{
    NSMutableArray* arr = [NSMutableArray array];
    
    for (id dict in plist)
    {
        [arr addObject:[[BSDTransaction alloc] initWithPlist:dict]];
    }
    
    return arr;
}

@end
