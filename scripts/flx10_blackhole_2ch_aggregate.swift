#!/usr/bin/env swift
// Create or destroy the Rekordbox-only aggregate: DDJ-FLX10 + BlackHole 2ch.
// Clock = FLX10 @ 44.1 kHz. Drift correction on BlackHole 2ch only.
// Does not change macOS default I/O.
// Does not touch: rekordbox Aggregate Device, Traktor S8 + BlackHole,
// Aggregate Device Maschine, Aggregate Device s88 MK2, BlackHole 16ch.
//
//   swift scripts/flx10_blackhole_2ch_aggregate.swift
//   swift scripts/flx10_blackhole_2ch_aggregate.swift --destroy

import CoreAudio
import Foundation

let aggregateName = "FLX10 + BlackHole 2ch"
let aggregateUID = "com.ixamal.flx10-blackhole-2ch"
let sampleRate: Float64 = 44100
let flxName = "DDJ-FLX10"
let blackHoleName = "BlackHole 2ch"
let protectedNames: Set<String> = [
    "rekordbox Aggregate Device",
    "Traktor S8 + BlackHole",
    "Aggregate Device Maschine",
    "Aggregate Device s88 MK2",
]

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

func nominalRate(_ id: AudioObjectID) -> Float64 {
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyNominalSampleRate,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    var rate: Float64 = 0
    var size = UInt32(MemoryLayout<Float64>.size)
    let err = AudioObjectGetPropertyData(id, &address, 0, nil, &size, &rate)
    return err == noErr ? rate : 0
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
    print("  \(name)  in=\(inn) out=\(out)  \(Int(nominalRate(id))) Hz  uid=\(uid)")
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

func assertUntouched() throws {
    let sixteen = try findDevice(named: "BlackHole 16ch")
    let rate = nominalRate(sixteen)
    if abs(rate - 48000) > 1 {
        fputs("ABORT: BlackHole 16ch is \(Int(rate)) Hz (want 48000). 11a would break.\n", stderr)
        exit(3)
    }
    let traktor = try findDevice(named: "Traktor S8 + BlackHole")
    let inn = try channelCount(traktor, scope: kAudioObjectPropertyScopeInput)
    let out = try channelCount(traktor, scope: kAudioObjectPropertyScopeOutput)
    if inn != 26 || out != 20 {
        fputs("ABORT: Traktor S8 + BlackHole is \(inn)/\(out) (want 26/20).\n", stderr)
        exit(3)
    }
    print("11a untouched:")
    printDevice(sixteen)
    printDevice(traktor)
}

func createAggregate() throws {
    try assertUntouched()
    if let existing = try? findDevice(named: aggregateName) {
        print("Already exists:")
        printDevice(existing)
        try snapshotDefaults()
        return
    }

    let flx = try findDevice(named: flxName)
    let blackHole = try findDevice(named: blackHoleName)
    let flxUID = try deviceUID(flx)
    let bhUID = try deviceUID(blackHole)

    print("Subdevices (FLX10 first = mixer stays on outputs 1–4):")
    printDevice(flx)
    printDevice(blackHole)

    try setNominalRate(flx, rate: sampleRate)
    try setNominalRate(blackHole, rate: sampleRate)

    let description: [String: Any] = [
        kAudioAggregateDeviceNameKey: aggregateName,
        kAudioAggregateDeviceUIDKey: aggregateUID,
        kAudioAggregateDeviceMainSubDeviceKey: flxUID,
        kAudioAggregateDeviceClockDeviceKey: flxUID,
        kAudioAggregateDeviceIsPrivateKey: 0,
        kAudioAggregateDeviceIsStackedKey: 0,
        kAudioAggregateDeviceSubDeviceListKey: [
            [
                kAudioSubDeviceUIDKey: flxUID,
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
    try assertUntouched()

    let inn = try channelCount(aggID, scope: kAudioObjectPropertyScopeInput)
    let out = try channelCount(aggID, scope: kAudioObjectPropertyScopeOutput)
    if inn != 12 || out != 6 {
        fputs("Warning: expected 12 in / 6 out (FLX10 10/4 + BlackHole 2/2), got \(inn)/\(out)\n", stderr)
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
    try assertUntouched()
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
