//
//  FireBullet.swift
//  Faceoff
//
//  Created by Huaying Tsai on 11/28/15.
//  Copyright © 2015 Liang. All rights reserved.
//

import Foundation
import SpriteKit

class FireBullet: Weapon{
    
    var burnEffectImg: SKSpriteNode!
    var minusLable: SKLabelNode!
    var damage: Double = 3.0
    var effectTimer: NSTimer!
    var effectTimes = 0
    
    override init(sceneNode :SKScene){
        super.init(sceneNode: sceneNode)
        bulletImageName = Constants.Weapon.WeaponImage.FireBullet
    }
    
    override func fire(){
        super.fire()
        
        let character = getCharacter()!
        let bulletPosition = CGPointMake(character.position.x, character.position.y + character.frame.height + 25)
        let bulletVector = CGVectorMake(0, (sceneNode!.size.height))
        fire(bulletPosition,vector: bulletVector)
        
        let normalizedX = 1 - (bulletPosition.x/sceneNode.size.width)
        btAdvertiseSharedInstance.update("fire-bullet",data: ["x":normalizedX.description])
    }
    
    override func fireFromEnemy(fireInfo: [String]) {
        
        if let normalizedX = Double(fireInfo[0]) {
            let x = CGFloat(normalizedX) * sceneNode.size.width
            let bulletPosition = CGPoint(x: CGFloat(x), y: sceneNode!.size.height)
            let bulletVector = CGVectorMake(0, -sceneNode!.size.height)
            fire(bulletPosition,vector: bulletVector,fromEnemy: true)
        }
        
    }
    func fire(fromPosition: CGPoint, vector: CGVector, fromEnemy: Bool = false){
        if let bulletImageName = bulletImageName {
            bullet = SKSpriteNode(imageNamed: bulletImageName)
            bullet!.xScale = 0.15
            bullet!.yScale = 0.15
            bullet!.position = fromPosition
            bullet!.name = Constants.GameScene.Fire
            PhysicsSetting.setupFire(bullet!)
            
            if fromEnemy {
                bullet!.yScale = -bullet!.yScale
                bullet!.name = Constants.GameScene.EnemyFire
                PhysicsSetting.setupEnemyFire(bullet!)
            }
            
            let bulletAction = SKAction.sequence([SKAction.moveBy(vector, duration: 1.0), SKAction.waitForDuration(3.0/60.0), SKAction.removeFromParent()])
            
            bullet!.runAction(bulletAction)
            sceneNode.addChild(bullet!)
        }
        
    }
    override func getDamage() -> Double {
        return damage
    }
    
    override func effect(character:CharacterNode){
        super.effect(character)
        
        removeEffect()
        burnEffectImg = SKSpriteNode(imageNamed: Constants.Weapon.Effect.Fire)
        burnEffectImg.zPosition = character.zPosition + 1
        burnEffectImg.xScale = 0.5
        burnEffectImg.yScale = 0.5
        burnEffectImg.alpha = 0.3
        character.addChild(burnEffectImg)
        
        effectTimer = NSTimer.scheduledTimerWithTimeInterval(1,
            target: self,
            selector: "burnEffect",
            userInfo: nil,
            repeats: true)
    }
    func burnEffect(){
        
        if effectTimes < 5 {
        
            let character = getCharacter()!
            minusLable = SKLabelNode()
            minusLable.text = "-2"
            minusLable.position.x = character.position.x
            minusLable.position.y = character.position.y + 50
            
            sceneNode.addChild(minusLable)
            
            minusLable.runAction(SKAction.moveToY(character.position.y+150, duration: 1.0))
            minusLable.runAction(SKAction.fadeAlphaTo(0.0, duration: 1.0), completion:{
                self.minusLable.removeFromParent()
            })
            
            
            burnEffectImg.runAction(SKAction.fadeAlphaTo(0.0, duration: 0.5), completion:
                {
                    self.burnEffectImg.runAction(SKAction.fadeAlphaTo(0.3, duration: 0.5))
            })
            
            gameScene?.decreaseHealth(2.0)
            effectTimes++
        }else {
            removeEffect()
        }
    }
    func removeEffect(){
        effectTimer?.invalidate()
        effectTimes = 0
        burnEffectImg?.removeFromParent()
        minusLable?.removeFromParent()
    }
}