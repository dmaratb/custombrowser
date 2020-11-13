//
//  ViewController.swift
//  browser
//
//  Created by Marat on 08/11/2020.
//

import UIKit
import WebKit

class WebViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate {
    
    // MARK: UI
    @IBOutlet weak var addressBarTF: UITextField!
    @IBOutlet weak var webview: WKWebView!
    
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var forwardBtn: UIButton!
    
    
    // MARK: Data
    let homePageAddr = UserDefaults.standard.string(forKey: "home_page_address") ?? "https://www.google.com/"
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        webview.navigationDelegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)
        
        let defaultUrl = URL(string: homePageAddr)!
        let request = URLRequest(url: defaultUrl)
        webview.load(request)
    }
    
    
    // MARK: Webview
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        addressBarTF.text = webView.title
        
        if webView.canGoBack {
            backBtn.isEnabled = true
        } else {
            backBtn.isEnabled = false
        }
        
        if webView.canGoForward {
            forwardBtn.isEnabled = true
        } else {
            forwardBtn.isEnabled = false
        }
        
        // try to save if needed
        if let address = webView.url?.absoluteString, address.caseInsensitiveCompare(homePageAddr) != .orderedSame {
            let historyItem = HistoryItem(context: context)
            historyItem.title = webView.title
            historyItem.url = webView.url
            historyItem.date = Date()
            
            do {
                try context.save()
            } catch {
                // failed to save context
            }
        }
    }
    
    
    // MARK: Textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        dismissKeyboard()
        
        guard var inputText = textField.text else { return true }
        inputText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        if inputText.count < 1 {
            return true
        }
        
        inputText = inputText.replacingOccurrences(of: " ", with: "+")
        if let query = inputText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL(string: "https://www.google.com/search?q=\(query)") {
            
            let request = URLRequest(url: url)
            webview.load(request)
            
        } else {
            // corrupted input text
        }
        
        return true
    }
    
    @objc func dismissKeyboard() -> Void {
        view.endEditing(true)
    }
    
    
    // MARK: Actions
    @IBAction func goBackAct(_ sender: UIButton) {
        webview.goBack()
    }
    
    @IBAction func goForwardAct(_ sender: UIButton) {
        webview.goForward()
    }
    
    @IBAction func showHistoryAct(_ sender: UIButton) {
        
        // goto history
        let historyViewController = storyboard?.instantiateViewController(withIdentifier: "HistoryViewController") as! HistoryViewController
        
        historyViewController.callback = {
            let request = URLRequest(url: $0)
            self.webview.load(request)
        }
        
        navigationController?.pushViewController(historyViewController, animated: true)
    }
    
}

