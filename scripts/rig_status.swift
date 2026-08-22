#!/usr/bin/env swift
// Print Core Audio devices, macOS defaults, and CoreMIDI ports.
// Does not change anything.
//   swift scripts/rig_status.swift

import CoreAudio
import CoreMIDI
import Foundation

enum CAError: Error, CustomStringConvertible {
    case status(String, OSStatus)
    var description: String {
        switch self {
        case let .status(what, status): return "\(what) failed: OSStatus \(status)"
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

func channelCount(_ id: AudioObjectID, scope: AudioObjectPropertyScope) -> Int {
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyStreamConfiguration,
        mScope: scope,
        mElement: kAudioObjectPropertyElementMain
    )
    var size: UInt32 = 0
    var err = AudioObjectGetPropertyDataSize(id, &address, 0, nil, &size)
    guard err == noErr else { return -1 }
    let buffer = UnsafeMutableRawPointer.allocate(byteCount: Int(size), alignment: MemoryLayout<AudioBufferList>.alignment)
    defer { buffer.deallocate() }
    err = AudioObjectGetPropertyData(id, &address, 0, nil, &size, buffer)
    guard err == noErr else { return -1 }
    let list = UnsafeMutableAudioBufferListPointer(buffer.bindMemory(to: AudioBufferList.self, capacity: 1))
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

func defaultDeviceID(selector: AudioObjectPropertySelector) -> AudioObjectID? {
    var address = AudioObjectPropertyAddress(
        mSelector: selector,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    var id = AudioObjectID(0)
    var size = UInt32(MemoryLayout<AudioObjectID>.size)
    let err = AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &address, 0, nil, &size, &id)
    return err == noErr ? id : nil
}

func midiName(_ ep: MIDIEndpointRef) -> String {
    var name: Unmanaged<CFString>?
    MIDIObjectGetStringProperty(ep, kMIDIPropertyDisplayName, &name)
    return (name?.takeRetainedValue() as String?) ?? "?"
}

let expected = [
    "Aggregate Device Maschine",
    "Aggregate Device s88 MK2",
    "BlackHole 2ch",
    "BlackHole 16ch",
    "Traktor Kontrol S8",
    "Traktor S8 + BlackHole",
    "rekordbox Aggregate Device",
    "MacBook Pro Speakers",
]

do {
    let ids = try allDeviceIDs()
    var names: [String] = []

    print("=== Core Audio defaults ===")
    let pairs: [(String, AudioObjectPropertySelector)] = [
        ("output", kAudioHardwarePropertyDefaultOutputDevice),
        ("system output", kAudioHardwarePropertyDefaultSystemOutputDevice),
        ("input", kAudioHardwarePropertyDefaultInputDevice),
    ]
    for (label, sel) in pairs {
        if let id = defaultDeviceID(selector: sel),
           let name = try? cfStringProperty(id, selector: kAudioObjectPropertyName) {
            print("  \(label): \(name)")
        } else {
            print("  \(label): ?")
        }
    }

    print("=== Core Audio devices ===")
    for id in ids {
        let name = (try? cfStringProperty(id, selector: kAudioObjectPropertyName)) ?? "?"
        let uid = (try? cfStringProperty(id, selector: kAudioDevicePropertyDeviceUID)) ?? "?"
        let inn = channelCount(id, scope: kAudioObjectPropertyScopeInput)
        let out = channelCount(id, scope: kAudioObjectPropertyScopeOutput)
        let rate = Int(nominalRate(id))
        names.append(name)
        print("  \(name)  in=\(inn) out=\(out)  \(rate) Hz  uid=\(uid)")
    }

    print("=== Expected names ===")
    for name in expected {
        print("  \(names.contains(name) ? "present" : "MISSING")  \(name)")
    }

    print("=== CoreMIDI destinations ===")
    for i in 0..<MIDIGetNumberOfDestinations() {
        print("  \(midiName(MIDIGetDestination(i)))")
    }
    print("=== CoreMIDI sources ===")
    for i in 0..<MIDIGetNumberOfSources() {
        print("  \(midiName(MIDIGetSource(i)))")
    }
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
