//
//  ETHDetailsViewController.swift
//  WalletApp
//
//  Created by Arunachalam Packirisamy on 3/29/22.
//

import UIKit

class ETHDetailsViewController: UIViewController {

    @IBOutlet weak var rateValueLabel: UILabel!
    @IBOutlet weak var dollarValueLabel: UILabel!
    @IBOutlet weak var ethereumValueLabel: UILabel!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        requestDataFromService()
    }
    
    func requestDataFromService() {
        
        activityIndicatorView.startAnimating()
        let urlString = "https://api.ethplorer.io/getAddressInfo/0x2ce780d7c743a57791b835a9d6f998b15bbba5a4?apiKey=EK-aGWaL-SSi8E3u-5Q3JE"

        guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { data, response, err in
                guard let data = data, err == nil else { return }
                
                do {
                    let jsonData = try JSONDecoder().decode(ETHResponseModel.self, from: data)
                    
                    print("Success")

                    DispatchQueue.main.async {
                    print("")
                        self.updateUI(response: jsonData)
                        self.activityIndicatorView.stopAnimating()
                    }

                } catch let jsonErr {
                    print("failed to decode json:", jsonErr)
                    DispatchQueue.main.async {
                        self.activityIndicatorView.stopAnimating()
                    }
                }
                print("")
                
            }.resume() // don't forget
        
    }
    
    private func updateUI(response: ETHResponseModel) {
        
        let ethRate = response.ETH.price.rate.rounded(toPlaces: 6)
        let ethDollarValue = ethRate * response.ETH.balance
        
        rateValueLabel.text = String(describing: ethRate.rounded(toPlaces: 6))
        dollarValueLabel.text = "$ " + formatCurrency(currency: ethDollarValue)
        ethereumValueLabel.text = String(describing: response.ETH.balance.rounded(toPlaces: 6)) + "ETH"
    }
    
    func formatCurrency(currency: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        formatter.groupingSeparator = ","
        let formattedStr = formatter.string(from: NSNumber(floatLiteral: currency))
        return formattedStr ?? ""
    }
}

struct ETHResponseModel: Codable {
    let address: String
    let countTxs: Int
    let ETH: ETHValue

}

struct ETHValue: Codable {
    let balance: Double
    let rawBalance: String
    let price: ETHPrice
}

struct ETHPrice: Codable {
    let rate: Double
    let diff: Double
}

extension Double {
    /// Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
