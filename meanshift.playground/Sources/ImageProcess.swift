import Foundation

func clamp<T: Comparable>(_ value: T, lower: T, upper: T) -> T {
    return min(max(value, lower), upper)
}

public class ImageProcess {
    
    public static func grabR(_ image: RGBAImage) -> RGBAImage {
        var outImage = image
        outImage.process { (pixel) -> Pixel in
            var pixel = pixel
            pixel.R = pixel.R
            pixel.G = 0
            pixel.B = 0
            return pixel
        }
        return outImage
    }
    
    public static func grabG(_ image: RGBAImage) -> RGBAImage {
        var outImage = image
        outImage.process { (pixel) -> Pixel in
            var pixel = pixel
            pixel.R = 0
            pixel.G = pixel.G
            pixel.B = 0
            return pixel
        }
        return outImage
    }
    
    public static func grabB(_ image: RGBAImage) -> RGBAImage {
        var outImage = image
        outImage.process { (pixel) -> Pixel in
            var pixel = pixel
            pixel.R = 0
            pixel.G = 0
            pixel.B = pixel.B
            return pixel
        }
        return outImage
    }
    
    public static func composite(_ rgbaImageList: RGBAImage...) -> RGBAImage {
        let result : RGBAImage = RGBAImage(width:rgbaImageList[0].width, height: rgbaImageList[0].height)
        for y in 0..<result.height {
            for x in 0..<result.width {
                
                let index = y * result.width + x
                var pixel = result.pixels[index]
                
                for rgba in rgbaImageList {
                    let rgbaPixel = rgba.pixels[index]
                    pixel.Rf = pixel.Rf + rgbaPixel.Rf
                    pixel.Gf = pixel.Gf + rgbaPixel.Gf
                    pixel.Bf = pixel.Bf + rgbaPixel.Bf
                }
                
                result.pixels[index] = pixel
            }
        }
        return result
    }
    
    public static func composite(_ functor : (Double, Double) -> Double, rgbaImageList: RGBAImage...) -> RGBAImage {
        let result : RGBAImage = RGBAImage(width:rgbaImageList[0].width, height: rgbaImageList[0].height)
        for y in 0..<result.height {
            for x in 0..<result.width {
                
                let index = y * result.width + x
                var pixel = result.pixels[index]
                
                for rgba in rgbaImageList {
                    let rgbaPixel = rgba.pixels[index]
                    pixel.Rf = functor(pixel.Rf, rgbaPixel.Rf)
                    pixel.Gf = functor(pixel.Gf, rgbaPixel.Gf)
                    pixel.Bf = functor(pixel.Bf, rgbaPixel.Bf)
                }
                
                result.pixels[index] = pixel
            }
        }
        return result
    }
    
    
    public static func composite(_ byteImageList: ByteImage...) -> RGBAImage {
        let result : RGBAImage = RGBAImage(width:byteImageList[0].width, height: byteImageList[0].height)
        for y in 0..<result.height {
            for x in 0..<result.width {
                
                let index = y * result.width + x
                var pixel = result.pixels[index]
                
                for (imageIndex, byte) in byteImageList.enumerated() {
                    
                    let bytePixel = byte.pixels[index]
                    switch imageIndex % 3 {
                    case 0:
                        pixel.Rf = pixel.Rf + bytePixel.Cf
                    case 1:
                        pixel.Gf = pixel.Gf + bytePixel.Cf
                    case 2:
                        pixel.Bf = pixel.Bf + bytePixel.Cf
                    default:
                        break
                    }
                }
                
                result.pixels[index] = pixel
            }
        }
        return result
    }
    
    public static func composite(_ functor : (Double, Double) -> Double, byteImageList: ByteImage...) -> RGBAImage {
        let result : RGBAImage = RGBAImage(width:byteImageList[0].width, height: byteImageList[0].height)
        for y in 0..<result.height {
            for x in 0..<result.width {
                
                let index = y * result.width + x
                var pixel = result.pixels[index]
                
                for (imageIndex, byte) in byteImageList.enumerated() {
                    
                    let bytePixel = byte.pixels[index]
                    switch imageIndex % 3 {
                    case 0:
                        pixel.Rf = functor(pixel.Rf, bytePixel.Cf)
                    case 1:
                        pixel.Gf = functor(pixel.Gf, bytePixel.Cf)
                    case 2:
                        pixel.Bf = functor(pixel.Bf, bytePixel.Cf)
                    default:
                        break
                    }
                }
                
                result.pixels[index] = pixel
            }
        }
        return result
    }
    
