//
//  GameViewController.swift
//  KillWoodsman
//
//  Created by Y on 25.12.2020.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true // отображение частоты кадров
        skView.showsNodeCount = true // отображение кол-ва нажатий
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
        
    }
}
