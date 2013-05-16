//
//  LocalSocketUtil.h
//  Yunho2
//
//  Created by l on 12-11-9.
//
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "AsyncUdpSocket.h"
//#import "XmlParseUtil.h"


// for "AF_INET"
#include <sys/socket.h>
//for ifaddrs
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <netdb.h>



#include <string.h>


/*
 单例
 有两个功能
 1、udp broadcas 获取路由地址&端口
 2、长连接tcp socket，进行mtalk通信
 
 */
//@class xml


@interface LocalSocketClient : NSObject<AsyncSocketDelegate,AsyncUdpSocketDelegate>
@property (retain,nonatomic) NSString* yunhoAddress;
@property int yunhoPort;

@property (retain,nonatomic)  AsyncSocket *socket;



@property (retain,nonatomic)     NSString* mIP;
@property int mPort;
@property BOOL isConnected;




+(LocalSocketClient*)share;
- (void) connectToHost;
- (void) connectToHost:(NSString*)host port:(int)port ;
- (void) disconnectTcp ;
-(void)sendSearchBroadcast;
-(void)sendToUDPServer:(NSString*) msg address:(NSString*)address port:(int)port;
- (void)sendMtalkMessage:(NSString*)mtalk_xml ;

@end
