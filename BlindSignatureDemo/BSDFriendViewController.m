//
//  BSDFriendViewController.m
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 15.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BSDFriendViewController.h"

@interface BSDFriendViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameField;
@property (weak, nonatomic) IBOutlet UITextField *theirPubkeyField;
@property (weak, nonatomic) IBOutlet UITextField *myPubkeyField;
@end

@implementation BSDFriendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nameField.text = self.friend.name;
    
    self.theirPubkeyField.text = self.friend.theirExtendedPublicKey;
    
    self.myPubkeyField.text =  BTCBase58CheckStringWithData(self.friend.myKeychain.extendedPublicKey);
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) update
{
    self.friend.name = self.nameField.text;
    self.friend.theirExtendedPublicKey = self.theirPubkeyField.text;
    
    [[BSDStorage sharedStorage] saveFriends];

}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.myPubkeyField) return NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self update];
    });
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    if (textField == self.myPubkeyField) return NO;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self update];
        
    });
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self update];
        
    });

    [textField resignFirstResponder];
    
    return NO;
}

@end
