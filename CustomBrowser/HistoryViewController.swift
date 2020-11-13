//
//  HistoryViewController.swift
//  CustomBrowser
//
//  Created by Marat on 12/11/2020.
//

import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    // MARK: UI
    @IBOutlet weak var historyTable: UITableView!


    // MARK: Data
    var callback:((URL) -> Void)?
    var history:[HistoryItem] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    private let formatter = DateFormatter()


    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        formatter.dateFormat = "dd/MMM/yy"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        do {
            history = try context.fetch(HistoryItem.fetchRequest())
            historyTable.reloadData()
        } catch {
            // failed to fetch
        }
    }


    // MARK: Tableview
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:HistoryViewCell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryViewCell

        let historyItem = history[indexPath.row]

        cell.titleLabel.text = historyItem.title
        cell.dateLabel.text = formatter.string(from: historyItem.date ?? Date.distantPast)

        return cell
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {

        if editingStyle == .delete {
            let toRemove = history[indexPath.row]
            context.delete(toRemove)
            do {
                try context.save()
                history = try context.fetch(HistoryItem.fetchRequest())

                tableView.deleteRows(at: [indexPath], with: .automatic)
            } catch {
                // save context failed, don't update UI
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let record = history[indexPath.row]
        if let cb = callback, let url = record.url {

            // delete first
            context.delete(record)
            do {
                try context.save()

                // then pass to caller
                cb(url)
            } catch {
                // save context failed, don't update UI
            }

            navigationController?.popViewController(animated: true)
        }
    }

    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    // MARK: - Actions

    @IBAction func clearHistoryAct(_ sender: UIButton) {

        if history.count < 1 {
            return
        }

        for toRemove in history {
            context.delete(toRemove)
        }

        do {
            try context.save()

            history.removeAll()
            historyTable.reloadData()
        } catch {
            //
        }
    }

    @IBAction func goBackAct(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }

}
