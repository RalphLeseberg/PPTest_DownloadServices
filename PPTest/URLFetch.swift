//
//  URLFetch.swift
//  PPTest
//
//  Created by r leseberg on 10/17/18.
//  Copyright © 2018 starion. All rights reserved.
//

import Foundation

class URLFetch {
    typealias RequestCompletion = (_ html: String) -> Void
    typealias FailureCompletion = (_ error: DownloadRequestErrorType) -> Void

    let kHeadSplit = "<head>"
    let kHeadEndSplit = "</head>"
    let kBodySplit = "<body>"
    let kShortBodySplit = "<body"
    let kEndBodySplit = "</body>"

    func updateHTML(blankHTML: String, url: URL?,
                    success: @escaping RequestCompletion,
                    failure: @escaping FailureCompletion) {
        
        guard let url = url else {
            return failure(DownloadRequestErrorType.notFound)
        }

        let request = URLRequest(url: url)
        DownloadService.shared.download(request: request,
                        success: { data in
                            print("updateHTML count: \(data.count)")
                            let downloadedHTML = String(decoding: data, as: UTF8.self)
                            let htmlString = self.mergeHTML(blankHTML: blankHTML, html: downloadedHTML)
                            return success(htmlString)
        },
                        failure: {error in
                            print("updateHTML error: \(error.localizedDescription))")
                            return failure(error)
        } )
    }
    
    private func mergeHTML(blankHTML: String, html: String) -> String {
        var merged = ""
        
        // move <head> info to blank
        let headerSplit = blankHTML.components(separatedBy: kHeadSplit)
        let htmlHeaderSplit = html.components(separatedBy: kHeadSplit)
        guard htmlHeaderSplit.count > 1, headerSplit.count > 1 else {
            print("<head> not found")
            return ""
        }
        let htmlEndHeaderSplit = htmlHeaderSplit[1].components(separatedBy: kHeadEndSplit)
        merged = headerSplit[0] + kHeadSplit + "\n" + htmlEndHeaderSplit[0] + headerSplit[1]
        
        // move <body> attributes and body to blank
        let bodySplit = merged.components(separatedBy: kBodySplit)
        let htmlBodySplit = html.components(separatedBy: kShortBodySplit)

        guard bodySplit.count > 1, htmlBodySplit.count > 1 else {
            print("<head> not found")
            return ""
        }
        let htmlBody = htmlBodySplit[1].components(separatedBy: kEndBodySplit)
        merged = bodySplit[0] + kShortBodySplit + htmlBody[0] + bodySplit[1]
        
        return merged
    }
}
