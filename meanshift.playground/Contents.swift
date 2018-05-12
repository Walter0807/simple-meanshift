//: Playground - noun: a place where people can play

import UIKit

let imgsrc = RGBAImage(image: UIImage(named: "sample")!)!
let width = Int(imgsrc.width)
let height = Int(imgsrc.height)
let MIN_DISTANCE = 0.00001
let MIN_DISTANCE_GROUP = 0.1

var allPoints = [Point]()
var easyFind = [[Int]]()
var cateCenter = [Point]()
var newPoint = [[Point]]()
var cateCounter = 0
let bandwidth = 20

public func distEuchilid(_ x: Point, _ y: Point) -> Double {
    let sum = (x.R-y.R)*(x.R-y.R) + (x.G-y.G)*(x.G-y.G) + (x.B-y.B)*(x.B-y.B)
    return sqrt(sum)
}

public func pointShift(_ p: Point) -> Point {
    var cnt = 0.0
    var totR = 0.0
    var totG = 0.0
    var totB = 0.0
    let bw = Double()
    var l = (Int(p.R) - (bandwidth + 1) > 0) ? Int(p.R) - (bandwidth + 1) : 0
    var r = (Int(p.R) + (bandwidth + 1) < 255) ? Int(p.R) + (bandwidth + 1) : 255
    for i in l...r {
        for j in easyFind[i] {
            var point = allPoints[j]
            if distEuchilid(point, p) < Double(bandwidth) {
                cnt += 1.0
                totR += point.R
                totG += point.G
                totB += point.B
            }
        }
    }
    return Point(totR/cnt, totG/cnt, totB/cnt, point.x, point.y)
}

public func meanShift() {
    var shiftingPointNumbers = allPoints.count
    while shiftingPointNumbers > 0 {
        for point in allPoints {
            if !point.shifting {continue}
            let pointShifted = pointShift(point)
            let dist = distEuchilid(point, pointShifted)
            if  dist < MIN_DISTANCE {
                point.shifting = false
                shiftingPointNumbers -= 1
            }
            newPoint[point.x][point.y] = pointShifted
        }
        easyFind = [[]]
        for (offset, point) in allPoints.enumerated() {
            point = newPoint[point.x][point.y]
            easyFind[Int(point.R)] += [offset]
        }
    }
}

public func clusterPoints() {
    for point in allPoints {
        var newCate = true
        for cc in cateCenter {
            if distEuchilid(point, cc) < MIN_DISTANCE_GROUP {
                newCate = false
                point.cate = cc.cate
            }
            if newCate {
                point.cate = cateCounter
                cateCounter += 1
                cateCenter += [point]
            }
        }
    }
}

public func reconstructPic() -> RGBAImage {
    var result = imgsrc.clone()
    for point in allPoints {
        let index = point.x * width + point.y
        result.pixels[index].R = UInt8(cateCenter[point.cate].R)
        result.pixels[index].G = UInt8(cateCenter[point.cate].G)
        result.pixels[index].B = UInt8(cateCenter[point.cate].B)
    }
    return result
}

for i in 0..<height {
    for j in 0..<width {
        let index = i * width + j
        let pixel = imgsrc.pixels[index]
        allPoints += [Point(Double(pixel.R), Double(pixel.G), Double(pixel.B), i, j)]
    }
}

//allPoints.shuffle()


meanShift()
clusterPoints()
let pic = reconstructPic().toUIImage()