    public static func gray1(_ image: RGBAImage) -> RGBAImage {
        var outImage = image
        outImage.process { (pixel) -> Pixel in
            var pixel = pixel
            let result = pixel.Rf*0.2999 + pixel.Gf*0.587 + pixel.Bf*0.114
            pixel.Rf = result
            pixel.Gf = result
            pixel.Bf = result
            return pixel
        }
        return outImage
    }
    
    public static func gray2(_ image: RGBAImage) -> RGBAImage {
        var outImage = image
        outImage.process { (pixel) -> Pixel in
            var pixel = pixel
            let result = (pixel.Rf + pixel.Gf + pixel.Bf) / 3.0
            pixel.Rf = result
            pixel.Gf = result
            pixel.Bf = result
            return pixel
        }
        return outImage
    }
    
    public static func gray3(_ image: RGBAImage) -> RGBAImage {
        var outImage = image
        outImage.process { (pixel) -> Pixel in
            var pixel = pixel
            pixel.R = pixel.G
            pixel.G = pixel.G
            pixel.B = pixel.G
            return pixel
        }
        return outImage
    }
    
    public static func gray4(_ image: RGBAImage) -> RGBAImage {
        var outImage = image
        outImage.process { (pixel) -> Pixel in
            var pixel = pixel
            let result = pixel.Rf*0.212671 + pixel.Gf*0.715160 + pixel.Bf*0.071169
            pixel.Rf = result
            pixel.Gf = result
            pixel.Bf = result
            return pixel
        }
        return outImage
    }
    
    public static func gray5(_ image: RGBAImage) -> RGBAImage {
        var outImage = image
        outImage.process { (pixel) -> Pixel in
            var pixel = pixel
            let result = sqrt(pow(pixel.Rf, 2) + pow(pixel.Rf, 2) + pow(pixel.Rf, 2))/sqrt(3.0)
            pixel.Rf = result
            pixel.Gf = result
            pixel.Bf = result
            return pixel
        }
        return outImage
    }
    
    public static func splitRGB(_ rgba: RGBAImage) -> (ByteImage, ByteImage, ByteImage) {
        let R = ByteImage(width: rgba.width, height: rgba.height)
        let G = ByteImage(width: rgba.width, height: rgba.height)
        let B = ByteImage(width: rgba.width, height: rgba.height)
        
        rgba.enumerate { (index, pixel) -> Void in
            
            R.pixels[index] = pixel.R.toBytePixel()
            G.pixels[index] = pixel.G.toBytePixel()
            B.pixels[index] = pixel.B.toBytePixel()
        }
        
        return (R, G, B)
    }
    
    // +, -, *, /
    public static func op(_ functor : (Double, Double) -> Double, rgbaImage: RGBAImage, factor: Double) -> RGBAImage {
        var outImage = rgbaImage
        outImage.process { (pixel) -> Pixel in
            var pixel = pixel
            pixel.Rf = functor(pixel.Rf, factor)
            pixel.Gf = functor(pixel.Gf, factor)
            pixel.Bf = functor(pixel.Bf, factor)
            return pixel
        }
        return outImage
    }
    
    public static func op(_ functor : (Double, Double) -> Double, rgbaImage1: RGBAImage, rgbaImage2: RGBAImage) -> RGBAImage {
        let result : RGBAImage = RGBAImage(width:rgbaImage1.width, height: rgbaImage1.height)
        for y in 0..<result.height {
            for x in 0..<result.width {
                
                let index = y * result.width + x
                var pixel = result.pixels[index]
                
                let rgba1Pixel = rgbaImage1.pixels[index]
                let rgba2Pixel = rgbaImage2.pixels[index]
                
                
                pixel.Rf = functor(rgba1Pixel.Rf, rgba2Pixel.Rf)
                pixel.Gf = functor(rgba1Pixel.Gf, rgba2Pixel.Gf)
                pixel.Bf = functor(rgba1Pixel.Bf, rgba2Pixel.Bf)
                
                result.pixels[index] = pixel
            }
        }
        return result
        
    }
    
