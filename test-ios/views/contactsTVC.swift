//
//  contactsTVCTableViewController.swift
//  test-ios
//
//  Created by h4x0rs on 26/07/19.
//  Copyright © 2019 h4x0rs. All rights reserved.
//

import UIKit

class contactsTVC: UITableViewController {
    
    struct statics {
        static let url = "http://localhost:8080/mock"
        static let title = "Transferências"
        static let alphabet = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
        static let sections = 3
    }
    
    var emptyViewError:emptyErrorV?
    var emptyViewLoading:emptyLoadingV?
    
    var contactSel:String?
    var accountSel:Conta?
    
    var rootBank:RootBank = RootBank()
    var listContactsOrg = Array<Array<String>>()
    
   
    @IBOutlet var contactsTable: UITableView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.initView()
        self.handlerView()
    }
    
    func initView(){
        
        self.title = statics.title
        
        self.contactsTable.delegate = self
        self.contactsTable.dataSource = self
        
        self.emptyViewError = Bundle.main.loadNibNamed("emptyErrorV", owner: self, options: nil)?.first as? emptyErrorV
        self.emptyViewLoading = Bundle.main.loadNibNamed("emptyLoadingV", owner: self, options: nil)?.first as? emptyLoadingV
        
        self.tableView.backgroundView = emptyViewLoading
    }
    
    func handlerView(){
        
        self.servGetContactsBank() { (res) in
            
            if let resBank = res {
                self.rootBank = resBank
                self.handlerSucess()
            } else {
                self.handlerError()
            }
        }
    }
    
    func handlerSucess(){
        
        DispatchQueue.main.async {
            self.rootBank.contatos = self.rootBank.contatos.sorted()
            for letter in statics.alphabet {
                let filter  = self.rootBank.contatos.filter({$0.uppercased().hasPrefix(letter)})
                
                if filter.count > 0 {
                    self.listContactsOrg.append(filter)
                }
            }
            
            self.tableView.reloadData()
        }
    }
    
    func handlerError(){
        
        DispatchQueue.main.async {
            self.tableView.backgroundView = self.emptyViewError
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            let cell = Bundle.main.loadNibNamed("genericInfoCenterTVCC", owner: self, options: nil)?.first as! genericInfoCenterTVCC
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.lblTextCenter.text = "de:"
            
            return cell
        case 1:
            let cell = Bundle.main.loadNibNamed("genericInfoLeftTVCC", owner: self, options: nil)?.first as! genericInfoLeftTVCC
            let fmt = NumberFormatter()
            
            fmt.locale = Locale(identifier: "pt_BR")
            fmt.numberStyle = .currency
            fmt.maximumFractionDigits = 2
            
            if let formattedSaldo = fmt.string(from: self.rootBank.contas[indexPath.row].valor as NSNumber) {
               cell.lblTextLeft.text = "\(self.rootBank.contas[indexPath.row].name) (\(formattedSaldo))"
            }
            
            return cell
        case 2:
            let cell = Bundle.main.loadNibNamed("genericInfoCenterTVCC", owner: self, options: nil)?.first as! genericInfoCenterTVCC
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.lblTextCenter.text = "para:"
            
            return cell
            
        case 3...listContactsOrg.count + statics.sections:
            let cell = Bundle.main.loadNibNamed("genericInfoLeftTVCC", owner: self, options: nil)?.first as! genericInfoLeftTVCC
            
            cell.selectionStyle = UITableViewCell.SelectionStyle.none
            cell.lblTextLeft.text = listContactsOrg[indexPath.section - statics.sections][indexPath.row]
            
            return cell
        default:
            let cell = Bundle.main.loadNibNamed("genericInfoLeftTVCC", owner: self, options: nil)?.first as! genericInfoLeftTVCC
            return cell
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        var numOfSections: Int = 0
        
        if listContactsOrg.count > 0 {
            numOfSections = listContactsOrg.count + statics.sections
            tableView.separatorStyle = .singleLine
            tableView.backgroundView?.isHidden = true
        } else {
            tableView.separatorStyle = .none
            tableView.backgroundView?.isHidden = false
        }
        
        return numOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0:
            return 1
        case 1:
            return self.rootBank.contas.count
        case 2:
            return 1
        case 3...listContactsOrg.count + statics.sections:
            return listContactsOrg[section - statics.sections].count
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {

        switch section {
        case 3...listContactsOrg.count + statics.sections:
            let name = listContactsOrg[section - statics.sections][0]
            let range = name.index(name.startIndex, offsetBy: 0)
            return String(name[range])
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 1:
            
            if let cell = tableView.cellForRow(at: indexPath as IndexPath) {
                if cell.isSelected {
                    if cell.accessoryType == .none {
                        
                        for item in tableView.visibleCells {
                            item.accessoryType = .none
                        }
                        
                        if self.rootBank.contas[indexPath.row] != nil {
                            self.accountSel = self.rootBank.contas[indexPath.row]
                        }
                        
                        cell.accessoryType = .checkmark
                    } else {
                        self.accountSel = nil
                        cell.accessoryType = .none
                    }
                }
            }
        case 3...listContactsOrg.count + statics.sections:
            
            if self.accountSel != nil {
                if self.listContactsOrg[indexPath.section - statics.sections][indexPath.row] != nil {
                    self.contactSel = self.listContactsOrg[indexPath.section - statics.sections][indexPath.row]
                }
                
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "transfer") as! transferTVC
                
                vc.contactSel = self.contactSel
                vc.accountSel = self.accountSel
                
                self.navigationController?.pushViewController(vc, animated: true)
                
            } else {
                let alert = UIAlertController(title: "Aviso", message: "Selecione a conta origem!", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        default:
            return
        }
    }
    
    func servGetContactsBank(completion: @escaping (_ result: RootBank?)->()){
        
        guard let url = URL(string: statics.url) else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, resp, err) in
            let decoder = JSONDecoder()
            
            guard let datag = data else { self.handlerError(); return }
            if let _ = err { self.handlerError(); return }
            
            do{
                let res = try decoder.decode(RootBank.self, from: datag)
                completion(res)
            } catch let parsingError {
                NSLog("#error - getResultsApi => \(parsingError)")
                completion(nil)
            }
        }
        
        task.resume()
    }
}
