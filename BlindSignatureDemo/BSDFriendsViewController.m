//
//  BSDFriendsViewController.m
//  BlindSignatureDemo
//
//  Created by Oleg Andreev on 15.06.2014.
//  Copyright (c) 2014 Oleg Andreev. All rights reserved.
//

#import "BSDFriendsViewController.h"
#import "BSDFriendViewController.h"

@interface BSDFriendsViewController () <UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation BSDFriendsViewController {
    NSArray* _friends;
}

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
    self.title = @"Friends";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    _friends = [[BSDStorage sharedStorage] loadFriends];
    [self.tableView reloadData];
}

- (IBAction)addFriend:(id)sender
{
    BSDPerson* friend = [[BSDStorage sharedStorage] addFriend];
    
    [self openFriend:friend];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _friends.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"x"];
    
    cell.textLabel.text = [_friends[indexPath.row] name];
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self openFriend:_friends[indexPath.row]];
}

- (void) openFriend:(BSDPerson*)person
{
    BSDFriendViewController* fvc = [[BSDFriendViewController alloc] initWithNibName:nil bundle:nil];
    
    fvc.friend = person;
    
    [self.navigationController pushViewController:fvc animated:YES];
}



@end
