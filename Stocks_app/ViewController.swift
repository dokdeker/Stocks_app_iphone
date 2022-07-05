//
//  ViewController.swift
//  Stocks_app
//
//  Created by Евгений on 11.02.2022.
//

import UIKit

class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    
    //MARK: - @IBOutlet
    @IBOutlet weak var currentCompanyNameLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var companyPickerView: UIPickerView!
    
    @IBOutlet weak var logoCompany: UIImageView!
    @IBOutlet weak var companySymbolLabel: UILabel!
    @IBOutlet weak var companyPriceChangeLabel: UILabel!
    @IBOutlet weak var companyPriceLabel: UILabel!
    
    
    
    
    
    
    //MARK: privat properties
    private let companies:[String:String] = ["Apple":"AAPL",
                                             "Microsoft":"MSFT",
                                             "Google":"GOOG",
                                             "Amazon":"AMZN",
                                             "Facebook": "FB"]
    
    
    //MARK: - privat methods
    
    private func getImg(url:String){
        if let url = URL(string: url) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                
                DispatchQueue.main.async { /// execute on main thread
                    self.logoCompany.image = UIImage(data: data)
                }
            }
            
            task.resume()
        }
    }
    

    private func checkStockProfit(label: UILabel,value:Double) {
        if value > 0 {
            label.textColor = .green
        } else {
            label.textColor = .red
        }
    }
    
    private func showAlertError(message_errror: String) {
        let alert = UIAlertController(title: "Ошибка", message: message_errror, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Принять", style: .cancel , handler: { action in

        }))
        
        present(alert, animated: true)
    }
    
    //MARK:  parse img
    private func requestImg(for symbol: String) {
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/logo/quote?token=pk_5b88c5e2261c4c92bd54c10a78f899d1")!

        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                
                DispatchQueue.main.async {
                    self.showAlertError(message_errror: "Отсутствует подключение к интернету")
                }
                return
            }
            
            self.parseImg(data: data)
            
        }
        
        dataTask.resume()
    }
    
    
    private func parseImg(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            
            guard
                let json = jsonObject as? [String:Any],
                let img = json["url"] as? String
                
                
            else {
                
                DispatchQueue.main.async {
                    self.showAlertError(message_errror: "Invalid Json format")
                }
                
                
                return
            }
            
            print("Company name is \(img)")
            DispatchQueue.main.async {
                self.getImg(url: img)
            }
            
        } catch {
            DispatchQueue.main.async {
                self.showAlertError(message_errror: "! Json parsing error: " + error.localizedDescription)
            }
            
        }
        
    }
    
    
    
    
    //MARK:  parse quote
    private func requestQuote(for symbol: String) {
        let url = URL(string: "https://cloud.iexapis.com/stable/stock/\(symbol)/quote?token=pk_5b88c5e2261c4c92bd54c10a78f899d1")!

        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
                let data = data
            else {
                
                DispatchQueue.main.async {
                    self.showAlertError(message_errror: "Отсутствует подключение к интернету")
                }
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
                let companyName = json["companyName"] as? String,
                let companySymbol = json["symbol"] as? String,
                let price = json["latestPrice"] as? Double,
                let priceChange = json["change"] as? Double
                
            else {
                
                DispatchQueue.main.async {
                    self.showAlertError(message_errror: "Invalid Json format")
                }
                
                
                return
            }
            
            DispatchQueue.main.async {
                self.displayStockInfo(companyName: companyName,
                                      symbol: companySymbol,
                                      price: price,
                                      priceChange: priceChange)
                
            }
            
        } catch {
            DispatchQueue.main.async {
                self.showAlertError(message_errror: "! Json parsing error: " + error.localizedDescription)
            }
            
        }
        
    }
    
    
    private func displayStockInfo(companyName: String,
                                  symbol: String,
                                  price: Double,
                                  priceChange:Double ) {
        
        self.activityIndicator.stopAnimating()
        self.currentCompanyNameLabel.text = companyName
        self.companySymbolLabel.text = symbol
        self.companyPriceLabel.text = "\(price)"
        self.companyPriceChangeLabel.text = "\(priceChange)"
        
        self.checkStockProfit(label: companyPriceChangeLabel, value: (companyPriceChangeLabel.text! as NSString).doubleValue)
        
    }
    
    
    private func requestQuoteUpdate() {
        self.activityIndicator.startAnimating()
        self.currentCompanyNameLabel.text = "—"
        self.companySymbolLabel.text = "—"
        self.companyPriceLabel.text = "—"
        self.companyPriceChangeLabel.text = "—"
        
        let selectedRow = self.companyPickerView.selectedRow(inComponent: 0)
        let selectedSymbol = Array(self.companies.values)[selectedRow]
        self.requestQuote(for: selectedSymbol)
        self.requestImg(for: selectedSymbol)
    }
    
    
    //MARK: - View did load
    override func viewDidLoad() {
        super.viewDidLoad()

        self.companyPickerView.dataSource = self
        self.companyPickerView.delegate = self

        self.activityIndicator.hidesWhenStopped = true
        
        requestQuoteUpdate()

    

    }

    
    
    //MARK: - !UIPicker!
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {

        self.activityIndicator.startAnimating()
        
        self.requestQuoteUpdate()
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

