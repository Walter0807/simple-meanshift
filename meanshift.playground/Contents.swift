//: Playground - noun: a place where people can play

import UIKit

let imgsrc = RGBAImage(image: UIImage(named: "sample")!)!
let width = Int(imgsrc.width)
let height = Int(imgsrc.height)
let MIN_DISTANCE = 0.00001
let MIN_DISTANCE_GROUP = 0.1

var allPoints = [Point]()
var easyFind = [[Int]]()
var cateCenter = [Int]()
var cateCounter = 0

for i in 0..<height {
    for j in 0..<width {
        let index = i * width + j
        let pixel = imgsrc.pixels[index]
        allPoints += [Point(Double(pixel.R), Double(pixel.G), Double(pixel.B), i, j)]
    }
}

//allPoints.shuffle()

public func meanShift() {
    var shiftingPointNumbers = allPoints.count
    while shiftingPointNumbers > 0 {
        for point in allPoints {
            if !point.shifting {continue}
            let pointShifted = pointShift(point)
            dist = distEuchilid(point, pointShifted)
            if  dist< MIN_DISTANCE {
                point.shifting = false
                shiftingPointNumbers -= 1
            }
            newPoint[point.x][point.y] = pointShifted
        }
        easyFind = [[]]
        for (offset, point) in allPoints.enumerated() {
            point = newPoint[point.x][point.y]
            easyFind[Int(point.x)] += [offset]
        }
    }
}

public func groupPoints() {
    for point in allPoints {
        var newCate = true
        for cc in cateCenter {
            if distEuchilid(point, cc) < MIN_DISTANCE_GROUP {
                newCate = false
                point.cate = cc.cate
            }
            if newCate {
                cateCounter += 1
                point.cate = cateCounter
                cateCenter += [point]
            }
        }
    }
}











