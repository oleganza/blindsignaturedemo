//
//  BSDViewController.m
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 14.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BSDViewController.h"
#import "BSDFriendsViewController.h"

@interface BSDViewController ()

@end

@implementation BSDViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
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

- (IBAction)lockFunds:(id)sender {
    
}

- (IBAction)unlockFunds:(id)sender {
    
}


@end
