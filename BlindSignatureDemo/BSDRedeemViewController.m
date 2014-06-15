//
//  BSDRedeemViewController.m
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 15.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BSDRedeemViewController.h"

@interface BSDRedeemViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextField *hashField;
@property (weak, nonatomic) IBOutlet UITextField *signatureField;
@property (weak, nonatomic) IBOutlet UILabel *toSignLabel;
@property (weak, nonatomic) IBOutlet UILabel *sourceLabel;
@property (weak, nonatomic) IBOutlet UIButton *redeemButton;

@end

@implementation BSDRedeemViewController {
    BTCTransaction* _signedTx;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Redeem Funds";
    }
    return self;
}

- (BSDPerson*) friend
{
    return self.transaction.friends.firstObject;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:(BOOL)animated];
    
    self.sourceLabel.text = self.transaction.address;
    
    self.toSignLabel.text = [NSString stringWithFormat:@"To sign by %@", self.friend.name];
    
    self.addressField.text = @"1CBtcGivXmHQ8ZqdPgeMfcpQNJrqTrSAcG";
    [self recalculate];
}


- (void) recalculate
{
    self.redeemButton.enabled = NO;
    self.redeemButton.alpha = 0.5;

    BTCAddress* addr = [BTCAddress addressWithBase58String:self.addressField.text];
    
    if (addr && self.transaction.txouts.count > 0)
    {
        BTCBlindSignature* blindAPI = [[BTCBlindSignature alloc] initWithClientKeychain:[BSDStorage sharedStorage].transactionsKeychain
                                                                      custodianKeychain:self.friend.theirKeychain];
        
        // Compose a transaction.
        BTCTransaction* tx = [[BTCTransaction alloc] init];
        
        // Only redeem one output as we can't safely redeem more.
        // Normally there will be only one output anyway.
        BTCTransactionOutput* txout = self.transaction.txouts.firstObject;
        
        BTCTransactionInput* txin = [[BTCTransactionInput alloc] init];
        txin.previousHash = txout.transactionHash;
        txin.previousIndex = txout.index;
        [tx addInput:txin];
            
        NSLog(@"txhash: http://blockchain.info/rawtx/%@", BTCHexStringFromData(txout.transactionHash));
        NSLog(@"txhash: http://blockchain.info/rawtx/%@ (reversed)", BTCHexStringFromData(BTCReversedData(txout.transactionHash)));
        
        // Add required outputs - payment and change
        BTCTransactionOutput* redeemingOutput = [BTCTransactionOutput outputWithValue:txout.value - 10000 address:addr];
        
        [tx addOutput:redeemingOutput];
        
        NSError* error = nil;
        unsigned char hashtype = BTCSignatureHashTypeAll;
        NSData* hash = [tx signatureHashForScript:txout.script inputIndex:0 hashType:hashtype error:&error];
        
        if (!hash)
        {
            NSLog(@"ERROR: cannot compute hash for signing: %@", error);
        }
    
        NSData* blindedHash = [blindAPI blindedHashForHash:hash index:self.transaction.index];
        
        NSMutableData* data = [NSMutableData data];
        
        uint32_t prefix = 268435613; // 268435613 = t****, 268435610 = s****
        uint32_t index = self.transaction.index;
        [data appendBytes:&prefix length:sizeof(prefix)];
        [data appendBytes:&index length:sizeof(index)];
        [data appendData:blindedHash];
        
        NSString* blindedHashSerialized = BTCBase58CheckStringWithData(data);
        
        self.hashField.text = blindedHashSerialized;
        
        if (self.signatureField.text.length > 0)
        {
            NSData* blindSig = BTCDataFromBase58Check(self.signatureField.text);
            
            NSData* fullSig = [blindAPI unblindedSignatureForBlindSignature:blindSig index:self.transaction.index];
            
            // scriptData contains pubkey in case of single signature tx.
            BTCKey* pubkey = [[BTCKey alloc] initWithPublicKey:self.transaction.scriptData];
            
            BOOL validSig = [pubkey isValidSignature:fullSig hash:hash];
            
            if (validSig)
            {
                // Compute the full signature, set _signedTx and enable Redeem button.
                BTCScript* sigScript = [[BTCScript alloc] init];
                
                NSMutableData* signatureForScript = [fullSig mutableCopy];
                
                [signatureForScript appendBytes:&hashtype length:1];
                [sigScript appendData:signatureForScript];
                [sigScript appendData:pubkey.publicKey];
                
                txin.signatureScript = sigScript;

            
                // Transaction is signed now, return it.
            
                // validate the signatures before returning for extra measure.

                BTCScriptMachine* sm = [[BTCScriptMachine alloc] initWithTransaction:tx inputIndex:0];
                NSError* error = nil;
                BOOL r = [sm verifyWithOutputScript:[[txout script] copy] error:&error];
                if (!r)
                {
                    NSLog(@"Error: %@", error);
                }
                else
                {
                    _signedTx = tx;
                    self.redeemButton.enabled = YES;
                    self.redeemButton.alpha = 1.0;
                }
            }
            
        }
    }
    else
    {
        self.hashField.text = @"";
        self.signatureField.text = @"";
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self recalculate];
    
    [textField resignFirstResponder];
    
    return NO;
}


- (IBAction)redeem:(id)sender
{
    // Send transaction out and show an alert saying "Ok!"
    if (!_signedTx) return;
    
    NSURLRequest* req = [[[BTCBlockchainInfo alloc] init] requestForTransactionBroadcastWithData:[_signedTx data]];
    NSData* data = [NSURLConnection sendSynchronousRequest:req returningResponse:nil error:nil];
    
    NSString* msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"Broadcast result: data = %@", data);
    NSLog(@"string = %@", msg);
    
    [[[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"%@", msg] message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}





@end
