import Foundation

open class MessagePackEncoder {

    public enum DateEncodingStrategy {
        case secondsSince1970
//        case secondAndNanoSecondSince1970
    }

    public enum UInt8ArrayEncodingStrategy {
        case binary
        case array
    }

    open var dateEncodingStrategy : DateEncodingStrategy = .secondsSince1970
    open var uint8ArrayEncodingStrategy : UInt8ArrayEncodingStrategy = .binary
    open var userInfo: [CodingUserInfoKey : Any] = [:]

    fileprivate struct _Options {
        let dateEncodingStrategy : DateEncodingStrategy
        let uint8ArrayEncodingStrategy : UInt8ArrayEncodingStrategy
        let userInfo : [CodingUserInfoKey : Any]
    }

    fileprivate var options : _Options {
        return _Options(dateEncodingStrategy: dateEncodingStrategy,
                        uint8ArrayEncodingStrategy: uint8ArrayEncodingStrategy,
                        userInfo: userInfo)
    }

    public init() {}

    open func encode<T : Encodable>(_ value : T) throws -> Data {
        do {
            let encoder = _MsgPackEncdoer(options: self.options)
            let topLevel = try encoder.box(value)
            let data = convertToData(topLevel)

            return data
        } catch let e {
            throw e
        }
    }

    private func convertToData(_ topLevel : Any) -> Data {
        var data = Data()

        if let dict = topLevel as? NSMutableDictionary {
            let count = dict.count
            if count <= 15 {
                let header = UInt8(0b10000000 | count)
                data.append(header)
            } else if count <= (2 << 15) - 1 {
                let header = [0xde, UInt8(truncatingIfNeeded: count >> 8), UInt8(truncatingIfNeeded: count)]
                data.append(contentsOf: header)
            } else if count <= (2 << 31) - 1 {
                let header = [0xdf,
                              UInt8(truncatingIfNeeded: count >> 24), UInt8(truncatingIfNeeded: count >> 16),
                              UInt8(truncatingIfNeeded: count >> 8), UInt8(truncatingIfNeeded: count)]
                data.append(contentsOf: header)
            }
            for (key, value) in dict {
                if let key = key as? Data {
                    data.append(contentsOf: key)
                } else {
                    data.append(contentsOf: convertToData(key))
                }
                if let value = value as? Data {
                    data.append(contentsOf: value)
                } else {
                    data.append(contentsOf: convertToData(value))
                }
            }
        } else if let array = topLevel as? NSArray {
            let count = array.count
            if count <= 15 {
                let header = UInt8(0b10010000 | count)
                data.append(header)
            } else if count <= (2 << 15) - 1 {
                let header = [0xdc, UInt8(truncatingIfNeeded: count >> 8), UInt8(truncatingIfNeeded: count)]
                data.append(contentsOf: header)
            } else if count <= (2 << 31) - 1 {
                let header = [0xdd,
                              UInt8(truncatingIfNeeded: count >> 24), UInt8(truncatingIfNeeded: count >> 16),
                              UInt8(truncatingIfNeeded: count >> 8), UInt8(truncatingIfNeeded: count)]
                data.append(contentsOf: header)
            }
            for value in array {
                if let value = value as? Data {
                    data.append(contentsOf: value)
                } else {
                    data.append(contentsOf: convertToData(value))
                }
            }
        } else {
            guard let container = topLevel as? Data else {
                fatalError()
            }

            data = container
        }

        return data
    }
}

