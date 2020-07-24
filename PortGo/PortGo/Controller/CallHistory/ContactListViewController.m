//
//  ContactListViewController.m
//  PortGo
//
//  Created by 今言网络 on 2017/8/24.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "ContactListViewController.h"
#import "AppDelegate.h"
#import "Contact.h"
#import "UIColor_Hex.h"
#import "AddorEditViewController.h"

@interface ContactListViewController () <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *orderedSections;
    NSMutableDictionary *contacts;
    BOOL isContactSave;
}

@property (nonatomic, strong)  UITableView *tableView;

@end

@implementation ContactListViewController

-(void)loadData {
    NSMutableArray *arr = [NSMutableArray arrayWithArray:[contactView contacts]] ;
    
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [newSectionsArray addObject:array];
    }
    
    for (Contact* contact in arr) {
        NSString *dispalyName = contact.displayName;
        if (dispalyName) {
            NSInteger sectionNumber = [collation sectionForObject:dispalyName collationStringSelector:@selector(self)];
            NSMutableArray *sectionNames = newSectionsArray[sectionNumber];
            [sectionNames addObject:contact];
        }
        
    }
    
    NSMutableArray *temp = [NSMutableArray array];
    [newSectionsArray enumerateObjectsUsingBlock:^(NSArray *arr, NSUInteger idx, BOOL *stop) {
        if (arr.count == 0) {
            
        } else {
            [temp addObject:[collation sectionTitles][idx]];
            [contacts setObject:arr forKey:[collation sectionTitles][idx]];
        }
    }];
    orderedSections = [NSMutableArray arrayWithArray:temp];
    
}

-(void)cancelAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (isContactSave) {
        isContactSave = !isContactSave;
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    self.navigationItem.rightBarButtonItem = right;
    self.navigationController.navigationBar.tintColor = MAIN_COLOR;
    
    self.title = NSLocalizedString(@"Select Contact", @"Select Contact");
    
    contacts = [NSMutableDictionary dictionary];
    [self loadData];
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [self.view addSubview:_tableView];
    
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.bounds.size.width, 30.0)];
    sectionView.backgroundColor = [UIColor colorWithRed:244.0/255 green:244.0/255 blue:244.0/255 alpha:1];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 30)];
    titleLabel.textColor = [UIColor grayColor];
    titleLabel.font = [UIFont systemFontOfSize:16];
    
    titleLabel.text = orderedSections[section];
    [sectionView addSubview:titleLabel];
    
    sectionView.tag = 100 + section;
    
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 29.5, self.tableView.bounds.size.width, 0.5)];
    line.backgroundColor = [UIColor colorWithHexString:@"#e4e4e4"];
    [sectionView addSubview:line];
    
    return sectionView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return orderedSections.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = orderedSections[section];
    NSArray *value = [contacts objectForKey:key];
    return value.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identi = @"cellID";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identi];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi];
    }
    
    NSString *key = orderedSections[indexPath.section];
    NSArray *value = [contacts objectForKey:key];
    Contact *contact = value[indexPath.row];
    
    
    
    cell.textLabel.text = contact.displayName;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    NSString *key = orderedSections[indexPath.section];
    NSArray *value = [contacts objectForKey:key];
    Contact *contac = value[indexPath.row];
    
    if ([self.remoteParty containsString:@"@"]) {
        NSDictionary *dic = [NSDictionary dictionaryWithObject:self.remoteParty forKey:NSLocalizedString(@"VoIP Call", @"VoIP Call")];
        [contac.IPCallNumbers addObject:dic];
    } else {
        [contac.phoneNumbers addObject:self.remoteParty];
    }
    
    AddorEditViewController *addOrEdit = [[AddorEditViewController alloc] init];
    addOrEdit.modalPresentationStyle = UIModalPresentationFullScreen;
    addOrEdit.recognizeID = 2777;
    
    addOrEdit.aContact = contac;
    
    [addOrEdit didEditHistoryToContactCallback:^{
        isContactSave = YES;
    }];
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:addOrEdit];
    nav.modalPresentationStyle = UIModalPresentationFullScreen;
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
