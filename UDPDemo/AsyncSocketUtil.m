//
//  SocketUtil.m
//  ASyncSocketDemo
//
//  Created by l on 12-10-31.
//  Copyright (c) 2012年 l. All rights reserved.
//

#import "AsyncSocketUtil.h"

#define SOCKET_TIMEOUT -1


//static NSString* getewayIp;
//static NSString* getewayPort;

@implementation AsyncSocketUtil
@synthesize socket, response,timer;

static id _socketUtil = nil;

// single
+(id)shared
{
    if (nil == _socketUtil) {
        _socketUtil = [[AsyncSocketUtil alloc] init];
    }
    return _socketUtil;
}

-(id)init
{
    //Instance variable used while 'self' is not set to the result of '[(super or self) init...]'
    socket = [[AsyncSocket alloc] initWithDelegate:self];
    return self;
}

-(void)setSocketDelegate:(id)delegate
{
    [socket setDelegate:delegate];
}


-(void)connectToHost:(NSString*)host port:(int)port
{
    @try {
        [socket connectToHost:host onPort:port error:nil];
    }
    @catch (NSException *exception) {
        NSLog(@"connect exception %@,%@", [exception name], [exception description]);
    }
    
}

-(void)sendData:(NSString *)data
{
    NSLog(@"socket send start %f, data %@", [[NSDate date] timeIntervalSince1970], data);
    [socket readDataWithTimeout:SOCKET_TIMEOUT tag:1];
    [socket writeData:[data dataUsingEncoding:NSUTF8StringEncoding] withTimeout:SOCKET_TIMEOUT tag:1];
}

-(void)setSocketUtilDelegate:(id<SocketUtilDelegate>)delegate
{
    self.response=delegate;
}

-(void)dealloc
{
    [super dealloc];
    NSLog(@"SocketUtil dealloc");
    if (socket) {
        [socket disconnect];
        NSLog(@"socket disconnected");
    }
}

- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"did connect to host %@:%d", host, port);
    if (response) {
        [response onSocket:sock didConnectToHost:host port:port];
    }
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease] ;
    NSLog(@"receive ReadData is: %@",message);
    NSLog(@"socket end %f", [[NSDate date] timeIntervalSince1970]);
    
    if (response) {
        [response onSocket:sock didReadData:message];
    }
}

-(BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
    NSLog(@"socket will connect");
    if (response) {
        [response onSocketWillConnect:sock];
    }
    return YES;
}

-(void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"socket will disconnect, %@", [err localizedDescription]);
    if (response) {
        [response onSocket:sock willDisconnectWithError:err];
    }
}

-(void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"socket did disconnect");
    if (response) {
        [response onSocketDidDisconnect:sock];
    }
}
-(void)startHeartBeatTimer{
    timer = [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(init) userInfo:nil repeats:YES];
}
-(void)stopHeartBeatTimer{
    [timer invalidate];
}

@end
