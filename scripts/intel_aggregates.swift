#!/usr/bin/env swift
// Create or destroy the Intel-known-good public aggregates:
//   Aggregate Device Maschine  = S8 + BlackHole 2ch + Mac speakers
//   Aggregate Device s88 MK2   = S8 + BlackHole 2ch
// Clock = S8 @ 48 kHz. Drift on BlackHole 2ch and speakers.
// Does not change macOS default input/output. Does not touch rekordbox Aggregate Device
// or last night's Traktor S8 + BlackHole (16ch) device.
//
//   swift scripts/intel_aggregates.swift
//   swift scripts/intel_aggregates.swift --destroy

import CoreAudio
import Foundation

let sampleRate: Float64 = 48000
let s8Name = "Traktor Kontrol S8"
let blackHoleName = "BlackHole 2ch"
let speakerCandidates = ["MacBook Pro Speakers", "MacBook Speakers", "Built-in Output"]
let protectedNames: Set<String> = [
    "rekordbox Aggregate Device",
    "Traktor S8 + BlackHole",
]

struct Spec {
    let name: String
    let uid: String
    let includeSpeakers: Bool
    let expectedIn: Int
    let expectedOut: Int
}

let specs: [Spec] = [
    Spec(
        name: "Aggregate Device Maschine",
        uid: "com.ixamal.aggregate-maschine",
        includeSpeakers: true,
        expectedIn: 12,
        expectedOut: 8
    ),
    Spec(
        name: "Aggregate Device s88 MK2",
        uid: "com.ixamal.aggregate-s88-mk2",
        includeSpeakers: false,
        expectedIn: 12,
        expectedOut: 6
    ),
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

func findSpeaker() throws -> AudioObjectID {
    for name in speakerCandidates {
        if let id = try? findDevice(named: name) { return id }
    }
    throw CAError.notFound("Mac speakers (\(speakerCandidates.joined(separator: " / ")))")
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

func subdeviceEntry(uid: String, drift: Bool) -> [String: Any] {
    var entry: [String: Any] = [
        kAudioSubDeviceUIDKey: uid,
        kAudioSubDeviceDriftCompensationKey: drift ? 1 : 0,
    ]
    if drift {
        entry[kAudioSubDeviceDriftCompensationQualityKey] = kAudioSubDeviceDriftCompensationMaxQuality
    }
    return entry
}

func createOne(_ spec: Spec, s8UID: String, bhUID: String, speakerUID: String?) throws {
    if let existing = try? findDevice(named: spec.name) {
        print("Already exists:")
        printDevice(existing)
        return
    }

    var subdevices: [[String: Any]] = [
        subdeviceEntry(uid: s8UID, drift: false),
        subdeviceEntry(uid: bhUID, drift: true),
    ]
    if spec.includeSpeakers, let speakerUID {
        subdevices.append(subdeviceEntry(uid: speakerUID, drift: true))
    }

    let description: [String: Any] = [
        kAudioAggregateDeviceNameKey: spec.name,
        kAudioAggregateDeviceUIDKey: spec.uid,
        kAudioAggregateDeviceMainSubDeviceKey: s8UID,
        kAudioAggregateDeviceClockDeviceKey: s8UID,
        kAudioAggregateDeviceIsPrivateKey: 0,
        kAudioAggregateDeviceIsStackedKey: 0,
        kAudioAggregateDeviceSubDeviceListKey: subdevices,
    ]

    var aggID = AudioObjectID(0)
    let err = AudioHardwareCreateAggregateDevice(description as CFDictionary, &aggID)
    guard err == noErr, aggID != 0 else { throw CAError.status("AudioHardwareCreateAggregateDevice \(spec.name)", err) }

    try setNominalRate(aggID, rate: sampleRate)

    print("Created:")
    printDevice(aggID)

    let inn = try channelCount(aggID, scope: kAudioObjectPropertyScopeInput)
    let out = try channelCount(aggID, scope: kAudioObjectPropertyScopeOutput)
    if inn != spec.expectedIn || out != spec.expectedOut {
        fputs(
            "Warning: expected \(spec.expectedIn) in / \(spec.expectedOut) out for \(spec.name), got \(inn)/\(out)\n",
            stderr
        )
    }
}

func createAggregates() throws {
    let s8 = try findDevice(named: s8Name)
    let blackHole = try findDevice(named: blackHoleName)
    let speakers: AudioObjectID? = specNeedsSpeakers() ? try findSpeaker() : nil

    let s8UID = try deviceUID(s8)
    let bhUID = try deviceUID(blackHole)
    let speakerUID: String? = try speakers.map { try deviceUID($0) }

    print("Subdevices (S8 first = mixer stays on outputs 1–4):")
    printDevice(s8)
    printDevice(blackHole)
    if let speakers { printDevice(speakers) }

    try setNominalRate(s8, rate: sampleRate)
    try setNominalRate(blackHole, rate: sampleRate)
    if let speakers { try? setNominalRate(speakers, rate: sampleRate) }

    for spec in specs {
        try createOne(spec, s8UID: s8UID, bhUID: bhUID, speakerUID: speakerUID)
    }
    try snapshotDefaults()
}

func specNeedsSpeakers() -> Bool {
    specs.contains { $0.includeSpeakers && (try? findDevice(named: $0.name)) == nil }
}

func destroyAggregates() throws {
    for spec in specs.reversed() {
        guard let id = try? findDevice(named: spec.name) else {
            print("Not present: \(spec.name)")
            continue
        }
        let name = try deviceName(id)
        if protectedNames.contains(name) {
            fputs("Refusing to destroy protected device: \(name)\n", stderr)
            exit(2)
        }
        print("Destroying:")
        printDevice(id)
        let err = AudioHardwareDestroyAggregateDevice(id)
        guard err == noErr else { throw CAError.status("AudioHardwareDestroyAggregateDevice \(spec.name)", err) }
        print("Destroyed \(spec.name).")
    }
    try snapshotDefaults()
}

do {
    let destroy = CommandLine.arguments.contains("--destroy")
    if destroy {
        try destroyAggregates()
    } else {
        try createAggregates()
    }
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
