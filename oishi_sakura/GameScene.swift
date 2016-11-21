//
//  GameScene.swift
//  oishi_sakura
//
//  Created by warinporn khantithamaporn on 11/17/2559 BE.
//  Copyright © 2559 Plaping Co., Ltd. All rights reserved.
//

import SpriteKit
import SceneKit
import GameplayKit

class GameScene: SKScene {
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    
    private var emitterNode : SKEmitterNode?
    
    private var sakuraEmitterNode1 : SKEmitterNode?
    private var sakuraEmitterNode2 : SKEmitterNode?
    private var sakuraEmitterNode3 : SKEmitterNode?
    private var sakuraEmitterNode4 : SKEmitterNode?
    private var sakuraEmitterNode5 : SKEmitterNode?
    private var sakuraEmitterNode6 : SKEmitterNode?
    
    override init(size: CGSize) {
        super.init(size: size)
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        self.sakuraEmitterNode1 = self.createSakuraEmitterNode1()
        self.sakuraEmitterNode2 = self.createSakuraEmitterNode2()
        self.sakuraEmitterNode3 = self.createSakuraEmitterNode3()
        self.sakuraEmitterNode4 = self.createSakuraEmitterNode4()
        self.sakuraEmitterNode5 = self.createSakuraEmitterNode5()
        self.sakuraEmitterNode6 = self.createSakuraEmitterNode6()
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func pointDetected(atPoint pos: CGPoint) {
        if let node = self.childNode(withName: "sakura_1") {
            node.position = pos
        } else {
            if let n = self.emitterNode {
                n.position = pos
                self.addChild(n)
            }
        }
    }
    
    func pointDetected(atPoint pos: CGPoint, headEulerAngleY: CGFloat, headEulerAngleZ: CGFloat) {
        for i in 1...6 {
            if let node = self.childNode(withName: "sakura_\(i)") {
                node.position = pos

                // MARK: - change emitter direction
                (node as! SKEmitterNode).emissionAngle = self.calculatedEmissionAngle(y: headEulerAngleY, z: headEulerAngleZ)
            } else {
                if let n = self.getSakuraEmitterNode(atIndex: i) {
                    n.position = pos
                    self.addChild(n)
                }
            }
        }
        
        
        /*if let node = self.childNode(withName: "sakura_1") {
            node.position = pos

            // MARK: - change emitter direction
            (node as! SKEmitterNode).emissionAngle = self.calculatedEmissionAngle(y: headEulerAngleY, z: headEulerAngleZ)
            
            // MARK: - change rotate on y axis
            
        } else {
            if let n = self.emitterNode {
                n.position = pos
                self.addChild(n)
            }
        }*/
    }
    
    func noPointDetected() {
        self.sakuraEmitterNode1?.removeFromParent()
        self.sakuraEmitterNode2?.removeFromParent()
        self.sakuraEmitterNode3?.removeFromParent()
        self.sakuraEmitterNode4?.removeFromParent()
        self.sakuraEmitterNode5?.removeFromParent()
        self.sakuraEmitterNode6?.removeFromParent()
    }
    
    func calculatedEmissionAngle(y: CGFloat, z: CGFloat) -> CGFloat {
        let radZ: CGFloat = CGFloat(z * .pi / 180.0)
        let radY = CGFloat(y * .pi / 180.0)
        
        print("radian Y: \(radY), radian Z: \(radZ)")
        
        if (radY < -0.15) {
            if (radY < -0.3) {
                return CGFloat(180.0 * .pi / 180.0) + radZ * 5.0
            } else {
                return CGFloat(270.0 * .pi / 180.0) + radZ * 5.0
            }
        } else if (radY > 0.15) {
            if (radY > 0.3) {
                return CGFloat(0.0 * .pi / 180.0) + radZ * 5.0
            } else {
                return CGFloat(270.0 * .pi / 180.0) + radZ * 5.0
            }
        } else {
            if (radZ < 0) {
                
            } else {
                
            }
            return CGFloat(270.0 * .pi / 180.0) + radZ
        }
    }
    
    func getSakuraEmitterNode(atIndex index: Int) -> SKEmitterNode? {
        switch index {
        case 1:
            return self.sakuraEmitterNode1
        case 2:
            return self.sakuraEmitterNode2
        case 3:
            return self.sakuraEmitterNode3
        case 4:
            return self.sakuraEmitterNode4
        case 5:
            return self.sakuraEmitterNode5
        case 6:
            return self.sakuraEmitterNode6
        default:
            return nil
        }
    }
    
    func createSakuraEmitterNode1() -> SKEmitterNode? {
        self.sakuraEmitterNode1 = SKEmitterNode()
        self.sakuraEmitterNode1?.name = "sakura_1"
        
        if let emitterNode = self.sakuraEmitterNode1 {
            emitterNode.particleTexture = SKTexture(imageNamed: "sakura_1")
            
            emitterNode.particleBirthRate = 10.0
            
            emitterNode.particleLifetime = 3.0
            emitterNode.particleLifetimeRange = 0.0
            
            emitterNode.particlePositionRange.dx = 20.0
            emitterNode.particlePositionRange.dy = 5.0
            
            emitterNode.emissionAngle = CGFloat(270.0 * .pi / 180.0)
            emitterNode.emissionAngleRange = CGFloat(40.0 * .pi / 180.0)
            
            emitterNode.particleRotation = CGFloat(180.0 * .pi / 180.0)
            emitterNode.particleRotationRange = CGFloat(45.0 * .pi / 180.0)
            emitterNode.particleRotationSpeed = 5.0
            
            emitterNode.particleSpeed = 500.0
            emitterNode.particleSpeedRange = 500.0
            
            emitterNode.particleScale = 0.025
            emitterNode.particleScaleRange = 0.025
            emitterNode.particleScaleSpeed = 0.05
            
            emitterNode.particleAlpha = 1.0
            emitterNode.particleAlphaRange = 0.5
            emitterNode.particleAlphaSpeed = 1.0
            
            emitterNode.particleBlendMode = .alpha
            
            return emitterNode
        }
        
        return nil
    }
    
    func createSakuraEmitterNode2() -> SKEmitterNode? {
        self.sakuraEmitterNode2 = SKEmitterNode()
        self.sakuraEmitterNode2?.name = "sakura_2"
        
        if let emitterNode = self.sakuraEmitterNode2 {
            emitterNode.particleTexture = SKTexture(imageNamed: "sakura_2")
            
            emitterNode.particleBirthRate = 12.0
            
            emitterNode.particleLifetime = 3.0
            emitterNode.particleLifetimeRange = 0.0
            
            emitterNode.particlePositionRange.dx = 20.0
            emitterNode.particlePositionRange.dy = 5.0
            
            emitterNode.emissionAngle = CGFloat(270.0 * .pi / 180.0)
            emitterNode.emissionAngleRange = CGFloat(50.0 * .pi / 180.0)
            
            emitterNode.particleRotation = CGFloat(180.0 * .pi / 180.0)
            emitterNode.particleRotationRange = CGFloat(90.0 * .pi / 180.0)
            emitterNode.particleRotationSpeed = 5.0
            
            emitterNode.particleSpeed = 500.0
            emitterNode.particleSpeedRange = 500.0
            
            emitterNode.particleScale = 0.025
            emitterNode.particleScaleRange = 0.025
            emitterNode.particleScaleSpeed = 0.05
            
            emitterNode.particleAlpha = 1.0
            emitterNode.particleAlphaRange = 0.5
            emitterNode.particleAlphaSpeed = -0.1
            
            emitterNode.particleBlendMode = .alpha
            
            /*
            let action0 = SKAction.scaleX(to: 1.0, duration: 0.2)
            let action1 = SKAction.scaleX(to: 0.8, duration: 0.2)
            let action2 = SKAction.scaleX(to: -0.6, duration: 0.2)
            let action3 = SKAction.scaleX(to: 0.8, duration: 0.2)
            let action4 = SKAction.scaleX(to: 1.0, duration: 0.2)
            
            let action = SKAction.sequence([action0, action1, action2, action3, action4])
             */
            
            let action0 = SKAction.scaleX(to: 1.0, duration: 1.0)
            let action1 = SKAction.scaleX(to: 1.2, duration: 1.0)
            let action2 = SKAction.scaleX(to: 0.5, duration: 1.0)
            let action = SKAction.sequence([action0, action1, action0, action2, action0])
            
            emitterNode.particleAction = action
            
            emitterNode.run(SKAction.repeatForever(action))
            
            return emitterNode
        }
        
        return nil
    }
    
    func createSakuraEmitterNode3() -> SKEmitterNode? {
        self.sakuraEmitterNode3 = SKEmitterNode()
        self.sakuraEmitterNode3?.name = "sakura_3"
        
        if let emitterNode = self.sakuraEmitterNode3 {
            emitterNode.particleTexture = SKTexture(imageNamed: "sakura_3")
            
            emitterNode.particleBirthRate = 10.0
            
            emitterNode.particleLifetime = 1.5
            emitterNode.particleLifetimeRange = 0.0
            
            emitterNode.particlePositionRange.dx = 20.0
            emitterNode.particlePositionRange.dy = 5.0
            
            emitterNode.emissionAngle = CGFloat(270.0 * .pi / 180.0)
            emitterNode.emissionAngleRange = CGFloat(360.0 * .pi / 180.0)
            
            emitterNode.particleRotation = CGFloat(180.0 * .pi / 180.0)
            emitterNode.particleRotationRange = CGFloat(45.0 * .pi / 180.0)
            emitterNode.particleRotationSpeed = 5.0
            
            emitterNode.particleSpeed = 400.0
            emitterNode.particleSpeedRange = -500.0
            
            emitterNode.particleScale = 0.03
            emitterNode.particleScaleRange = 0.025
            emitterNode.particleScaleSpeed = 0.015
            
            emitterNode.particleAlpha = 1.0
            emitterNode.particleAlphaRange = 0.5
            emitterNode.particleAlphaSpeed = -0.25
            
            emitterNode.particleBlendMode = .alpha
            
            let action0 = SKAction.scaleY(to: 1.0, duration: 1.0)
            let action1 = SKAction.scaleY(to: 1.2, duration: 1.0)
            let action2 = SKAction.scaleY(to: 0.5, duration: 1.0)
            let action = SKAction.sequence([action0, action1, action0, action2, action0])
            
            emitterNode.particleAction = action
            
            emitterNode.run(SKAction.repeatForever(action))
            
            return emitterNode
        }
        
        return nil
    }
    
    func createSakuraEmitterNode4() -> SKEmitterNode? {
        self.sakuraEmitterNode4 = SKEmitterNode()
        self.sakuraEmitterNode4?.name = "sakura_4"
        
        if let emitterNode = self.sakuraEmitterNode4 {
            emitterNode.particleTexture = SKTexture(imageNamed: "sakura_4")
            
            emitterNode.particleBirthRate = 3.0
            
            emitterNode.particleLifetime = 1.0
            emitterNode.particleLifetimeRange = 0.5
            
            emitterNode.particlePositionRange.dx = 20.0
            emitterNode.particlePositionRange.dy = 5.0
            
            emitterNode.emissionAngle = CGFloat(270.0 * .pi / 180.0)
            emitterNode.emissionAngleRange = CGFloat(360.0 * .pi / 180.0)
            
            emitterNode.particleRotation = CGFloat(180.0 * .pi / 180.0)
            emitterNode.particleRotationRange = CGFloat(45.0 * .pi / 180.0)
            emitterNode.particleRotationSpeed = 5.0
            
            emitterNode.particleSpeed = 500.0
            emitterNode.particleSpeedRange = 300.0
            
            emitterNode.particleScale = 0.01
            emitterNode.particleScaleRange = 0.1
            emitterNode.particleScaleSpeed = -0.005
            
            emitterNode.particleAlpha = 1.0
            emitterNode.particleAlphaRange = 0.0
            emitterNode.particleAlphaSpeed = -0.25
            
            emitterNode.particleBlendMode = .alpha
            
            return emitterNode
        }
        
        return nil
    }
    
    func createSakuraEmitterNode5() -> SKEmitterNode? {
        self.sakuraEmitterNode5 = SKEmitterNode()
        self.sakuraEmitterNode5?.name = "sakura_5"
        
        if let emitterNode = self.sakuraEmitterNode5 {
            emitterNode.particleTexture = SKTexture(imageNamed: "sakura_5")
            
            emitterNode.particleBirthRate = 2.0
            
            emitterNode.particleLifetime = 3.0
            emitterNode.particleLifetimeRange = 0.0
            
            emitterNode.particlePositionRange.dx = 20.0
            emitterNode.particlePositionRange.dy = 5.0
            
            emitterNode.emissionAngle = CGFloat(270.0 * .pi / 180.0)
            emitterNode.emissionAngleRange = CGFloat(180.0 * .pi / 180.0)
            
            emitterNode.particleRotation = CGFloat(180.0 * .pi / 180.0)
            emitterNode.particleRotationRange = CGFloat(45.0 * .pi / 180.0)
            emitterNode.particleRotationSpeed = 5.0
            
            emitterNode.particleSpeed = 500.0
            emitterNode.particleSpeedRange = 500.0
            
            emitterNode.particleScale = 0.015
            emitterNode.particleScaleRange = 0.025
            emitterNode.particleScaleSpeed = 0.03
            
            emitterNode.particleAlpha = 1.0
            emitterNode.particleAlphaRange = 0.5
            emitterNode.particleAlphaSpeed = 1.0
            
            emitterNode.particleBlendMode = .alpha
            
            let action0 = SKAction.scaleY(to: 1.0, duration: 0.2)
            let action1 = SKAction.scaleY(to: 0.8, duration: 0.2)
            let action2 = SKAction.scaleY(to: 0.6, duration: 0.2)
            let action3 = SKAction.scaleY(to: 0.8, duration: 0.2)
            let action4 = SKAction.scaleY(to: 1.0, duration: 0.2)
            
            let action = SKAction.sequence([action0, action1, action2, action3, action4])
            
            // emitterNode.particleAction = SKAction.repeatForever(action)
            emitterNode.run(SKAction.repeatForever(action))
            
            return emitterNode
        }
        
        return nil
    }
    
    func createSakuraEmitterNode6() -> SKEmitterNode? {
        self.sakuraEmitterNode6 = SKEmitterNode()
        self.sakuraEmitterNode6?.name = "sakura_6"
        
        if let emitterNode = self.sakuraEmitterNode6 {
            emitterNode.particleTexture = SKTexture(imageNamed: "sakura_6")
            
            emitterNode.particleBirthRate = 1.0
            
            emitterNode.particleLifetime = 3.0
            emitterNode.particleLifetimeRange = 0.0
            
            emitterNode.particlePositionRange.dx = 20.0
            emitterNode.particlePositionRange.dy = 5.0
            
            emitterNode.emissionAngle = CGFloat(270.0 * .pi / 180.0)
            emitterNode.emissionAngleRange = CGFloat(40.0 * .pi / 180.0)
            
            emitterNode.particleRotation = CGFloat(180.0 * .pi / 180.0)
            emitterNode.particleRotationRange = CGFloat(45.0 * .pi / 180.0)
            emitterNode.particleRotationSpeed = 5.0
            
            emitterNode.particleSpeed = 500.0
            emitterNode.particleSpeedRange = 500.0
            
            emitterNode.particleScale = 0.01
            emitterNode.particleScaleRange = 0.01
            emitterNode.particleScaleSpeed = 0.025
            
            emitterNode.particleAlpha = 1.0
            emitterNode.particleAlphaRange = 0.5
            emitterNode.particleAlphaSpeed = 1.0
            
            emitterNode.particleBlendMode = .alpha
            
            return emitterNode
        }
        
        return nil
    }
    
    func touchDown(atPoint pos : CGPoint) {
        print("touchDown at \(pos)")
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let label = self.label {
            label.run(SKAction.init(named: "Pulse")!, withKey: "fadeInOut")
        }
        
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
