//
//  BSDStorage.h
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 14.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BSDPerson;
@class BSDTransaction;
@interface BSDStorage : NSObject

+ (instancetype) sharedStorage;

// Friends list
- (NSArray*) friends;

// Returns a list of BSDPerson entries that have keys associated with them.
- (NSArray*) loadFriends;

// Saves current friends.
- (void) saveFriends;

// Adds new person, saves it and returns to the caller.
- (BSDPerson*) addFriend;

// Keypairs for friends are derived from here, per friend.
- (BTCKeychain*) friendsKeychain;

// Random numbers for transactions are derived from here, per transaction.
- (BTCKeychain*) transactionsKeychain;

// Adds tx and saves it.
- (BSDTransaction*) addTransactionForFriends:(NSArray*)friends minSignatures:(int)minSigs;

// Loads a list of saved transactions.
- (NSArray*) loadTransactions;


@end
