//
//  MarkViewController.m
//  PortGo
//
//  Created by 今言网络 on 2017/6/8.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "MarkViewController.h"
#import <Contacts/Contacts.h>

#define kTextFieldWidth  175.0f
#define kTextFieldHeight 25.0f

@interface MarkViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>
{
    UITextField *_customMarkFeild;
    
    NSString *lastSelectKey;
    NSInteger lastSelectRow;
}
@property (nonatomic, strong) UITableView *markTableVew;
@property (nonatomic, strong) NSMutableArray *dataSource;
@end

@implementation MarkViewController

-(UITableView *)creatMarkTableView {
    UITableView *mark = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, MAIN_SCREEN_WIDTH, self.view.bounds.size.height) style:UITableViewStyleGrouped];
    mark.delegate = self;
    mark.dataSource = self;
    return mark;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *left = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    self.navigationItem.leftBarButtonItem = left;
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Done", @"Done") style:UIBarButtonItemStylePlain target:self action:@selector(doneAction)];
    self.navigationItem.rightBarButtonItem = right;
    
    lastSelectKey = [_info allKeys][0];
    
    _dataSource = [NSMutableArray arrayWithObjects:[CNLabeledValue localizedStringForLabel:CNLabelHome],
                   [CNLabeledValue localizedStringForLabel:CNLabelWork],[CNLabeledValue localizedStringForLabel:CNLabelPhoneNumberiPhone],[CNLabeledValue localizedStringForLabel:CNLabelPhoneNumberMobile],[CNLabeledValue localizedStringForLabel:CNLabelPhoneNumberMain],[CNLabeledValue localizedStringForLabel:CNLabelPhoneNumberHomeFax],[CNLabeledValue localizedStringForLabel:CNLabelPhoneNumberWorkFax],[CNLabeledValue localizedStringForLabel:CNLabelPhoneNumberOtherFax],[CNLabeledValue localizedStringForLabel:CNLabelOther], nil];
    
    _markTableVew = [self creatMarkTableView];
    [self.view addSubview:_markTableVew];
    
}

-(void)cancelAction {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(void)doneAction {
    if ([_customMarkFeild.text isEqualToString:@""] || [_customMarkFeild.text isEqualToString:@" "]) {
        return ;
    }
    
    if (self.callBack) {
        self.callBack(_customMarkFeild.text);
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2 ;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return _dataSource.count;
    }
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = _dataSource[indexPath.row];
        if ([cell.textLabel.text isEqualToString:lastSelectKey]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            lastSelectRow = indexPath.row;
        } else {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
        return cell;
    }
    
    cell.accessoryView = nil;
    
    _customMarkFeild = [self getMarkTextFeild];
    //    _customMarkFeild.text = @"添加自定义标签";
    //    _customMarkFeild.placeholder = NSLocalizedString(@"Add Custom Mark", @"Add Custom Mark");
    
    _customMarkFeild.placeholder = NSLocalizedString(@"Create New Label", @"Create New Label");
    
    _customMarkFeild.textColor = [UIColor darkGrayColor];
    _customMarkFeild.font = [UIFont systemFontOfSize:15];
    _customMarkFeild.backgroundColor = [UIColor clearColor];
    _customMarkFeild.borderStyle = UITextBorderStyleNone;
    _customMarkFeild.autocorrectionType = UITextAutocorrectionTypeNo;
    _customMarkFeild.delegate = self;
    [cell.contentView addSubview:_customMarkFeild];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == lastSelectRow) {
        return;
    }
    UITableViewCell *lastCell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:lastSelectRow inSection:0]];
    lastCell.accessoryType = UITableViewCellAccessoryNone;
    
    UITableViewCell *currentCell = [tableView cellForRowAtIndexPath:indexPath];
    currentCell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    lastSelectKey = _dataSource[indexPath.row];
    
    if (self.callBack) {
        self.callBack(lastSelectKey);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(UITextField *)getMarkTextFeild {
    CGRect textFieldFrame = CGRectMake((MAIN_SCREEN_WIDTH - kTextFieldWidth) / 2, 7, kTextFieldWidth, kTextFieldHeight);
    UITextField *displayTextField = [[UITextField alloc] initWithFrame:textFieldFrame];
    displayTextField.keyboardType = UIKeyboardTypeDefault;
    displayTextField.textAlignment = NSTextAlignmentCenter;
    displayTextField.returnKeyType = UIReturnKeyDone;
    return displayTextField;
}


#pragma mark - UItextFeildDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField {
    _customMarkFeild.text = nil;
    _markTableVew.contentOffset = CGPointMake(0, 220);
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    _markTableVew.contentOffset = CGPointZero;
}

-(void)didMarkSelectedCallBack:(DidmarkSlected)callback {
    self.callBack = callback;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
