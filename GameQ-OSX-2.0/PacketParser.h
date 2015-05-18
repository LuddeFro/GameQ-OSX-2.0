//
//  PackerParser.h
//  GameQ-OSX-2.0
//
//  Created by Ludvig Fröberg on 18/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <pcap/pcap.h>

@class PacketParser;

@interface PacketParser : NSObject

@property pcap_t* handle;

static void parse_packet(u_char *user, const struct pcap_pkthdr *header, const u_char *packet);
+ (void) start_loop;
@end
