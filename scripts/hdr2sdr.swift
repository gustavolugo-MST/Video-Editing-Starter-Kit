// iPhone HDR (HLG / Dolby Vision) -> SDR Rec.709 using Apple's own tone mapping (AVFoundation), keeping the frame rate.
// Our ffmpeg build has no zscale/libplacebo, so this is the correct way to bring iPhone HDR into the FFmpeg pipeline.
// Usage: swift hdr2sdr.swift IN.mov OUT.mov [FPS] [START_SEC DURATION_SEC]     (FPS default 60; 0 = keep source)
// Output: H.264 High (AVAssetExportPresetHighestQuality), bt709, with audio.
import AVFoundation
import Foundation

let args = CommandLine.arguments
guard args.count >= 3 else { print("usage: hdr2sdr.swift IN OUT [FPS] [START DUR]"); exit(1) }
let src = URL(fileURLWithPath: args[1]), dst = URL(fileURLWithPath: args[2])
let fps = args.count > 3 ? Int32(args[3]) ?? 60 : 60
try? FileManager.default.removeItem(at: dst)

let asset = AVURLAsset(url: src)
let sem = DispatchSemaphore(value: 0)
Task {
    do {
        let comp = try await AVMutableVideoComposition.videoComposition(withPropertiesOf: asset)
        if fps > 0 { comp.frameDuration = CMTime(value: 1, timescale: fps) }
        comp.colorPrimaries = AVVideoColorPrimaries_ITU_R_709_2
        comp.colorTransferFunction = AVVideoTransferFunction_ITU_R_709_2
        comp.colorYCbCrMatrix = AVVideoYCbCrMatrix_ITU_R_709_2
        guard let ex = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { print("no export session"); exit(1) }
        ex.videoComposition = comp
        if args.count > 5, let s = Double(args[4]), let d = Double(args[5]) {
            ex.timeRange = CMTimeRange(start: CMTime(seconds: s, preferredTimescale: 600), duration: CMTime(seconds: d, preferredTimescale: 600))
        }
        try await ex.export(to: dst, as: .mov)
        print("ok \(dst.lastPathComponent)")
    } catch { print("error: \(error)"); exit(1) }
    sem.signal()
}
sem.wait()
