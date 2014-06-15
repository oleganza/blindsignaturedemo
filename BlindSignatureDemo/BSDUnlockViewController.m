//
//  BSDUnlockViewController.m
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 15.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BSDUnlockViewController.h"
#import "BSDRedeemViewController.h"

@interface BSDUnlockViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation BSDUnlockViewController {
    NSArray* _transactions;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Transactions";
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // Do any additional setup after loading the view from its nib.
    
    _transactions = [[BSDStorage sharedStorage] loadTransactions];
    
    [self.tableView reloadData];
    
    BTCBlockchainInfo* bci = [[BTCBlockchainInfo alloc] init];

    for (BSDTransaction* tx in _transactions)
    {
        BTCAddress* addr = [BTCAddress addressWithBase58String:tx.address];
        
        if (!addr) continue;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            NSError* error = nil;
            NSArray* outputs = [bci unspentOutputsWithAddresses:@[ addr ] error:&error];
            
            if (!outputs)
            {
                NSLog(@"ERROR: %@", error);
            }
            
            BTCSatoshi balance = 0;
            
            for (BTCTransactionOutput* txout in outputs)
            {
                balance += txout.value;
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                tx.txouts = outputs;
                tx.balance = balance;
                
//                if (rand() % 3 == 0)
//                {
//                    tx.balance = rand();
//                }
                if (self.isViewLoaded && self.view.window)
                {
                    [self.tableView reloadData];
                }
            });
        });
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _transactions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"x"];
    
    BSDTransaction* tx = _transactions[indexPath.row];
    
    BTCTransactionOutput* txout = tx.txouts.firstObject;
    NSUInteger confs = txout.confirmations;
    
    cell.textLabel.text = tx.title;
    
    cell.detailTextLabel.text = (tx.balance > 0) ? [NSString stringWithFormat:@"%0.06f btc", ((double)tx.balance) / 100000000.0] : @"";
    
    if (confs == 0 && tx.balance > 0)
    {
        cell.detailTextLabel.textColor = [UIColor grayColor];
    }
    else if (tx.balance > 0)
    {
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.055 green:0.473 blue:0.998 alpha:1.000];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BSDTransaction* tx = _transactions[indexPath.row];
    
    BSDRedeemViewController* vc = [[BSDRedeemViewController alloc] initWithNibName:nil bundle:nil];
    vc.transaction = tx;
    [self.navigationController pushViewController:vc animated:YES];
}



@end
