//
//  BSDViewController.m
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 14.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BSDViewController.h"
#import "BSDFriendsViewController.h"
#import "BSDSelectFriendsViewController.h"
#import "BSDUnlockViewController.h"

@interface BSDViewController ()

@end

@implementation BSDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"The Ultimate Vault";
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)openFriends:(id)sender {
    BSDFriendsViewController* fvc = [[BSDFriendsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:fvc animated:YES];
}

- (IBAction)lockFunds:(id)sender
{
    BSDSelectFriendsViewController* fvc = [[BSDSelectFriendsViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:fvc animated:YES];
    
}

- (IBAction)unlockFunds:(id)sender
{
    BSDUnlockViewController* fvc = [[BSDUnlockViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:fvc animated:YES];
    
}


@end
