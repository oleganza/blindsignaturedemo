//
//  BSDTransaction.h
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 15.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSDTransaction : NSObject

@property(nonatomic) uint32_t index;
@property(nonatomic) NSString* label;
@property(nonatomic) NSString* address;
@property(nonatomic) NSData* scriptData;
@property(nonatomic) int minSignatures;
@property(nonatomic) NSArray* friends;

// Dynamic properties
@property(nonatomic) BTCSatoshi balance;
@property(nonatomic) NSArray* txouts;

- (id) initWithPlist:(NSDictionary*)dict;

- (NSDictionary*) plist;

- (NSString*) title;

+ (NSArray*) txsFromPlist:(NSArray *)plist;


@end