    public static func op(_ functor : (Double, Double) -> Double, byteImage: ByteImage, factor: Double) -> ByteImage {
        var outImage = byteImage
        outImage.process { (pixel) -> BytePixel in
            var pixel = pixel
            pixel.Cf = functor(pixel.Cf, factor)
            return pixel
        }
        return outImage
    }
    
    public static func op(_ functor : (Double, Double) -> Double, byteImage1: ByteImage, byteImage2: ByteImage) -> ByteImage {
        let result : ByteImage = ByteImage(width:byteImage1.width, height: byteImage1.height)
        for y in 0..<result.height {
            for x in 0..<result.width {
                
                let index = y * result.width + x
                var pixel = result.pixels[index]
                
                let byte1Pixel = byteImage1.pixels[index]
                let byte2Pixel = byteImage2.pixels[index]
                
                
                pixel.Cf = functor(byte1Pixel.Cf, byte2Pixel.Cf)
                result.pixels[index] = pixel
            }
        }
        return result
        
    }
    
    
    // MARK:- RGBA
    
    
    public static func add(_ rgba: RGBAImage, factor: Double) -> RGBAImage {
        return op((+), rgbaImage: rgba, factor: factor)
    }
    
    public static func add(_ rgba1: RGBAImage, _ rgba2: RGBAImage) -> RGBAImage {
        return op((+), rgbaImage1: rgba1, rgbaImage2: rgba2)
    }
    
    public static func sub(_ rgba: RGBAImage, factor: Double) -> RGBAImage {
        return op((-), rgbaImage: rgba, factor: factor)
    }
    
    public static func sub(_ rgba1: RGBAImage, _ rgba2: RGBAImage) -> RGBAImage {
        return op((-), rgbaImage1: rgba1, rgbaImage2: rgba2)
    }
    
    public static func mul(_ rgba: RGBAImage, factor: Double) -> RGBAImage {
        return op((*), rgbaImage: rgba, factor: factor)
    }
    
    public static func mul(_ rgba1: RGBAImage, _ rgba2: RGBAImage) -> RGBAImage {
        return op((*), rgbaImage1: rgba1, rgbaImage2: rgba2)
    }
    
    
    public static func div(_ rgba: RGBAImage, factor: Double) -> RGBAImage {
        if factor == 0.0 {
            return rgba
        }
        return op((/), rgbaImage: rgba, factor: factor)
    }
    
    // 0으로 나누면 안되기 때문에 따로 만듦
    public static func div(_ rgba1: RGBAImage, _ rgba2: RGBAImage) -> RGBAImage {
        let result : RGBAImage = RGBAImage(width:rgba1.width, height: rgba1.height)
        for y in 0..<result.height {
            for x in 0..<result.width {
                
                let index = y * result.width + x
                var pixel = result.pixels[index]
                
                let rgba1Pixel = rgba1.pixels[index]
                let rgba2Pixel = rgba2.pixels[index]
                
                
                pixel.Rf = rgba1Pixel.Rf / (rgba2Pixel.Rf <= 0.0 ? 1.0 : rgba2Pixel.Rf)
                pixel.Gf = rgba1Pixel.Gf / (rgba2Pixel.Gf <= 0.0 ? 1.0 : rgba2Pixel.Gf)
                pixel.Bf = rgba1Pixel.Bf / (rgba2Pixel.Bf <= 0.0 ? 1.0 : rgba2Pixel.Bf)
                
                result.pixels[index] = pixel
            }
        }
        return result
        
    }
    
    
    // MARK:- BYTE
    public static func add(_ img: ByteImage, factor: Double) -> ByteImage {
        return op((+), byteImage: img, factor: factor)
    }
    
    public static func add(_ img1: ByteImage, _ img2: ByteImage) -> ByteImage {
        return op((+), byteImage1: img1, byteImage2: img2)
    }
    
    public static func sub(_ img: ByteImage, factor: Double) -> ByteImage {
        return op((-), byteImage: img, factor: factor)
    }
    
    public static func sub(_ img1: ByteImage, _ img2: ByteImage) -> ByteImage {
        return op((-), byteImage1: img1, byteImage2: img2)
    }
    
    public static func mul(_ img: ByteImage, factor: Double) -> ByteImage {
        return op((*), byteImage: img, factor: factor)
    }
    
