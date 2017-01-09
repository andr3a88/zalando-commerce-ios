//
//  Copyright © 2017 Zalando SE. All rights reserved.
//

import Foundation
import Swifter

extension HttpServer {

    func registerAvailableJSONMocks() throws {
        let jsonExt = ".json"

        guard let jsonFiles = try serverBundle.pathsForResources(containingInName: jsonExt) else { return }

        for filePath in jsonFiles {
            let fullFilePath = URL(fileURLWithPath: filePath).lastPathComponent
                .replacingOccurrences(of: jsonExt, with: "")
                .replace(old: "|", "/")
            guard !fullFilePath.contains("!") else { continue }

            let contents = try String(contentsOfFile: filePath)
            let method = fullFilePath.components(separatedBy: "*")[0]
            let urlPath = fullFilePath.components(separatedBy: "*")[1]

            print("Registered endpoint:", method, urlPath)

            switch method {
            case "POST":
                self.POST[urlPath] = { _ in
                    return .ok(.text(contents))
                }
            default:
                self[urlPath] = { _ in
                    return .ok(.text(contents))
                }
            }
        }
    }

}
