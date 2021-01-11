//
//  ViewController.swift
//  CurrencyConverter
//
//  Created by Paresh Thakor on 11/01/21.
//

import UIKit

import UIKit
import MessageUI
class ViewController: UIViewController {

    @IBOutlet weak var valueField: UITextField! {
        didSet {
            valueField?.delegate = self
            self.addDoneButtonOnKeyboard()
        }
    }
    
    @IBOutlet weak var conversionFieldStack: UIStackView!
    @IBOutlet weak var exchangeButton: UIButton!
    @IBOutlet weak var conversionListView: UIView!
    
    @IBOutlet weak var loaderView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var indicatorLabel: UILabel!
    
    var currentQuote: CurrencyPedia? {
        didSet {
            if self.selectedCurrency == nil {
                if let usdCurrency = DBManager.realm.objects(Currency.self).filter("code = %@", "USD").first {
                    self.selectedCurrency = usdCurrency
                }
            }
        }
    }
    var selectedCurrency: Currency? {
        didSet {
            self.exchangeButton.setTitle(self.selectedCurrency?.name, for: .normal)
        }
    }
    
    var conversionController : ConversionListController?
    var exchangeListController : ExchangeListViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("#### REALM LOCATION: >>>>" + (DBManager.realm.configuration.fileURL?.absoluteString ?? ""))
        
        let gr = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(gr)
        
        self.refreshExchange()
        self.deviceOrientationChanged()
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshExchangeRateNotificationHandler(_:)), name: .kRefreshExchangeRateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationChanged), name: UIDevice.orientationDidChangeNotification, object: nil)

    }
    
    deinit {
        self.conversionController?.willMove(toParent: nil)
        self.conversionController?.removeFromParent()
        self.conversionController?.view.removeFromSuperview()
        
        NotificationCenter.default.removeObserver(self, name: .kRefreshExchangeRateNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    func addConversionListView() {
        if self.conversionController == nil {
            let conversionController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: ConversionListController.Storyboard_ID) as! ConversionListController
            
            self.conversionListView.addSubview(conversionController.view)
            self.addChild(conversionController)
            conversionController.didMove(toParent: self)
            
            conversionController.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                conversionController.view.centerXAnchor.constraint(equalTo: self.conversionListView.centerXAnchor),
                conversionController.view.centerYAnchor.constraint(equalTo: self.conversionListView.centerYAnchor),
                conversionController.view.heightAnchor.constraint(equalTo: self.conversionListView.heightAnchor),
                conversionController.view.widthAnchor.constraint(equalTo: self.conversionListView.widthAnchor)
            ])
            
            conversionController.originalValue = 1.0
            self.conversionController = conversionController
        }
        
        self.conversionController?.quote = self.currentQuote
        self.conversionController?.refreshList(self.conversionController?.originalValue ?? 1.0, self.selectedCurrency)
    }
    
    func addDoneButtonOnKeyboard() {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction))

        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        valueField.inputAccessoryView = doneToolbar
    }

    @objc func doneButtonAction() {
        valueField.resignFirstResponder()
        
        if valueField.text?.isEmpty ?? false {
            valueField.text = "1"
        }
        
        self.performConversion()
    }
    
    func performConversion() {
        self.conversionController?.refreshList(Double(valueField.text ?? "0.0") ?? 0.0, self.selectedCurrency)
    }

    
    @IBAction func refreshExchangeRateTapped(_ sender: UIButton) {
        self.refreshExchange()
    }
    
    @IBAction func exchangeSelectionButtonTapped(_ sender: UIButton) {
        let buttonFrame = sender.frame
        
        if self.exchangeListController == nil {
            self.exchangeListController = self.storyboard?.instantiateViewController(withIdentifier: ExchangeListViewController.Storyboard_ID) as? ExchangeListViewController
            self.exchangeListController?.modalPresentationStyle = .popover
            self.exchangeListController?.delegate = self
        }
        
        self.exchangeListController?.quote = self.currentQuote
        self.exchangeListController?.selectedCurrency = self.selectedCurrency
         
        if let popoverPresentationController = self.exchangeListController?.popoverPresentationController {
            popoverPresentationController.permittedArrowDirections = .any
            popoverPresentationController.sourceView = self.view
            popoverPresentationController.sourceRect = buttonFrame
            popoverPresentationController.delegate = self
            
            if let popoverController = self.exchangeListController {
                present(popoverController, animated: true)
            }
        }
        
        self.tapAction()
    }
    
    func refreshExchange() {
        self.indicator.startAnimating()
        self.loaderView.isHidden = false
        
        DBManager.reloadExchangeData { (quote, error) in
            
            if let quote = quote {
                self.currentQuote = quote
            }
            
            if let error = error {
                alert("Error", error.localizedDescription, presented: self)
            }
            
            DispatchQueue.main.async { [weak self] in
                
                guard let self = self else {
                    return
                }
                
                self.indicator.stopAnimating()
                self.loaderView.isHidden = true
                
                self.addConversionListView()
            }
        }
    }
    
    @objc func refreshExchangeRateNotificationHandler(_ notification: Notification ) {
        self.refreshExchange()
    }
    
    @objc func tapAction() {
        self.view.endEditing(true)
    }
    
    @objc func appBecomeActive() {
        self.refreshExchange()
    }
    
    @objc func deviceOrientationChanged() {
        if UIDevice.current.orientation.isLandscape {
            conversionFieldStack.axis = .horizontal
        } else if UIDevice.current.orientation.isPortrait {
            conversionFieldStack.axis = .vertical
        }
    }
}

extension ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        if textField.text?.isEmpty ?? false {
            textField.text = "1"
        }
        
        self.performConversion()
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let sRange = Range(range, in: textField.text ?? "") {
            let newString = textField.text?.replacingCharacters(in: sRange, with: string)
            return (newString?.count ?? 0) <= 12
        }
        
        return true
    }
}

extension ViewController: ExchangeListDelegate {
    func exchangeListCurrencySelected(_ currency: Currency) -> Void {
        self.selectedCurrency = currency
        self.performConversion()
        
        if let exchangeList = self.exchangeListController {
            exchangeList.dismiss(animated: true, completion: nil)
        }
    }
}

extension ViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
     
    //UIPopoverPresentationControllerDelegate
    func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
     
    }
     
    func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
        return true
    }
}


