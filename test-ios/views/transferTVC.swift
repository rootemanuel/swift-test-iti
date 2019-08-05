//
//  transferTVC.swift
//  test-ios
//
//  Created by h4x0rs on 29/07/19.
//  Copyright © 2019 h4x0rs. All rights reserved.
//

import UIKit

class transferTVC: UITableViewController {
    
    struct statics {
        static let title = "Transferir"
        static let now = "now"
        static let value = "value"
        static let date_formatter = "yyyyMMdd"
        static let limit = 10000.00
        static let json_empty = "{}"
    }
    
    @IBOutlet weak var lblDe: UILabel!
    @IBOutlet weak var lblPara: UILabel!
    @IBOutlet weak var lblValor: UILabel!
    @IBOutlet weak var btnSaldo1: ButtonExtender!
    @IBOutlet weak var btnSaldo5: ButtonExtender!
    @IBOutlet weak var btnSaldo10: ButtonExtender!
    @IBOutlet weak var btnConfirmar: ButtonExtender!
    
    var contactSel:String?
    var accountSel:Conta?
    var transfValue:Double = 0.0
    var transfValueD:Double = 0.0
    var spinnerView:UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
    }
    
    func initView(){
        let fmt = NumberFormatter()
        
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.numberStyle = .currency
        fmt.maximumFractionDigits = 2
        
        self.title = statics.title
        
        if let account = accountSel {
            if let formattedValue = fmt.string(from: account.valor as NSNumber) {
                self.lblDe.text = "\(account.name) (\(formattedValue))"
            }
        }
        
        if let contact = contactSel {
            self.lblPara.text = contact
        }
        
        self.btnSaldo1.addTarget(self, action: #selector(btnAddSaldo1), for: .touchUpInside)
        self.btnSaldo5.addTarget(self, action: #selector(btnAddSaldo5), for: .touchUpInside)
        self.btnSaldo10.addTarget(self, action: #selector(btnAddSaldo10), for: .touchUpInside)
        self.btnConfirmar.addTarget(self, action: #selector(btnTransferir), for: .touchUpInside)
    }
    
    func updateValues(){
        let fmt = NumberFormatter()
        
        fmt.locale = Locale(identifier: "pt_BR")
        fmt.numberStyle = .currency
        fmt.maximumFractionDigits = 2
        
        if let formattedTransfValue = fmt.string(from: transfValue as NSNumber) {
            self.lblValor.text = formattedTransfValue
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func shwSpinner() {
        
        let spinnerView = UIView.init(frame: self.view.bounds)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
            
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            self.view.addSubview(spinnerView)
            self.spinnerView = spinnerView
        }
    }
    
    func rmvSpinner() {
        self.spinnerView?.removeFromSuperview()
        self.spinnerView = nil
    }
    
    @objc func btnTransferir(_ sender: Any) {
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.shwSpinner()
                self.getResultsApi() { (result) in
                    
                self.saveValuesCache(value: self.transfValueD)
                DispatchQueue.main.async {
                    self.rmvSpinner()
                    
                    let alert = UIAlertController(title: "Sucesso", message: "Transferência realizada com Sucesso!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in self.backView()}))
                    alert.addAction(UIAlertAction(title: "Novo valor", style: UIAlertAction.Style.default, handler: {(alert: UIAlertAction!) in self.initValues()}))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc func btnAddSaldo1(_ sender: Any) {
        
        let value = 1.0
        self.handleCalc(valuen: value)
    }
    
    @objc func btnAddSaldo5(_ sender: Any) {
        
        let value = 5.0
        self.handleCalc(valuen: value)
    }
    
    @objc func btnAddSaldo10(_ sender: Any) {
        
        let value = 1000.0
        self.handleCalc(valuen: value)
    }
    
    func handleCalc(valuen: Double){
        
        let formatter = DateFormatter()
        formatter.dateFormat = statics.date_formatter
        
        let nows = formatter.string(from: Date())
        
        let defaults = UserDefaults.standard
        if let dates = defaults.string(forKey: statics.now) {
            
            let value = defaults.double(forKey: statics.value)
            let sum = value + (self.transfValue + valuen)
            
            if dates == nows {
                if sum > statics.limit {
                    let alert = UIAlertController(title: "Aviso", message: "Valor acima do permitido!", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.transfValueD=sum
                    self.transfValue+=valuen
                    self.updateValues()
                }
            } else {
                self.transfValue+=valuen
                self.updateValues()
                self.saveValuesCache(value: 0.0)
            }
        } else {
            self.transfValue+=valuen
            self.updateValues()
            self.saveValuesCache(value: 0.0)
        }
    }
    
    func getResultsApi(completion: @escaping (_ result:Bool)->()){
        
        guard let url = URL(string: "http://localhost:8080/mock") else {
            return
        }
        
        var urlr = URLRequest(url: url)
        urlr.httpMethod = "POST"

        let task = URLSession.shared.dataTask(with: urlr) { (data, resp, err) in
            if err != nil {
                print("#error - callback => \(err)")
                completion(false)
            }
            
            completion(true)
        }
        task.resume()
    }
    
    func saveValuesCache(value:Double?){
        
        let defaults = UserDefaults.standard
        let formatter = DateFormatter()
        
        formatter.dateFormat = statics.date_formatter
        let nows = formatter.string(from: Date())
        
        if value != nil {
            defaults.set(value, forKey: statics.value)
        }
       
        defaults.set(nows, forKey: statics.now)
    }
    
    func initValues(){
        self.transfValue = 0.0
        self.updateValues()
    }
    
    func backView(){
        self.navigationController?.popViewController(animated: true)
    }
}
