//
//  ViewController.swift
//  SocketLogger
//
//  Created by ntoworks on 2022/06/24.
//

import UIKit

class ViewController: UIViewController {
    
    public enum LevelFilter: Int {
        case info = 0, warning = 1, debug = 2, error = 3
    }
    
    struct LogItem {
        var level: LevelFilter = .info
        var message: String = ""
    }
    

    var isVisible = false       // view foreground 여부
    var logStrings: [LogItem] = [LogItem]() // 오리지널 로그
    var filteredLogStrings: [LogItem] = [LogItem]() // 필터된 로그
    var currQueryString: String = ""
    var currLevelFilter: LevelFilter = .info
    
    @IBOutlet var logTableView: UITableView!
    @IBOutlet var filterEditView: UITextField!
    @IBOutlet var levelCompoView: UIView!
    @IBOutlet var levelButton: UIButton!
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initViews()

        logStrings.append(LogItem(level: .info, message: "Network Logger Started!!!"))
        doApplyFilter("")

        startLogServer()
    }
    
    func initViews() {
        logTableView.register(UINib(nibName: "LogTableViewCell", bundle: nil), forCellReuseIdentifier: "LogTableViewCell")
        logTableView.estimatedRowHeight = 50
        logTableView.rowHeight = UITableView.automaticDimension
        let gesture = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        isVisible = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.logTableView.reloadData()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        isVisible = false
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    //MARK: Events
    @IBAction func logLevelButtonTouchedAction(_ sender: Any) {
        levelCompoView.isHidden = false
    }
    
    @IBAction func filterEditChangedAction(_ sender: Any) {
        doApplyFilter(filterEditView.text)
    }
    @IBAction func levelComboSelectAction(_ sender: Any) {
        switch (sender as! UIView).tag {
        case 0:
            levelButton.setTitle("INFO", for: .normal)
            currLevelFilter = .info
        case 1:
            levelButton.setTitle("WARNING", for: .normal)
            currLevelFilter = .warning
        case 2:
            levelButton.setTitle("DEBUG", for: .normal)
            currLevelFilter = .debug
        case 3:
            levelButton.setTitle("ERROR", for: .normal)
            currLevelFilter = .error
        default:
            levelButton.setTitle("INFO", for: .normal)
            currLevelFilter = .info
        }
        levelCompoView.isHidden = true
        
        doApplyFilter(currQueryString, levelFilter: currLevelFilter)
    }

    //MARK: Filter
    func doApplyFilter(_ query: String?, levelFilter: LevelFilter = .info) {
        if let query = query {
            currQueryString = query
            filteredLogStrings = logStrings.filter({ log in
                (query.isEmpty || log.message.contains(query)) && log.level.rawValue >= levelFilter.rawValue
            })
            logTableView.reloadData()
        }
    }

    //MARK: SocketServer Functions
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
                                let data = Data(bytes: d, count: d.count)
                                if let msg = String(data: data, encoding: .utf8) {
                                    print("\(msg)")
                                    let level = self.extractLevel(msg)
                                    let logItem = LogItem(level: level, message: msg)
                                    self.logStrings.append(logItem)
                                    if (self.currQueryString.isEmpty || logItem.message.contains(self.currQueryString)) && logItem.level.rawValue >= self.currLevelFilter.rawValue {
                                        self.filteredLogStrings.append(logItem)
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

    func extractLevel(_ msg: String)-> LevelFilter {
        if msg.contains("⚠️ WARNING") {
            return .warning
        } else if msg.contains("🐛 DEBUG") {
            return .debug
        } else if msg.contains("🚫 ERROR") {
            return .error
        }
        return .info
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
        self.filteredLogStrings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: LogTableViewCell = tableView.dequeueReusableCell(withIdentifier: "LogTableViewCell") as! LogTableViewCell
        let count = filteredLogStrings.count
        if indexPath.row < count {
            let logItem = filteredLogStrings[indexPath.row]
            cell.logText.text = logItem.message
            if logItem.level == .error  {
                cell.logText.textColor = UIColor.red
            } else {
                if #available(iOS 12.0, *) {
                    if self.traitCollection.userInterfaceStyle == .dark {
                        cell.logText.textColor = UIColor.white
                    } else {
                        cell.logText.textColor = UIColor.black
                    }
                } else {
                    cell.logText.textColor = UIColor.black
                }
            }
        }
        
        cell.contentView.backgroundColor = indexPath.row % 2 == 0 ? UIColor.init(red: 128, green: 128, blue: 128, a: 48) : UIColor.init(red: 128, green: 128, blue: 128, a: 128)
        return cell
    }
}
