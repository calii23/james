//
//  NetworkUtils.swift
//  JamesApp
//
//  Created by Maximilian Schelbach on 07.03.20.
//  Copyright © 2020 Maximilian Schelbach. All rights reserved.
//

import Foundation
import Darwin
import SystemConfiguration.CaptiveNetwork

func getSSID() -> String? {
    guard let interfaces = CNCopySupportedInterfaces() as NSArray? else {
        return nil
    }
    
    guard interfaces.count == 1 else {
        return nil
    }
    
    guard let interfaceInfo = CNCopyCurrentNetworkInfo(interfaces[0] as! CFString) as NSDictionary? else {
        return nil
    }
    
    return interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
}

func getWifiInterface() -> String? {
    if let interfaces = CNCopySupportedInterfaces() as NSArray? {
        for interface in interfaces {
            let name = interface as! CFString
            if let _ = CNCopyCurrentNetworkInfo(name) as NSDictionary? {
                return String(name)
            }
        }
    }
    return nil
}

func getBroadcastAddress() -> in_addr_t? {
    guard let wifiInterface = getWifiInterface() else {
        print("no wifi interface found")
        return nil
    }
    
    var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
    guard getifaddrs(&ifaddr) == 0 else {
        print("getifaddrs() failed")
        return nil
    }
    
    while let ptr = ifaddr {
        let interface = ptr.pointee
        let name = String(cString: interface.ifa_name)
        if Int32(interface.ifa_flags) & IFF_UP != 0 && interface.ifa_addr.pointee.sa_family == AF_INET && name == wifiInterface {
            let addr = sockaddrToIpv4(addr: interface.ifa_addr)
            let mask = sockaddrToIpv4(addr: interface.ifa_netmask)
            let broadcast = addr | ~mask
            #if DEBUG
            print("wifi configuration: address: \(ipv4ToString(addr)), mask: \(ipv4ToString(mask)), boardcast: \(ipv4ToString(broadcast))")
            #endif
            return broadcast
        }
        ifaddr = interface.ifa_next
    }
    
    return nil
}

func broadcastUdpMessage(message: Data, port: UInt16) -> Bool {
    guard let address = getBroadcastAddress() else {
        print("could not find broadcast address")
        return false
    }
    
    let fd = socket(AF_INET, SOCK_DGRAM, 0)
    guard fd >= 0 else {
        print("could not open udp socket")
        return false
    }
    defer { close(fd) }
    
    
    var on: Int32 = 1
    guard setsockopt(fd, SOL_SOCKET, SO_BROADCAST, &on, socklen_t(MemoryLayout<Int32>.size)) == 0 else {
        print("could not set broadcast flag: \(errno)")
        return false
    }
    
    var remoteAddr = sockaddr_in()
    remoteAddr.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
    remoteAddr.sin_family = sa_family_t(AF_INET)
    remoteAddr.sin_port = htons(port)
    remoteAddr.sin_addr.s_addr = address
    let addrPointer = withUnsafePointer(to: &remoteAddr) { UnsafeRawPointer($0).bindMemory(to: sockaddr.self, capacity: 1) }
    
    guard (message.withUnsafeBytes { sendto(fd, $0, message.count, 0, addrPointer, socklen_t(MemoryLayout<sockaddr_in>.size)) }) > 0 else {
        print("failed to send udp packet: \(errno)")
        return false
    }
    
    return true
}

func htons(_ value: UInt16) -> UInt16 {
    return (value << 8) + (value >> 8)
}

func sockaddrToIpv4(addr: UnsafePointer<sockaddr>) -> in_addr_t {
    var data = addr.pointee.sa_data
    let ptr = withUnsafePointer(to: &data) { $0.withMemoryRebound(to: UInt8.self, capacity: 14) { $0 } }
    let bufferPtr = UnsafeBufferPointer(start: ptr, count: 14)
    let array = Array(bufferPtr)
    
    return in_addr_t(array[2]) | in_addr_t(array[3]) << 8 | in_addr_t(array[4]) << 16 | in_addr_t(array[5]) << 24
}

#if DEBUG
func ipv4ToString(_ addr: in_addr_t) -> String {
    return "\(addr & 0xff).\(addr >> 8 & 0xff).\(addr >> 16 & 0xff).\(addr >> 24)"
}
#endif
