import Foundation
import UIKit

/// FFI C bridge for image processing.
/// Exposes C-linkage functions callable from Dart via dart:ffi.

@_cdecl("process_icon")
func processIcon(
    _ inputData: UnsafePointer<UInt8>,
    _ inputLength: Int32,
    _ outputData: UnsafeMutablePointer<UnsafeMutablePointer<UInt8>?>,
    _ outputLength: UnsafeMutablePointer<Int32>
) -> Int32 {
    // Initialize output to safe defaults
    outputData.pointee = nil
    outputLength.pointee = 0

    // Build Data from input pointer
    let data = Data(bytes: inputData, count: Int(inputLength))

    // Decode to UIImage
    guard let uiImage = UIImage(data: data) else {
        return 1 // UIImage decode failure
    }

    // Call MetalImageProcessor
    guard let processedImage = MetalImageProcessor.shared.processSync(uiImage, thickness: 4) else {
        return 2 // Metal processing failure
    }

    // Encode result as PNG
    guard let pngData = processedImage.pngData() else {
        return 3 // PNG encoding failure
    }

    // Allocate output buffer and copy data
    let count = pngData.count
    guard let buffer = malloc(count)?.assumingMemoryBound(to: UInt8.self) else {
        return 3
    }
    pngData.copyBytes(to: buffer, count: count)

    outputData.pointee = buffer
    outputLength.pointee = Int32(count)

    return 0 // Success
}

/// Frees memory allocated by process_icon for the output buffer.
/// Called from Dart via dart:ffi to release native-side allocated memory.
@_cdecl("free_processed_data")
func freeProcessedData(_ pointer: UnsafeMutablePointer<UInt8>?) {
    guard let pointer = pointer else { return }
    free(pointer)
}
