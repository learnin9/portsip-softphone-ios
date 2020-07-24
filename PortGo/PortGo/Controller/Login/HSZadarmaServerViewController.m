//
//  HSZadarmaServerViewController.m
//  PortGo
//
//  Created by MrLee on 14/10/30.
//  Copyright (c) 2014年 PortSIP Solutions, Inc. All rights reserved.
//

#import "HSZadarmaServerViewController.h"
#define cellID @"cellID"
@interface HSZadarmaServerViewController ()
{
    NSMutableArray *_mServerArray;
}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *returnButton;
@property (weak, nonatomic) IBOutlet UITableView *contentTableView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@end

@implementation HSZadarmaServerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [_topView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"tabbar_background.png"]]];
    
    self.titleLabel.text = NSLocalizedString(@"SIP Servers", @"SIP Servers");
    _mServerArray = [[NSMutableArray alloc] init];
    
    NSDictionary* sipServer = [[NSDictionary alloc] initWithObjectsAndKeys:@"sip.zadarma.com", @"serverName", @"sip.ios.zadarma.com", @"SIPServerIP", @"5065", @"SIPServerPort", nil];
    
    [_mServerArray addObject:sipServer];
    NSDictionary* pbxServer = [[NSDictionary alloc] initWithObjectsAndKeys:@"pbx.zadarma.com", @"serverName", @"pbx.ios.zadarma.com", @"SIPServerIP", @"5065", @"SIPServerPort", nil];
    [_mServerArray addObject:pbxServer];
    [_contentTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
}

- (IBAction)returnButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _mServerArray.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    NSDictionary * cellServer = [_mServerArray objectAtIndex:indexPath.row];
    cell.textLabel.text = cellServer[@"serverName"];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self.delegate didSelectSIPServer:[_mServerArray objectAtIndex:indexPath.row]];
    [_returnButton sendActionsForControlEvents:UIControlEventTouchUpInside];
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
