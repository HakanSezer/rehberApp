//
//  ViewController.swift
//  RehberUygulaması
//
//  Created by Hakan Sezer on 4.09.2023.
//

import UIKit
import CoreData


//MARK: - CoreData
let appDelegate = UIApplication.shared.delegate as! AppDelegate

class ViewController: UIViewController {
    
    // CoreData üzerindeki veri kayıt işlemlerini gerçekleştirmek için kullanmış olduğum kod.
    let context = appDelegate.persistentContainer.viewContext
    
    
    // MARK: - UI Elements
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var kisilerTableView: UITableView!
    
    var kisilerListesi = [Kisiler]()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kisilerTableView.dataSource = self
        kisilerTableView.delegate =  self
        
        searchBar.delegate = self
    }
    
    
    ///Uygulama Eski ekrana geri döndüğünde kullanıyoruz.
    override func viewWillAppear(_ animated: Bool) {
        //Listeyi güncelle
        turKisilerAl()
        
        //Uygulama'ya geri dönünce TableView'ın yenilenmesini sağlar.
        kisilerTableView.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Bu kod ile hangisine tıklanıldığını anlamış olacağız.
        let index = sender as? Int
        
        /// Label veya TextFieldlera verileri aktarmaya sağlayacaktır.
        if segue.identifier == "toDetay" {
            let gidilecekVC = segue.destination as! KisiDetayViewController
            gidilecekVC.kisi = kisilerListesi[index!]
            
        }
        if segue.identifier == "toGuncelle" {
            let gidilecekVC = segue.destination as! KisiGuncelleViewController
            gidilecekVC.kisi = kisilerListesi[index!]
            
        }
        
        
        
        
    }
    
    // MARK: - Function
    func turKisilerAl() {
        do {
            kisilerListesi = try context.fetch(Kisiler.fetchRequest())
        }catch {
            print(error)
        }
    }
    
    
    
    func aramaYap(kisi_ad:String) {
        let fetchRequest:NSFetchRequest<Kisiler> = Kisiler.fetchRequest()
        
        fetchRequest.predicate = NSPredicate(format: "kisi_ad CONTAINS %@", kisi_ad)
        
        do {
            kisilerListesi = try context.fetch(fetchRequest)
        }catch {
            print(error)
        }
    }
}

    // MARK: - Extension
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    /// Table View içerisinde kaç satır alan olacak.
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Kaç Hucre olması gerektiğini bize gösterir.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return kisilerListesi.count
    }
    
    /// İçerideki sıraya tıklandığı zaman ne yapması gerektiğini bize gösterir.
    /// Kisiler Hucresine tıklanınca ne olacağını anlatıp KısıHucreCell ile bağlantı kurar.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let kisi = kisilerListesi[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "kisiHucre") as! KisiHucreTableViewCell
        
        cell.kisiYaziLabel.text = "\(kisi.kisi_ad!) - \(kisi.kisi_tel!)"
        
        return cell
    }
    
    /// Sola kaydırma işlemi yaparak. Arka planda button oluşturmamızı sağlar.
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        // Silme
        let silAction = UIContextualAction(style: .destructive, title: "Sil") {
            (contextualAction, view, boolValue) in
            
            let kisi = self.kisilerListesi[indexPath.row]
            
            self.context.delete(kisi)
            
            appDelegate.saveContext()
            
            self.turKisilerAl()
            self.kisilerTableView.reloadData()
            
        }
        // Guncelleme
        let guncelleAction = UIContextualAction(style: .normal, title: "Guncelle") {
            (contextualAction, view, boolValue) in
            self.performSegue(withIdentifier: "toGuncelle", sender: indexPath.row)
        }
        
        return UISwipeActionsConfiguration(actions: [silAction,guncelleAction])
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("Arama Sonuc: \(searchText)")
        
        // Bu kod ile birlikte harfleri sildiğim zaman o harfe göre arama yapmaya devam ediyor.
        if searchText == "" {
            turKisilerAl()
        }else {
            aramaYap(kisi_ad: searchText)
        }
        
        kisilerTableView.reloadData()
    }
    
}
