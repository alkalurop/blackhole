#!/usr/bin/env swift
// Create or destroy the public aggregate: Traktor Kontrol S8 + BlackHole 16ch.
// Clock = S8 @ 48 kHz. Drift correction on BlackHole only.
// Does not change macOS default input/output. Does not touch rekordbox Aggregate Device.
//
//   swift scripts/traktor_s8_blackhole_aggregate.swift
//   swift scripts/traktor_s8_blackhole_aggregate.swift --destroy

import CoreAudio
import Foundation

let aggregateName = "Traktor S8 + BlackHole"
let aggregateUID = "com.ixamal.traktor-s8-blackhole"
let sampleRate: Float64 = 48000
let s8Name = "Traktor Kontrol S8"
let blackHoleName = "BlackHole 16ch"
let protectedNames: Set<String> = ["rekordbox Aggregate Device"]

enum CAError: Error, CustomStringConvertible {
    case status(String, OSStatus)
    case notFound(String)
    var description: String {
        switch self {
        case let .status(what, status): return "\(what) failed: OSStatus \(status)"
        case let .notFound(name): return "Audio device not found: \(name)"
        }
    }
}

func cfStringProperty(_ id: AudioObjectID, selector: AudioObjectPropertySelector) throws -> String {
    var address = AudioObjectPropertyAddress(
        mSelector: selector,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    var cf: CFString = "" as CFString
    var size = UInt32(MemoryLayout<CFString>.size)
    let err = withUnsafeMutablePointer(to: &cf) { ptr in
        AudioObjectGetPropertyData(id, &address, 0, nil, &size, ptr)
    }
    guard err == noErr else { throw CAError.status("get \(selector)", err) }
    return cf as String
}

func deviceName(_ id: AudioObjectID) throws -> String {
    try cfStringProperty(id, selector: kAudioObjectPropertyName)
}

func deviceUID(_ id: AudioObjectID) throws -> String {
    try cfStringProperty(id, selector: kAudioDevicePropertyDeviceUID)
}

func channelCount(_ id: AudioObjectID, scope: AudioObjectPropertyScope) throws -> Int {
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyStreamConfiguration,
        mScope: scope,
        mElement: kAudioObjectPropertyElementMain
    )
    var size: UInt32 = 0
    var err = AudioObjectGetPropertyDataSize(id, &address, 0, nil, &size)
    guard err == noErr else { throw CAError.status("stream config size", err) }
    let buffer = UnsafeMutableRawPointer.allocate(byteCount: Int(size), alignment: MemoryLayout<AudioBufferList>.alignment)
    defer { buffer.deallocate() }
    err = AudioObjectGetPropertyData(id, &address, 0, nil, &size, buffer)
    guard err == noErr else { throw CAError.status("stream config", err) }
    let list = UnsafeMutableAudioBufferListPointer(
        buffer.bindMemory(to: AudioBufferList.self, capacity: 1)
    )
    return list.reduce(0) { $0 + Int($1.mNumberChannels) }
}

func allDeviceIDs() throws -> [AudioObjectID] {
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDevices,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    var size: UInt32 = 0
    var err = AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size)
    guard err == noErr else { throw CAError.status("device list size", err) }
    let count = Int(size) / MemoryLayout<AudioObjectID>.size
    var ids = [AudioObjectID](repeating: 0, count: count)
    err = ids.withUnsafeMutableBufferPointer { buf in
        AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, buf.baseAddress!)
    }
    guard err == noErr else { throw CAError.status("device list", err) }
    return ids
}

func findDevice(named name: String) throws -> AudioObjectID {
    for id in try allDeviceIDs() {
        if (try? deviceName(id)) == name { return id }
    }
    throw CAError.notFound(name)
}

func defaultDeviceID(selector: AudioObjectPropertySelector) throws -> AudioObjectID {
    var address = AudioObjectPropertyAddress(
        mSelector: selector,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    var id = AudioObjectID(0)
    var size = UInt32(MemoryLayout<AudioObjectID>.size)
    let err = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &id)
    guard err == noErr else { throw CAError.status("default device", err) }
    return id
}

func setNominalRate(_ id: AudioObjectID, rate: Float64) throws {
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyNominalSampleRate,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    var value = rate
    let err = AudioObjectSetPropertyData(
        id, &address, 0, nil, UInt32(MemoryLayout<Float64>.size), &value
    )
    guard err == noErr else { throw CAError.status("set sample rate", err) }
}

