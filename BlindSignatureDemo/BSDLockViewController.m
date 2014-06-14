//
//  BSDLockViewController.m
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 15.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BSDLockViewController.h"

@interface BSDLockViewController ()
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIImageView *qrcodeView;

@end

@implementation BSDLockViewController {
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.friends.count == 0)
    {
        [[[UIAlertView alloc] initWithTitle:@"No friends" message:@"Please select some friends" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        [self.navigationController popViewControllerAnimated:animated];
        return;
    }
    
    int minSignatures = MAX(1, ((int)self.friends.count + 1) / 2); // 1->1, 2->1, 3->2, 4->2, 5->3, 6->3, ...
    
    // Generate transaction
    
    BSDTransaction* tx = [[BSDStorage sharedStorage] addTransactionForFriends:self.friends minSignatures:minSignatures];
    
    self.title = [NSString stringWithFormat:@"Transaction #%03d", tx.index];
    
    self.addressLabel.text = tx.address ?: @"";
    
    NSString* txaddr = [tx.address copy];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        if (txaddr.length > 0)
        {
            NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"https://blockchain.info/qr?data=%@&size=256", txaddr]];
            NSData* data = [NSURLConnection sendSynchronousRequest:[NSURLRequest requestWithURL:url] returningResponse:NULL error:NULL];
            if (data)
            {
                UIImage* image = [UIImage imageWithData:data];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (image) self.qrcodeView.image = image;
                });
            }
        }
    });
}


@end
