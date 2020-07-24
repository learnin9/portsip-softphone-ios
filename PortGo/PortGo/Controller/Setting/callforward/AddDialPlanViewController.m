//
//  AddDialPlanViewController.m
//  PortGo
//
//  Created by 今言网络 on 2017/11/14.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "AddDialPlanViewController.h"
#import "DataBase.h"
#import "Toast+UIView.h"
@interface AddDialPlanViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

{
    UITextField *textfield0;
    UITextField *textfield1;
    UITextField *textfield2;
    UITextField *textfield3;
    
    
    
}


@property (nonatomic)  UITableView * AddDialPlanTableview;

@end



@implementation AddDialPlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.title = NSLocalizedString(@"New Dial Plan",@"New Dial Plan");
    
    self.view.backgroundColor = RGB(242, 242, 242);
    
 
    [self.view addSubview:self.AddDialPlanTableview];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle: NSLocalizedString(@"Save", @"Save") style:UIBarButtonItemStylePlain target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = right;
    self.navigationController.navigationBar.tintColor = SYSTEM_COLOR;
    
    // Do any additional setup after loading the view.
}

-(void)save{
    
    
    if ([textfield0.text isEqualToString:@""]) {
        
         [ self.view makeToast:NSLocalizedString(@"Name is required",@"Name is required") duration:1.0 position:@"center"];
        return;
        
    }
    
//    if ([textfield1.text rangeOfString:textfield2.text].location ==NSNotFound) {
//
//        [ self.view makeToast:@"删除前缀必须是匹配前缀的开头一部分" duration:1.0 position:@"center"];
//
//        return ;
//    }
    
    
    _person.name = textfield0.text;
       _person.str1 = textfield1.text;
       _person.str2 = textfield2.text;
       _person.str3 = textfield3.text;
    
  //  NSLog(@"_person.ID====%@",_person.ID);
    //NSLog(@"name=%@ 1=%@ 2=%@ 3=%@",_person.name ,_person.str1 ,_person.str2  ,_person.str3);
    
    if (!_person.ID ) {
        
        //添加
        
        [[DataBase sharedDataBase]addPerson:_person];
        
    }
    else
    {
        //更新
        
        [[DataBase sharedDataBase]updatePerson:_person];
        
        
    }
    
    [self.navigationController popViewControllerAnimated:YES];
    
    
}


- ( BOOL )textFieldShouldReturn:( UITextField*)textField{
    
    
    [textField resignFirstResponder];
    
    
    if ([textField isEqual:textfield0]) {
        
        _person.name = textField.text;
        
        
    }
    else if ([textField isEqual:textfield1]){
        
        _person.str1 = textField.text;
        
        
    }
    else if ([textField isEqual:textfield2]){
        
        
      
             _person.str2 = textField.text;
        
    }
    else if ([textField isEqual:textfield3]){
        
              _person.str3 = textField.text;
        
    }
    
    
    
    
    return YES;
}
#pragma mark --
#pragma mark tableview delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    return 4;
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString * celld = [NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:celld];
    
    if (indexPath.row==0) {
        
        cell.textLabel.text =  NSLocalizedString(@"Name",@"Name");
        
        textfield0 = [[UITextField alloc]init];
        
        textfield0.frame = CGRectMake(ScreenWid-150, 0, 140, 44);
        
        textfield0.delegate =self;
        
        textfield0.textAlignment = NSTextAlignmentRight;
        
        textfield0.font = [UIFont systemFontOfSize:13];
        
        textfield0.text = _person.name;
        
        textfield0.placeholder  = NSLocalizedString(@"description", @"description");
        
        [cell.contentView addSubview:textfield0];
        
        
    }else if (indexPath.row==1){
        
         cell.textLabel.text =  NSLocalizedString(@"Match Prefix", @"Match Prefix");
        
     
        textfield1 = [[UITextField alloc]init];
        
        textfield1.frame = CGRectMake(ScreenWid-150, 0, 140, 44);
        
        textfield1.delegate =self;
        
        textfield1.textAlignment = NSTextAlignmentRight;
        
        textfield1.font = [UIFont systemFontOfSize:13];
        
        textfield1.text = _person.str1;
        
           textfield1.placeholder  =  NSLocalizedString(@"e.g. +173", @"e.g. +173");
        [cell.contentView addSubview:textfield1];
        
        
        
    }else if (indexPath.row==2){
        
         cell.textLabel.text = NSLocalizedString(@"Remove Prefix", @"Remove Prefix");
        
        textfield2 = [[UITextField alloc]init];
        
        textfield2.frame = CGRectMake(ScreenWid-150, 0, 140, 44);
        
        textfield2.delegate =self;
        
        textfield2.textAlignment = NSTextAlignmentRight;
        
        textfield2.font = [UIFont systemFontOfSize:13];
        
        textfield2.text = _person.str2;
        
              textfield2.placeholder  =  NSLocalizedString(@"e.g. +1", @"e.g. +1");
        [cell.contentView addSubview:textfield2];
        
        
        
    }else if (indexPath.row==3){
        
         cell.textLabel.text =  NSLocalizedString(@"Prepend Prefix", @"Prepend Prefix");
      
        
        textfield3 = [[UITextField alloc]init];
        
        textfield3.frame = CGRectMake(ScreenWid-150, 0, 140, 44);
        
        textfield3.delegate =self;
        
        textfield3.textAlignment = NSTextAlignmentRight;
        
        textfield3.font = [UIFont systemFontOfSize:13];
        
        textfield3.text = _person.str3;
        
                textfield3.placeholder  =  NSLocalizedString(@"e.g. 8", @"e.g. 8");
        
        [cell.contentView addSubview:textfield3];
        
        
    }
   
   // cell.textLabel.text =
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
    
    
}





-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //分割线补全
    
    if (indexPath.row==3) {
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    
    
}


-(UITableView*)AddDialPlanTableview{
    
    
    if (!_AddDialPlanTableview) {
        
        
        _AddDialPlanTableview = [[UITableView alloc]initWithFrame:CGRectMake(0,0,ScreenWid,ScreenHeight) style:0];
        
        
        // [accountTableview zy_registClassCell:[yanchangshiyongCell class]];
        
        
        _AddDialPlanTableview.backgroundColor = [UIColor clearColor];
        //    _myTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.0001)];
        // _myTable.separatorStyle =0;
        //myTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
        _AddDialPlanTableview.delegate = self;
        _AddDialPlanTableview.dataSource = self;
        
        
        _AddDialPlanTableview.scrollEnabled = YES;
        
        _AddDialPlanTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [_AddDialPlanTableview flashScrollIndicators];
        
    }
    return _AddDialPlanTableview;
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
