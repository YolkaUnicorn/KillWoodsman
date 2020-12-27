//
//  GameScene.swift
//  KillWoodsman
//
//  Created by Y on 25.12.2020.
//

import SpriteKit
import GameplayKit


func +(left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}
func -(left:CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}
func *(point:CGPoint, scalar:CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}
func /(point:CGPoint, scalar:CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}


#if !(arch(x86_64) || arch(arm64))
func sqrt(a:CGFloat) -> CGFloat {
    return CGFloat(sqrt(Float(a)))
}
#endif

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(x*x + y*y)
    }
    func normalized() -> CGPoint {
        return self / length()
    }
}



class GameScene: SKScene {
    
    struct PhysicsCategory {
        static let none          : UInt32 = 0
        static let all           : UInt32 = UInt32.max
        static let monster       : UInt32 = 0b1             // 1
        static let projectile    : UInt32 = 0b10            // 2
    }
    
    
    let player = SKSpriteNode(imageNamed: "player")
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        addChild(player)
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        
        
        
        
        func random() -> CGFloat {
            return CGFloat(Float(arc4random()) / 0xFFFFFFFF) // Этот блок кода включает в себя некоторые вспомогательные методы для генерации случайного числа в диапазоне с помощью arc4random(). Этого достаточно для простых потребностей в генерации случайных чисел в этой игре, но если вы хотите более продвинутую функциональность, ознакомьтесь с API случайных чисел в GameplayKit.
        }
        
        func random(min: CGFloat, max: CGFloat) -> CGFloat {
            return random () * (max - min) + min
        }
        
        func addMonster() { // Первая часть addMonster имеет смысл, основываясь на том, что мы уже узнали: мы выполняем несколько простых вычислений, чтобы определить, где мы хотим создать объект, устанавливаем положение объекта и добавляем его в сцену таким же образом, как мы сделали для спрайта игрока.
            
            // создаем спрайт
            let monster = SKSpriteNode(imageNamed: "monster")
            
            monster.physicsBody = SKPhysicsBody(rectangleOf: monster.size) // Создайте физическое тело для спрайта. В этом случае тело определяется как прямоугольник того же размера, что и спрайт, так как это приличное приближение для монстра
            monster.physicsBody?.isDynamic = true // Установите спрайт динамическим. Это означает, что физический движок не будет контролировать движение монстра. Вы будете проходить через уже написанный код, используя действия перемещения
            monster.physicsBody?.categoryBitMask = PhysicsCategory.monster // Установите битовую маску категории как monsterCategory, которую вы определили ранее
            monster.physicsBody?.contactTestBitMask = PhysicsCategory.projectile // contactTestBitMaskуказывает, какие категории объектов этот объект должен уведомлять прослушиватель контакта при их пересечении. Здесь вы выбираете снаряды
            monster.physicsBody?.collisionBitMask = PhysicsCategory.none // collisionBitMask указывает, на какие категории объектов этот объект обрабатывает ответные контакты физического движка (т.е. отскакивает). Вы не хотите, чтобы монстр и снаряд отскакивали друг от друга - это нормально для них, чтобы пройти друг через друга в этой игре - так что вы установили это на .none
            
            // выбираем где родить монстра по оси Y
            let actualY = random(min: monster.size.height / 2, max: size.height - monster.size.height / 2)
            
            
            // поместить монстра за пределами экрана вдоль правого края
            // и вдоль случайного положения оси Y как вычеслено выше в actualY
            monster.position = CGPoint(x: size.width + monster.size.width / 2, y: actualY)
            
            // добавить монстра в сцену
            addChild(monster)
            
            // определить скорость монстра
            let actualDuration = random(min: CGFloat(2.0), max: CGFloat(4.0))
            
            // создать действие
            // SKAction.move(to:duration:): Это действие используется для перемещения объекта за пределами экрана влево. Вы можете указать, сколько времени должно занять движение, и здесь вы варьируете продолжительность случайным образом от 2-4 секунд
            // SKAction.removeFromParent(): SpriteKit поставляется с полезным действием, которое удаляет узел из родительского элемента, эффективно удаляя его из сцены. Здесь вы используете это действие, чтобы удалить монстра из сцены, когда он больше не виден. Это важно, потому что в противном случае у вас был бы бесконечный запас монстров и в конечном итоге вы бы потребляли все ресурсы устройства
            // SKAction.sequence(_:): Действие последовательности позволяет связать вместе последовательность действий, которые выполняются по порядку, по одному. Таким образом, вы можете сначала выполнить действие «переместить к», а после его завершения выполнить действие «удалить из родительского»
            let actionMove = SKAction.move(to: CGPoint(x: -monster.size.width / 2, y: actualY), duration: TimeInterval(actualDuration))
            let actionMoveDone = SKAction.removeFromParent()
            monster.run(SKAction.sequence([actionMove, actionMoveDone]))
            

        }

        // Здесь вы запускаете последовательность действий для вызова блока кода, а затем ждете 1 секунду. Вы повторяете эту последовательность действий бесконечно.
        run(SKAction.repeatForever(SKAction.sequence([SKAction.run(addMonster),SKAction.wait(forDuration: 1.0)])))
        
    }

    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // нажать куда-то для расчетов
        guard let touch = touches.first else {
            return
        }
        // настроить начальное положение снаряда
        let touchLocation = touch.location(in: self)
        //определить  смещение местоположения к снаряду
        let projectile = SKSpriteNode(imageNamed: "projectile")
        projectile.position = player.position
        
        projectile.physicsBody = SKPhysicsBody(circleOfRadius: projectile.size.width/2)
        projectile.physicsBody?.isDynamic = true
        projectile.physicsBody?.categoryBitMask = PhysicsCategory.projectile
        projectile.physicsBody?.contactTestBitMask = PhysicsCategory.monster
        projectile.physicsBody?.usesPreciseCollisionDetection = true
        
        // смещение
        let offset = touchLocation - projectile.position
        // проверить позицию
        if offset.x < 0 { return }
        
        addChild(projectile)
        // получить направление куда стрелять
        let direction = offset.normalized()
        // сделали так, чтобы он стрелял достаточно далеко, чтобы попасть за край экрана
        let shootAmount = direction * 1000
        // добавить сумму снаряда к позиции
        let realDest = shootAmount + projectile.position
        // создать действие
        let actionMove = SKAction.move(to: realDest, duration: 2.0)
        let actionMoveDone = SKAction.removeFromParent()
        projectile.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func projectileDidCollideWithMonster (projectile: SKSpriteNode, monster: SKSpriteNode) {
        print("Hit")
        projectile.removeFromParent()
        monster.removeFromParent()
    }

    
}

extension GameScene : SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody : SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if ((firstBody.categoryBitMask & PhysicsCategory.monster != 0 ) && (secondBody.categoryBitMask & PhysicsCategory.projectile != 0)) {
            if let monster = firstBody.node as? SKSpriteNode, let projectile = secondBody.node as? SKSpriteNode {
                projectileDidCollideWithMonster(projectile: projectile, monster: monster)
            }
        }
        
    }
    
}
