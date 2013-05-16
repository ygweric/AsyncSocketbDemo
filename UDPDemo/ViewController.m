//
//  ViewController.m
//  UDPDemo
//
//  Created by Eric Yang on 13-5-10.
//  Copyright (c) 2013年 Eric Yang. All rights reserved.
//

#import "ViewController.h"
#import "LocalSocketClient.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sendUdpMsg:(id)sender {
    
//    [self performSelectorOnMainThread:@selector(sendYunhoUDPSearch) withObject:nil waitUntilDone:NO];
    [self sendYunhoUDPSearch];
}
-(void)sendYunhoUDPSearch{
    //255.255.255.255 is broadcast
    [[LocalSocketClient share] sendToUDPServer:@"<mtalk id=\"1231231231\" xmlns=\"urn:xmpp:mtalk:1\"><search/></mtalk>" address:@"255.255.255.255" port:9001];
//    [[LocalSocketClient share] sendToUDPServer:@"hello" address:@"255.255.255.255" port:9001];
}
@end
