//
//  Meanshift.swift
//  Meanshift
//
//  Created by Walter on 5/12/18.
//  Copyright © 2018 朱文韬. All rights reserved.
//

import Foundation
import UIKit

public func rgb2luv(_ R: UInt8, _ G: UInt8, _ B: UInt8) -> (Double,Double,Double) {
    let r = Double(R) / 255.0
    let g = Double(G) / 255.0
    let b = Double(B) / 255.0
    let x = 0.412453 * r + 0.357580 * g + 0.180423 * b
    let y = 0.212671 * r + 0.715160 * g + 0.072169 * b
    let z = 0.019334 * r + 0.119193 * g + 0.950227 * b
    var L = Double()
    var u = Double()
    var v = Double()
    if (y > 0.008856) {
        L = 116.0 * pow(y, 1.0 / 3.0) - 16.0
    }
    else {
        L = 903.3 * y
    }
    let sum = x + 15 * y + 3 * z
    if (sum != 0) {
        u = 4 * x / sum
        v = 9 * y / sum
    }
    else {
        u = 4.0
        v = 9.0 / 15.0
    }
    return (L, 13 * L * (u - 0.19784977571475), 13 * L * (v - 0.46834507665248))
}

public func distEuchilid(_ x: Point, _ y: Point) -> Double {
    let sum = (x.R-y.R)*(x.R-y.R) + (x.G-y.G)*(x.G-y.G) + (x.B-y.B)*(x.B-y.B)
    return sqrt(sum)
}

class Meanshift {
    var bandwidth = 8
    var width = Int()
    var height = Int()
    let MIN_DISTANCE = 1.0
    var MIN_DISTANCE_GROUP = 40
    
    
    
    var allPoints = [Point]()
    var easyFind = [[Int]]()
    var cateCenter = [Point]()
    var newPoint = [[Point]]()
    var cateCounter = 0
    var gaussian = true
    var luv = true
    var h2 = 128.0
    var imgmat: RGBAImage
    
    public init (_ bw: Int) {
        bandwidth = bw
        h2 = Double(bandwidth * bandwidth * 2)
        imgmat = RGBAImage(width: 1, height: 1)
    }
    
    public func process(_ imgsrc: UIImage) -> RGBAImage {
        allPoints = []
        let imgmat = RGBAImage(image: imgsrc)!
        width = Int(imgmat.width)
        height = Int(imgmat.height)
        for i in 0..<height {
            for j in 0..<width {
                let index = i * width + j
                let pixel = imgmat.pixels[index]
                if !luv {allPoints += [Point(Double(pixel.R), Double(pixel.G), Double(pixel.B), i, j)]}
                else {
                    let tmp = rgb2luv(pixel.R, pixel.G, pixel.B)
                    allPoints += [Point(tmp.0, tmp.1, tmp.2, i, j)]
                }
            }
        }
        return imgmat
    }
    
    public func pointShift(_ p: Point) -> Point {
        var cnt = 0.0
        var totR = 0.0
        var totG = 0.0
        var totB = 0.0
        var totsc = 0.0
        let l = (Int(p.R) - (bandwidth + 1) > 0) ? Int(p.R) - (bandwidth + 1) : 0
        let r = (Int(p.R) + (bandwidth + 1) < 255) ? Int(p.R) + (bandwidth + 1) : 255
        for i in l...r {
            if !easyFind[i].isEmpty{
                for j in easyFind[i] {
                    let point = allPoints[j]
                    let dist = distEuchilid(point, p)
                    if dist < Double(bandwidth) {
                        cnt += 1.0
                        if !gaussian {
                            totR += point.R
                            totG += point.G
                            totB += point.B
                        }
                        else {
                            let sc = exp(-dist * dist / h2)
                            totR += sc * point.R
                            totG += sc * point.G
                            totB += sc * point.B
                            totsc += sc
                        }
                    }
                }
            }
        }
        if !gaussian {return Point(totR/cnt, totG/cnt, totB/cnt, p.x, p.y)}
        else {
            return Point(totR/totsc, totG/totsc, totB/totsc, p.x, p.y)
        }
    }
    
    public func meanShift() {
        var shiftingPointNumbers = allPoints.count
        easyFind = Array(repeating: [], count: 258)
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
//                print("shifted \(dist)")
                if  dist < MIN_DISTANCE {
                    pointShifted.shifting = false
                    shiftingPointNumbers -= 1
                }
                newPoint[point.x][point.y] = pointShifted
            }
            easyFind = Array(repeating: [], count: 258)
            for idx in allPoints.indices {
                allPoints[idx] = newPoint[allPoints[idx].x][allPoints[idx].y]
                easyFind[Int(allPoints[idx].R)] += [idx]
            }
        }
    }
    
    
    public func clusterPoints() {
        cateCenter = []
        cateCounter = 0
        for idx in allPoints.indices {
//            print(idx, cateCounter)
            var newCate = true
            for cc in cateCenter {
                if distEuchilid(allPoints[idx], cc) < Double(MIN_DISTANCE_GROUP) {
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

    public func segmentPic(with imgmat: RGBAImage) -> RGBAImage {
        var result = imgmat.clone()
        for point in allPoints {
            let index = point.x * width + point.y
            let oridx = cateCenter[point.cate].x * width + cateCenter[point.cate].y
            result.pixels[index].R = imgmat.pixels[oridx].R
            result.pixels[index].G = imgmat.pixels[oridx].G
            result.pixels[index].B = imgmat.pixels[oridx].B
        }
        return result
    }
    
    public func reconstructPic(with imgmat: RGBAImage) -> RGBAImage {
        var result = imgmat.clone()
        var cateToRemove = Set<Int>()
        var cateid = Array(repeating: Array(repeating: Int(), count: width), count: height)
        for point in allPoints {
            if point.x == 0 && point.y == width - 1 {
                cateToRemove.insert(point.cate)
                print("Remove Cate ID: \(point.cate)")
            }
            cateid[point.x][point.y] = point.cate
        }
        
        for i in 0..<height {
            for j in 0..<width {
                let index = i * width + j
                if cateToRemove.contains(cateid[i][j]) {
                    result.pixels[index].A = 0
                }
                else {
                    var cnt = 0
                    if i+1<height && cateToRemove.contains(cateid[i+1][j]) {cnt += 1}
                    if i-1>0 && cateToRemove.contains(cateid[i-1][j]) {cnt += 1}
                    if j-1>0 && cateToRemove.contains(cateid[i][j-1]) {cnt += 1}
                    if j+1<width && cateToRemove.contains(cateid[i][j+1]) {cnt += 1}
                    if cnt>3 {cnt = 3}
                    result.pixels[index].A = UInt8(255 - 83 * cnt)
                }
            }
        }
        
        return result
    }
    
    public func adjust(_ imgsrc: UIImage, _ groupTolerance: Int) -> UIImage {
        MIN_DISTANCE_GROUP = groupTolerance
        self.clusterPoints()
        return reconstructPic(with: imgmat).toUIImage()!
    }
    
    public func run(_ imgsrc: UIImage) -> UIImage {
        imgmat = self.process(imgsrc)
        self.meanShift()
        self.clusterPoints()
        return reconstructPic(with: imgmat).toUIImage()!
//      return segmentPic(with: imgmat).toUIImage()!
    }
    
}










