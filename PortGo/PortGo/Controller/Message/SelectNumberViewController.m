//
//  SelectNumberViewController.m
//  PortGo
//
//  Created by 今言网络 on 2017/9/22.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "SelectNumberViewController.h"
#import "ContactCell.h"
#import "AppDelegate.h"

@interface SelectNumberViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *orderedSections;
}
@property (nonatomic, strong) UITableView *selectTableview;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) NSMutableDictionary *mContacts;

@end

@implementation SelectNumberViewController

-(void)creatTableview {
    _selectTableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    
    _selectTableview.delegate = self;
    _selectTableview.dataSource = self;
    
    [self.view addSubview:_selectTableview];
}

-(void)loadData {
    NSMutableArray *allContacts = [contactView getSipFriendsAndContacts];
    
    [self allDataRangerwithArry:allContacts];
}

- (void)allDataRangerwithArry:(NSMutableArray *)arr {
    [_mContacts removeAllObjects];
    [orderedSections removeAllObjects];
    //    [sectionflagArr removeAllObjects];
    // 通讯录排序，分组
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
            [_mContacts setObject:arr forKey:[collation sectionTitles][idx]];
            
        }
    }];
    orderedSections = [NSMutableArray arrayWithArray:temp];
}

-(void)cancelAction {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIBarButtonItemStylePlain target:self action:@selector(cancelAction)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    _mContacts = [NSMutableDictionary dictionary];
    [self loadData];
    [self creatTableview];
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return orderedSections.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSString *key = orderedSections[section];
    NSArray *arr  = _mContacts[key];
    return arr.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifi = @"cellID";
    ContactCell *cell = [tableView dequeueReusableCellWithIdentifier:identifi];
    if (!cell) {
        cell = [[ContactCell alloc] init];
    }
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
