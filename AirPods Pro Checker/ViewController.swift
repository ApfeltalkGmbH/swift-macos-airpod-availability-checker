//
//  ViewController.swift
//  AirPods Pro Checker
//
//  Created by Tobias Scholze on 01.11.19.
//  Copyright © 2019 Tobias Scholze. All rights reserved.
//

import Cocoa

class ViewController: NSViewController
{
    // MARK: - Outlets -
    
    @IBOutlet private weak var tableView: NSTableView!
    @IBOutlet private weak var refreshButton : NSButton!
    @IBOutlet private weak var progressIndicator: NSProgressIndicator!
    
    // MARK: - Private constants -
    
    private let kZipSouth = "86150"
    private let kZipNorth = "20095"
    private let kJsonUrl = "https://www.apple.com/de/shop/retail/pickup-message?parts.0=MWP22ZM%2FA&location="
    private let storeUrl = "https://www.apple.com/de/airpods-pro"
    
    // MARK: - Private properties -
    
    private var stores = [Store]()
    
    // MARK: - View life cycle -
    
    override func viewDidLoad()
    {
        // Setup view and window.
        super.viewDidLoad()
        
        // Setup table view.
        tableView.delegate = self
        tableView.dataSource = self
        
        // Load data from server.
        loadData()
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        view.window?.title = "AirPods Pro Checker"
    }
    
    // MARK: - Actions -
    
    @IBAction
    private func handleRefreshButtonTapped(_ sender: Any)
    {
        loadData()
    }
    
    
    @IBAction
    private func handleGoToStoreButtonTapped(_ sender: Any)
    {
        guard let url = URL(string: storeUrl) else { return }
        NSWorkspace.shared.open(url)
    }
    
    // MARK: - Private helper -
    
    private func loadData()
    {
        // Show loading indicator.
        progressIndicator.startAnimation(nil)
        
        // Load stores form the south of Germany.
        loadData(forZip: kZipSouth) {[weak self] (southStores, error) in
            
            guard let self = self else { return }
            
            // Check if an error occured.
            // If yes, show an alert and empty the table view.
            if let error = error
            {
                self.stores = []
                self.showCloseAlert(title: "Achtung", text: error) { _ in
                    self.tableView.reloadData()
                }
                return
            }
            
            // Use found stores or empty list.
            self.stores = southStores ?? []
            
            // Secondly load stores from the north of the country.
            self.loadData(forZip: self.kZipNorth) { [weak self] (northStores, _) in
                // Only add not already present stores to the list.
                for store in northStores ?? []
                {
                    if (self?.stores.contains(where: { $0.sanitizedName == store.sanitizedName }) == false)
                    {
                        self?.stores.append(store)
                    }
                }
                
                // Order stores.
                self?.stores.sort(by: { $0.sanitizedName < $1.sanitizedName })
                
                // Reload table view on main thread.
                DispatchQueue.main.async
                    {
                        self?.tableView.reloadData()
                        self?.progressIndicator.stopAnimation(nil)
                }
            }
        }
    }
    
    private func loadData(forZip zip: String, completion: @escaping (([Store]?, String?) -> Void))
    {
        // Build url.
        guard let url = URL(string: "\(kJsonUrl)\(zip)") else { return }
        
        // Create task to request data.
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            // Ensure all required information are available.
            guard error == nil,
                let httpResponse = response as? HTTPURLResponse ,
                httpResponse.statusCode == 200,
                let data = data else
            {
                completion(nil, "Serverabfrage ist fehlgeschlagen")
                return
            }
            
            // Try to parse the requested information into understandable objects
            do
            {
                let container = try JSONDecoder().decode(Container.self, from: data)
                completion(container.body.stores, nil)
            }
            catch
            {
                completion(nil, "Serverabfrage ist fehlgeschlagen")
            }
        }
        
        // Start task.
        task.resume()
    }
}

// MARK: - NSTableViewDelegate -

extension ViewController: NSTableViewDelegate
{
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView?
    {
        // Get requesting identifier.
        guard let identifier = tableColumn?.identifier else {  return nil }
        
        // Get related store.
        let store = stores[row]
        
        // Create cell accordingly to its identifier.
        guard let cell = tableView.makeView(withIdentifier: identifier, owner: nil) as? NSTableCellView else
        {
            return nil
        }
        
        if identifier.rawValue == "store"
        {
            cell.textField?.stringValue = store.sanitizedName
        }
            
        else if identifier.rawValue == "city"
        {
            cell.textField?.stringValue = store.city
        }
            
        else if identifier.rawValue == "days"
        {
            cell.textField?.stringValue = store.partsAvailability.mwp22ZmA.sanitizedAvailableDate
        }
        
        return cell
    }
}

// MARK: - NSTableViewDataSource -

extension ViewController: NSTableViewDataSource
{
    func numberOfRows(in tableView: NSTableView) -> Int
    {
        return stores.count
    }
}
