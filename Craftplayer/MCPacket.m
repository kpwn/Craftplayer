//
//  MCPacket.m
//  Craftplayer
//
//  Created by qwertyoruiop on 23/04/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "MCPacket.h"
#import "MCSocket.h"
#import "MCString.h"
#import "MCMetadata.h"
@implementation MCPacket
@synthesize sock,identifier,buffer;
+(MCPacket*)packetWithID:(unsigned char)idt andSocket:(MCSocket*)sock
{
    MCPacket* kret=[MCPacket new];
    [[sock inputStream] setDelegate:kret];
    [kret setIdentifier:idt];
    [kret setSock:sock];
    [kret setBuffer:[NSMutableData new]];
    NSLog(@"Packet: %02X", idt);
    return kret;
}
- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
	switch (streamEvent) {
		case NSStreamEventHasBytesAvailable:;;
            unsigned char byte;
            [(NSInputStream *)theStream read:&byte maxLength:1];
            [buffer appendBytes:&byte length:1];
            switch (identifier) {
                case 0x02:
                    if ([buffer length]>=2) {
                        const unsigned char* data=[buffer bytes];
                        short len = flipshort(*(short*)data);
                        if ([buffer length] == (len*2 + 2))
                        {
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            NSString* kdata=[MCString NSStringWithMinecraftString:(m_char_t*)data];
                            if(![[[self sock] auth] joinToServer:kdata])
                            {
                                NSLog(@"A wild error! <%@>", [[[[self sock] auth] login] objectForKey:kMCAuthResult]);
                            } else {
                                unsigned char pckid=0x01;
                                [[[self sock] outputStream] write:&pckid maxLength:1];
                                unsigned int ver=OSSwapInt32(29);
                                [[[self sock] outputStream] write:(uint8_t*)&ver maxLength:4];
                                m_char_t* __name_msg=[MCString MCStringFromString:[[sock auth] username]];
                                [[[self sock] outputStream] write:(unsigned char*)__name_msg maxLength:m_char_t_sizeof(__name_msg)];
                                char* z=malloc(13);
                                bzero(z, 13);
                                [[[self sock] outputStream] write:(unsigned char*)z maxLength:13];
                                free(__name_msg);
                                free(z);
                            }
                            [self release];
                            return;
                        }
                    }
                    break;
                case 0x01:
                    if ([buffer length]>8) {
                        const unsigned char* data=[buffer bytes];
                        short len = flipshort(*(short*)(data+6));
                        if ([buffer length] == (len*2 + 8 + 2 + 4 + 4 + 1))
                        {
                            NSLog(@"Connected!");
                            int worldtype=(OSSwapInt32((*(int*)(data+12+OSSwapInt16(*(short*)(data+6))*2))));
                            NSString* type = @"Unknown";
                            if (worldtype == -1) {
                                type = @"The Nether";
                            } else if (worldtype == 0) {
                                type = @"Overworld";
                            } else if (worldtype == 1) {
                                type = @"The End";
                            }
                            char difficulty=(*(char*)(data+16+OSSwapInt16(*(short*)(data+6))*2));
                            NSString* diff = @"Unknown";
                            switch (difficulty) {
                                case 0:
                                    diff = @"Peaceful";
                                    break;
                                case 1:
                                    diff = @"Easy";
                                    break;
                                case 2:
                                    diff = @"Normal";
                                    break;
                                case 3:
                                    diff = @"Hard";
                                    break;
                                default:
                                    break;
                            }
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"EntityID",
                                                      [MCString NSStringWithMinecraftString:(m_char_t*)(data+6)], @"WorldType",
                                                      (OSSwapInt32((*(int*)(data+8+OSSwapInt16(*(short*)(data+6))*2)))) == 0 ? @"Survival" : @"Creative", @"GameMode",
                                                      @"Login", @"PacketType",
                                                      type, @"Dimension",
                                                      diff, @"Difficulty",
                                                      [NSNumber numberWithChar:(*(char*)(data+18+OSSwapInt16(*(short*)(data+6))*2))], @"MaxPlayers",
                                                      nil];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [[self sock] packet:self gotParsed:infoDict];
                            [self release];
                            return;
                        }
                    }
                    break;
                case 0xFA:
                    if ([buffer length]>2) {
                        const unsigned char* data=[buffer bytes];
                        short len = flipshort(*(short*)data);
                        if ([buffer length] > (len*2 + 4))
                        {
                            short lenk = flipshort(*(short*)(data+(len*2 + 2)));
                            if ([buffer length] == (len*2 + 2 + lenk + 2))
                            {
                                NSString* channel = [MCString NSStringWithMinecraftString:(m_char_t*)(data)];
                                NSData* kdata = [NSData dataWithBytes:(data+2+len*2+2) length:lenk];
                                NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                          channel, @"Channel",
                                                          kdata, @"Data",
                                                          @"PluginMessage", @"PacketType",
                                                          nil];
                                [[[self sock] inputStream] setDelegate:[self sock]];
                                [[self sock] packet:self gotParsed:infoDict];
                                [self release];
                            }
                        }
                    }
                    break;
                case 0x06:
                    if ([buffer length]==12) {
                        const unsigned char* data=[buffer bytes];
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"X",
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+4)))], @"Y",
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)(data+8)))], @"Z",
                                                  @"SpawnPosition", @"PacketType",
                                                  nil];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                case 0xCA:
                    if ([buffer length] == 4) {
                        const unsigned char* data=[buffer bytes];
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithChar:*(char*)(data)], @"Invulnerability",
                                                  [NSNumber numberWithChar:*(char*)(data+1)], @"IsFlying",
                                                  [NSNumber numberWithChar:*(char*)(data+2)], @"CanFly",
                                                  [NSNumber numberWithChar:*(char*)(data+3)], @"Instabreak",
                                                  @"PlayerAbilities", @"PacketType",
                                                  nil];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                case 0x04:
                    if ([buffer length] == 8) {
                        char* time=(char*)[buffer bytes];
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithLongLong:OSSwapInt64(*(uint64_t*)(time))], @"Time",
                                                  @"TimeUpdate", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x03:
                    if ([buffer length] >= 2) {
                        const unsigned char* data=[buffer bytes];
                        short len = flipshort(*(short*)data);
                        if ([buffer length] == (len*2 + 2))
                        {
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [MCString createColorandTextPairsForMinecraftFormattedString:[MCString NSStringWithMinecraftString:(m_char_t *)data]], @"Message",
                                                      @"ChatMessage", @"PacketType",
                                                      nil];
                            [[self sock] packet:self gotParsed:infoDict];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [self release];
                            return;
                        }
                    }
                    break;
                case 0xFF:
                    if ([buffer length] >= 2) {
                        const unsigned char* data=[buffer bytes];
                        short len = flipshort(*(short*)data);
                        if ([buffer length] == (len*2 + 2))
                        {
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [MCString createColorandTextPairsForMinecraftFormattedString:[MCString NSStringWithMinecraftString:(m_char_t *)data]], @"Message",
                                                      @"Disconnect", @"PacketType",
                                                      nil];
                            [[self sock] packet:self gotParsed:infoDict];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [self release];
                            return;
                        }
                    }
                    break;
                case 0x46:
                    if ([buffer length] == 2) {
                        const unsigned char* data=[buffer bytes];
                        NSString* reason=@"Unknown";
                        switch (*data) {
                            case 0:
                                reason=@"Invalid Bed";
                                break;
                                
                            case 1:
                                reason=@"Begin Raining";
                                break;
                                
                            case 2:
                                reason=@"End Raining";
                                break;
                                
                            case 3:
                                reason=@"Change Gamemode";
                                break;
                                
                            case 4:
                                reason=@"Credits";
                                break;
                                
                            default:
                                break;
                        }
                        NSString* gm=(*data == 3) ? ((*(data+1) == 0) ? @"Survival" : @"Creative") : @"Unknown";
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  reason , @"Reason",
                                                  gm, @"GameMode",
                                                  @"ChangeState", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                case 0x05:
                    if ([buffer length] == 10) {
                        const unsigned char* data = [buffer bytes];
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"EntityID",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(int*)(data+4))], @"Slot",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(int*)(data+6))], @"ItemID",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(int*)(data+8))], @"Damage",
                                                  @"EntityEquipement", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x08:
                    if ([buffer length] == 8) {
                        const unsigned char* data = [buffer bytes];
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithShort:OSSwapInt16(*(int*)data)], @"Health",
                                                  [NSNumber numberWithFloat:OSSwapInt16(*(int*)(data+2))], @"Food",
                                                  [NSNumber numberWithFloat:OSSwapInt32(*(int*)(data+4))], @"Food Saturation",
                                                  @"HealthUpdate", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                        
                    }
                    break;
                case 0x09:
                    if ([buffer length]>10) {
                        const unsigned char* data=[buffer bytes];
                        short len = flipshort(*(short*)(data+8));
                        if ([buffer length] == (len*2+10))
                        {
                            int worldtype=OSSwapInt32(*(int*)data);
                            NSString* type = @"Unknown";
                            if (worldtype == -1) {
                                type = @"The Nether";
                            } else if (worldtype == 0) {
                                type = @"Overworld";
                            } else if (worldtype == 1) {
                                type = @"The End";
                            }
                            char difficulty=(*(char*)(data+4));
                            NSString* diff = @"Unknown";
                            switch (difficulty) {
                                case 0:
                                    diff = @"Peaceful";
                                    break;
                                case 1:
                                    diff = @"Easy";
                                    break;
                                case 2:
                                    diff = @"Normal";
                                    break;
                                case 3:
                                    diff = @"Hard";
                                    break;
                                default:
                                    break;
                            }
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      @"Respawn", @"PacketType",
                                                      type, @"Dimension",
                                                      diff, @"Difficulty",
                                                      ((*(char*)(data+5)) == 0) ? @"Survival" : @"Creative" , @"GameMode",
                                                      [NSNumber numberWithShort:OSSwapInt16(*(short*)(data+6))], @"WorldHeight",
                                                      [MCString NSStringWithMinecraftString:((m_char_t*)(data+8))], @"WorldType",
                                                      nil];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [[self sock] packet:self gotParsed:infoDict];
                            [self release];
                            return;
                        }
                    }
                    break;
                case 0x18:
                    if ([buffer length] == 20) {
                        const unsigned char* data=[buffer bytes];
                        NSString* type = @"Unknown";
                        switch ((*(char*)(data+4))) {
                            case 50:
                                type = @"Creeper";
                                break;
                            case 51:
                                type = @"Skeleton";
                                break;
                            case 52:
                                type = @"Spider";
                                break;
                            case 53:
                                type = @"Giant Zombie";
                                break;
                            case 54:
                                type = @"Zombie";
                                break;
                            case 55:
                                type = @"Slime";
                                break;
                            case 56:
                                type = @"Ghast";
                                break;
                            case 57:
                                type = @"Zombie Pigman";
                                break;
                            case 58:
                                type = @"Enderman";
                                break;
                            case 59:
                                type = @"Cave Spider";
                                break;
                            case 60:
                                type = @"Silverfish";
                                break;
                            case 61:
                                type = @"Blaze";
                                break;
                            case 62:
                                type = @"Magma Cube";
                                break;
                            case 63:
                                type = @"Ender Dragon";
                                break;
                            case 90:
                                type = @"Pig";
                                break;
                            case 91:
                                type = @"Sheep";
                                break;
                            case 92:
                                type = @"Cow";
                                break;
                            case 93:
                                type = @"Chicken";
                                break;
                            case 94:
                                type = @"Squid";
                                break;
                            case 95:
                                type = @"Wolf";
                                break;
                            case 96:
                                type = @"Mooshroom";
                                break;
                            case 97:
                                type = @"Snowman";
                                break;
                            case 98:
                                type = @"Ocelot";
                                break;
                            case 99:
                                type = @"Iron Golem";
                                break;
                            case 120:
                                type = @"Villager";
                                break;
                            default:
                                break;
                        }
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        int x = (OSSwapInt32(*(int*)(data+5 )));
                        int y = (OSSwapInt32(*(int*)(data+9 )));
                        int z = (OSSwapInt32(*(int*)(data+13)));
                        MCMetadata* metadata = [[MCMetadata metadataWithSocket:[self sock] andEntity:[MCEntity entityWithIdentifier:OSSwapInt32(*(int*)data)] andType:type] retain];
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  @"MobSpawn", @"PacketType", 
                                                  [NSNumber numberWithInt:OSSwapInt32(*(int*)data)], @"EntityID",
                                                  [NSNumber numberWithDouble:(double)x/32.0], @"X",
                                                  [NSNumber numberWithDouble:(double)y/32.0], @"Y",
                                                  [NSNumber numberWithDouble:(double)z/32.0], @"Z",
                                                  [NSNumber numberWithChar:(*((char*)(data+17)))], @"Yaw",
                                                  [NSNumber numberWithChar:(*((char*)(data+18)))], @"Pitch",
                                                  [NSNumber numberWithChar:(*((char*)(data+19)))], @"Head Yaw",
                                                  type, @"Type",
                                                  metadata, @"Metadata",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [self release];
                        return;
                    }
                    break;
                case 0x1C:
                    if ([buffer length] == 10) {
                        const unsigned char* data = [buffer bytes];
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"EntityID",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(short*)(data+4))], @"VelocityX",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(short*)(data+6))], @"VelocityY",
                                                  [NSNumber numberWithShort:OSSwapInt16(*(short*)(data+8))], @"VelocityZ",
                                                  @"EntityVelocity", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x32:
                    if ([buffer length] == 9) {
                        const unsigned char* data = [buffer bytes];
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithInt:OSSwapInt32((*(int*)data))], @"X",
                                                  [NSNumber numberWithInt:OSSwapInt32(*(int*)(data+4))], @"Z",
                                                  ((*(char*)(data+8)) == 0) ? @"DellocateColumn" : @"AllocateColumn", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0xC9:
                    if ([buffer length] >= 2) {
                        const unsigned char* data=[buffer bytes];
                        short len = flipshort(*(short*)data);
                        if ([buffer length] == (len*2 + 5))
                        {
                            NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [MCString createColorandTextPairsForMinecraftFormattedString:[MCString NSStringWithMinecraftString:(m_char_t *)data]], @"Nick",
                                                      [NSNumber numberWithShort:OSSwapInt16(*(short*)(data+3+len*2))], @"Ping",
                                                      [NSNumber numberWithBool:(*(BOOL*)(data+len*2+2))], @"IsOnline",
                                                      @"PlayerListItem", @"PacketType",
                                                      nil];
                            [[self sock] packet:self gotParsed:infoDict];
                            [[[self sock] inputStream] setDelegate:[self sock]];
                            [self release];
                            return;
                        }
                    }
                    break;
                case 0x0D:
                    if ([buffer length] == 41) {
                        const unsigned char* data = [buffer bytes];
                        NSDictionary* infoDict = [NSDictionary dictionaryWithObjectsAndKeys:
                                                  [NSNumber numberWithDouble:OSSwapInt64((*(uint64_t*)data))], @"X",
                                                  [NSNumber numberWithDouble:OSSwapInt64((*(uint64_t*)((char*)data+8)))], @"Stance",
                                                  [NSNumber numberWithDouble:OSSwapInt64((*(uint64_t*)((char*)data+16)))], @"Y",
                                                  [NSNumber numberWithDouble:OSSwapInt64((*(uint64_t*)((char*)data+24)))], @"Z",
                                                  [NSNumber numberWithFloat:OSSwapInt32((*(uint32_t*)((char*)data+32)))], @"Yaw",
                                                  [NSNumber numberWithFloat:OSSwapInt32((*(uint32_t*)((char*)data+36)))], @"Pitch",
                                                  [NSNumber numberWithBool:(*(BOOL*)(data+40))], @"On Ground",
                                                  @"PositionAndLook", @"PacketType",
                                                  nil];
                        [[self sock] packet:self gotParsed:infoDict];
                        [[[self sock] inputStream] setDelegate:[self sock]];
                        [self release];
                        return;
                    }
                    break;
                case 0x00:
                    if ([buffer length] == 4) {
                        char* retpacket=malloc(5);
                        bzero(retpacket, 5);
                        memcpy(retpacket+1, [buffer bytes], 4);
                        [[[self sock] outputStream] write:(unsigned char*)retpacket maxLength:5];
                        free(retpacket);
                    }
                    break;
                default:
                    NSLog(@"Unknown packet [%02X]", identifier);
                    [[[self sock] outputStream] close];
                    [[[self sock] inputStream] setDelegate:[self sock]];
                    [self release];
                    break;
            }
            break;
        default:
            [[self sock] stream:theStream handleEvent:streamEvent];
            break;
    }
}
- (oneway void)dealloc
{
    [self setSock:nil];
    [self setBuffer:nil];
    [super dealloc];
}
@end
