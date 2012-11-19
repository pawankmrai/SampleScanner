//
//  ViewController.m
//  SampleScan
//
//  Created by Sandeep Nasa on 11/17/12.
//  Copyright (c) 2012 Pawan Rai. All rights reserved.
//

#import "ViewController.h"
#import "OverlayController.h"
#import "DetailViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize detailTextView=_detailTextView;
@synthesize dataArray;
@synthesize mytableview;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    // We create the BarcodePickerController here so that we can call prepareToScan before
    // the user actually requests a scan.
    pickerController = [[BarcodePickerController alloc] init];
    [pickerController setDelegate:self];
    
    dataArray=[[NSMutableArray alloc] init];
}
- (IBAction)loadScanner:(id)sender {
    
    // Make ourselves an overlay controller and tell the SDK about it.
	OverlayController *overlayController = [[OverlayController alloc] initWithNibName:@"OverlayController" bundle:nil];
	[pickerController setOverlay:overlayController];
	[overlayController release];
	
	// hide the status bar and show the scanner view
	[[UIApplication sharedApplication] setStatusBarHidden:YES];
	[self presentModalViewController:pickerController animated:FALSE];
}
-(void)barcodePickerController:(BarcodePickerController *)picker returnResults:(NSSet *)results{
    
    [picker dismissModalViewControllerAnimated:YES];
    
//    tempSet=[[NSSet alloc] initWithSet:results copyItems:YES];
//    NSLog(@"tesmp---%@",tempSet);
   
//    NSString  *tempString=[tempSet valueForKey:@"barcodeString"] ;
//    if ([tempString isKindOfClass:[NSString class]]) {
//        
//        NSLog(@"good string");
//    }
//    else
//        NSLog(@"bad string");
//    
//        NSLog(@"array---%@",tempString);
    
   barCodeDetail=@"upc614141999996";
   [self loadDetailForBarCode:barCodeDetail];
    
}
-(void)loadDetailForBarCode:(NSString *)barcode{
    
    //NSLog(@"barcode---%@",[[barcode description] retain]);
    
    NSString *tempString=[NSString stringWithFormat:@"https://api.x.com/milo/v3/products?key=%@&q=%@",miloApiKey,barcode];
    NSURL *url=[NSURL URLWithString:tempString];
    
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL:url];
        
        [self performSelectorOnMainThread:@selector(fetchedData:)
                               withObject:data waitUntilDone:YES];
    });

}
- (void)fetchedData:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData //1
                          
                          options:kNilOptions
                          error:&error];
    
    NSArray* latestLoans = [json allValues]; //2
    
   // NSLog(@"loans: %@", latestLoans); //3
    [_detailTextView setText:[latestLoans description]];
    
    NSArray *tempArray=[latestLoans objectAtIndex:1];
    NSLog(@"tempDict---%@", tempArray);
     
    
    for (NSDictionary *tempDict in tempArray) {
        
        ScanDataClass *dataOBJ=[ScanDataClass new];
       
        NSString *name=[tempDict objectForKey:@"name"];
        dataOBJ.name=name;
        
        NSLog(@"oproduct name----%@", name);
        
        NSString *tempID=[tempDict objectForKey:@"product_id"];
        dataOBJ.productID=tempID;
     
        [dataArray addObject:dataOBJ];
    }
    
    [self designtable];
    
}
-(void)viewWillAppear:(BOOL)animated{

    [self.mytableview reloadData];

}
-(void)designtable{

    
    [mytableview setDelegate:self];
    [mytableview setDataSource:self];

}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    
    return [dataArray count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    dataClass=(ScanDataClass *)[dataArray objectAtIndex:indexPath.row];
    cell.textLabel.text=dataClass.name;
    
    return cell;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_detailTextView release];
    [mytableview release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setDetailTextView:nil];
    [self setMytableview:nil];
    [super viewDidUnload];
}
@end
