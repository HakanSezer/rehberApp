//
//  KisiGuncelleViewController.swift
//  RehberUygulaması
//
//  Created by Hakan Sezer on 4.09.2023.
//

import UIKit

class KisiGuncelleViewController: UIViewController {
    
    // CoreData üzerindeki veri kayıt işlemlerini gerçekleştirmek için kullanmış olduğum kod.
    let context = appDelegate.persistentContainer.viewContext
    
    @IBOutlet weak var kisiAdTextField: UITextField!
    
    @IBOutlet weak var kisiTelTextField: UITextField!
    
    var kisi:Kisiler?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if  let k = kisi {
            // Bu textField ile guncelleye bastığımız zaman Guncelleme bölümüne o seçtiğimiz ad ve tel numarası aktırılacak.
            kisiTelTextField.text = k.kisi_tel
            kisiAdTextField.text = k.kisi_ad
        }
    }
    
    
    @IBAction func guncelle(_ sender: Any) {
        
        if let k = kisi ,let ad = kisiAdTextField.text , let tel = kisiTelTextField.text {
            k.kisi_ad = ad
            k.kisi_tel = tel
            
            appDelegate.saveContext()
        }
    }
    
}
