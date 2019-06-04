//
//  IntroduceController.swift
//  VAC Agent
//
//  Created by Mytruong on 3/25/19.
//  Copyright © 2019 Mytruong. All rights reserved.
//

import UIKit

class IntroduceController: UIViewController {
    
    let lblPlay = UILabel()
    let lblStill = UILabel()
    let lblGame = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        let const:CGFloat = 100
        view.addSubview(views: lblPlay, lblStill, lblGame)
        lblStill.widthAnchor.constraint(equalToConstant: const).isActive = true
        lblStill.heightAnchor.constraint(equalToConstant: const).isActive = true
        lblStill.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        lblStill.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        lblPlay.widthAnchor.constraint(equalToConstant: const).isActive = true
        lblPlay.heightAnchor.constraint(equalToConstant: const).isActive = true
        lblPlay.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        lblPlay.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -250).isActive = true
    
        
        lblGame.widthAnchor.constraint(equalToConstant: const).isActive = true
        lblGame.heightAnchor.constraint(equalToConstant: const).isActive = true
        lblGame.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        lblGame.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 250).isActive = true
        
        lblPlay.text = "Chơi"
        lblStill.text = "Mà"
        lblGame.text = "Học"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 1, animations: {
            
        }) { (finish) in
            UIView.animate(withDuration: 0.5, animations: {
                
            }, completion: { (fin) in
                
            })
        }
    }
}
