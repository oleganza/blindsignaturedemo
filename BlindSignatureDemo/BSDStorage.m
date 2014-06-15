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
        // FIXME: This should be in keychain, obviously and not in defaults. But for hackathon demo we can be quick and dirty.
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

// Keypairs for friends are derived from here, per friend.
- (BTCKeychain*) friendsKeychain
{
    return [_keychain derivedKeychainAtIndex:0 hardened:YES];
}

// Random numbers for transactions are derived from here, per transaction.
- (BTCKeychain*) transactionsKeychain
{
    return [_keychain derivedKeychainAtIndex:1 hardened:YES];
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
    
    _friends = [BSDPerson peopleFromPlist:plists];
    
    return _friends;
}

- (void) saveFriends
{
    [self saveFriends:_friends];
}

- (void) saveFriends:(NSArray*)friends
{
    // FIXME: This should be in keychain, obviously and not in defaults. But for hackathon demo we can be quick and dirty.
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
    
    BTCKeychain* keychain = [[self friendsKeychain] derivedKeychainAtIndex:i hardened:YES];
    
    NSData* extPrivKey = [keychain extendedPrivateKey];
    person.myExtendedPrivateKey = BTCBase58CheckStringWithData(extPrivKey);
    
    [self saveFriends:friends];
    
    _friends = friends;
    
    return person;
}

- (NSArray*) loadTransactions
{
    id txsPlist = [[NSUserDefaults standardUserDefaults] objectForKey:@"transactions"];
    NSArray* txs = [BSDTransaction txsFromPlist:txsPlist ?: @[]];
    return txs;
}

- (BSDTransaction*) addTransactionForFriends:(NSArray*)friends minSignatures:(int)minSigs
{
    if (friends.count == 0) return nil;
    if (minSigs < 1) return nil;
    
    // Check that every friend has a public key.
    for (BSDPerson* person in friends)
    {
        if (!person.theirKeychain.rootKey || person.theirKeychain.isPrivate)
        {
            return nil;
        }
    }
    
    NSArray* txs = [self loadTransactions];
    
    BSDTransaction* tx = [[BSDTransaction alloc] init];
    
    tx.index = txs.count; // autoincrement index
    tx.label = @"";
    tx.friends = friends;
    
    // Two cases:
    // 1. one friend - normal pubkey address.
    // 2. many friends - multisig script wrapped in a P2SH address.
    
    
    if (friends.count == 1)
    {
        // Normal address
        BSDPerson* person = friends.firstObject;
        
        BTCBlindSignature* api = [[BTCBlindSignature alloc] initWithClientKeychain:[[BSDStorage sharedStorage] transactionsKeychain]
                                                                 custodianKeychain:person.theirKeychain];
        
        BTCKey* pubkey = [api publicKeyAtIndex:tx.index];
        
        tx.address = pubkey.publicKeyAddress.base58String;
        tx.scriptData = [pubkey.publicKey copy];
        
    }
    else
    {
        // MULTISIG version.
        
    }
    
    txs = [(txs ?: @[]) arrayByAddingObject:tx];
    
    id plist = [txs valueForKey:@"plist"];
    [[NSUserDefaults standardUserDefaults] setObject:plist forKey:@"transactions"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    
    return tx;
}



@end
