//
//  BSDStorage.m
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 14.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BSDStorage.h"
#import "BSDPerson.h"

@implementation BSDStorage {
    NSArray* _friends;
    BTCKeychain* _keychain;
}

+ (instancetype) sharedStorage
{
    static BSDStorage* storage;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        storage = [[BSDStorage alloc] init];
    });
    return storage;
}

- (id) init
{
    if (self = [super init])
    {
        // TODO: load or generate a seed.
        // This should be in keychain, obviously and not in defaults. But for demo we can be quick and dirty.
        NSData* seed = [[NSUserDefaults standardUserDefaults] dataForKey:@"seed"];
        if (!seed)
        {
            seed = BTCRandomDataWithLength(256);
            [[NSUserDefaults standardUserDefaults] setObject:seed forKey:@"seed"];
        }
        
        _keychain = [[BTCKeychain alloc] initWithSeed:seed];
    }
    return self;
}

- (NSArray*) friends
{
    if (_friends) return _friends;
    _friends = [self loadFriends];
    return _friends;
}

- (NSArray*) loadFriends
{
    NSArray* plists = [[NSUserDefaults standardUserDefaults] objectForKey:@"friends"];
    NSMutableArray* arr = [NSMutableArray array];
    
    for (id plist in plists)
    {
        [arr addObject:[[BSDPerson alloc] initWithPlist:plist]];
    }
    
    _friends = arr;
    
    return arr;
}

- (void) saveFriends
{
    [self saveFriends:_friends];
}

- (void) saveFriends:(NSArray*)friends
{
    id plist = [friends valueForKey:@"plist"];
    [[NSUserDefaults standardUserDefaults] setObject:plist forKey:@"friends"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BSDPerson*) addFriend
{
    BSDPerson* person = [[BSDPerson alloc] init];
    
    person.name = @"New person";
    
    NSArray* friends = [self loadFriends];
    
    uint32_t i = friends.count;
    
    friends = [friends arrayByAddingObject:person];
    
    BTCKeychain* keychain = [_keychain derivedKeychainAtIndex:i hardened:YES];
    
    NSData* extPrivKey = [keychain extendedPrivateKey];
    person.myExtendedPrivateKey = BTCBase58CheckStringWithData(extPrivKey);
    
    [self saveFriends:friends];
    
    _friends = friends;
    
    return person;
}



@end