    public static func mul(_ img1: ByteImage, _ img2: ByteImage) -> ByteImage {
        return op((*), byteImage1: img1, byteImage2: img2)
    }
    
    
    public static func div(_ img: ByteImage, factor: Double) -> ByteImage {
        if factor == 0.0 {
            return img
        }
        return op((/), byteImage: img, factor: factor)
    }
    
    // 0으로 나누면 안되기 때문에 따로 만듦
    public static func div(_ img1: ByteImage, _ img2: ByteImage) -> ByteImage {
        let result : ByteImage = ByteImage(width:img1.width, height: img1.height)
        for y in 0..<result.height {
            for x in 0..<result.width {
                
                let index = y * result.width + x
                var pixel = result.pixels[index]
                
                let pixel1 = img1.pixels[index]
                let pixel2 = img2.pixels[index]
                
                
                pixel.Cf = pixel1.Cf / (pixel2.Cf <= 0.0 ? 1.0 : pixel2.Cf)
                result.pixels[index] = pixel
            }
        }
        return result
        
    }
    
    // MARK:- RGBA Blending
    public static func blending(_ img1: RGBAImage, _ img2: RGBAImage, alpha: Double) -> RGBAImage {
        let result : RGBAImage = RGBAImage(width:img1.width, height: img1.height)
        for y in 0..<result.height {
            for x in 0..<result.width {
                
                let index = y * result.width + x
                var pixel = result.pixels[index]
                
                let pixel1 = img1.pixels[index]
                let pixel2 = img2.pixels[index]
                
                
                pixel.Rf = alpha * pixel1.Rf + (1.0 - alpha) * pixel2.Rf
                pixel.Gf = alpha * pixel1.Gf + (1.0 - alpha) * pixel2.Gf
                pixel.Bf = alpha * pixel1.Bf + (1.0 - alpha) * pixel2.Bf
                
                result.pixels[index] = pixel
            }
        }
        return result
    }
    
    // MARK: - Brightness
    public static func brightness(_ img1: RGBAImage, contrast: Double, brightness: Double) -> RGBAImage {
        let result : RGBAImage = RGBAImage(width:img1.width, height: img1.height)
        for y in 0..<result.height {
            for x in 0..<result.width {
                
                let index = y * result.width + x
                var pixel = result.pixels[index]
                
                let pixel1 = img1.pixels[index]
                
                pixel.Rf = pixel1.Rf * contrast + brightness
                pixel.Gf = pixel1.Gf * contrast + brightness
                pixel.Bf = pixel1.Bf * contrast + brightness
                
                result.pixels[index] = pixel
            }
        }
        return result
    }
    
    public static func brightness(_ img1: ByteImage, contrast: Double, brightness: Double) -> ByteImage {
        let result : ByteImage = ByteImage(width:img1.width, height: img1.height)
        for y in 0..<result.height {
            for x in 0..<result.width {
                
                let index = y * result.width + x
                var pixel = result.pixels[index]
                
                let pixel1 = img1.pixels[index]
                pixel.Cf = pixel1.Cf * contrast + brightness
                
                result.pixels[index] = pixel
            }
        }
        return result
    }
    
    // MARK: - Convolution
    public static func convolution(_ image: ByteImage, mask: Array2D<Double>) -> ByteImage {
        var image = image
        let height = image.height
        let width  = image.width
        
        let maskHeight = mask.rowCount()
        let maskWidth  = mask.colCount()
        
        for y in 0..<height - maskHeight + (maskHeight-1)/2 {
            for x in 0..<width - maskWidth + (maskWidth-1)/2 {
                var v = 0.0
                if (y+maskHeight > height) || (x+maskWidth) > width {
                    continue
                }
                
                for my in 0..<maskHeight {
                    for mx in 0..<maskWidth {
                        let tmp = mask[my, mx]
                        v = v + (image.pixel(x+mx, y+my)!.Cf * tmp)
                    }
                }
                
                v = clamp(v, lower: 0.0, upper: 1.0)
                let pixel = BytePixel(value: v)
                let xx = x+(maskWidth-1)/2
                let yy = y+(maskHeight-1)/2
                image.setPixel(xx, yy, pixel)
            }
        }
        return image
    }
}
