//
//  ViewController.swift
//  Stocks_app
//
//  Created by Евгений on 11.02.2022.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    

    @IBOutlet weak var companyNameLabel: UILabel!
    @IBOutlet weak var currentCompanyNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var companyPickerView: UIPickerView!
    
    //MARK: privat properties
    private let companies:[String:String] = ["Apple":"AAPL",
                                             "Microsoft":"MSFT",
                                             "Google":"GOOG",
                                             "Amazon":"AMZN",
                                             "Facebook": "FB"]
    
    
    //MARK: privat methods
    private func requestQuote(for symbol: String) {
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=pk_5b88c5e2261c4c92bd54c10a78f899d1")!
//        let url = URL(string: "https://api.polygon.io/v2/aggs/ticker/\(symbol)/prev?adjusted=true&apiKey=Ya9JokdAQkbbwqC3I18TENN3LXpZVWEJ")!
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                print("Network error")
                return
            }
            
            self.parseQuote(data: data)
            
        }
        
        dataTask.resume()
    }
    
    private func parseQuote(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard
                let json = jsonObject as? [String:Any],
                let companyName = json["companyName"] as? String
            else {
                print("Invalid Json format")
                return
            }
            
            print("Company name is \(companyName)")
            
        } catch {
            print("! Json parsing error: " + error.localizedDescription)
        }
        
    }
    
    
    private func displayStockInfo(companyName: String) {
        self.activityIndicator.stopAnimating()
        self.companyNameLabel.text = companyName
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.currentCompanyNameLabel.text = "bank"
        self.companyPickerView.dataSource = self
        self.companyPickerView.delegate = self
        
        self.activityIndicator.startAnimating()
        self.requestQuote(for: "AAPL")
        
        
        
    //start
    }

    
    
    //MARK: !UIPicker!
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.activityIndicator.startAnimating()
        
        let selectedSymbol = Array(self.companies.values)[row]
        self.requestQuote(for: selectedSymbol)
    }
    
    
    //MARK: UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        companies.keys.count
    }
    
    
    //MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Array(self.companies.keys)[row]
    }
    
}

