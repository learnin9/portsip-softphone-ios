//
//  CallForwardingViewController.m
//  PortGo
//
//  Created by 今言网络 on 2017/11/13.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

//呼叫转移


#import "CallForwardingViewController.h"
#import "AccountTool.h"
#import "IQKeyboardManager.h"
#import "AppDelegate.h"
#import "Toast+UIView.h"

@interface CallForwardingViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

{
    AccountTool * accountTool;
    
    UITextField * NoResponseTimeTextfield;
    
    UITextField *ForwardingObjectTextfield;
    
}

@property (nonatomic)  UITableView * CallForwardingTableview;

@end



@implementation CallForwardingViewController


-(void)dealloc
{
    
    if (ForwardingObjectTextfield.text.length==0) {
        
        accountTool.callforwardindex = @"0";
        
        [[NSUserDefaults standardUserDefaults]setObject:accountTool.callforwardindex forKey:@"callforwardindex"];
        
    }
    
    
    
    if ([accountTool.callforwardindex isEqualToString:@"0"]) {
        
        [portSIPEngine disableCallForward];
    }
    else if ([accountTool.callforwardindex isEqualToString:@"1"]){
        
        [portSIPEngine enableCallForward:false forwardTo:ForwardingObjectTextfield.text];
        
        
    }
    else if ([accountTool.callforwardindex isEqualToString:@"2"]){
        
        [portSIPEngine enableCallForward:true forwardTo:ForwardingObjectTextfield.text];
        
    }
    else if ([accountTool.callforwardindex isEqualToString:@"3"]){
        
        
    }
    
    
    [[NSUserDefaults standardUserDefaults]setObject: NoResponseTimeTextfield.text forKey:@"callforwardtime"];
    [[NSUserDefaults standardUserDefaults]setObject:ForwardingObjectTextfield.text  forKey:@"callforwardobject"];
    
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [IQKeyboardManager sharedManager].enable = YES;
}

-(void)viewWillDisappear:(BOOL)animated
{
    NSLog(@"viewwilldisapper");
    
    //    [self.view makeToast:NSLocalizedString(@"no set call for", @"no set call for") duration:2.0 position:@"center"];
    //
    
    
    [IQKeyboardManager sharedManager].enable = NO;
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
    }
    else{
        bkColor = [UIColor whiteColor];
    }
    
    self.CallForwardingTableview.backgroundColor = bkColor;
    self.view.backgroundColor = bkColor;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Call Forward", @"Call Forward");
    
    self.view.backgroundColor = RGB(242, 242, 242);
    
    [self.view addSubview:self.CallForwardingTableview];
    
    
    accountTool = [[AccountTool alloc]init];
    
    accountTool.callforwardindex = [[NSUserDefaults standardUserDefaults]objectForKey:@"callforwardindex"];
    accountTool.callforwardtime =[[NSUserDefaults standardUserDefaults]objectForKey:@"callforwardtime"];
    accountTool.callforwardobject =[[NSUserDefaults standardUserDefaults]objectForKey:@"callforwardobject"];
    
    [self traitCollectionDidChange:self.traitCollection];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark --
