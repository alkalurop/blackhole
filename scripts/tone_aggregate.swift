#!/usr/bin/env swift
// Play a short stereo tone on outputs 1–2 of a named Core Audio device.
// Does not change macOS defaults.
//   swift scripts/tone_aggregate.swift
//   swift scripts/tone_aggregate.swift "Aggregate Device Maschine"

import AudioToolbox
import CoreAudio
import Foundation

let deviceName = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1] : "Aggregate Device Maschine"
let duration: Double = 1.5
let freq: Double = 440
let amplitude: Float32 = 0.15
let sampleRate: Float64 = 48000
let channels: UInt32 = 2
let bytesPerFrame: UInt32 = 8

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
        if (try? cfStringProperty(id, selector: kAudioObjectPropertyName)) == name { return id }
    }
    throw CAError.notFound(name)
}

func hogOwner(_ id: AudioObjectID) throws -> pid_t {
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyHogMode,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    var pid: pid_t = -1
    var size = UInt32(MemoryLayout<pid_t>.size)
    let err = AudioObjectGetPropertyData(id, &address, 0, nil, &size, &pid)
    guard err == noErr else { throw CAError.status("hog mode", err) }
    return pid
}

func fillSine(_ buffer: AudioQueueBufferRef, phase: inout Double) {
    let frames = Int(buffer.pointee.mAudioDataBytesCapacity) / Int(bytesPerFrame)
    let ptr = buffer.pointee.mAudioData.bindMemory(to: Float32.self, capacity: frames * Int(channels))
    let twoPi = 2.0 * Double.pi
    let step = twoPi * freq / sampleRate
    for i in 0..<frames {
        let s = Float32(sin(phase)) * amplitude
        ptr[i * 2] = s
        ptr[i * 2 + 1] = s
        phase += step
        if phase > twoPi { phase -= twoPi }
    }
    buffer.pointee.mAudioDataByteSize = buffer.pointee.mAudioDataBytesCapacity
}

func playTone(deviceID: AudioObjectID) throws {
    var desc = AudioStreamBasicDescription(
        mSampleRate: sampleRate,
        mFormatID: kAudioFormatLinearPCM,
        mFormatFlags: kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked,
        mBytesPerPacket: bytesPerFrame,
        mFramesPerPacket: 1,
        mBytesPerFrame: bytesPerFrame,
        mChannelsPerFrame: channels,
        mBitsPerChannel: 32,
        mReserved: 0
    )

    var queue: AudioQueueRef?
    let err = AudioQueueNewOutput(
        &desc,
        { _, queue, buffer in
            AudioQueueEnqueueBuffer(queue, buffer, 0, nil)
        },
        nil,
        nil,
        nil,
        0,
        &queue
    )
    guard err == noErr, let queue else { throw CAError.status("AudioQueueNewOutput", err) }
    defer { AudioQueueDispose(queue, true) }

    var uidCF = try cfStringProperty(deviceID, selector: kAudioDevicePropertyDeviceUID) as CFString
    let uidErr = withUnsafePointer(to: &uidCF) { ptr in
        AudioQueueSetProperty(
            queue,
            kAudioQueueProperty_CurrentDevice,
            ptr,
            UInt32(MemoryLayout<CFString>.size)
        )
    }
    guard uidErr == noErr else { throw CAError.status("set queue device", uidErr) }

    var phase = 0.0
    for _ in 0..<4 {
        var buffer: AudioQueueBufferRef?
        let berr = AudioQueueAllocateBuffer(queue, bytesPerFrame * 2048, &buffer)
        guard berr == noErr, let buffer else { throw CAError.status("alloc buffer", berr) }
        fillSine(buffer, phase: &phase)
        AudioQueueEnqueueBuffer(queue, buffer, 0, nil)
    }

    let start = AudioQueueStart(queue, nil)
    guard start == noErr else { throw CAError.status("AudioQueueStart", start) }
    Thread.sleep(forTimeInterval: duration)
    AudioQueueStop(queue, true)
}

do {
    let id = try findDevice(named: deviceName)
    let hog = (try? hogOwner(id)) ?? -1
    print("Device: \(deviceName) id=\(id) hogPid=\(hog) (-1 = not hogged / unsupported)")
    print("Playing \(Int(freq)) Hz on outs 1–2 for \(duration)s — listen on S8 master")
    try playTone(deviceID: id)
    print("Tone done")
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
