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
    
    [self traitCollectionDidChange:self.traitCollection];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Dial Plan",@"Dial Plan");
    
    self.view.backgroundColor = RGB(242, 242, 242);
    
    [self.view addSubview:self.DialPlanTableview];
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Add",@"Add") style:UIBarButtonItemStylePlain target:self action:@selector(add)];
    self.navigationItem.rightBarButtonItem = right;
    self.navigationController.navigationBar.tintColor = MAIN_COLOR;
    
    
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

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection{
    UIColor* bkColor;
    if (@available(iOS 11.0, *)) {
        bkColor = [UIColor colorNamed:@"mainBKColor"];
    }
    else{
        bkColor = [UIColor whiteColor];
    }
    
    self.DialPlanTableview.backgroundColor = bkColor;
    self.view.backgroundColor = bkColor;
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
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AddDialPlanViewController * addcon  = [[AddDialPlanViewController alloc]init];
    
    addcon.person =[DataArr objectAtIndex:indexPath.row];
    
    self.hidesBottomBarWhenPushed = YES;
    
    
    
    [self.navigationController pushViewController:addcon animated:YES];
    
    
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    Person *person =[DataArr objectAtIndex:indexPath.row];
    
    [[DataBase sharedDataBase]deletePerson:person];
    
    DataArr = [[DataBase sharedDataBase]getAllPerson];
    
    
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NSLocalizedString(@"Delete",@"Delete");
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
        _DialPlanTableview.backgroundColor = [UIColor clearColor];
        _DialPlanTableview.delegate = self;
        _DialPlanTableview.dataSource = self;
        _DialPlanTableview.scrollEnabled = YES;
        _DialPlanTableview.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        
        [_DialPlanTableview flashScrollIndicators];
        
    }
    return _DialPlanTableview;
    
    
}

@end
