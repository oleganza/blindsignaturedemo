//
//  BSDSelectFriendsViewController.m
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 15.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BSDSelectFriendsViewController.h"
#import "BSDLockViewController.h"

@interface BSDSelectFriendsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;


@end

@implementation BSDSelectFriendsViewController {
        NSArray* _friends;
        NSMutableArray* _selectedFriends;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Continue" style:UIBarButtonItemStylePlain target:self action:@selector(next:)];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Select Friends";
    // Do any additional setup after loading the view from its nib.
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _friends = [[BSDStorage sharedStorage] loadFriends];
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"x"];
    
    BSDPerson* friend =_friends[indexPath.row];
    cell.textLabel.text = friend.name;
    
    if (friend.theirExtendedPublicKey.length  == 0)
    {
        cell.textLabel.text = [NSString stringWithFormat:@"%@ (no pubkey)", cell.textLabel.text];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    if ([_selectedFriends containsObject:friend])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BSDPerson* person = _friends[indexPath.row];
    
    if ([_selectedFriends containsObject:person])
    {
        [_selectedFriends removeObject:person];
    }
    else
    {
        _selectedFriends = _selectedFriends ?: [NSMutableArray array];
        [_selectedFriends addObject:person];
    }
    
    [self.tableView reloadData];
}

- (void) next:(id)_
{
    if (_selectedFriends.count == 0) return;
    
    BSDLockViewController* vc = [[BSDLockViewController alloc] initWithNibName:nil bundle:nil];
    
    vc.friends = _selectedFriends;
    
    [self.navigationController pushViewController:vc animated:YES];
}



@end
