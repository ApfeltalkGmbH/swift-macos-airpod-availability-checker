//
//  AboutViewController.swift
//  AirPods Pro Checker
//
//  Created by Tobias Scholze on 01.11.19.
//  Copyright © 2019 Tobias Scholze. All rights reserved.
//

import AppKit

class AboutViewController: NSViewController
{
    // MARK: - Private constants -
    
    private let kGitHubUrl = "https://github.com/tscholze/swift-macos-airpod-availability-checker"
    private let kApfeltalkUrl = "https://apfeltalk.de"
    
    // MARK: - Actions -
    
    @IBAction
    private func onGitHubButtonClicked(_ sender: Any)
    {
        guard let url = URL(string: kGitHubUrl) else { return }
        NSWorkspace.shared.open(url)
    }
    
    @IBAction
    private func onApfeltalkButtonTapped(_ sender: Any)
    {
        guard let url = URL(string: kApfeltalkUrl) else { return }
        NSWorkspace.shared.open(url)
    }
}
