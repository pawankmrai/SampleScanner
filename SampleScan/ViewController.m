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
    
     UIActionSheet *actionSheet=[[UIActionSheet alloc] initWithTitle:@"Select Type" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera",@"Photo Album", nil];
    
    [actionSheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{

    NSString *title=[actionSheet buttonTitleAtIndex:buttonIndex];
    if ([title isEqualToString:@"Camera"]) {
        
        // Make ourselves an overlay controller and tell the SDK about it.
        OverlayController *overlayController = [[OverlayController alloc] initWithNibName:@"OverlayController" bundle:nil];
        [pickerController setOverlay:overlayController];
        [overlayController release];
        
        // hide the status bar and show the scanner view
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        [self presentModalViewController:pickerController animated:FALSE];

    }
    else{
    
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        
        imagePicker.delegate = self;
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        imagePicker.allowsEditing = YES;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
        
    }
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    // Code here to work with media
    UIImage *image=info[UIImagePickerControllerOriginalImage];
    FindBarcodesInUIImage(image);
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)barcodePickerController:(BarcodePickerController *)picker returnResults:(NSSet *)results{
    
    [picker dismissModalViewControllerAnimated:YES];
    
    NSLog(@"result---%@", results);
       
    NSSet  *tempSet=[results valueForKey:@"barcodeString"] ;
    
    for (NSString *tempString in tempSet) {
        
        self.barCode=tempString;
        
    }
//    NSLog(@"barcode string--%@",[results valueForKey:@"barcodeString"]);
//    NSLog(@"extended barcode--%@",[results valueForKey:@"extendedBarcodeString"]);
//    NSLog(@"barcode int value--%@",[results valueForKey:@"barcodeType"]);
//    NSLog(@"associated barcode---%@",[results valueForKey:@"associatedBarcode"]);
//     NSLog(@"first scan barcode---%@",[results valueForKey:@"firstScanTime"]);
//     NSLog(@"most recent barcode---%@",[results valueForKey:@"mostRecentScanTime"]); 
//
//    self.barCode=[results valueForKey:@"barcodeString"];
   // NSLog(@"bar code---%@",self.barCode);
    
   [self loadDetailForBarCode:self.barCode];
    
}
-(void)loadDetailForBarCode:(NSString *)finalBarcode{
    
    NSLog(@"barcode---%@",finalBarcode);
   // NSString *miloString=[NSString stringWithFormat:@"https://api.x.com/milo/v3/products?key=%@&postal_code=94301&show_defaults=false&show=614141999996",miloApiKey];
    
    NSString *tempString=[NSString stringWithFormat:@"https://api.x.com/milo/v3/products?key=%@&q=EAN:%@",miloApiKey,finalBarcode];
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
   // NSLog(@"json---%@",json);
    
    NSArray* latestLoans = [json allValues]; //2
    
   // NSLog(@"loans: %@", latestLoans); //3
    [_detailTextView setText:[latestLoans description]];
    
    NSArray *tempArray=[latestLoans objectAtIndex:1];
    //NSLog(@"tempDict---%@", tempArray);
     
    
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
