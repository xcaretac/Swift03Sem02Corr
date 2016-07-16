//
//  ViewController.swift
//  Swift03Semana01Error
//
//  Created by Xcaret A Ceniceros on 01/07/16.
//  Copyright © 2016 Xcaret Arellano Ceniceros. All rights reserved.
//

import UIKit
/*
Examples of ISBNs:
978-84-376-0494-7 Default
9780821775769 Multiple authors
9780425220351 Multiple authors 2
978-3-16-148410-0 No Image
*/
extension UIImageView {
    public func imageFromUrl(urlString:String) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlString)!) { (data, response, error) in
            dispatch_async(dispatch_get_main_queue()) {
                self.contentMode = UIViewContentMode.ScaleAspectFill
                self.image = UIImage(data: data!)
            }
            }.resume()
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var ISBN: UITextField!
    @IBOutlet weak var titulo: UILabel!
    @IBOutlet weak var autores: UILabel!
    @IBOutlet weak var imagenLibro: UIImageView!
    
    func asincrono(){
        let valorISBN=ISBN.text
        let urls = "https://openlibrary.org/api/books?jscmd=data&format=json&bibkeys=ISBN:"+valorISBN!
        let url = NSURL(string: urls)
        let sesion = NSURLSession.sharedSession()
        let bloque = { (datos:NSData?, resp: NSURLResponse?, error: NSError?) -> Void in
            if resp==nil {
                dispatch_async(dispatch_get_main_queue()){
                    self.titulo.text="El servidor no existe / No hay red"
                }
            }else{
                
                let info = NSData(contentsOfURL: url!)
                if valorISBN?.characters.count != 17 {
                    dispatch_async(dispatch_get_main_queue()){
                        self.titulo.text="Revisa tu ISBN"
                    }
                }else {
                    do{
                        let json = try NSJSONSerialization.JSONObjectWithData(info!, options: NSJSONReadingOptions.MutableLeaves)
                        let diccMain = json as! NSDictionary
                        let diccISBN = diccMain["ISBN:\(valorISBN!)"] as! NSDictionary
                        let tituloLibro = diccISBN["title"] as! NSString as String
                        let autores = diccISBN["by_statement"]
                        if autores == nil {
                            let arrayAutor = diccISBN["authors"] as! NSArray
                            let diccAutor = arrayAutor[0] as! NSDictionary
                            let autorLibro = diccAutor["name"] as! NSString as String
                            dispatch_async(dispatch_get_main_queue()){
                                self.titulo.text="Título: \(tituloLibro) \n Autor: \(autorLibro)"
                            }
                        }else{
                            let autorLibro = diccISBN["by_statement"] as! NSString as String
                            dispatch_async(dispatch_get_main_queue()){
                                self.titulo.text="Título: \(tituloLibro) \n Autor: \(autorLibro)"
                            }
                        }
                        let portada = diccISBN["cover"]
                        if portada == nil {
                            dispatch_async(dispatch_get_main_queue()){
                                self.imagenLibro.image=UIImage(named: "Libro.png")
                            }
                
                        }else {
                            let diccPortada = diccISBN["cover"] as! NSDictionary
                            let cadenaPortada = diccPortada["medium"] as! NSString as String
                            print(cadenaPortada)
                            self.imagenLibro.imageFromUrl(cadenaPortada)
                        }
                    
                    }
                    catch _{
                    
                    }
                }
            }
        }

        let dt = sesion.dataTaskWithURL(url!, completionHandler: bloque)
        dt.resume()
    }
    
    

    @IBAction func consultarLibro(sender: AnyObject) {
        titulo.text=""
        asincrono()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

