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

open class MessagePackDecoder {

    open var userInfo: [CodingUserInfoKey : Any] = [:]

    fileprivate struct _Options {
        let userInfo : [CodingUserInfoKey : Any]
    }

    fileprivate var options : _Options {
        return _Options(userInfo: userInfo)
    }

    public init() {}

    open func decode<T : Decodable>(_ type : T.Type, from data : Data) throws -> T? {
        let container = _MsgPackDecodingContainer(data: data)
        let decoder = _MsgPackDecoder(options: options, container: container)

        guard let value = try decoder.unbox(as: T.self) else {
            return nil
        }

        return value
    }

}

fileprivate class _MsgPackDecoder : Decoder {
    fileprivate let options : MessagePackDecoder._Options
    fileprivate var storage : _MsgPackDecodingContainer
    public var codingPath: [CodingKey]

    var userInfo: [CodingUserInfoKey : Any]

    fileprivate init(options: MessagePackDecoder._Options, container : _MsgPackDecodingContainer, codingPath : [CodingKey] = []) {
        self.options = options
        self.storage = container
        self.codingPath = codingPath
        self.userInfo = options.userInfo
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = _MsgPackKeyedDecodingContainer<Key>(decoder: self, codingPath: self.codingPath)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let header = Int(self.storage.popFirst(1)[0])
        let count : Int
        switch header {
        case 0x90...0x9f:
            count = header ^ 0x90
        case 0xdc:
            count = Int(unpack(self.storage.popFirst(2), 2))
        case 0xdd:
            count = Int(unpack(self.storage.popFirst(4), 4))
        default:
            throw DecodingError.typeMismatch(Decoder.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Array type."))
        }
        return _MsgPackUnkeyedDecodingContainer(decoder: self, count: count)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        return self
    }
}

fileprivate class _MsgPackDecodingContainer {

    fileprivate var data : Data

    public var count : Int {
        return data.count
    }

    fileprivate init(data : Data) {
        self.data = data
    }

    public func popFirst(_ n : Int) -> Data {
        var result = Data(capacity: n)

        for _ in 0..<n {
            if let first = self.data.popFirst() {
                result.append(first)
            }
        }

        return result
    }
}

fileprivate struct _MsgPackKeyedDecodingContainer<K : CodingKey> : KeyedDecodingContainerProtocol {

    typealias Key = K

    fileprivate let decoder : _MsgPackDecoder
    var codingPath: [CodingKey]


    var allKeys: [Key] {
        return []
    }

    fileprivate init(decoder : _MsgPackDecoder, codingPath : [CodingKey] = []) {
        self.decoder = decoder
        self.codingPath = codingPath
    }

    func contains(_ key: Key) -> Bool {
        fatalError()
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        fatalError()
    }

    func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
        fatalError()
    }

    func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
        fatalError()
    }

    func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
        fatalError()
    }

    func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
        fatalError()
    }

    func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
        fatalError()
    }

    func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
        fatalError()
    }

    func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
        fatalError()
    }

    func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
        fatalError()
    }

    func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
        fatalError()
    }

    func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
        fatalError()
    }

    func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
        fatalError()
    }

    func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
        fatalError()
    }

    func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
        fatalError()
    }

    func decode(_ type: String.Type, forKey key: Key) throws -> String {
        fatalError()
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        fatalError()
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func superDecoder() throws -> Decoder {
        fatalError()
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        fatalError()
    }
}

