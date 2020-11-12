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

    // MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.

        webview.navigationDelegate = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        self.view.addGestureRecognizer(tapGesture)

        let defaultUrl = URL(string: "https://www.google.com")!
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

    }


    // MARK: Textfield
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        /*
         place for search or goto url logic
         */
        if textField.text != nil && textField.text!.count > 0, let url = URL(string: "https://www.google.com/search?q=\(textField.text!)") {
            let request = URLRequest(url: url)
            webview.load(request)
        } else {
            print("empty")
        }

        dismissKeyboard()
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
        let mylist = webview.backForwardList
        print("open history")

    }

}

