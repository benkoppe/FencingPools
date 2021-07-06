//
//  ShareViewController.swift
//  FencingTimeURL
//
//  Created by Ben K on 7/5/21.
//

import UIKit
import Social
import SwiftUI
import MobileCoreServices

@objc(ShareExtensionViewController)
class ShareViewController: UIViewController {

    override func viewDidLoad() {
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            accessWebpageProperties(extensionItem: item)
        }
    }
    
    private func accessWebpageProperties(extensionItem: NSExtensionItem) {
        let propertyList = String(kUTTypePropertyList)
        
        for attachment in extensionItem.attachments! where attachment.hasItemConformingToTypeIdentifier(propertyList) {
            print("2")
            attachment.loadItem(
                forTypeIdentifier: propertyList,
                options: nil,
                completionHandler: { (item, error) -> Void in

                    guard let dictionary = item as? NSDictionary,
                        let results = dictionary[NSExtensionJavaScriptPreprocessingResultsKey] as? NSDictionary,
                        let title = results["title"] as? String else {
                        print("failed")
                        return
                    }

                    print("title: \(title)")
                }
            )
        }
    }

}
