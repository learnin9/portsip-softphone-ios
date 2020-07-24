//
//  HSNamesViewController.m
//  PortGo
//
//  Created by MrLee on 14-9-25.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSNamesViewController.h"
#import "HSNamesCell.h"
#import "Account.h"
#import "DataBaseManage.h"

#define kCellHeight 44
#define cellID @"cellID"

@interface HSNamesViewController ()<HSNamesCellDelegate>
{
    NSArray *_array;
    NSString *_displayName;
    NSString *_authorName;
    NSString *_domainName;
}
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *nameTV;

//@property (weak, nonatomic) IBOutlet UITableView *tableview;
@end

@implementation HSNamesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _titleLabel.text = NSLocalizedString(@"Names", @"Names");
    _array = [NSArray arrayWithObjects:NSLocalizedString(@"Display Name", @"Display Name"), NSLocalizedString(@"Auth Name", @"Auth Name"), NSLocalizedString(@"User Domain", @"User Domain"), nil];
    [_topView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbar_background.png"]]];
    [_nameTV registerNib:[UINib nibWithNibName:@"HSNamesCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:cellID];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.delegate didWriteDoneWithDisplayName:_displayName AuthorName:_authorName Domain:_domainName];
}

- (IBAction)returnButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark Tableview delegate method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _array.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HSNamesCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.tipsLabel.font = SYSTEM_FONT;
    cell.inputTextField.font = SYSTEM_FONT;
    
    if (indexPath.row == 0) {
        _displayName = _account.displayName;
        if ([_displayName isEqualToString:@"(null)"]) {
            cell.inputTextField.text = nil;
        }
        else{
            cell.inputTextField.text = _displayName;
        }
    }
    else if (indexPath.row == 1){
        _authorName = _account.authName;
        if ([_authorName isEqualToString:@"(null)"]) {
            cell.inputTextField.text = nil;
        }
        else{
            cell.inputTextField.text = _authorName;
        }
    }
    else if (indexPath.row == 2){
        _domainName = _account.userDomain;
        if ([_domainName isEqualToString:@"(null)"]) {
            cell.inputTextField.text = nil;
        }
        else{
            cell.inputTextField.text = _domainName;
        }
    }
    
    //    cell.inputTextField.placeholder = _array[indexPath.row];
    cell.tipsLabel.text = _array[indexPath.row];
    cell.tag = indexPath.row;
    cell.delegate = self;
    
    return cell;
}

#pragma mark - HSNamesCellDelegate

- (void)endEditingWithText:(NSString *)str cell:(id)cell
{
    HSNamesCell *nameCell = (HSNamesCell*)cell;
    if (nameCell.tag == 0) {
        _displayName = str;
    }
    else if (nameCell.tag == 1){
        _authorName = str;
    }
    else if (nameCell.tag == 2){
        _domainName = str;
    }
    
    _account.displayName = _displayName;
    _account.authName = _authorName;
    _account.userDomain = _domainName;
    
    [databaseManage saveActiveAccount:_account reset:YES];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}
@end