fileprivate class _MsgPackEncdoer : Encoder {
    fileprivate let options : MessagePackEncoder._Options
    fileprivate var storage : _MsgPackEncodingStorage
    public var codingPath: [CodingKey]

    public var userInfo: [CodingUserInfoKey : Any] {
        return self.options.userInfo
    }

    init(options: MessagePackEncoder._Options, codingPath: [CodingKey] = []) {
        self.options = options
        self.codingPath = codingPath
        self.storage = _MsgPackEncodingStorage()
    }

    fileprivate var canEncodeNewValue: Bool {
        return self.storage.count == self.codingPath.count
    }

    func container<Key>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> where Key : CodingKey {
        let topContainer : NSMutableDictionary
        if self.canEncodeNewValue {
            topContainer = self.storage.pushKeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? NSMutableDictionary else {
                preconditionFailure("Attempt to push new keyed encoding container when already previously encoded at this path.")
            }
            topContainer = container
        }

        let container = _MsgPackKeyedEncodingContainer<Key>(referencing: self, codingPath: self.codingPath, wrapping: topContainer)

        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        let topContainer : NSMutableArray
        if self.canEncodeNewValue {
            topContainer = self.storage.pushUnkeyedContainer()
        } else {
            guard let container = self.storage.containers.last as? NSMutableArray else {
                preconditionFailure("Attempt to push new unkeyed encoding container when already previously encoded at this path.")
            }
            topContainer = container
        }

        return _MsgPackUnkeyedEncodingContainer(referencing: self, codingPath: self.codingPath, wrapping: topContainer)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return self
    }
}

fileprivate struct _MsgPackEncodingStorage {
    private(set) var containers : [NSObject] = []

    init() {}

    fileprivate var count: Int {
        return self.containers.count
    }

    fileprivate mutating func pushKeyedContainer() -> NSMutableDictionary {
        let dictionary = NSMutableDictionary()
        self.containers.append(dictionary)
        return dictionary
    }

    fileprivate mutating func pushUnkeyedContainer() -> NSMutableArray {
        let array = NSMutableArray()
        self.containers.append(array)
        return array
    }

    fileprivate mutating func push(container: NSObject) {
        self.containers.append(container)
    }

    fileprivate mutating func popContainer() -> NSObject {
        precondition(self.containers.count > 0, "Empty container stack.")
        return self.containers.popLast()!
    }
}

