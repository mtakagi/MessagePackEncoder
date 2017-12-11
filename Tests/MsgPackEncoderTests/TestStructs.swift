//
//  TestData.swift
//  MsgPackEncoderPackageDescription
//
//  Created by mtakagi on 2017/12/12.
//

import Foundation


internal struct Empty : Codable {

    public init() {}

    public init(from: Decoder) {

    }

}

extension Empty : Equatable {
    public static func ==(lhs: Empty, rhs: Empty) -> Bool {
        return true
    }
}

internal struct Sample : Codable {
    var foo : UInt8
    var bar : String
    var bazz : UInt32
}

extension Sample : Equatable {
    static func ==(lhs: Sample, rhs: Sample) -> Bool {
        return lhs.foo == rhs.foo && lhs.bar == rhs.bar && lhs.bazz == rhs.bazz
    }

    static func !=(lhs: Sample, rhs: Sample) -> Bool {
        return !(lhs == rhs)
    }
}

internal struct Nested : Codable {
    var nested : String
    var sample : Sample
}

extension Nested : Equatable {
    static func ==(lhs: Nested, rhs: Nested) -> Bool {
        return lhs.nested == rhs.nested && lhs.sample == rhs.sample
    }

    static func !=(lhs: Nested, rhs: Nested) -> Bool {
        return !(lhs == rhs)
    }
}

internal struct NestStruct : Codable {
    struct Nest : Codable {
        var nest : String
    }

    var nest : String
    var nested : Nest
}

extension NestStruct : Equatable {
    static func ==(lhs: NestStruct, rhs: NestStruct) -> Bool {
        return lhs.nest == rhs.nest && lhs.nested == rhs.nested
    }
}

extension NestStruct.Nest : Equatable {
    static func ==(lhs: NestStruct.Nest, rhs: NestStruct.Nest) -> Bool {
        return lhs.nest == rhs.nest
    }
}

internal struct Unkeyed : Codable {
    var empty : Empty?
    var bool : Bool
    var uint : UInt
    var uint64 : UInt64
    var uint32 : UInt32
    var uint16 : UInt16
    var uint8 : UInt8
    var int : Int
    var int64 : Int64
    var int32 : Int32
    var int16 : Int16
    var int8 : Int8
    var float : Float
    var double : Double
    var string : String

    init(empty: Empty?, bool: Bool, uint: UInt, uint64: UInt64,
         uint32: UInt32, uint16: UInt16, uint8: UInt8,
         int: Int, int64: Int64, int32: Int32, int16: Int16,
         int8: Int8, float: Float, double: Double, string: String) {
        self.empty = empty
        self.bool = bool
        self.uint = uint
        self.uint64 = uint64
        self.uint32 = uint32
        self.uint16 = uint16
        self.uint8 = uint8
        self.int = int
        self.int64 = int64
        self.int32 = int32
        self.int16 = int16
        self.int8 = int8
        self.float = float
        self.double = double
        self.string = string
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()

        try container.encode(empty)
        try container.encode(uint)
        try container.encode(uint64)
        try container.encode(uint32)
        try container.encode(uint16)
        try container.encode(uint8)
        try container.encode(int)
        try container.encode(int64)
        try container.encode(int32)
        try container.encode(int16)
        try container.encode(int8)
        try container.encode(float)
        try container.encode(double)
        try container.encode(string)
    }

    init(from decoder : Decoder) throws {
        var container = try decoder.unkeyedContainer()

        self.empty = try container.decode(Empty?.self)
        self.bool = false
        self.uint = try container.decode(UInt.self)
        self.uint64 = try container.decode(UInt64.self)
        self.uint32 = try container.decode(UInt32.self)
        self.uint16 = try container.decode(UInt16.self)
        self.uint8 = try container.decode(UInt8.self)
        self.int = try container.decode(Int.self)
        self.int64 = try container.decode(Int64.self)
        self.int32 = try container.decode(Int32.self)
        self.int16 = try container.decode(Int16.self)
        self.int8 = try container.decode(Int8.self)
        self.float = try container.decode(Float.self)
        self.double = try container.decode(Double.self)
        self.string = try container.decode(String.self)
    }
}

extension Unkeyed : Equatable {
    static func ==(lhs: Unkeyed, rhs: Unkeyed) -> Bool {
        if lhs.float.isNaN || lhs.double.isNaN || rhs.float.isNaN || rhs.double.isNaN {
            return lhs.empty == rhs.empty && lhs.bool == rhs.bool && lhs.uint == rhs.uint
                && lhs.uint64 == rhs.uint64 && lhs.uint32 == rhs.uint32 && lhs.uint16 == rhs.uint16
                && lhs.uint8 == rhs.uint8 && lhs.int == rhs.int && lhs.int64 == rhs.int64 && lhs.int32 == rhs.int32
                && lhs.int16 == rhs.int16 && lhs.int8 == rhs.int8
                && lhs.string == rhs.string
        } else {
            return lhs.empty == rhs.empty && lhs.bool == rhs.bool && lhs.uint == rhs.uint
                && lhs.uint64 == rhs.uint64 && lhs.uint32 == rhs.uint32 && lhs.uint16 == rhs.uint16
                && lhs.uint8 == rhs.uint8 && lhs.int == rhs.int && lhs.int64 == rhs.int64 && lhs.int32 == rhs.int32
                && lhs.int16 == rhs.int16 && lhs.int8 == rhs.int8 && lhs.float == rhs.float && lhs.double == rhs.double
                && lhs.string == rhs.string
        }
    }

    static func !=(lhs: Unkeyed, rhs: Unkeyed) -> Bool {
        return !(lhs == rhs)
    }
}

internal struct Keyed : Codable {
    var empty : Empty?
    var bool : Bool
    var uint : UInt
    var uint64 : UInt64
    var uint32 : UInt32
    var uint16 : UInt16
    var uint8 : UInt8
    var int : Int
    var int64 : Int64
    var int32 : Int32
    var int16 : Int16
    var int8 : Int8
    var float : Float
    var double : Double
    var string : String
}