fileprivate struct _MsgPackUnkeyedDecodingContainer : UnkeyedDecodingContainer {
    private let decoder : _MsgPackDecoder
    private(set) var codingPath: [CodingKey]
    private(set) var currentIndex: Int

    private(set) public var count: Int?

    public var isAtEnd: Bool {
        return decoder.storage.count == 0
    }


    fileprivate init(decoder : _MsgPackDecoder, count: Int) {
        self.decoder = decoder
        self.codingPath = decoder.codingPath
        self.currentIndex = 0
        self.count = count
    }

    mutating func decodeNil() throws -> Bool {
        return self.decoder.storage.data.first == 0xc0
    }

    mutating func decode(_ type: Bool.Type) throws -> Bool {
        return try self.decoder.unbox(as: type)!
    }

    mutating func decode(_ type: Int.Type) throws -> Int {
        return try self.decoder.unbox(as: type)!
    }

    mutating func decode(_ type: Int8.Type) throws -> Int8 {
        return try self.decoder.unbox(as: type)!
    }

    mutating func decode(_ type: Int16.Type) throws -> Int16 {
        return try self.decoder.unbox(as: type)!
    }

    mutating func decode(_ type: Int32.Type) throws -> Int32 {
        return try self.decoder.unbox(as: type)!
    }

    mutating func decode(_ type: Int64.Type) throws -> Int64 {
        return try self.decoder.unbox(as: type)!
    }

    mutating func decode(_ type: UInt.Type) throws -> UInt {
        return try self.decoder.unbox(as: type)!
    }

    mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try self.decoder.unbox(as: type)!
    }

    mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try self.decoder.unbox(as: type)!
    }

    mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try self.decoder.unbox(as: type)!
    }

    mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try self.decoder.unbox(as: type)!
    }

    mutating func decode(_ type: Float.Type) throws -> Float {
        return try self.decoder.unbox(as: type)!
    }

    mutating func decode(_ type: Double.Type) throws -> Double {
        return try self.decoder.unbox(as: type)!
    }

    mutating func decode(_ type: String.Type) throws -> String {
        return try self.decoder.unbox(as: type)!
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try self.decoder.unbox(as: type)!
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError()
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        let header = Int(self.decoder.storage.popFirst(1)[0])
        let count : Int
        switch header {
        case 0x90...0x9f:
            count = header ^ 0x90
        case 0xdc:
            count = Int(unpack(self.decoder.storage.popFirst(2), 2))
        case 0xdd:
            count = Int(unpack(self.decoder.storage.popFirst(4), 4))
        default:
            throw DecodingError.typeMismatch(UnkeyedDecodingContainer.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Array type."))
        }
        return _MsgPackUnkeyedDecodingContainer(decoder: self.decoder, count: count)
    }

    mutating func superDecoder() throws -> Decoder {
        return _MsgPackDecoder(options: self.decoder.options, container: self.decoder.storage)
    }


}

extension _MsgPackDecoder : SingleValueDecodingContainer {
    func decodeNil() -> Bool {
        return self.storage.data.first == 0xc0
    }

    func decode(_ type: Bool.Type) throws -> Bool {
        return try self.unbox(as: type)!
    }

    func decode(_ type: Int.Type) throws -> Int {
        return try self.unbox(as: type)!
    }

    func decode(_ type: Int8.Type) throws -> Int8 {
        return try self.unbox(as: type)!
    }

    func decode(_ type: Int16.Type) throws -> Int16 {
        return try self.unbox(as: type)!
    }

    func decode(_ type: Int32.Type) throws -> Int32 {
        return try self.unbox(as: type)!
    }

    func decode(_ type: Int64.Type) throws -> Int64 {
        return try self.unbox(as: type)!
    }

    func decode(_ type: UInt.Type) throws -> UInt {
        return try self.unbox(as: type)!
    }

    func decode(_ type: UInt8.Type) throws -> UInt8 {
        return try self.unbox(as: type)!
    }

    func decode(_ type: UInt16.Type) throws -> UInt16 {
        return try self.unbox(as: type)!
    }

    func decode(_ type: UInt32.Type) throws -> UInt32 {
        return try self.unbox(as: type)!
    }

    func decode(_ type: UInt64.Type) throws -> UInt64 {
        return try self.unbox(as: type)!
    }

    func decode(_ type: Float.Type) throws -> Float {
        return try self.unbox(as: type)!
    }

    func decode(_ type: Double.Type) throws -> Double {
        return try self.unbox(as: type)!
    }

    func decode(_ type: String.Type) throws -> String {
        return try self.unbox(as: type)!
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        return try self.unbox(as: type)!
    }
}

