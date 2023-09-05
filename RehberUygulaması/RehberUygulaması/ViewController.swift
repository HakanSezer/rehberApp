//
//  ViewController.swift
//  RehberUygulaması
//
//  Created by Hakan Sezer on 4.09.2023.
//

import UIKit
import CoreData


//MARK: - CoreData
// Bu model ile CoreDatayı kullanılabilir hale getirdik ViewController içerisinde olmamamsı bizim her yerden ulaşmamızı sağlayacaktır.
let appDelegate = UIApplication.shared.delegate as! AppDelegate

class ViewController: UIViewController {
    
    // CoreData üzerindeki veri kayıt işlemlerini gerçekleştirmek için kullanmış olduğum kod.
    // Silme ve Güncelleme işlemleri için gereklidir.
    let context = appDelegate.persistentContainer.viewContext
    
    
    // MARK: - UI Elements
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var kisilerTableView: UITableView!
    
    var kisilerListesi = [Kisiler]()
    
    
    var aramaYapiliyorMu = false
    var aramaKelimesi: String?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        kisilerTableView.dataSource = self
        kisilerTableView.delegate =  self
        
        searchBar.delegate = self
    }
    
    
    ///Uygulama Eski ekrana geri döndüğünde kullanıyoruz.
    override func viewWillAppear(_ animated: Bool) {
        
        // arama yapılıyorsa çalışacak.
        if aramaYapiliyorMu {
            aramaYap(kisi_ad: aramaKelimesi!)
        }else {
            //Listeyi güncelle
            turKisilerAl()
        }
        
        //Listeyi güncelle
        turKisilerAl()
        
        //Uygulama'ya geri dönünce TableView'ın yenilenmesini sağlar.
        // Ara yüzde çalıştığımız için güncelleme buttonuna tıkladıktan ve geri döndükten sonra çalışan kodtur.
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
        
        // cellForAt üzerinden hucre'ye tıkalayıp güncelle dediğimiz anda ne olacağını gösteriyoruz. Eğer identify uyuşuyorsa bu yoldan devam ediyor.
        if segue.identifier == "toGuncelle" {
            let gidilecekVC = segue.destination as! KisiGuncelleViewController
            gidilecekVC.kisi = kisilerListesi[index!]
            
        }
        
        
        
        
    }
    
    // MARK: - Function
    // Veri tabanından tüm bilgileri alıp kişilerListesine aktarmayı sağlıyor.
    func turKisilerAl() {
        do {
            kisilerListesi = try context.fetch(Kisiler.fetchRequest())
        }catch {
            print(error)
        }
    }
    
    
    
    func aramaYap(kisi_ad:String) {
        let fetchRequest:NSFetchRequest<Kisiler> = Kisiler.fetchRequest()
        
        // içermiyor mu içeriyor mu diye arama yapıyor.
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
            
            // Silmek istediğimiz nesneyi seçiyoruz.
            let kisi = self.kisilerListesi[indexPath.row]
            
            self.context.delete(kisi)
            
            appDelegate.saveContext()
            
            // Ekranı güncelleyen kodtur. Arama yaptığı sırada bir şeyi sildiğimizde alt kalan farklı bir hucreyi buraya çıkarmamasını sağlıyor.
            // arama yapılıyorsa çalışacak.
            if self.aramaYapiliyorMu {
                self.aramaYap(kisi_ad: self.aramaKelimesi!)
            }else {
                //Listeyi güncelle
                self.turKisilerAl()
            }
            
            // Sildikten sonra ara yüzü yeniliyoruz.
            //self.turKisilerAl()
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
        
        // Arama kelimesi bölümüne harfi kayıt etti ve if döngüsüne attı.
        aramaKelimesi = searchText
        
        // Bu kod ile birlikte harfleri sildiğim zaman o harfe göre arama yapmaya devam ediyor.
        //
        if searchText == "" {
            aramaYapiliyorMu = false
            turKisilerAl()
        }else {
            // arama yapılıyorsa çalışır.
            aramaYapiliyorMu = true
            aramaYap(kisi_ad: aramaKelimesi!)
        }
        
        kisilerTableView.reloadData()
    }
    
}
