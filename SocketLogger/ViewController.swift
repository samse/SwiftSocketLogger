//
//  ViewController.swift
//  SocketLogger
//
//  Created by ntoworks on 2022/06/24.
//

import UIKit

class ViewController: UIViewController {
    
    var logStrings: [String] = [String]()
    var filteredLogStrings: [String] = [String]()
    var queryString: String = ""
    @IBOutlet var logTableView: UITableView!
    var isVisible = false
    @IBOutlet var filterEditView: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logTableView.register(UINib(nibName: "LogTableViewCell", bundle: nil), forCellReuseIdentifier: "LogTableViewCell")
        logTableView.estimatedRowHeight = 50
        logTableView.rowHeight = UITableView.automaticDimension
        logStrings.append( "ntoworks network looger started")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)

        startLogServer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        isVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.logTableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isVisible = false
        print("viewWillDisappear")
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func startLogServer() {
        DispatchQueue.global().async {
            let server = TCPServer(address: "127.0.0.1", port: 2532)
            print("server listening");
            switch server.listen() {
              case .success:
                while true {
                    if let client = server.accept(timeout: 4) {
                        if let len = client.bytesAvailable() {
                            if let d = client.read(Int(len)) {
                                if let data = Data(bytes: d, count: d.count) as? Data, let msg = String(data: data, encoding: .utf8) {
                                    print("\(msg)")
                                    self.logStrings.append(msg)
                                    if (!self.queryString.isEmpty) {
                                        if msg.contains(self.queryString) {
                                            self.filteredLogStrings.append(msg)
                                        }
                                    }
                                    
                                    if self.isVisible {
                                        DispatchQueue.main.async {
                                            self.logTableView.reloadData()
                                        }
                                    }
                                }
                            }
                        }
                        client.close()
                        
                    }
                }
              case .failure(let error):
                print(error)
            }
        }
    }
    
    @IBAction func logLevelButtonTouchedAction(_ sender: Any) {
        
    }
    
    @IBAction func filterEditChangedAction(_ sender: Any) {
        doApplyFilter(filterEditView.text)
    }
    
    func doApplyFilter(_ query: String?) {
        if let query = query {
            queryString = query
            filteredLogStrings = logStrings.filter({ log in
                log.contains(query)
            })
            logTableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if queryString.isEmpty { return self.logStrings.count }
        else { return self.filteredLogStrings.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: LogTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogTableViewCell") as! LogTableViewCell
        let count = queryString.isEmpty ? logStrings.count : filteredLogStrings.count
        if indexPath.row < count {
            let text = queryString.isEmpty ? logStrings[indexPath.row] : filteredLogStrings[indexPath.row]
            cell.logText.text = text
            if text.contains("🚫 ERROR") {
                cell.logText.textColor = UIColor.red
            }
        }
        cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? .gray : .darkGray
        return cell
    }
}

extension ViewController {
    
}
