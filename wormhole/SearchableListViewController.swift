import AppKit

class SearchableListViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, NSTextFieldDelegate {

    let tableView = NSTableView()
    let searchField = NSTextField()

    var data: [String] = []
    var filteredData: [String] {
        return data.filter { $0.hasPrefix(searchField.stringValue) }
    }

    override func loadView() {
        let view = NSView()
        self.view = view
        self.view.setFrameSize(NSSize(width: 600, height: 600))

        let scrollView = NSScrollView()
        scrollView.documentView = tableView
        scrollView.hasVerticalScroller = true
        view.addSubview(scrollView)

        searchField.delegate = self
        searchField.placeholderString = "Search"
        view.addSubview(searchField)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        searchField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchField.topAnchor.constraint(equalTo: view.topAnchor, constant: 20),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            searchField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            scrollView.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 20),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.dataSource = self
        tableView.delegate = self
        tableView.target = self
        tableView.doubleAction = #selector(doubleClick(_:))
        tableView.addTableColumn(NSTableColumn(identifier: NSUserInterfaceItemIdentifier(rawValue: "column")))
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProjects()
    }

    func fetchProjects() {
        let url = URL(string: "http://o/projects/")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
            } else if let data = data {
                let str = String(data: data, encoding: .utf8)
                self.data = str?.components(separatedBy: "\n") ?? []
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        task.resume()
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredData.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = NSTextField()
        cell.isEditable = false
        cell.isSelectable = false
        cell.isBezeled = false
        cell.backgroundColor = .clear
        cell.stringValue = filteredData[row]
        return cell
    }

    func controlTextDidChange(_ obj: Notification) {
        tableView.reloadData()
    }

    @objc func doubleClick(_ sender: Any) {
        let selectedName = filteredData[tableView.selectedRow]
        print("Selected: \(selectedName)")
        self.view.window?.close()
    }
}