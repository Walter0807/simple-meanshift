import UIKit

/**
 * 1byte크기의 화소 배열로 이뤄진 이미지
 */
public struct BytePixel {
    private var value: UInt8
    
    public init(value : UInt8) {
        self.value = value
    }
    
    public init(value: Double) {
        self.value = UInt8(max(min(value, 1.0), 0.0) * 255.0)
    }
    
    //red
    public var C: UInt8 {
        get { return value }
        set {
            let v = max(min(newValue, 255), 0)
            value = v
        }
    }
    
    public var Cf: Double {
        get { return Double(self.C) / 255.0 }
        set { self.C = UInt8(max(min(newValue, 1.0), 0.0) * 255.0) }
    }
}

public struct ByteImage {
    public var pixels: UnsafeMutableBufferPointer<BytePixel>
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
        
        // 1 * width * height 크기의 버퍼를 생성한다.
        let bytesPerRow = width * 1
        let imageData = UnsafeMutablePointer<BytePixel>.allocate(capacity: width * height)
        
        // 색상공간은 Device의 것을 따른다
        let colorSpace = CGColorSpaceCreateDeviceGray()
        
        // BGRA로 비트맵을 만든다
        let bitmapInfo: UInt32 = CGBitmapInfo().rawValue
        // 비트맵 생성
        guard let imageContext = CGContext(data: imageData, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        // cgImage를 imageData에 채운다.
        imageContext.draw(cgImage, in: CGRect(origin: .zero, size: image.size))
        
        // 이미지 화소의 배열 주소를 pixels에 담는다
        pixels = UnsafeMutableBufferPointer<BytePixel>(start: imageData, count: width * height)
    }
    
    
    public init(width: Int, height: Int) {
        let image = ByteImage.newUIImage(width: width, height: height)
        self.init(image: image)!
    }
    
    public func clone() -> ByteImage {
        let cloneImage = ByteImage(width: self.width, height: self.height)
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                cloneImage.pixels[index] = self.pixels[index]
            }
        }
        return cloneImage
    }
    
    public func toUIImage() -> UIImage? {
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let bitmapInfo: UInt32 = CGBitmapInfo().rawValue
        let bytesPerRow = width * 1
        
        
        guard let imageContext = CGContext(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo, releaseCallback: nil, releaseInfo: nil) else {
            return nil
        }
        guard let cgImage = imageContext.makeImage() else {
            return nil
        }
        
        let image = UIImage(cgImage: cgImage)
        return image
    }
    
    public func pixel(_ x : Int, _ y : Int) -> BytePixel? {
        guard x >= 0 && x < width && y >= 0 && y < height else {
            return nil
        }
        
        let address = y * width + x
        return pixels[address]
    }
    
    public mutating func pixel(_ x : Int, _ y : Int, _ pixel: BytePixel) {
        guard x >= 0 && x < width && y >= 0 && y < height else {
            return
        }
        
        let address = y * width + x
        pixels[address] = pixel
    }
    
    public mutating func setPixel(_ x : Int, _ y : Int, _ pixel: BytePixel) {
        guard x >= 0 && x < width && y >= 0 && y < height else {
            return
        }
        
        let address = y * width + x
        pixels[address] = pixel
    }
    
    public mutating func process(_ functor : ((BytePixel) -> BytePixel) ) {
        for y in 0..<height {
            for x in 0..<width {
                let index = y * width + x
                pixels[index] = functor(pixels[index])
            }
        }
    }
    
    private static func newUIImage(width: Int, height: Int) -> UIImage {
        let size = CGSize(width: CGFloat(width), height: CGFloat(height));
        UIGraphicsBeginImageContextWithOptions(size, true, 0);
        UIColor.black.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}

extension UInt8 {
    public func toBytePixel() -> BytePixel {
        return BytePixel(value: self)
    }
}


