//
//  PremiumFeaturesController.m
//  PortGo
//
//  Created by 今言网络 on 2017/12/5.
//  Copyright © 2017年 PortSIP Solutions, Inc. All rights reserved.
//

#import "PremiumFeaturesController.h"

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>
#import "MBProgressHUD.h"
#import "AppDelegate.h"



static const NSString *productCoin999 =@"20171205999";

@interface PremiumFeaturesController ()<SKPaymentTransactionObserver,SKProductsRequestDelegate>

@end

@implementation PremiumFeaturesController


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        
    }
    
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"Premium Features", @"Premium Features");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc]initWithStyle:0 reuseIdentifier:@"PremiumFeatures"];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section==0) {
        
        
        cell.textLabel.text =@"H.264,AMR-WB codec";
        
        cell.textLabel.font = [UIFont systemFontOfSize:13];
        
        UIButton * button = [[UIButton alloc]init];
        
        BOOL productID999 = [[NSUserDefaults standardUserDefaults]boolForKey:@"productID999"];
        
        if (productID999) {
            button.backgroundColor =[UIColor grayColor];
            
            button.userInteractionEnabled = NO;
            
        }
        else
        {
            button.backgroundColor = RGB(158, 191, 55);
            button.userInteractionEnabled = YES;
            
        }
        
        
        button .frame = CGRectMake(ScreenWid-70, 7, 60, 30);
        
        [button addTarget:self action:@selector(PremiumFeatures) forControlEvents:UIControlEventTouchUpInside];
        
        
        UILabel * lab = [[UILabel alloc]init];
        
        lab.textColor =[UIColor whiteColor];
        
        lab.backgroundColor = [UIColor clearColor];
        
        
        lab.textAlignment =NSTextAlignmentCenter;
        
        lab.frame = CGRectMake(ScreenWid-70, 7, 60, 30);
        
        lab.font = [UIFont systemFontOfSize:12];
        
        lab.text =@"$9.99";
        
        
        
        [cell addSubview:button];
        
        [cell addSubview:lab];
        
        
    }
    else if (indexPath.section==1){
        
        cell.textLabel.text =NSLocalizedString(@"Sync Premium Features", @"Sync Premium Features");
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        cell.textLabel.textColor = RGB(226, 135, 0);
        
        
    }
    
    
    
    
    
    
    
    return cell;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{  
    
    
    return nil;
    
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    
    if (section==0) {
        
        return  NSLocalizedString(@"Premium Features Introduction1", @"Premium Features Introduction1");
    }
    
    else if (section==1){
        
        return  NSLocalizedString(@"Premium Features Introduction2", @"Premium Features Introduction2");
    }
    
    
    return nil;
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.section==1) {
        [self buy];
    }
}





#pragma mark - 9.99内购

-(void)PremiumFeatures{
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    if([SKPaymentQueue canMakePayments]) {
        
        [self requestProductData];
        
    }else{
    }
}


- (void)requestProductData{
    NSArray *product = @[productCoin999];
    
    NSSet *nsset = [NSSet setWithArray:product];
    
    SKProductsRequest *request = [[SKProductsRequest alloc]initWithProductIdentifiers:nsset];
    
    request.delegate =self;
    
    [request start];
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
}

#pragma mark - SKProductsRequestDelegate
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    
    NSArray *myProduct = response.products;
    
    // populate UI
    
    for(SKProduct *product in myProduct){
        
        [MBProgressHUD hideHUDForView:self.view animated:YES];
        
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
};

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error{
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)requestDidFinish:(SKRequest *)request{
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transaction{
    
    for(SKPaymentTransaction *tran in transaction){
        
        switch(tran.transactionState) {
                
            case SKPaymentTransactionStatePurchased :
                
                
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                
                [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"productID999"];
                
                [self verifyTransactionResult];
                
                [self.tableView reloadData];
                
                break;
                
                
                
            case SKPaymentTransactionStatePurchasing:
                
                break;
                
            case SKPaymentTransactionStateRestored:
                break;
                
            case SKPaymentTransactionStateFailed:
                [[SKPaymentQueue defaultQueue] finishTransaction:tran];
                
                break;
            default:
                
                break;
                
        }
        
    }
    
}



- (void)verifyTransactionResult{
    
}


- (void)dealloc{
    
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    
}



-(void)buy{
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
    
}


- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSMutableArray *  purchasedItemIDs = [[NSMutableArray alloc] init];
    
    for (SKPaymentTransaction *transaction in queue.transactions)
    {
        NSString *productID = transaction.payment.productIdentifier;
        
        [purchasedItemIDs addObject:productID];
        
    }
    
    
    BOOL productID999 = NO;
    
    for (NSString *productID in  purchasedItemIDs ) {
        
        if ([productID isEqualToString:@"20171205999"]) {
            
            productID999 = YES;
            
            [[NSUserDefaults standardUserDefaults]setBool:productID999 forKey:@"productID999"];
            
            [self.tableView reloadData];
        }
        
    }
    
    
    
}

@end
