//
//  Extensions.swift
//  AirPods Pro Checker
//
//  Created by Tobias Scholze on 01.11.19.
//  Copyright © 2019 Tobias Scholze. All rights reserved.
//

import AppKit

extension NSViewController
{
    func showCloseAlert(title: String, text: String, completion: @escaping (Bool) -> Void)
    {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = title
            alert.informativeText = text
            alert.addButton(withTitle: "OK")
            alert.alertStyle = NSAlert.Style.warning
            completion(alert.runModal() == NSApplication.ModalResponse.alertFirstButtonReturn)
        }
    }
}

extension DateFormatter
{
    static var shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        formatter.locale = Locale(identifier: "en")
        return formatter
    }()
}

extension String
{    
    var trimmed: String
    {
        let characterSet = CharacterSet.whitespacesAndNewlines
        return trimmingCharacters(in: characterSet)
    }
}
