//
//  IMEditViewController.m
//  PortGo
//
//  Created by 今言网络 on 2017/9/11.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "IMEditViewController.h"

@interface IMEditViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSInteger lastSelect;
    NSString *selectNumber;
}
@property (nonatomic, strong) UITableView *IMAddressView;
@end

@implementation IMEditViewController

-(void)createTableviw {
    _IMAddressView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    
    _IMAddressView.delegate = self;
    _IMAddressView.dataSource = self;
    
    [self.view addSubview:_IMAddressView];
}

-(void)loadDataSource {
    for (int i = 0; i<_IMAddresses.count; ++i) {
        NSDictionary *dic = _IMAddresses[i];
        NSString *key = [dic allKeys][0];
        NSString *value = dic[key];
        if ([value isEqualToString:@"AddIPCall"] || [value isEqualToString:@"No IM"] || [value isEqualToString:@""]) {
            [_IMAddresses removeObjectAtIndex:i];
            i -= 1;
        }
    }
}

-(void)doneAction {
    if (self.block) {
        self.block(selectNumber);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)didIMAddressSaved:(IMSaveBlock)callback {
    self.block = callback;
}


#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    selectNumber = [self.contacrIM copy];
    
    [self loadDataSource];
    [self createTableviw];
    
}

-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, footer.bounds.size.width - 20, 50)];
    
    label.text = NSLocalizedString(@"tempstr", @"tempstr");
    
    label.font = [UIFont systemFontOfSize:12];
    label.numberOfLines = 3;
    label.textColor = [UIColor lightGrayColor];
    [footer addSubview:label];
    return footer;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 30)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, header.bounds.size.width - 20, 30)];
    
    label.text = NSLocalizedString(@"Select  IM Address", @"Select  IM Address");
    label.font = [UIFont systemFontOfSize:14];
    label.textColor = [UIColor lightGrayColor];
    [header addSubview:label];
    return header;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1 ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _IMAddresses.count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"None", @"None");
        
        if (!_contacrIM) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
    
    NSDictionary *dic = _IMAddresses[indexPath.row-1];
    NSString *key = [dic allKeys][0];
    NSString *value = [dic objectForKey:key];
    
    cell.textLabel.text = value;
    
    if ([value isEqualToString:self.contacrIM]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        lastSelect = indexPath.row;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    if (lastSelect != indexPath.row){
        UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelect inSection:0]];
        lastCell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    lastSelect = indexPath.row;
    if ([cell.textLabel.text isEqualToString:NSLocalizedString(@"None", @"None")]  || [cell.textLabel.text isEqualToString:@"无即时通讯地址"]  ) {
        selectNumber = @"";
        
    } else {
        selectNumber = cell.textLabel.text;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
