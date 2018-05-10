import UIKit

public struct Pixel {
    public var value: UInt32
    
    //red
    public var R: UInt8 {
        get { return UInt8(value & 0xFF); }
        set { value = UInt32(newValue) | (value & 0xFFFFFF00) }
    }
    
    //green
    public var G: UInt8 {
        get { return UInt8((value >> 8) & 0xFF) }
        set { value = (UInt32(newValue) << 8) | (value & 0xFFFF00FF) }
    }
    
    //blue
    public var B: UInt8 {
        get { return UInt8((value >> 16) & 0xFF) }
        set { value = (UInt32(newValue) << 16) | (value & 0xFF00FFFF) }
    }
    
    //alpha
    public var A: UInt8 {
        get { return UInt8((value >> 24) & 0xFF) }
        set { value = (UInt32(newValue) << 24) | (value & 0x00FFFFFF) }
    }    
}

public struct RGBAImage {
    public var pixels: UnsafeMutableBufferPointer<Pixel>
    public var width: Int
    public var height: Int
    
    public init?(image: UIImage) {
        // CGImage로 변환이 가능해야 한다.
        guard let cgImage = image.cgImage else {
            return nil
        }
        
        // 주소 계산을 위해서 Float을 Int로 저장한다.
        width = Int(image.size.width)
        height = Int(image.size.height)
        
//        let bitsPerComponent = 8 // 픽셀의 한 요소당 1바이트
//        let bytesPerPixels = 4 // RGBA 
        let bytesPerRow = width * 4
        let imageData = UnsafeMutablePointer<Pixel>.allocate(capacity: width * height)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        bitmapInfo = bitmapInfo | CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        imageContext.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
        
        pixels = UnsafeMutableBufferPointer<Pixel>(start: imageData, count: width * height)
    }
    
    public func toUIImage() -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        var bitmapInfo: UInt32 = CGBitmapInfo.byteOrder32Big.rawValue
        let bytesPerRow = width * 4
        
        bitmapInfo |= CGImageAlphaInfo.premultipliedLast.rawValue & CGBitmapInfo.alphaInfoMask.rawValue
        
        guard let imageContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil) else {
            return nil
        }
        guard let cgImage = imageContext.makeImage() else {
            return nil
        }
        
        let image = UIImage(cgImage: cgImage)
        return image
    }
    
    public func pixel(x : Int, _ y : Int) -> Pixel? {
        guard x >= 0 && x < width && y >= 0 && y < height else {
            return nil
        }
        
        let address = y * width + x
        return pixels[address]
    }
    
    public func pixel(x : Int, _ y : Int, _ pixel: Pixel) {
        guard x >= 0 && x < width && y >= 0 && y < height else {
            return
        }
        
        let address = y * width + x
        pixels[address] = pixel
    }
    
    public func process( functor : ((Pixel) -> Pixel) ) {
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                let outPixel = functor(pixels[index])
                pixels[index] = outPixel
            }
        }
    }
}