func printDevice(_ id: AudioObjectID) {
    let name = (try? deviceName(id)) ?? "?"
    let uid = (try? deviceUID(id)) ?? "?"
    let inn = (try? channelCount(id, scope: kAudioObjectPropertyScopeInput)) ?? -1
    let out = (try? channelCount(id, scope: kAudioObjectPropertyScopeOutput)) ?? -1
    print("  \(name)  in=\(inn) out=\(out)  uid=\(uid)")
}

func snapshotDefaults() throws {
    let out = try defaultDeviceID(selector: kAudioHardwarePropertyDefaultOutputDevice)
    let sys = try defaultDeviceID(selector: kAudioHardwarePropertyDefaultSystemOutputDevice)
    let inn = try defaultDeviceID(selector: kAudioHardwarePropertyDefaultInputDevice)
    print("Defaults (must stay put):")
    print("  output:        \((try? deviceName(out)) ?? "?")")
    print("  system output: \((try? deviceName(sys)) ?? "?")")
    print("  input:         \((try? deviceName(inn)) ?? "?")")
}

func createAggregate() throws {
    if let existing = try? findDevice(named: aggregateName) {
        print("Already exists:")
        printDevice(existing)
        try snapshotDefaults()
        return
    }

    let s8 = try findDevice(named: s8Name)
    let blackHole = try findDevice(named: blackHoleName)
    let s8UID = try deviceUID(s8)
    let bhUID = try deviceUID(blackHole)

    print("Subdevices (S8 first = mixer stays on outputs 1–4):")
    printDevice(s8)
    printDevice(blackHole)

    try setNominalRate(s8, rate: sampleRate)
    try setNominalRate(blackHole, rate: sampleRate)

    let description: [String: Any] = [
        kAudioAggregateDeviceNameKey: aggregateName,
        kAudioAggregateDeviceUIDKey: aggregateUID,
        kAudioAggregateDeviceMainSubDeviceKey: s8UID,
        kAudioAggregateDeviceClockDeviceKey: s8UID,
        kAudioAggregateDeviceIsPrivateKey: 0,
        kAudioAggregateDeviceIsStackedKey: 0,
        kAudioAggregateDeviceSubDeviceListKey: [
            [
                kAudioSubDeviceUIDKey: s8UID,
                kAudioSubDeviceDriftCompensationKey: 0,
            ],
            [
                kAudioSubDeviceUIDKey: bhUID,
                kAudioSubDeviceDriftCompensationKey: 1,
                kAudioSubDeviceDriftCompensationQualityKey: kAudioSubDeviceDriftCompensationMaxQuality,
            ],
        ],
    ]

    var aggID = AudioObjectID(0)
    let err = AudioHardwareCreateAggregateDevice(description as CFDictionary, &aggID)
    guard err == noErr, aggID != 0 else { throw CAError.status("AudioHardwareCreateAggregateDevice", err) }

    try setNominalRate(aggID, rate: sampleRate)

    print("Created:")
    printDevice(aggID)
    try snapshotDefaults()

    let inn = try channelCount(aggID, scope: kAudioObjectPropertyScopeInput)
    let out = try channelCount(aggID, scope: kAudioObjectPropertyScopeOutput)
    if inn != 26 || out != 20 {
        fputs("Warning: expected 26 in / 20 out (S8 10/4 + BlackHole 16/16), got \(inn)/\(out)\n", stderr)
    }
}

func destroyAggregate() throws {
    let id = try findDevice(named: aggregateName)
    let name = try deviceName(id)
    if protectedNames.contains(name) {
        fputs("Refusing to destroy protected device: \(name)\n", stderr)
        exit(2)
    }
    print("Destroying:")
    printDevice(id)
    let err = AudioHardwareDestroyAggregateDevice(id)
    guard err == noErr else { throw CAError.status("AudioHardwareDestroyAggregateDevice", err) }
    print("Destroyed \(aggregateName).")
    try snapshotDefaults()
}

do {
    let destroy = CommandLine.arguments.contains("--destroy")
    if destroy {
        try destroyAggregate()
    } else {
        try createAggregate()
    }
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
