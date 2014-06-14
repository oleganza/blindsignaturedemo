//
//  BSDPerson
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 14.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BSDPerson : NSObject

@property(nonatomic) NSString* name;
@property(nonatomic) NSString* myExtendedPrivateKey;
@property(nonatomic) NSString* theirExtendedPublicKey;

- (id) initWithPlist:(NSDictionary*)dict;

- (NSDictionary*) plist;

- (BTCKeychain*) myKeychain;
- (BTCKeychain*) theirKeychain;

+ (NSArray*) peopleFromPlist:(NSArray*)plist;

@end
