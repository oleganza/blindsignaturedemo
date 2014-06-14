//
//  BSDPerson
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 14.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BSDPerson.h"

@implementation BSDPerson

- (id) initWithPlist:(NSDictionary*)dict
{
    if (self = [super init])
    {
        self.name = dict[@"name"];
        
        self.myExtendedPrivateKey = dict[@"myExtendedPrivateKey"];
        if (self.myExtendedPrivateKey.length == 0) self.myExtendedPrivateKey = nil;
        
        self.theirExtendedPublicKey = dict[@"theirExtendedPublicKey"];
        if (self.theirExtendedPublicKey.length == 0) self.theirExtendedPublicKey = nil;
    }
    return self;
}

- (NSDictionary*) plist
{
    return @{
             @"name": self.name ?: @"",
             @"myExtendedPrivateKey": self.myExtendedPrivateKey ?: @"",
             @"theirExtendedPublicKey": self.theirExtendedPublicKey ?: @"",
            };
}


- (BTCKeychain*) myKeychain
{
    if (self.myExtendedPrivateKey.length < 1) return nil;
    
    NSData* extkey = BTCDataFromBase58Check(self.myExtendedPrivateKey);
    return [[BTCKeychain alloc] initWithExtendedKey:extkey];
}

- (BTCKeychain*) theirKeychain
{
    if (self.theirExtendedPublicKey.length < 1) return nil;
    
    NSData* extkey = BTCDataFromBase58Check(self.theirExtendedPublicKey);
    return [[BTCKeychain alloc] initWithExtendedKey:extkey];
}



@end

