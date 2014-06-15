//
//  BSDSignViewController.m
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 15.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BSDSignViewController.h"

@interface BSDSignViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txField;
@property (weak, nonatomic) IBOutlet UITextField *sigField;

@end

@implementation BSDSignViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Sign";
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.sigField.text = @"";
    
    if (self.txField.text.length > 0)
    {
        // Parse: 4 bytes prefix, 4 bytes index, rest is blinded hash.
        NSData* rawdata = BTCDataFromBase58Check(self.txField.text);
        if (rawdata.length > 8)
        {
            uint32_t index = *(((uint32_t*)rawdata.bytes) + 1);
            NSData* blindedhash = [rawdata subdataWithRange:NSMakeRange(sizeof(uint32_t)*2, rawdata.length - sizeof(uint32_t)*2)];
            
            BTCBlindSignature* blindAPI = [[BTCBlindSignature alloc] initWithCustodianKeychain:self.friend.myKeychain];
            
            NSData* blindSignature = [blindAPI blindSignatureForBlindedHash:blindedhash index:index];
            
            self.sigField.text = BTCBase58CheckStringWithData(blindSignature);
        }
    }
    
    return YES;
}

@end
