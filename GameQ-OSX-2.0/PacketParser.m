//
//  PacketParser.m
//  GameQ-OSX-2.0
//
//  Created by Ludvig Fröberg on 18/05/15.
//  Copyright (c) 2015 GameQ AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameQ_OSX_2_0-Swift.h"
#import "PacketParser.h"
#import <netinet/ip.h>
#import <netinet/udp.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <net/ethernet.h>






@implementation PacketParser : NSObject;
@synthesize handle;
/* ethernet headers are always exactly 14 bytes [1] */
#define SIZE_ETHERNET 14
struct sniff_ip {
    u_char  ip_vhl;                 /* version << 4 | header length >> 2 */
    u_char  ip_tos;                 /* type of service */
    u_short ip_len;                 /* total length */
    u_short ip_id;                  /* identification */
    u_short ip_off;                 /* fragment offset field */
#define IP_RF 0x8000            /* reserved fragment flag */
#define IP_DF 0x4000            /* dont fragment flag */
#define IP_MF 0x2000            /* more fragments flag */
#define IP_OFFMASK 0x1fff       /* mask for fragmenting bits */
    u_char  ip_ttl;                 /* time to live */
    u_char  ip_p;                   /* protocol */
    u_short ip_sum;                 /* checksum */
    struct  in_addr *ip_src,*ip_dst;  /* source and dest address */
};
#define IP_HL(ip)               (((ip)->ip_vhl) & 0x0f)
#define IP_V(ip)                (((ip)->ip_vhl) >> 4)

/* TCP header */
typedef u_int tcp_seq;

struct sniff_tcp {
    u_short th_sport;               /* source port */
    u_short th_dport;               /* destination port */
    tcp_seq th_seq;                 /* sequence number */
    tcp_seq th_ack;                 /* acknowledgement number */
    u_char  th_offx2;               /* data offset, rsvd */
#define TH_OFF(th)      (((th)->th_offx2 & 0xf0) >> 4)
    u_char  th_flags;
#define TH_FIN  0x01
#define TH_SYN  0x02
#define TH_RST  0x04
#define TH_PUSH 0x08
#define TH_ACK  0x10
#define TH_URG  0x20
#define TH_ECE  0x40
#define TH_CWR  0x80
#define TH_FLAGS        (TH_FIN|TH_SYN|TH_RST|TH_ACK|TH_URG|TH_ECE|TH_CWR)
    u_short th_win;                 /* window */
    u_short th_sum;                 /* checksum */
    u_short th_urp;                 /* urgent pointer */
};


struct sniff_udp {
    u_short uh_sport;               /* source port */
    u_short uh_dport;               /* destination port */
    u_short uh_ulen;                /* udp length */
    u_short uh_sum;                 /* udp checksum */
    
};

#define SIZE_UDP        8               /* length of UDP header */
// total udp header length: 8 bytes (=64 bits)



void parse_packet(u_char *user, const struct pcap_pkthdr *header, const u_char *packet)
{
    NSLog(@"got packet");
    static int count = 1;                   /* packet counter */
    
    /* declare pointers to packet headers */
    //  const struct sniff_ethernet *ethernet;  /* The ethernet header [1] */
    const struct sniff_ip *ip;              /* The IP header */
    const struct sniff_tcp *tcp;            /* The TCP header */
    const struct sniff_udp *udp;
    
    int size_ip;
    int size_tcp;
    int size_udp;
    
    printf("\nPacket number %d:\n", count);
    count++;
    
    /* define ethernet header */
    //	ethernet = (struct sniff_ethernet*)(packet);
    
    /* define/compute ip header offset */
    ip = (struct sniff_ip*)(packet + SIZE_ETHERNET);
    size_ip = IP_HL(ip)*4;
    if (size_ip < 20) {
        printf("   * Invalid IP header length: %u bytes\n", size_ip);
        return;
    }
    
    /* print source and destination IP addresses */
    //	printf("       From: %s\n", inet_ntoa(ip->ip_src));
    //	printf("         To: %s\n", inet_ntoa(ip->ip_dst));
    
    /* determine protocol */
    switch(ip->ip_p) {
        case IPPROTO_TCP:
            printf("   Protocol: TCP\n");
            tcp = (struct sniff_tcp*)(packet + SIZE_ETHERNET + size_ip);
            size_tcp = TH_OFF(tcp)*4;
            if (size_tcp < 20) {
                printf("   * Invalid TCP header length: %u bytes\n", size_tcp);
                return;
            }
            printf("Header length: %u bytes\n", size_tcp);
            printf("   Src port: %d\n", ntohs(tcp->th_sport));
            printf("   Dst port: %d\n", ntohs(tcp->th_dport));
            break;
        case IPPROTO_UDP:
            printf("   Protocol: UDP\n");
            udp = (struct sniff_udp*)(packet + SIZE_ETHERNET + size_ip);
            size_udp = ntohs(udp->uh_ulen);
            if (size_udp < 8) {
                printf("   * Invalid UDP header length: %u bytes\n", size_udp);
            }
            printf("Header length: %u bytes\n", size_udp);
            printf("ip_len: %d", ntohs(ip->ip_len));
            printf("   Src port: %d\n", ntohs(udp->uh_sport));
            printf("   Dst port: %d\n", ntohs(udp->uh_dport));
            int dport = ntohs(udp->uh_dport);
            int sport = ntohs(udp->uh_sport);
            
            return;
        case IPPROTO_ICMP:
            printf("   Protocol: ICMP\n");
            return;
        case IPPROTO_IP:
            printf("   Protocol: IP\n");
            return;
        default:
            printf("   Protocol: unknown\n");
            return;
    }
   
    
    
    return;
    
    
    
}

+ (void) start_loop
{
    struct bpf_program fp;
    bpf_u_int32 net;
    char errbuf[PCAP_ERRBUF_SIZE];
    u_char user;
    char filter[] = "udp";
    pcap_t *handle = pcap_create("en0", errbuf);
    pcap_set_buffer_size(handle, 1);
    pcap_activate(handle);

    
    
    
    /* Compile a filter */
    if (pcap_compile(handle, &fp, filter, 0, net) == -1){
        printf("Coudldn't compile filter");
        return;
    }
    /* Apply a filter */
    if (pcap_setfilter(handle, &fp) == -1){
        printf("Coudldn't apply filter");
        return;
    }
    
    
    NSLog(@"calling pcap_loop");
    pcap_loop(handle, -1, parse_packet, &user);
    NSLog(@"called pcap_loop");

}




    
    

    

@end
    
    
    
    
    
    
    
