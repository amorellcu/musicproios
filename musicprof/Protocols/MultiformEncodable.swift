//
//  MultiformEncodable.swift
//  musicprof
//
//  Created by John Doe on 7/9/19.
//  Copyright © 2019 Alexis Morell Blanco. All rights reserved.
//

import Foundation
import Alamofire
import MobileCoreServices

protocol MultiformEncodable {
    func encode(to form: MultipartFormData)
}

extension MultipartFormData {
    func encode(_ str: CustomStringConvertible, withName name: String) {
        self.append(str.description.data(using: .utf8)!, withName: name)
    }
    
    func encodeIfPresent(_ str: CustomStringConvertible?, withName name: String) {
        guard let str = str else { return }
        self.append(str.description.data(using: .utf8)!, withName: name)
    }
    
    func encodeValues<T: CustomStringConvertible>(_ values: [T]?, withName name: String) {
        let values = values ?? []
        for i in 0 ..< values.count {
            self.encode(values[i], withName: "\(name)[]")
        }
    }
    
    func mimeType(forPathExtension pathExtension: String) -> String {
        if
            let id = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, pathExtension as CFString, nil)?.takeRetainedValue(),
            let contentType = UTTypeCopyPreferredTagWithClass(id, kUTTagClassMIMEType)?.takeRetainedValue()
        {
            return contentType as String
        }
        
        return "application/octet-stream"
    }
}
