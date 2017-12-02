# MsgPackEncoder


[![Build Status](https://travis-ci.org/mtakagi/MessagePackEncoder.svg?branch=master)](https://travis-ci.org/mtakagi/MessagePackEncoder)
[![codecov](https://codecov.io/gh/mtakagi/MessagePackEncoder/branch/master/graph/badge.svg)](https://codecov.io/gh/mtakagi/MessagePackEncoder)
[![Join the chat at https://gitter.im/mtakagi/MessagePackEncoder](https://badges.gitter.im/mtakagi/MessagePackEncoder.svg)](https://gitter.im/mtakagi/MessagePackEncoder?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

This project is experimental MessagePack Encoder like a Swift 4's `Codable` conform ` (JSON|PropertyList)Encoder` class

**Caution**

Currently MessagePackEncoder is encode support only.

## How to use

Simply instantiate `MessagePackEncoder` class and invoke encode method with `Codable` instance.

```
struct Sample : Codable {
    var name : String
}

let sample = Samle(name: "Sample")
let encoder = MessagePackEncoder()
let result = try! encoder.encode(sample)
```