#pragma mark tableview delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 2;
    
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (section==0) {
        
        if ([accountTool .callforwardindex isEqualToString:@"3"]) {
            
            return 5;
        }
        
        
        return 4;
        
    }else {
        
        return 1;
    }
    
    
    
    
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString * celld = [NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:celld];
    
    
    if (indexPath.section==0) {
        
        if (indexPath.row==0) {
            
            cell.textLabel.text =  NSLocalizedString(@"Disable forward", @"Disable forward");
            
            if ([accountTool.callforwardindex isEqualToString:@"0"]) {
                
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
            }
            
            if ([accountTool.callforwardindex integerValue] ==0) {
                
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
            
            
        }
        else if (indexPath.row==1){
            
            cell.textLabel.text = NSLocalizedString(@"Forward all", @"Forward all");
            
            if ([accountTool.callforwardindex isEqualToString:@"1"]) {
                
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
            }
            
        }
        
        
        
        else if (indexPath.row==2){
            
            cell.textLabel.text = NSLocalizedString(@"Forward when busy", @"Forward when busy");
            
            if ([accountTool.callforwardindex isEqualToString:@"2"]) {
                
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
            }
            
        }
        else if (indexPath.row==3){
            
            cell.textLabel.text = NSLocalizedString(@"Forward when no answer", @"Forward when no answer");
            
            if ([accountTool.callforwardindex isEqualToString:@"3"]) {
                
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
            }
            
        }
        else if (indexPath.row==4){
            
            cell.textLabel.text = NSLocalizedString(@"Forward after (seconds)", @"Forward after (seconds)");
            
            NoResponseTimeTextfield = [[UITextField alloc]init];
            
            NoResponseTimeTextfield.frame = CGRectMake(ScreenWid-150, 0, 140, 44);
            
            NoResponseTimeTextfield.delegate =self;
            
            NoResponseTimeTextfield.textAlignment = NSTextAlignmentRight;
            
            NoResponseTimeTextfield.font = [UIFont systemFontOfSize:13];
            
            
            NoResponseTimeTextfield.text = accountTool.callforwardtime;
            
            // NoResponseTimeTextfield.keyboardType = UIKeyboardTypeNumberPad;
            
            NoResponseTimeTextfield.placeholder = NSLocalizedString(@"seconds", @"seconds");
            
            [cell.contentView addSubview:NoResponseTimeTextfield];
            
        }
        
        
    }else if(indexPath.section==1) {
        
        cell.textLabel.text = NSLocalizedString(@"Forward to", @"Forward to");
        
        
        ForwardingObjectTextfield = [[UITextField alloc]init];
        
        ForwardingObjectTextfield.frame = CGRectMake(ScreenWid-150, 0, 140, 44);
        
        ForwardingObjectTextfield.delegate =self;
        
        ForwardingObjectTextfield.textAlignment = NSTextAlignmentRight;
        
        ForwardingObjectTextfield.font = [UIFont systemFontOfSize:13];
        
        ForwardingObjectTextfield.text = accountTool.callforwardobject;
        
        ForwardingObjectTextfield.placeholder = NSLocalizedString(@"Forward to", @"Forward to");
        
        [cell.contentView addSubview:ForwardingObjectTextfield];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==0 &&  indexPath.row ==4) {
        
        [NoResponseTimeTextfield becomeFirstResponder];
        return;
        
    }
    
    if (indexPath.section==1) {
        
        [ForwardingObjectTextfield becomeFirstResponder];
        
        
        return;
    }
    
    
    if (indexPath.section==0) {
        
        
        accountTool.callforwardobject = ForwardingObjectTextfield.text;
        
        [[NSUserDefaults standardUserDefaults]setObject: ForwardingObjectTextfield.text forKey:@"callforwardobject"];
        
        accountTool.callforwardindex = [NSString stringWithFormat:@"%ld",(long)indexPath.row];
        
        
        //NSLog(@"accountTool.callforwardindex=====%@",accountTool.callforwardindex);
        
        [[NSUserDefaults standardUserDefaults]setObject: accountTool.callforwardindex forKey:@"callforwardindex"];
        
        
        
        if (indexPath.row !=0   ) {
            
            
            if  ([ForwardingObjectTextfield.text isEqualToString:@""] ||  ForwardingObjectTextfield.text ==nil){
                [self.view makeToast:NSLocalizedString(@"no set call for", @"no set call for") duration:0.8 position:@"center"];
                
            }
        }
    }
    
    [tableView reloadData];
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc]init];
    UIColor *bkColorlight;
    if (@available(iOS 11.0, *)) {
        bkColorlight = [UIColor colorNamed:@"mainBKColorLight"];
    }
    else{
        bkColorlight = [UIColor whiteColor];
    }
    
    view.backgroundColor = bkColorlight;
    
    return view;
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    
    
}

#pragma mark --
#pragma mark   UiTextfield delegate

- ( BOOL )textFieldShouldReturn:( UITextField*)textField{
    
    
    [textField resignFirstResponder];
    
    
    if ([textField isEqual:NoResponseTimeTextfield]) {
        
        NSLog(@"NoResponseTimeTextfield.text==%@",NoResponseTimeTextfield.text);
        
        accountTool.callforwardtime =NoResponseTimeTextfield.text;
        
        
        
        [[NSUserDefaults standardUserDefaults]setObject: accountTool.callforwardtime forKey:@"callforwardtime"];
        
        
    }
    else if ([textField isEqual:ForwardingObjectTextfield]){
        
        NSLog(@"ForwardingObjectTextfield.text===%@",ForwardingObjectTextfield.text);
        
        accountTool.callforwardobject =ForwardingObjectTextfield.text;
        [[NSUserDefaults standardUserDefaults]setObject: accountTool.callforwardobject forKey:@"callforwardobject"];
    }
    
    return YES;
}

-(UITableView*)CallForwardingTableview{
    
    
    if (!_CallForwardingTableview) {
        
        _CallForwardingTableview = [[UITableView alloc]initWithFrame:CGRectMake(0,0,ScreenWid,ScreenHeight) style:0];
        _CallForwardingTableview.backgroundColor = [UIColor clearColor];
        _CallForwardingTableview.delegate = self;
        _CallForwardingTableview.dataSource = self;
        _CallForwardingTableview.scrollEnabled = YES;
        _CallForwardingTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [_CallForwardingTableview flashScrollIndicators];
        
    }
    return _CallForwardingTableview;
    
}


@end
