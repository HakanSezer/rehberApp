//
//  KisiEkleViewController.swift
//  RehberUygulaması
//
//  Created by Hakan Sezer on 4.09.2023.
//

import UIKit

class KisiEkleViewController: UIViewController {
    
    // CoreData üzerindeki veri kayıt işlemlerini gerçekleştirmek için kullanmış olduğum kod.
    let context = appDelegate.persistentContainer.viewContext
    
    @IBOutlet weak var kisiAdTextField: UITextField!
    
    @IBOutlet weak var kisiTelTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func ekle(_ sender: Any) {
        
        if let ad = kisiAdTextField.text , let tel = kisiTelTextField.text {
            let kisi = Kisiler(context: context)
            kisi.kisi_ad = ad
            kisi.kisi_tel = tel
            
            appDelegate.saveContext()
        }
        
        
    }
    
}
