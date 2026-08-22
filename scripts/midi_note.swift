#!/usr/bin/env swift
// Send a short middle-C to a CoreMIDI destination. Does not change routing.
//   swift scripts/midi_note.swift
//   swift scripts/midi_note.swift "Komplete Kontrol DAW - 1"

import CoreMIDI
import Foundation

let destName = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1] : "Komplete Kontrol DAW - 1"

enum MIDIError: Error, CustomStringConvertible {
    case status(String, OSStatus)
    case notFound(String)
    var description: String {
        switch self {
        case let .status(what, status): return "\(what) failed: OSStatus \(status)"
        case let .notFound(name): return "MIDI destination not found: \(name)"
        }
    }
}

func destinationName(_ dest: MIDIEndpointRef) -> String {
    var name: Unmanaged<CFString>?
    MIDIObjectGetStringProperty(dest, kMIDIPropertyDisplayName, &name)
    return (name?.takeRetainedValue() as String?) ?? "?"
}

func findDestination(named name: String) throws -> MIDIEndpointRef {
    for i in 0..<MIDIGetNumberOfDestinations() {
        let dest = MIDIGetDestination(i)
        if destinationName(dest) == name { return dest }
    }
    throw MIDIError.notFound(name)
}

func sendNote(to dest: MIDIEndpointRef) throws {
    var client = MIDIClientRef()
    var err = MIDIClientCreate("ixamal-midi-note" as CFString, nil, nil, &client)
    guard err == noErr else { throw MIDIError.status("MIDIClientCreate", err) }
    defer { MIDIClientDispose(client) }

    var port = MIDIPortRef()
    err = MIDIOutputPortCreate(client, "out" as CFString, &port)
    guard err == noErr else { throw MIDIError.status("MIDIOutputPortCreate", err) }
    defer { MIDIPortDispose(port) }

    var packet = MIDIPacket()
    packet.timeStamp = 0
    packet.length = 3
    packet.data.0 = 0x90
    packet.data.1 = 60
    packet.data.2 = 100

    var list = MIDIPacketList(numPackets: 1, packet: packet)
    err = MIDISend(port, dest, &list)
    guard err == noErr else { throw MIDIError.status("note on", err) }

    Thread.sleep(forTimeInterval: 0.8)

    packet.data.2 = 0
    list = MIDIPacketList(numPackets: 1, packet: packet)
    err = MIDISend(port, dest, &list)
    guard err == noErr else { throw MIDIError.status("note off", err) }
}

do {
    print("Destinations:")
    for i in 0..<MIDIGetNumberOfDestinations() {
        print("  \(destinationName(MIDIGetDestination(i)))")
    }
    let dest = try findDestination(named: destName)
    print("Sending middle C (vel 100, 0.8s) → \(destName)")
    try sendNote(to: dest)
    print("Sent")
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