fileprivate struct _MsgPackKeyedEncodingContainer<K : CodingKey> : KeyedEncodingContainerProtocol {
    typealias Key = K
    private let encoder : _MsgPackEncdoer
    private let container : NSMutableDictionary
    private(set) public var codingPath: [CodingKey]


    fileprivate init(referencing encoder: _MsgPackEncdoer, codingPath: [CodingKey], wrapping container : NSMutableDictionary) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }

    mutating func encodeNil(forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = [0xc0]
    }

    mutating func encode(_ value: Bool, forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func encode(_ value: Int, forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func encode(_ value: Int8, forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func encode(_ value: Int16, forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func encode(_ value: Int32, forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func encode(_ value: Int64, forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func encode(_ value: UInt, forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func encode(_ value: UInt8, forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func encode(_ value: UInt16, forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func encode(_ value: UInt32, forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func encode(_ value: UInt64, forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func encode(_ value: Float, forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func encode(_ value: Double, forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func encode(_ value: String, forKey key: K) throws {
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func encode<T>(_ value: T, forKey key: K) throws where T : Encodable {
        self.encoder.codingPath.append(key)
        defer {
            self.encoder.codingPath.removeLast()
        }
        try container[encoder.box(key.stringValue)] = encoder.box(value)
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type, forKey key: K) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let dictionary = NSMutableDictionary()
        try! self.container[encoder.box(key.stringValue)] = dictionary

        self.codingPath.append(key)
        defer {
            self.codingPath.removeLast()
        }

        let container = _MsgPackKeyedEncodingContainer<NestedKey>(referencing: self.encoder, codingPath: self.codingPath, wrapping: dictionary)

        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: K) -> UnkeyedEncodingContainer {
        let array = NSMutableArray()
        try! self.container[encoder.box(key.stringValue)] = array

        self.codingPath.append(key)
        defer {
            self.codingPath.removeLast()
        }

        return _MsgPackUnkeyedEncodingContainer(referencing: self.encoder, codingPath: self.codingPath, wrapping: array)
    }

    mutating func superEncoder() -> Encoder {
        return _MsgPackReferencingEncoder(referencing: self.encoder, at: _MsgPackKey.super, wrapping: self.container)
    }

    mutating func superEncoder(forKey key: K) -> Encoder {
        return _MsgPackReferencingEncoder(referencing: self.encoder, at: key, wrapping: self.container)
    }
}


fileprivate struct _MsgPackUnkeyedEncodingContainer : UnkeyedEncodingContainer {
    private let encoder : _MsgPackEncdoer
    private let container : NSMutableArray
    private(set) public var codingPath: [CodingKey]

    public var count: Int {
        return self.container.count
    }

    fileprivate init(referencing encoder : _MsgPackEncdoer, codingPath : [CodingKey], wrapping container : NSMutableArray) {
        self.encoder = encoder
        self.codingPath = codingPath
        self.container = container
    }
    

    mutating func encode(_ value: Int) throws {
       self.container.add(self.encoder.box(value))
    }

    mutating func encode(_ value: Int8) throws {
       self.container.add(self.encoder.box(value))
    }

    mutating func encode(_ value: Int16) throws {
       self.container.add(self.encoder.box(value))
    }

    mutating func encode(_ value: Int32) throws {
       self.container.add(self.encoder.box(value))
    }

    mutating func encode(_ value: Int64) throws {
       self.container.add(self.encoder.box(value))
    }

    mutating func encode(_ value: UInt) throws {
       self.container.add(self.encoder.box(value))
    }

    mutating func encode(_ value: UInt8) throws {
       self.container.add(self.encoder.box(value))
    }

    mutating func encode(_ value: UInt16) throws {
       self.container.add(self.encoder.box(value))
    }

    mutating func encode(_ value: UInt32) throws {
       self.container.add(self.encoder.box(value))
    }

    mutating func encode(_ value: UInt64) throws {
       self.container.add(self.encoder.box(value))
    }

    mutating func encode(_ value: Float) throws {
       self.container.add(self.encoder.box(value))
    }

    mutating func encode(_ value: Double) throws {
       self.container.add(self.encoder.box(value))
    }

    mutating func encode(_ value: String) throws {
       try self.container.add(self.encoder.box(value))
    }

    mutating func encode<T>(_ value: T) throws where T : Encodable {
        self.encoder.codingPath.append(_MsgPackKey(index: self.count))
        defer {
            self.encoder.codingPath.removeLast()
        }
        try self.container.add(self.encoder.box(value))
    }

    mutating func encode(_ value: Bool) throws {
       self.container.add(self.encoder.box(value))
    }

    mutating func encodeNil() throws {
        self.container.add([0xc0])
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        self.codingPath.append(_MsgPackKey(index: self.count))
        defer {
            self.codingPath.removeLast()
        }

        let dictionary =  NSMutableDictionary()
        let container = _MsgPackKeyedEncodingContainer<NestedKey>(referencing: self.encoder, codingPath: self.codingPath, wrapping: dictionary)

        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        self.codingPath.append(_MsgPackKey(index: self.count))
        defer {
            self.codingPath.removeLast()
        }

        let array = NSMutableArray()

        return _MsgPackUnkeyedEncodingContainer(referencing: self.encoder, codingPath: self.codingPath, wrapping: array)
    }

    mutating func superEncoder() -> Encoder {
        return _MsgPackReferencingEncoder(referencing: self.encoder, at: self.container.count, wrapping: self.container)
    }


}

extension _MsgPackEncdoer : SingleValueEncodingContainer {
    fileprivate func assertCanEncodeNewValue() {
        precondition(self.canEncodeNewValue, "Attempt to encode value through single value container when previously value already encoded.")
    }

    public func encodeNil() throws {
        assertCanEncodeNewValue()
        self.storage.push(container: Data([0xc0]) as NSObject)
    }

    public func encode(_ value: Bool) throws {
        assertCanEncodeNewValue()
        let result = self.box(value)
        self.storage.push(container: result as NSObject)
    }

    public func encode(_ value: Int) throws {
        assertCanEncodeNewValue()
        let result = self.box(value)
        self.storage.push(container: result as NSObject)
    }

    public func encode(_ value: Int8) throws {
        assertCanEncodeNewValue()
        let result = self.box(value)
        self.storage.push(container: result as NSObject)
    }

    public func encode(_ value: Int16) throws {
        assertCanEncodeNewValue()
        let result = self.box(value)
        self.storage.push(container: result as NSObject)
    }

    public func encode(_ value: Int32) throws {
        assertCanEncodeNewValue()
        let result = self.box(value)
        self.storage.push(container: result as NSObject)
    }

    public func encode(_ value: Int64) throws {
        assertCanEncodeNewValue()
        let result = self.box(value)
        self.storage.push(container: result as NSObject)
    }

    public func encode(_ value: UInt) throws {
        assertCanEncodeNewValue()
        let result = self.box(value)
        self.storage.push(container: result as NSObject)
    }

    public func encode(_ value: UInt8) throws {
        assertCanEncodeNewValue()
        let result = self.box(value)
        self.storage.push(container: result as NSObject)
    }

    public func encode(_ value: UInt16) throws {
        assertCanEncodeNewValue()
        let result = self.box(value)
        self.storage.push(container: result as NSObject)
    }

    public func encode(_ value: UInt32) throws {
        assertCanEncodeNewValue()
        let result = self.box(value)
        self.storage.push(container: result as NSObject)
    }

    public func encode(_ value: UInt64) throws {
        assertCanEncodeNewValue()
        let result = self.box(value)
        self.storage.push(container: result as NSObject)
    }

    public func encode(_ value: Float) throws {
        assertCanEncodeNewValue()
        let result = self.box(value)
        self.storage.push(container: result as NSObject)
    }

    public func encode(_ value: Double) throws {
        assertCanEncodeNewValue()
        let result = self.box(value)
        self.storage.push(container: result as NSObject)
    }

    public func encode(_ value: String) throws {
        assertCanEncodeNewValue()
        let result = try self.box(value)
        self.storage.push(container: result as NSObject)
    }

    public func encode<T>(_ value: T) throws where T : Encodable {
        assertCanEncodeNewValue()
        try self.storage.push(container: self.box(value))
    }
}

extension _MsgPackEncdoer {
    fileprivate func box(_ value : Bool) -> Data { return value ? Data([0xc3]) : Data([0xc2]) }
    fileprivate func box(_ value: UInt) -> Data { return MemoryLayout<UInt>.size == 4 ? box((UInt32(value))) : box((UInt64(value)))}
    fileprivate func box(_ value : UInt8) -> Data {
        switch value {
        case 0x00...0x7f:
            return Data([value])
        default:
            return Data([0xcc, value])
        }
    }
    fileprivate func box(_ value : UInt16) -> Data {
        if value <= UInt8.max {
            return self.box(UInt8(value))
        }
        return Data([0xcd, UInt8(value >> 8 & 0xff), UInt8(value & 0xff)])
    }
    fileprivate func box(_ value : UInt32) -> Data {
        if value <= UInt16.max {
            return self.box(UInt16(value))
        }
        return Data([0xce, UInt8(value >> 24 & 0xff), UInt8(value >> 16 & 0xff), UInt8(value >> 8 & 0xff), UInt8(value & 0xff)])
    }
    fileprivate func box(_ value : UInt64) -> Data {
        if value <= UInt32.max {
            return self.box(UInt32(value))
        }

        return Data([0xcf,
                     UInt8(truncatingIfNeeded: value >> 56), UInt8(truncatingIfNeeded: value >> 48),
                     UInt8(truncatingIfNeeded: value >> 40), UInt8(truncatingIfNeeded: value >> 32),
                     UInt8(truncatingIfNeeded: value >> 24), UInt8(truncatingIfNeeded: value >> 16),
                     UInt8(truncatingIfNeeded: value >> 8), UInt8(truncatingIfNeeded: value)])
    }

    fileprivate func box(_ value: Int) -> Data {
        return MemoryLayout<Int>.size == 4 ? box((Int32(value))) : box((Int64(value)))
    }
    fileprivate func box(_ value : Int8) -> Data {
        let value = UInt8(truncatingIfNeeded: value)
        switch value {
        case 0x00...0x7f:
            fallthrough
        case 0xe0...0xff:
             return Data([value])
        default:
            return Data([0xd0, value])
        }
    }
    fileprivate func box(_ value : Int16) -> Data {
        if Int8.min <= value && value <= Int8.max {
            return self.box(Int8(value))
        }
        return Data([0xd1, UInt8(value >> 8 & 0xff), UInt8(value & 0xff)])
    }
    fileprivate func box(_ value : Int32) -> Data {
        if Int16.min <= value && value <= Int16.max {
            return self.box(Int16(value))
        }
        return Data([0xd2, UInt8(value >> 24 & 0xff), UInt8(value >> 16 & 0xff), UInt8(value >> 8 & 0xff), UInt8(value & 0xff)])
    }
    fileprivate func box(_ value : Int64) -> Data {
        if Int32.min <= value && value <= Int32.max {
            return self.box(Int32(value))
        }
        return Data([0xd3,
                     UInt8(truncatingIfNeeded: value >> 56), UInt8(truncatingIfNeeded: value >> 48),
                     UInt8(truncatingIfNeeded: value >> 40), UInt8(truncatingIfNeeded: value >> 32),
                     UInt8(truncatingIfNeeded: value >> 24), UInt8(truncatingIfNeeded: value >> 16),
                     UInt8(truncatingIfNeeded: value >> 8), UInt8(truncatingIfNeeded: value)])
    }

    fileprivate func box(_ value : Float) -> Data {
        let bitPattern = value.bitPattern

        return Data([0xca, UInt8(bitPattern >> 24 & 0xff), UInt8(bitPattern >> 16 & 0xff), UInt8(bitPattern >> 8 & 0xff), UInt8(bitPattern & 0xff)])
    }

    fileprivate func box(_ value : Double) -> Data {
        let bitPattern = value.bitPattern

        return Data([0xcb,
                     UInt8(truncatingIfNeeded: bitPattern >> 56), UInt8(truncatingIfNeeded: bitPattern >> 48),
                     UInt8(truncatingIfNeeded: bitPattern >> 40), UInt8(truncatingIfNeeded: bitPattern >> 32),
                     UInt8(truncatingIfNeeded: bitPattern >> 24), UInt8(truncatingIfNeeded: bitPattern >> 16),
                     UInt8(truncatingIfNeeded: bitPattern >> 8), UInt8(truncatingIfNeeded: bitPattern)])
    }

    fileprivate func box(_ value: String) throws -> Data {
        var container : [UInt8] = []
        let count = value.utf8.count

        switch count {
        case 0x00...0x1f:
            container += [UInt8(0b10100000 | count)]
            let utf8 = value.utf8.map() { $0 }
            container += utf8
        case 0x20...0xff:
            container += [0xd9, UInt8(count)]
            let utf8 = value.utf8.map() { $0 }
            container += utf8
        case 0x100...0xffff:
            container += [0xda, UInt8(count >> 8 & 0xff), UInt8(count & 0xff)]
            let utf8 = value.utf8.map() { $0 }
            container += utf8
        case 0x10000...0xffff_ffff:
            container += [0xdb, UInt8(count >> 24 & 0xff), UInt8(count >> 16 & 0xff), UInt8(count >> 8 & 0xff), UInt8(count & 0xff)]
            let utf8 = value.utf8.map() { $0 }
            container += utf8
        default:
            throw EncodingError.invalidValue(value,
                                             EncodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Length Error"))
        }

        return Data(container)
    }

    fileprivate func box(_ value : Data) throws -> Data {
        var data = Data()
        let count = value.count
        switch count {
        case 0x00...0xff:
            data += [0xc4, UInt8(count)]
        case 0x100...0xffff:
            data += [0xc5, UInt8(count >> 8), UInt8(count & 0xff)]
        case 0x10000...0xffff_ffff:
            data += [0xc6, UInt8(truncatingIfNeeded: count >> 24), UInt8(truncatingIfNeeded: count >> 16), UInt8(truncatingIfNeeded: count >> 8), UInt8(truncatingIfNeeded: count)]
        default:
            throw EncodingError.invalidValue(value,
                                             EncodingError.Context(codingPath: self.codingPath,
                                                                    debugDescription: "Length Error"))
        }

        data += value

        return data
    }

    fileprivate func box(_ value : [UInt8]) throws -> Data {
        var data : [UInt8] = []
        let count = value.count
        switch count {
        case 0x00...0xff:
            data += [0xc4, UInt8(truncatingIfNeeded: count)]
        case 0x100...0xffff:
            data += [0xc5, UInt8(truncatingIfNeeded: count >> 8), UInt8(truncatingIfNeeded: count & 0xff)]
        case 0x10000...0xffff_ffff:
            data += [0xc6,
                     UInt8(truncatingIfNeeded: count >> 24), UInt8(truncatingIfNeeded: count >> 16),
                     UInt8(truncatingIfNeeded: count >> 8), UInt8(truncatingIfNeeded: count)]
        default:
            throw EncodingError.invalidValue(value,
                                             EncodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Length Error"))
        }

        data += value

        return Data(data)
    }

    fileprivate func box(_ value : Date) throws -> Data {
        guard let seconds = UInt32(exactly: value.timeIntervalSince1970) else {
            return Data([0xc0])
        }

        return Data([0xd6, 0xff,
                     UInt8(truncatingIfNeeded: seconds >> 24), UInt8(truncatingIfNeeded: seconds >> 16),
                     UInt8(truncatingIfNeeded: seconds >> 8), UInt8(truncatingIfNeeded: seconds)])
    }

    fileprivate func box<T : Encodable>(_ value : T) throws -> NSObject {
        return try box_(value) ?? NSMutableDictionary()
    }

    fileprivate func box_<T : Encodable>(_ value : T) throws -> NSObject? {
        if T.self == Data.self || T.self == NSData.self {
            let result : Data = try self.box((value as! Data))
            return result as NSObject
        } else if T.self == Date.self || T.self == NSDate.self {
            let result : Data = try self.box((value as! Date))
            return result as NSObject
        } else if T.self == [UInt8].self && self.options.uint8ArrayEncodingStrategy == .binary {
            let result : Data = try self.box(value as! [UInt8])
            return result as NSObject
        }

        let depth = self.storage.count
        try value.encode(to: self)
        guard self.storage.count > depth else {
            return nil
        }
        return self.storage.popContainer()
    }
}

fileprivate class _MsgPackReferencingEncoder : _MsgPackEncdoer {
    private enum Reference {
        case array(NSMutableArray, Int)
        case dictionary(NSMutableDictionary, String)
    }

    fileprivate let encoder : _MsgPackEncdoer
    private let reference : Reference

    fileprivate init(referencing encoder : _MsgPackEncdoer, at index : Int, wrapping array : NSMutableArray) {
        self.encoder = encoder
        self.reference = .array(array, index)
        super.init(options: encoder.options, codingPath: encoder.codingPath)

        self.codingPath.append(_MsgPackKey(index: index))
    }

    fileprivate init(referencing encoder : _MsgPackEncdoer, at key : CodingKey, wrapping dictionary : NSMutableDictionary) {
        self.encoder = encoder
        self.reference = .dictionary(dictionary, key.stringValue)
        super.init(options: encoder.options, codingPath: encoder.codingPath)

        self.codingPath.append(key)
    }

    fileprivate override var canEncodeNewValue: Bool {
        return self.storage.count == self.codingPath.count - self.encoder.codingPath.count - 1
    }

    deinit {
        let value: Any
        switch self.storage.count {
        case 0: value = NSMutableDictionary()
        case 1: value = self.storage.popContainer()
        default: fatalError("Referencing encoder deallocated with multiple containers on stack.")
        }

        switch self.reference {
        case .array(let array, let index):
            array.insert(value, at: index)

        case .dictionary(let dictionary, let key):
            // TODO: Support key other type
            do {
                try dictionary[self.box(key)] = value
            } catch let e {
                fatalError(e.localizedDescription)
            }
        }
    }
}

fileprivate struct _MsgPackKey : CodingKey {
    public var stringValue: String
    public var intValue: Int?

    public init?(stringValue: String) {
        self.stringValue = stringValue
        self.intValue = nil
    }

    public init?(intValue: Int) {
        self.stringValue = "\(intValue)"
        self.intValue = intValue
    }

    public init(index: Int) {
        self.stringValue = "Index \(index)"
        self.intValue = index
    }

    fileprivate static let `super` = _MsgPackKey(stringValue: "super")!
}
