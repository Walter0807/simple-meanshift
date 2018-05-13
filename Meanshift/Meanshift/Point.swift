import Foundation

public struct Point {
    public var R: Double = 0
    public var G: Double = 0
    public var B: Double = 0
    public var x: Int = 0 //0..<Height
    public var y: Int = 0//0..<Width
    public var cate: Int = -1
    public var shifting: Bool = true
    
    public init(_ r: Double, _ g: Double, _ b: Double, _ x: Int, _ y: Int) {
        R = r<255 ? r : 255
        G = g<255 ? g : 255
        B = b<255 ? b : 255
        
        R = r>0 ? r : 0
        G = g>0 ? g : 0
        B = b>0 ? b : 0
        
        
        self.x = x
        self.y = y
    }
    
    public init() { }
    
}

extension Array {
    public func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
    
    public func shuffle() -> Array {
        var list = self
        for index in 0..<list.count {
            let newIndex = Int(arc4random_uniform(UInt32(list.count-index))) + index
            if index != newIndex {
                list.swapAt(index, newIndex)
            }
        }
        return list
    }
}











