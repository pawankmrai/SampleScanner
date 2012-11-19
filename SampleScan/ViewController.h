//
//  ViewController.h
//  SampleScan
//
//  Created by Sandeep Nasa on 11/17/12.
//  Copyright (c) 2012 Pawan Rai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RedLaserSDK.h"
#import "ScanDataClass.h"

#define miloApiKey @"162b8719799c2e19cae18d4511334920"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //1

@interface ViewController : UIViewController<BarcodePickerControllerDelegate, UITableViewDataSource, UITableViewDelegate>
{

    BarcodePickerController *pickerController;
    NSString *barCodeDetail;
    ScanDataClass *dataClass;
}
@property (retain, nonatomic) IBOutlet UITextView *detailTextView;

@property (retain, nonatomic) IBOutlet UITableView *mytableview;
@property(retain , nonatomic) NSMutableArray *dataArray;

@end
