//
//  HSTransportViewController.m
//  PortGo
//
//  Created by MrLee on 14-9-30.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSTransportViewController.h"
#import "DataBaseManage.h"

#define kTranportKey    NSLocalizedString(@"Transport", @"Transport")
#define kServerKey      NSLocalizedString(@"STUN Server", @"STUN Server")

#define kTextFieldWidth  175.0f
#define kTextFieldHeight 25.0f
#define kLeftMargin      105.0f
#define kRightMargin     5.0f

#define cellID @"cellID"
@interface HSTransportViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    NSArray *_mList;
    NSIndexPath *_mLastSelected;
    
    NSArray *_mStunList;
    
    UITextField *_mStunServerTextField;
    UITextField *_mStunPortTextField;
    
    CGRect _mTableViewRect;
}
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *transportTableView;

@end

@implementation HSTransportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.titleLabel.text = NSLocalizedString(@"Transport", @"Transport");
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [_topView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbar_background.png"]]];
    
    _mList = [[NSArray alloc]initWithObjects:@"UDP", @"TLS",@"TCP",@"PERS", nil];
    
    _mStunList = [[NSArray alloc]initWithObjects:NSLocalizedString(@"Enable STUN", @"Enable Stun"),
                  NSLocalizedString(@"Server", @"Server"),
                  NSLocalizedString(@"Port", @"Port"), nil];
    
    _mStunServerTextField = [self getServerTextField];
    _mStunPortTextField = [self getPortTextField];
    
    
    
    _mTableViewRect = _transportTableView.frame;
    [_transportTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
}

- (void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification*)notification
{
    
    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    
    CGFloat keyboardTop = keyboardRect.origin.y;
    
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    CGRect tableviewRect = _transportTableView.frame;
    tableviewRect.origin.y = _topView.bounds.size.height;
    tableviewRect.size.height = keyboardTop - 64;
    
    [_transportTableView setFrame:tableviewRect];
    
}

-(void) scrollToBottom:(BOOL)animated
{
    [_transportTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(_mStunList.count - 1) inSection:1] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
}

- (void)keyboardWillHide:(NSNotification*)notification
{
    NSDictionary *userInfo = [notification userInfo];
    // Get the duration of the animation.
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [_transportTableView setFrame:_mTableViewRect];
}


-(UITextField *)getPortTextField
{
    CGRect textFieldFrame = CGRectMake(0, 7, kTextFieldWidth, kTextFieldHeight);
    UITextField *portTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
    portTextField.text = [[NSString alloc] initWithFormat:@"%d",databaseManage.mAccount.STUNPort];
    portTextField.keyboardType = UIKeyboardTypeNumberPad;
    portTextField.textAlignment = NSTextAlignmentRight;
    portTextField.returnKeyType = UIReturnKeyDone;
    
    return portTextField;
}

-(UITextField *)getServerTextField
{
    CGRect textFieldFrame = CGRectMake(0, 7, kTextFieldWidth, kTextFieldHeight);
    UITextField *serverTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
    serverTextField.placeholder = kServerKey;
    serverTextField.text = databaseManage.mAccount.STUNServer;
    serverTextField.keyboardType =UIKeyboardTypeEmailAddress;
    serverTextField.returnKeyType = UIReturnKeyDone;
    serverTextField.textAlignment = NSTextAlignmentRight;
    
    return serverTextField;
}

- (IBAction)returnButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return _mList.count;
    }
    else{
        return _mStunList.count;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return NSLocalizedString(@"STUN", @"STUN");
    }
    else{
        return NSLocalizedString(@"Signaling Transport", @"Signaling Transport");
    }
}

#pragma mark- cell
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    NSUInteger row = indexPath.row;
    NSUInteger section = indexPath.section;
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.accessoryView = nil;
    
    if (section == 0) {
        cell.textLabel.text = _mList[indexPath.row];
        
        if([cell.textLabel.text isEqualToString:_lastSelectTranport])
        {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            _mLastSelected = indexPath;
        }
        else
        {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    else{
        
        if (row == 0) {
            cell.textLabel.text = NSLocalizedString([_mStunList objectAtIndex:row], [_mStunList objectAtIndex:row]);
            UISwitch *switchOperation = [[UISwitch alloc]init];
            [switchOperation addTarget:self action:@selector(switchPressed:) forControlEvents:UIControlEventValueChanged];
            switchOperation.on = (databaseManage.mAccount.enableSTUN != 0);
            cell.accessoryView = switchOperation;
        }
        else if (row == 1){
            cell.textLabel.text = NSLocalizedString([_mStunList objectAtIndex:row], [_mStunList objectAtIndex:row]);
            _mStunServerTextField.textColor = [UIColor darkGrayColor];
            _mStunServerTextField.font = SYSTEM_FONT;
            _mStunServerTextField.backgroundColor = [UIColor clearColor];
            _mStunServerTextField.borderStyle = UITextBorderStyleNone;
            _mStunServerTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            _mStunServerTextField.delegate = self;
            cell.accessoryView = _mStunServerTextField;
        }
        else if (row == 2){
            cell.textLabel.text = NSLocalizedString([_mStunList objectAtIndex:row], [_mStunList objectAtIndex:row]);
            _mStunPortTextField.textColor = [UIColor darkGrayColor];
            _mStunPortTextField.font = SYSTEM_FONT;
            _mStunPortTextField.backgroundColor = [UIColor clearColor];
            _mStunPortTextField.borderStyle = UITextBorderStyleNone;
            _mStunPortTextField.autocorrectionType = UITextAutocorrectionTypeNo;
            _mStunPortTextField.delegate = self;
            cell.accessoryView = _mStunPortTextField;
        }
    }
    
    return cell;
    
}

-(void)switchPressed:(id)sender
{
    Account *account = [databaseManage mAccount];
    account.enableSTUN = [sender isOn];
    [databaseManage saveActiveAccount:account reset:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    Account *account = [databaseManage mAccount];
    account.STUNServer = _mStunServerTextField.text;
    account.STUNPort = [_mStunPortTextField.text intValue];
    [databaseManage saveActiveAccount:account reset:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
    return YES;
}

#pragma mark - TableView Delegate Method

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        return;
    }
    
    if (indexPath == _mLastSelected) {
        return;
    }
    
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:_mLastSelected];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    _mLastSelected = indexPath;
    
    UITableViewCell *newCell = [tableView cellForRowAtIndexPath:indexPath];
    newCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.lastSelectTranport = newCell.textLabel.text;
    [self.delegate didSelectTranport:_lastSelectTranport];
    
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
