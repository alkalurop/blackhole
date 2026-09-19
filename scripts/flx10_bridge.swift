#!/usr/bin/env swift
// Read BlackHole 2ch, resample to 48 kHz, write BlackHole 16ch channels 5–6 only.
// Does not change macOS defaults. Does not set BlackHole 16ch sample rate.
// Does not touch Traktor S8 + BlackHole.
//
//   swift scripts/flx10_bridge.swift
// Ctrl-C to stop.

import AudioToolbox
import CoreAudio
import Foundation

let inputName = "BlackHole 2ch"
let outputName = "BlackHole 16ch"
let requiredOutRate: Float64 = 48000
let outChannelOffset = 4 // 0-based → device channels 5–6
let ringFrames = 16384

enum CAError: Error, CustomStringConvertible {
    case status(String, OSStatus)
    case notFound(String)
    case refused(String)
    var description: String {
        switch self {
        case let .status(what, status): return "\(what) failed: OSStatus \(status)"
        case let .notFound(name): return "Audio device not found: \(name)"
        case let .refused(why): return why
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

func nominalRate(_ id: AudioObjectID) throws -> Float64 {
    var address = AudioObjectPropertyAddress(
        mSelector: kAudioDevicePropertyNominalSampleRate,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMain
    )
    var rate: Float64 = 0
    var size = UInt32(MemoryLayout<Float64>.size)
    let err = AudioObjectGetPropertyData(id, &address, 0, nil, &size, &rate)
    guard err == noErr else { throw CAError.status("sample rate", err) }
    return rate
}

func floatStereoASBD(_ rate: Float64) -> AudioStreamBasicDescription {
    AudioStreamBasicDescription(
        mSampleRate: rate,
        mFormatID: kAudioFormatLinearPCM,
        mFormatFlags: kAudioFormatFlagIsFloat | kAudioFormatFlagIsPacked,
        mBytesPerPacket: 8,
        mFramesPerPacket: 1,
        mBytesPerFrame: 8,
        mChannelsPerFrame: 2,
        mBitsPerChannel: 32,
        mReserved: 0
    )
}

final class Ring {
    private let samples: UnsafeMutablePointer<Float32>
    private let capacity: Int
    private var write = 0
    private var read = 0
    private let lock = NSLock()

    init(frames: Int) {
        capacity = frames * 2
        samples = .allocate(capacity: capacity)
        samples.initialize(repeating: 0, count: capacity)
    }

    deinit {
        samples.deinitialize(count: capacity)
        samples.deallocate()
    }

    func push(_ src: UnsafePointer<Float32>, count: Int) {
        lock.lock()
        defer { lock.unlock() }
        for i in 0..<count {
            samples[write] = src[i]
            write = (write + 1) % capacity
            if write == read {
                read = (read + 1) % capacity
            }
        }
    }

    func pop(_ dst: UnsafeMutablePointer<Float32>, count: Int) -> Int {
        lock.lock()
        defer { lock.unlock() }
        var n = 0
        while n < count {
            let avail = write >= read ? write - read : capacity - read + write
            if avail == 0 { break }
            dst[n] = samples[read]
            read = (read + 1) % capacity
            n += 1
        }
        return n
    }
}

final class Bridge {
    let ring = Ring(frames: ringFrames)
    var converter: AudioConverterRef?
    var inUnit: AudioUnit?
    var outUnit: AudioUnit?
    var inASBD = floatStereoASBD(44100)
    var outASBD = floatStereoASBD(requiredOutRate)
    var convertScratch = UnsafeMutablePointer<Float32>.allocate(capacity: 8192)
    var convertScratchCount = 8192
}

let bridge = Bridge()

func findHAL() throws -> AudioComponent {
    var desc = AudioComponentDescription(
        componentType: kAudioUnitType_Output,
        componentSubType: kAudioUnitSubType_HALOutput,
        componentManufacturer: kAudioUnitManufacturer_Apple,
        componentFlags: 0,
        componentFlagsMask: 0
    )
    guard let comp = AudioComponentFindNext(nil, &desc) else {
        throw CAError.refused("HAL output component missing")
    }
    return comp
}

func setEnableIO(_ unit: AudioUnit, scope: AudioUnitScope, bus: UInt32, on: UInt32) throws {
    var value = on
    let err = AudioUnitSetProperty(
        unit,
        kAudioOutputUnitProperty_EnableIO,
        scope,
        bus,
        &value,
        UInt32(MemoryLayout<UInt32>.size)
    )
    guard err == noErr else { throw CAError.status("EnableIO \(bus)", err) }
}

func setDevice(_ unit: AudioUnit, id: AudioObjectID) throws {
    var dev = id
    let err = AudioUnitSetProperty(
        unit,
        kAudioOutputUnitProperty_CurrentDevice,
        kAudioUnitScope_Global,
        0,
        &dev,
        UInt32(MemoryLayout<AudioObjectID>.size)
    )
    guard err == noErr else { throw CAError.status("CurrentDevice", err) }
}

func inputCallback(
    inRefCon: UnsafeMutableRawPointer,
    ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
    inTimeStamp: UnsafePointer<AudioTimeStamp>,
    inBusNumber: UInt32,
    inNumberFrames: UInt32,
    ioData: UnsafeMutablePointer<AudioBufferList>?
) -> OSStatus {
    guard let unit = bridge.inUnit else { return noErr }
    var buffer = AudioBuffer(
        mNumberChannels: 2,
        mDataByteSize: inNumberFrames * 8,
        mData: malloc(Int(inNumberFrames) * 8)
    )
    defer { free(buffer.mData) }
    var list = AudioBufferList(mNumberBuffers: 1, mBuffers: buffer)
    let err = AudioUnitRender(unit, ioActionFlags, inTimeStamp, inBusNumber, inNumberFrames, &list)
    guard err == noErr, let data = list.mBuffers.mData else { return err }
    let floats = data.assumingMemoryBound(to: Float32.self)
    bridge.ring.push(floats, count: Int(inNumberFrames) * 2)
    return noErr
}

func converterInput(
    inAudioConverter: AudioConverterRef,
    ioNumberDataPackets: UnsafeMutablePointer<UInt32>,
    ioData: UnsafeMutablePointer<AudioBufferList>,
    outDataPacketDescription: UnsafeMutablePointer<UnsafeMutablePointer<AudioStreamPacketDescription>?>?,
    inUserData: UnsafeMutableRawPointer?
) -> OSStatus {
    let wantFrames = Int(ioNumberDataPackets.pointee)
    let samples = wantFrames * 2
    if samples > bridge.convertScratchCount {
        bridge.convertScratch.deallocate()
        bridge.convertScratch = .allocate(capacity: samples)
        bridge.convertScratchCount = samples
    }
    let floats = bridge.convertScratch
    let got = bridge.ring.pop(floats, count: samples)
    if got < samples {
        for i in got..<samples { floats[i] = 0 }
    }
    ioData.pointee.mNumberBuffers = 1
    ioData.pointee.mBuffers.mNumberChannels = 2
    ioData.pointee.mBuffers.mData = UnsafeMutableRawPointer(floats)
    ioData.pointee.mBuffers.mDataByteSize = UInt32(samples * 4)
    ioNumberDataPackets.pointee = UInt32(wantFrames)
    return noErr
}

func outputCallback(
    inRefCon: UnsafeMutableRawPointer,
    ioActionFlags: UnsafeMutablePointer<AudioUnitRenderActionFlags>,
    inTimeStamp: UnsafePointer<AudioTimeStamp>,
    inBusNumber: UInt32,
    inNumberFrames: UInt32,
    ioData: UnsafeMutablePointer<AudioBufferList>?
) -> OSStatus {
    guard let ioData, let converter = bridge.converter else { return noErr }
    var packets = inNumberFrames
    let err = AudioConverterFillComplexBuffer(
        converter,
        converterInput,
        nil,
        &packets,
        ioData,
        nil
    )
    return err
}

func makeUnit() throws -> AudioUnit {
    var unit: AudioUnit?
    let err = AudioComponentInstanceNew(try findHAL(), &unit)
    guard err == noErr, let unit else { throw CAError.status("AudioComponentInstanceNew", err) }
    return unit
}

func start() throws {
    let inID = try findDevice(named: inputName)
    let outID = try findDevice(named: outputName)
    let outRate = try nominalRate(outID)
    if abs(outRate - requiredOutRate) > 1 {
        throw CAError.refused(
            "ABORT: \(outputName) is \(Int(outRate)) Hz (want 48000). Refusing so 11a stays put."
        )
    }
    _ = try findDevice(named: "Traktor S8 + BlackHole")

    let inRate = try nominalRate(inID)
    bridge.inASBD = floatStereoASBD(inRate)
    bridge.outASBD = floatStereoASBD(requiredOutRate)

    print("FLX10 bridge")
    print("  in  \(inputName) @ \(Int(inRate)) Hz (2ch)")
    print("  out \(outputName) @ \(Int(outRate)) Hz channels 5–6 only")
    print("  11a pairs 1–4 not written")
    print("Ctrl-C to stop")

    let inUnit = try makeUnit()
    let outUnit = try makeUnit()
    bridge.inUnit = inUnit
    bridge.outUnit = outUnit

    try setEnableIO(inUnit, scope: kAudioUnitScope_Input, bus: 1, on: 1)
    try setEnableIO(inUnit, scope: kAudioUnitScope_Output, bus: 0, on: 0)
    try setDevice(inUnit, id: inID)
    var inFmt = bridge.inASBD
    var err = AudioUnitSetProperty(
        inUnit,
        kAudioUnitProperty_StreamFormat,
        kAudioUnitScope_Output,
        1,
        &inFmt,
        UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
    )
    guard err == noErr else { throw CAError.status("input StreamFormat", err) }

    var inCB = AURenderCallbackStruct(inputProc: inputCallback, inputProcRefCon: nil)
    err = AudioUnitSetProperty(
        inUnit,
        kAudioOutputUnitProperty_SetInputCallback,
        kAudioUnitScope_Global,
        0,
        &inCB,
        UInt32(MemoryLayout<AURenderCallbackStruct>.size)
    )
    guard err == noErr else { throw CAError.status("input callback", err) }

    try setEnableIO(outUnit, scope: kAudioUnitScope_Input, bus: 1, on: 0)
    try setEnableIO(outUnit, scope: kAudioUnitScope_Output, bus: 0, on: 1)
    try setDevice(outUnit, id: outID)
    var outFmt = bridge.outASBD
    err = AudioUnitSetProperty(
        outUnit,
        kAudioUnitProperty_StreamFormat,
        kAudioUnitScope_Input,
        0,
        &outFmt,
        UInt32(MemoryLayout<AudioStreamBasicDescription>.size)
    )
    guard err == noErr else { throw CAError.status("output StreamFormat", err) }

    var map = [Int32](repeating: -1, count: 16)
    map[outChannelOffset] = 0
    map[outChannelOffset + 1] = 1
    err = AudioUnitSetProperty(
        outUnit,
        kAudioOutputUnitProperty_ChannelMap,
        kAudioUnitScope_Output,
        0,
        &map,
        UInt32(MemoryLayout<Int32>.size * map.count)
    )
    guard err == noErr else { throw CAError.status("channel map", err) }

    var outCB = AURenderCallbackStruct(inputProc: outputCallback, inputProcRefCon: nil)
    err = AudioUnitSetProperty(
        outUnit,
        kAudioUnitProperty_SetRenderCallback,
        kAudioUnitScope_Input,
        0,
        &outCB,
        UInt32(MemoryLayout<AURenderCallbackStruct>.size)
    )
    guard err == noErr else { throw CAError.status("output callback", err) }

    var conv: AudioConverterRef?
    var src = bridge.inASBD
    var dst = bridge.outASBD
    err = AudioConverterNew(&src, &dst, &conv)
    guard err == noErr, let conv else { throw CAError.status("AudioConverterNew", err) }
    bridge.converter = conv

    err = AudioUnitInitialize(inUnit)
    guard err == noErr else { throw CAError.status("init input", err) }
    err = AudioUnitInitialize(outUnit)
    guard err == noErr else { throw CAError.status("init output", err) }
    err = AudioOutputUnitStart(inUnit)
    guard err == noErr else { throw CAError.status("start input", err) }
    err = AudioOutputUnitStart(outUnit)
    guard err == noErr else { throw CAError.status("start output", err) }
}

do {
    setbuf(stdout, nil)
    try start()
    fflush(stdout)
    signal(SIGINT) { _ in
        if let unit = bridge.inUnit { AudioOutputUnitStop(unit) }
        if let unit = bridge.outUnit { AudioOutputUnitStop(unit) }
        exit(0)
    }
    dispatchMain()
} catch {
    fputs("\(error)\n", stderr)
    exit(1)
}
