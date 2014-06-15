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
        self.minSignatures = MAX(1, [dict[@"minSignatures"] intValue]);
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
             @"minSignatures": @(self.minSignatures),
             @"friends": [self.friends valueForKey:@"plist"],
             };
}

- (NSString*) title
{
    NSString* keysInfo = nil;
    if (self.friends.count == 1)
    {
        keysInfo = @"1 key";
    }
    else
    {
        keysInfo = [NSString stringWithFormat:@"%d-of-%d", self.minSignatures, self.friends.count];
    }
    return [NSString stringWithFormat:@"%d) %@... (%@)", self.index, [self.address substringToIndex:6], keysInfo];
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
