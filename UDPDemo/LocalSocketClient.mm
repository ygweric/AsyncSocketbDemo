//
//  LocalSocketUtil.m
//  Yunho2
//
//  Created by l on 12-11-9.
//
//

#import "LocalSocketClient.h"

#define MTALK_SEARTH @"<mtalk id=\"%@\" xmlns=\"urn:xmpp:mtalk:1\"><search/></mtalk>"
#define MTALK_STANDARD_HEADER @"<mtalk id=\"%@\" xmlns=\"urn:xmpp:mtalk:1\">"
#define SOCKET_TIMEOUT -1 //当timeout，socket会断开
#define BCPORT 9001


@implementation LocalSocketClient{
@private

    
    
}
@synthesize isConnected;
@synthesize yunhoAddress;
@synthesize yunhoPort;

@synthesize socket;


@synthesize mIP;
@synthesize mPort;


static LocalSocketClient* localSocketClient;

+(LocalSocketClient*)share{
    if (localSocketClient==nil) {
        localSocketClient =[[LocalSocketClient alloc] init];
    }
    return localSocketClient;
}

-(id)init{
    if (self=[super init]) {
      
        
    }
    return self;
}

#pragma mark udp
-(void)sendSearchBroadcast{
    NSString* bchost=@"255.255.255.255";
    [self sendToUDPServer:[NSString stringWithFormat:MTALK_SEARTH,@"1231-12312-4214-234"] address:bchost port:BCPORT];
}
-(void)sendToUDPServer:(NSString*) msg address:(NSString*)address port:(int)port{
    AsyncUdpSocket *udpSocket=[[[AsyncUdpSocket alloc]initWithDelegate:self]autorelease];
    NSLog(@"---address:%@,port:%d,msg:%@",address,port,msg);
    //receiveWithTimeout is necessary or you won't receive anything
    [udpSocket receiveWithTimeout:10 tag:2]; //
    [udpSocket enableBroadcast:YES error:nil];
    NSData *data=[msg dataUsingEncoding:NSUTF8StringEncoding];
    [udpSocket sendData:data toHost:address port:port withTimeout:10 tag:1];
}
-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
    NSString* rData= [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]
                      autorelease];
    NSLog(@"onUdpSocket:didReceiveData:---%@",rData);


    return YES;
}
-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"didNotSendDataWithTag----");

    
}
-(void)onUdpSocket:(AsyncUdpSocket *)sock didNotReceiveDataWithTag:(long)tag dueToError:(NSError *)error{
    NSLog(@"didNotReceiveDataWithTag----");

}
-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"didSendDataWithTag----");

}
-(void)onUdpSocketDidClose:(AsyncUdpSocket *)sock{
    NSLog(@"onUdpSocketDidClose----");
}


- (void) connectToHost{
    
    [self connectToHost:mIP port:mPort];
    
    
}

#pragma mark tcp
- (void) connectToHost:(NSString*)host port:(int)port {
    socket = [[AsyncSocket alloc] initWithDelegate:self];

    [socket disconnect];

    NSLog(@"tcp connecting to host:%@,port:%d",host,port);
    @try {
        [socket connectToHost:host onPort:port error:nil];
        [socket readDataWithTimeout:SOCKET_TIMEOUT tag:1];

    }
    @catch (NSException *exception) {
        NSLog(@"connect exception %@,%@", [exception name], [exception description]);

    }
}
- (void) disconnectTcp {
    if ([socket isConnected]) {
        [socket disconnect];
    }
}
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port{
    NSLog(@"did connect to host %@:%d", host, port);
    isConnected=YES;
    [NSThread detachNewThreadSelector:@selector(keepActivityST) toTarget:self withObject:nil];
    
}

-(void)keepActivityST{
    while (isConnected) {
        [NSThread sleepForTimeInterval:1];
        [self performSelectorOnMainThread:@selector(sendMessage:) withObject:@"" waitUntilDone:NO];
    }
}

-(void)onSocketDidDisconnect:(AsyncSocket *)sock{
    isConnected=NO;
    NSLog(@"onSocketDidDisconnect sock:%@",sock);

    
}

- (void)sendMtalkMessage:(NSString*)mtalk_xml {

    [self sendMessage:mtalk_xml];
}
- (void)sendMessage:(NSString*)msg {
    NSLog(@"tcp send msg:%@",  msg);
    [socket readDataWithTimeout:SOCKET_TIMEOUT tag:1];
    [socket writeData:[msg dataUsingEncoding:NSUTF8StringEncoding] withTimeout:SOCKET_TIMEOUT tag:1];
}
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSString* message = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]autorelease];
    NSLog(@"onSocket:didReadData msg:%@ ",message);
   }
-(NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
    NSLog(@"onSocket:shouldTimeout-ReadWithTag:-----------");
    return 0;
}
-(NSTimeInterval)onSocket:(AsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
    NSLog(@"onSocket:shouldTimeout-WriteWithTag:-----------");
    return 0;
}

-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"didWriteDataWithTag tag:%ld",tag);
}

#pragma mark other utils function


@end