extension _MsgPackDecoder {
    fileprivate func unbox(as type: Bool.Type) throws -> Bool? {
        guard let data = self.storage.data.popFirst() else {
            fatalError()
        }

        guard 0xc0 != data else {
            return nil
        }

        switch data {
        case 0xc2:
            return false
        case 0xc3:
            return true
        default:
            throw DecodingError.typeMismatch(Bool.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Bool type"))
        }
    }

    fileprivate func unbox(as type: Int.Type) throws -> Int? {
        guard let first = self.storage.data.first, first != 0xc0 else {
            return nil
        }

        switch first {
        case 0x00...0x7f:
            self.storage.data.removeFirst()
            return Int(first)
        case 0xe0...0xff:
            self.storage.data.removeFirst()
            return Int(Int8(truncatingIfNeeded: first))
        case 0xd0:
            return try Int(unbox(as: Int8.self)!)
        case 0xd1:
            return try Int(unbox(as: Int16.self)!)
        case 0xd2:
            return try Int(unbox(as: Int32.self)!)
        case 0xd3:
            return try MemoryLayout<Int>.size == 4 ? nil : Int(unbox(as: Int64.self)!)
        default:
            throw DecodingError.typeMismatch(Int.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Int type"))
        }
    }

    fileprivate func unbox(as type: Int8.Type) throws -> Int8? {
        guard let header = self.storage.data.popFirst(), header != 0xc0 else {
            return nil
        }

        guard header == 0xd0, let value = self.storage.data.popFirst() else {
            throw DecodingError.typeMismatch(Int8.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Int8 type"))
        }
        return Int8(truncatingIfNeeded: value)
    }

    fileprivate func unbox(as type: Int16.Type) throws -> Int16? {
        guard let header = self.storage.data.popFirst(), header == 0xd1 else {
            throw DecodingError.typeMismatch(Int16.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Int16 type"))
        }

        let pattern = UInt16(unpack(self.storage.popFirst(2), 2))

        return Int16(bitPattern: pattern)
    }

    fileprivate func unbox(as type: Int32.Type) throws -> Int32? {
        guard let header = self.storage.data.popFirst() else {
            fatalError()
        }
        guard header == 0xd2 else {
            throw DecodingError.typeMismatch(Int32.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Int32 type"))
        }

        let pattern = UInt32(unpack(self.storage.popFirst(4), 4))

        return Int32(bitPattern: pattern)
    }

    fileprivate func unbox(as type: Int64.Type) throws -> Int64? {
        guard let header = self.storage.data.popFirst() else {
            fatalError()
        }
        guard header == 0xd3 else {
            throw DecodingError.typeMismatch(Int32.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Int32 type"))
        }

        let pattern = unpack(self.storage.popFirst(8), 8)

        return Int64(bitPattern: pattern)
    }

    fileprivate func unbox(as type: UInt.Type) throws -> UInt? {
        guard let first = self.storage.data.first, first != 0xc0 else {
            return nil
        }

        switch first {
        case 0x00...0x7f:
            self.storage.data.removeFirst()
            return UInt(first)
        case 0xd0:
            return try UInt(unbox(as: UInt8.self)!)
        case 0xd1:
            return try UInt(unbox(as: UInt16.self)!)
        case 0xd2:
            return try UInt(unbox(as: UInt32.self)!)
        case 0xd3:
            return try MemoryLayout<UInt>.size == 4 ? nil : UInt(unbox(as: UInt64.self)!)
        default:
            throw DecodingError.typeMismatch(Int.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Int type"))
        }
    }

    fileprivate func unbox(as type: UInt8.Type) throws -> UInt8? {
        guard let header = self.storage.data.popFirst(), header != 0xc0 else {
            return nil
        }

        guard header == 0xcc, let value = self.storage.data.popFirst() else {
            throw DecodingError.typeMismatch(UInt8.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a UInt8 type"))
        }
        return value
    }

    fileprivate func unbox(as type: UInt16.Type) throws -> UInt16? {
        guard let header = self.storage.data.popFirst(), header == 0xcd else {
            throw DecodingError.typeMismatch(Int16.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Int16 type"))
        }

        return UInt16(unpack(self.storage.popFirst(2), 2))
    }

    fileprivate func unbox(as type: UInt32.Type) throws -> UInt32? {
        guard let header = self.storage.data.popFirst() else {
            fatalError()
        }
        guard header == 0xce else {
            throw DecodingError.typeMismatch(Int32.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Int32 type"))
        }

        return UInt32(unpack(self.storage.popFirst(4), 4))
    }

    fileprivate func unbox(as type: UInt64.Type) throws -> UInt64? {
        guard let header = self.storage.data.popFirst() else {
            fatalError()
        }
        guard header == 0xcf else {
            throw DecodingError.typeMismatch(Int32.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Int32 type"))
        }

        return unpack(self.storage.popFirst(8), 8)
    }

    fileprivate func unbox(as type: Float.Type) throws -> Float? {
        guard let header = self.storage.data.popFirst() else {
            fatalError()
        }

        if header == 0xc0 {
            return nil
        }

        guard header == 0xca else {
            throw DecodingError.typeMismatch(Int32.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Float type"))
        }

        let pattern = UInt32(unpack(self.storage.popFirst(4), 4))

        return Float(bitPattern: pattern)
    }

    fileprivate func unbox(as type: Double.Type) throws -> Double? {
        guard let header = self.storage.data.popFirst() else {
            fatalError()
        }

        if header == 0xc0 {
            return nil
        }/* else if header == 0xca {
            return Double(unbox(as: Float.Type))
        }*/

        guard header == 0xcb else {
            throw DecodingError.typeMismatch(Int32.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Float type"))
        }

        let pattern = unpack(self.storage.popFirst(8), 8)

        return Double(bitPattern: pattern)
    }

    fileprivate func unbox(as type: String.Type) throws -> String? {
        guard let header = self.storage.data.popFirst() else {
            fatalError()
        }

        if header == 0xc0 {
            return nil
        }

        switch header {
        case 0b101_00000...0b101_11111:
            let count = header ^ 0b101_00000
            let data = self.storage.popFirst(Int(count))
            return String(data: data, encoding: .utf8)
        case 0xd9:
            let count = self.storage.data.removeFirst()
            let data = self.storage.popFirst(Int(count))
            return String(data: data, encoding: .utf8)
        case 0xda:
            let countData = self.storage.popFirst(2)
            let count = Int(countData[0]) << 8 | Int(countData[1])
            let data = self.storage.popFirst(count)
            return String(data: data, encoding: .utf8)
        case 0xdb:
            let count : Int = Int(unpack(self.storage.popFirst(4), 4))

            let data = self.storage.popFirst(count)
            return String(data: data, encoding: .utf8)
        default:
            throw DecodingError.typeMismatch(String.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a String type"))
        }
    }

    fileprivate func unbox(as type: Data.Type) throws -> Data? {
        guard let header = self.storage.data.popFirst() else {
            fatalError()
        }

        if header == 0xc0 {
            return nil
        }

        switch header {
        case 0xc4:
            let count = self.storage.data.removeFirst()

            return self.storage.popFirst(Int(count))
        case 0xc5:
            let count = Int(unpack(self.storage.popFirst(2), 2))

            return self.storage.popFirst(count)
        case 0xc6:
            let count = Int(unpack(self.storage.popFirst(4), 4))

            return self.storage.popFirst(count)
        default:
            throw DecodingError.typeMismatch(Data.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Data type"))
        }
    }

    fileprivate func unbox(as type: Date.Type) throws -> Date? {
        guard let header = self.storage.data.popFirst() else {
            fatalError()
        }

        if header == 0xc0 {
            return nil
        }

        guard header == 0xd6, let ext = self.storage.data.popFirst(), ext == 0xff else {
            throw DecodingError.typeMismatch(Data.self,
                                             DecodingError.Context(codingPath: self.codingPath,
                                                                   debugDescription: "Not a Data type"))
        }

        let count = unpack(self.storage.popFirst(4), 4)

        return Date(timeIntervalSince1970: TimeInterval(count))
    }

    fileprivate func unbox<T : Decodable>(as type: T.Type) throws -> T? {
        guard self.storage.data.first != 0xc0 else {
            return nil
        }

        let decode : T

        if T.self == Data.self || T.self == NSData.self {
            guard let data = try self.unbox(as: Data.self) else {
                return nil
            }

            decode = data as! T
        } else if T.self == Date.self || T.self == NSDate.self {
            guard let date = try self.unbox(as: Date.self) else {
                return nil
            }

            decode = date as! T
        } else {
            decode = try T(from: self)
        }

        return decode
    }
}

fileprivate let unpack = {(data : Data, count : Int) -> UInt64 in
    guard data.count > 0 else {
        return 0
    }
    var result : UInt64 = 0

    for i in 0..<count {
        result = result << 8 | UInt64(data[i])
    }

    return result
}
