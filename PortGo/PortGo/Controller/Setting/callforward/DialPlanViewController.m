//
//  DialPlanViewController.m
//  PortGo
//
//  Created by 今言网络 on 2017/11/13.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//
//拨号计划

#import "DialPlanViewController.h"

#import "DataBase.h"
#import "Person.h"

#import "AddDialPlanViewController.h"

@interface DialPlanViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    
        NSMutableArray * DataArr;
    
    
    NSString * selectindex;
    
    
}


@property (nonatomic)  UITableView * DialPlanTableview;


@end

@implementation DialPlanViewController


-(void)viewWillAppear:(BOOL)animated
{
    
    DataArr = [[DataBase sharedDataBase]getAllPerson];
    
    [self.DialPlanTableview reloadData];
    
    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
     self.title = NSLocalizedString(@"Dial Plan",@"Dial Plan");
    
     self.view.backgroundColor = RGB(242, 242, 242);
    
  //  selectindex = [[[NSUserDefaults standardUserDefaults]objectForKey:@"DialPlanPerson"] stringValue];
    
    [self.view addSubview:self.DialPlanTableview];
    
    
    // Do any additional setup after loading the view.
    
    
    //NSLocalizedString(@"Cancel", @"Cancel")
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add",@"Add") style:UIBarButtonItemStylePlain target:self action:@selector(add)];
    self.navigationItem.rightBarButtonItem = right;
    self.navigationController.navigationBar.tintColor = SYSTEM_COLOR;
    
    
}

-(void)add{
    
    AddDialPlanViewController * addcon  = [[AddDialPlanViewController alloc]init];
    
    addcon.person = [Person new];
    
    self.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addcon animated:YES];

    
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark --
#pragma mark tableview delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
    
    
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    
    return DataArr.count;
    
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString * celld = [NSString stringWithFormat:@"%ld%ld",(long)indexPath.section,(long)indexPath.row];
    
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:celld];
    
    
    Person *person  = [DataArr objectAtIndex:indexPath.row];
    
    cell.textLabel.text = person.name;
    
    NSLog(@"name=====%@",person.name);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    if ([[person.ID stringValue] isEqualToString:selectindex]) {
//
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
//    else
//    {
//        cell.accessoryType  = 0;
//    }
    
    return cell;
    
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
            AddDialPlanViewController * addcon  = [[AddDialPlanViewController alloc]init];
    
            addcon.person =[DataArr objectAtIndex:indexPath.row];
    
            self.hidesBottomBarWhenPushed = YES;
    
    
    
            [self.navigationController pushViewController:addcon animated:YES];
    
    
}


//-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
//
//
//    UITableViewRowAction *checkCallAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"查看" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//        AddDialPlanViewController * addcon  = [[AddDialPlanViewController alloc]init];
//
//        addcon.person =[DataArr objectAtIndex:indexPath.row];
//
//        self.hidesBottomBarWhenPushed = YES;
//
//
//
//        [self.navigationController pushViewController:addcon animated:YES];
//
//    }];
//    checkCallAction.backgroundColor =RGB(107 , 184, 129);
//
//    //NSLocalizedString(@"Audio Call",@"Audio Call")
//    UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
//
//        Person *person =[DataArr objectAtIndex:indexPath.row];
//
//        [[DataBase sharedDataBase]deletePerson:person];
//
//        DataArr = [[DataBase sharedDataBase]getAllPerson];
//
//
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//
//    }];
//
//    deleteAction.backgroundColor = RGB(219, 0, 0);
//
//
//    return @[deleteAction,checkCallAction];
//
//
//
//}

//左滑编辑模式
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //可在此对点击cell右边出现的按钮进行逻辑处理

    //[DataArr removeObjectAtIndex:indexPath.row];

    Person *person =[DataArr objectAtIndex:indexPath.row];

    [[DataBase sharedDataBase]deletePerson:person];

    DataArr = [[DataBase sharedDataBase]getAllPerson];


     [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];


}

//设置左滑删除按钮的文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //设置右边按钮的文字
    return NSLocalizedString(@"Delete",@"Delete");
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    //分割线补全
    
    if (indexPath.row==DataArr.count-1) {
        
        if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
            [cell setLayoutMargins:UIEdgeInsetsZero];
        }
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]){
            [cell setSeparatorInset:UIEdgeInsetsZero];
        }
    }
    
    
}


-(UITableView*)DialPlanTableview{
    
    
    if (!_DialPlanTableview) {
        
        
        _DialPlanTableview = [[UITableView alloc]initWithFrame:CGRectMake(0,0,ScreenWid,ScreenHeight) style:0];
        
        
        // [accountTableview zy_registClassCell:[yanchangshiyongCell class]];
        
        
        _DialPlanTableview.backgroundColor = [UIColor clearColor];
        //    _myTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.0001)];
        // _myTable.separatorStyle =0;
        //myTable.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0.001)];
        _DialPlanTableview.delegate = self;
        _DialPlanTableview.dataSource = self;
        
        
        _DialPlanTableview.scrollEnabled = YES;
        
        _DialPlanTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [_DialPlanTableview flashScrollIndicators];
        
    }
    return _DialPlanTableview;
    
    
}

@end
