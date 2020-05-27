//
//  MMXMLParser.swift
//  MMLibrary
//
//  Created by 曾亮敏 on 2020/5/27.
//  Copyright © 2020 zlm. All rights reserved.
//

import Foundation
public class MMXMLElement {
    public var elementName: String = ""
    public var characters: String {
        get {
            return _characters
        }
        set {
            if isWriteCharacters {
                _characters = newValue
            }
        }
    }
    public var attributeDict: [String: String] = [:]
    public var subElementList: [MMXMLElement] = []
    
    private var _characters: String = ""
    fileprivate var isWriteCharacters = true
}

public class MMXMLParser: NSObject {
    public var data: [MMXMLElement] = []
    public init(url: URL? = nil) {
        super.init()
        if let url = url {
            self.parse(url: url)
        }
    }
    public func parse(url: URL) {
        let xmlParser = XMLParser(contentsOf: url)
        xmlParser?.delegate = self
        xmlParser?.parse()
    }
    
    private var currentElement: MMXMLElement?
    private var heapList: [MMXMLElement] = []
    
}
fileprivate typealias __Public = MMXMLParser
extension __Public: XMLParserDelegate {
    public func parserDidStartDocument(_ parser: XMLParser) {
        heapList = []
        data = []
    }
    public func parserDidEndDocument(_ parser: XMLParser) {
        data = heapList.reversed()
    }
    public func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        var subList: [MMXMLElement] = []
        while let last = heapList.popLast() {
            if last.elementName == elementName {
                last.subElementList = subList.reversed()
                last.isWriteCharacters = false
                heapList.append(last)
                break
            } else {
                subList.append(last)
            }
        }
    }
    public func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        let element = MMXMLElement()
        element.elementName = elementName
        element.attributeDict = attributeDict
        heapList.append(element)
    }
    public func parser(_ parser: XMLParser, foundCharacters string: String) {
        if let last = heapList.last, last.isWriteCharacters == true {
            last.characters = string
        }
    }
}
