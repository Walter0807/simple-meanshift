//
//  Meanshift.swift
//  Meanshift
//
//  Created by Walter on 5/12/18.
//  Copyright © 2018 朱文韬. All rights reserved.
//

import Foundation
import UIKit

public func distEuchilid(_ x: Point, _ y: Point) -> Double {
    let sum = (x.R-y.R)*(x.R-y.R) + (x.G-y.G)*(x.G-y.G) + (x.B-y.B)*(x.B-y.B)
    return sqrt(sum)
}

class Meanshift {
    var bandwidth = 8
    var width = Int()
    var height = Int()
    let MIN_DISTANCE = 1.0
    let MIN_DISTANCE_GROUP = 40.0
    var allPoints = [Point]()
    var easyFind = [[Int]]()
    var cateCenter = [Point]()
    var newPoint = [[Point]]()
    var cateCounter = 0

    
    public init (_ bw: Int) {
        bandwidth = bw
    }
    
    public func process(_ imgsrc: UIImage) -> RGBAImage {
        let imgmat = RGBAImage(image: imgsrc)!
        width = Int(imgmat.width)
        height = Int(imgmat.height)
        for i in 0..<height {
            for j in 0..<width {
                let index = i * width + j
                let pixel = imgmat.pixels[index]
                allPoints += [Point(Double(pixel.R), Double(pixel.G), Double(pixel.B), i, j)]
            }
        }
        return imgmat
    }
    
    public func pointShift(_ p: Point) -> Point {
        var cnt = 0.0
        var totR = 0.0
        var totG = 0.0
        var totB = 0.0
        let l = (Int(p.R) - (bandwidth + 1) > 0) ? Int(p.R) - (bandwidth + 1) : 0
        let r = (Int(p.R) + (bandwidth + 1) < 255) ? Int(p.R) + (bandwidth + 1) : 255
        for i in l...r {
            if !easyFind[i].isEmpty{
                for j in easyFind[i] {
                    let point = allPoints[j]
                    if distEuchilid(point, p) < Double(bandwidth) {
                        cnt += 1.0
                        totR += point.R
                        totG += point.G
                        totB += point.B
                    }
                }
            }
        }
        return Point(totR/cnt, totG/cnt, totB/cnt, p.x, p.y)
    }
    
    public func meanShift() {
        var shiftingPointNumbers = allPoints.count
        easyFind = Array(repeating: [], count: 256)
        newPoint = Array(repeating: Array(repeating: Point(), count: width), count: height)
        
        for idx in allPoints.indices {
            easyFind[Int(allPoints[idx].R)] += [idx]
        }
        
        while shiftingPointNumbers > 0 {
            print(shiftingPointNumbers)
            for point in allPoints {
                if !point.shifting {continue}
                var pointShifted = pointShift(point)
                let dist = distEuchilid(point, pointShifted)
                if  dist < MIN_DISTANCE {
                    pointShifted.shifting = false
                    shiftingPointNumbers -= 1
                }
                newPoint[point.x][point.y] = pointShifted
            }
            easyFind = Array(repeating: [], count: 256)
            for idx in allPoints.indices {
                allPoints[idx] = newPoint[allPoints[idx].x][allPoints[idx].y]
                easyFind[Int(allPoints[idx].R)] += [idx]
            }
        }
    }
    
    
    public func clusterPoints() {
        for idx in allPoints.indices {
//            print(idx, cateCounter)
            var newCate = true
            for cc in cateCenter {
                if distEuchilid(allPoints[idx], cc) < MIN_DISTANCE_GROUP {
                    newCate = false
                    allPoints[idx].cate = cc.cate
                }
            }
            if newCate {
                allPoints[idx].cate = cateCounter
                cateCounter += 1
                cateCenter += [allPoints[idx]]
            }
        }
        print("\(cateCounter) Clusters")
    }

    public func reconstructPic(with imgmat: RGBAImage) -> RGBAImage {
        var result = imgmat.clone()
        for point in allPoints {
            let index = point.x * width + point.y
//            print("!!!!!\(index)")
            result.pixels[index].R = UInt8(cateCenter[point.cate].R)
            result.pixels[index].G = UInt8(cateCenter[point.cate].G)
            result.pixels[index].B = UInt8(cateCenter[point.cate].B)
        }
        return result
    }
    
    public func run(_ imgsrc: UIImage) -> UIImage {
        let imgmat = self.process(imgsrc)
        self.meanShift()
        self.clusterPoints()
        return reconstructPic(with: imgmat).toUIImage()!
    }
    
}










