//
//  bridge.m
//  Rocket.Chat.iOS
//
//  Created by Michael Arthur on 7/6/14.
//  Copyright (c) 2014 . All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "MeteorClient.h"
//#import "ObjectiveDDP.h"
#import <ObjectiveDDP/MeteorClient.h>
#import <ObjectiveDDP/ObjectiveDDP.h>


MeteorClient* initialiseMeteor(NSString* version, NSString* endpoint) {
    MeteorClient *meteorClient = [[MeteorClient alloc] initWithDDPVersion:version];
    ObjectiveDDP *ddp = [[ObjectiveDDP alloc] initWithURLString:endpoint delegate:meteorClient];
    meteorClient.ddp = ddp;
    [meteorClient.ddp connectWebSocket];
    return meteorClient;
}