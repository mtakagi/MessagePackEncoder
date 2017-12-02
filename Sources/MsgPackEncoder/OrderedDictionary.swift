//
//  OrderedDictionary.swift
//  MsgPackEncoderPackageDescription
//
//  Created by mtakagi on 2017/12/02.
//

import Foundation

public class OrderedDictionary<K, V> : NSObject, Sequence, IteratorProtocol, ExpressibleByDictionaryLiteral {
    class KeyValuePair {
        var key : K
        var value : V
        var before : KeyValuePair?
        var after : KeyValuePair?

        init(key: Key, value : Value) {
            self.key = key
            self.value = value
        }
    }

    private var head : KeyValuePair?
    private var tail : KeyValuePair?
    private var dict : NSMutableDictionary

    public var count : Int { return dict.count }

    public subscript(key: K) -> V? {
        get {
            guard let value = dict.object(forKey: key) as? KeyValuePair else {
                return nil
            }
            return value.value
        }
        set {
            if let value = dict.object(forKey: key) as? V {
                remove(value: value)
                dict.removeObject(forKey: key)
            }
            guard let value = newValue else {
                dict.removeObject(forKey: key)
                return
            }
            let kvp = add(key: key, value: value)
            dict[key] = kvp
        }
    }

    public required override init() {
        self.dict = [:]
    }

    public typealias Key = K
    public typealias Value = V

    public convenience required init(dictionaryLiteral elements: (OrderedDictionary.Key, OrderedDictionary.Value)...) {
        self.init()
        for (key, Value) in elements {
            self[key] = Value
        }
    }

    private func add(key : K, value : V) -> KeyValuePair {
        let kvp = KeyValuePair(key: key, value: value)
        insertLast(kvp: kvp)

        return kvp
    }

    private func insertLast(kvp : KeyValuePair) {
        let last = self.tail
        self.tail = kvp

        if let last = last {
            kvp.before = last
            last.after = self.tail!
        } else {
            self.head = kvp
        }
    }

    private func remove(value : V) {
        guard let kvp = value as? KeyValuePair else {
            return
        }

        let p = kvp
        var b = p.before
        var a = p.after

        if let c = b {
            self.head = c
        } else {
            b = a
        }

        if let c = a {
            self.tail = c
        } else {
            a = b
        }
    }

    public typealias Element = (K, V)

    var current : KeyValuePair?

    public func next() -> (K, V)? {
        if current == nil {
            current = self.head
        } else {
            current = current?.after
        }
        guard let head = current else {
            return nil
        }

        return (head.key, head.value)
    }
}

fileprivate struct OrderedKey : CodingKey {
    var stringValue: String

    init(stringValue: String) {
        self.stringValue = stringValue
    }

    var intValue: Int?

    init(intValue: Int) {
        self.intValue = intValue
        self.stringValue = "Index \(intValue)"
    }
}

extension OrderedDictionary : Encodable {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: OrderedKey.self)

        for (key, value) in self {
            guard let description = key as? CustomStringConvertible else {
                fatalError()
            }
            let refEncoder = container.superEncoder(forKey: OrderedKey(stringValue: description.description))

            guard let encodable = value as? Encodable else {
                fatalError()
            }
            try encodable.encode(to: refEncoder)
        }
    }
}
