//
//  ViewController.swift
//  ARDicee
//
//  Created by Tracy Adams on 1/12/23.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    var diceArray = [SCNNode]()

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        // Set the view's delegate
        sceneView.delegate = self
        
        //sceneView.scene.rootNode.addChildNode(node)
        sceneView.autoenablesDefaultLighting = true
        
        //nodes are points in 3D space

   }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        //If there were touches detected:
        if let touch = touches.first {
            let touchLocation = touch.location(in: sceneView)
            
            //placing a point on the Z axis (through screen)
            let results = sceneView.hitTest(touchLocation, types: .existingPlaneUsingExtent)
            
            if let hitResult = results.first{
                addDice(atLocation: hitResult)
              
            }
        }
    }
    
    //external - internal parameter example
    func addDice(atLocation location : ARHitTestResult){
        
        // Create a new scene
        let diceScene = SCNScene(named: "art.scnassets/diceCollada.scn")!
        
        //if dice exists....
        if let diceNode = diceScene.rootNode.childNode(withName: "Dice", recursively: true){
        
        diceNode.position = SCNVector3(
            x: location.worldTransform.columns.3.x,
            y: location.worldTransform.columns.3.y + diceNode.boundingSphere.radius,
            z: location.worldTransform.columns.3.z
        
        )
            
            diceArray.append(diceNode)
        
        //place dice in scene
        sceneView.scene.rootNode.addChildNode(diceNode)
            
            roll(dice: diceNode)
            
        }
        
        
    }
    
    //MARK: - Dice Movement Methods
    
    func rollAll(){
        
        if !diceArray.isEmpty{
            for dice in diceArray {
                roll(dice:dice)
            }
        }
    }
    
    func roll(dice: SCNNode) {
        
        //To change faces of die: no need for y axis.
        let randomX = Float(arc4random_uniform(4) + 1) * (Float.pi/2) //x axis
        
        let randomZ = Float(arc4random_uniform(4) + 1) * (Float.pi/2) //z axis
        
        dice.runAction(SCNAction.rotateBy(
            x: CGFloat(randomX * 5),
            y: 0,
            z: CGFloat(randomZ * 5),
            duration: 0.5))
        
    }
    
    @IBAction func rollAgain(_ sender: UIBarButtonItem) {
        
        rollAll()
    }
    
    override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        rollAll()
    }
    
    @IBAction func removeAllDice(_ sender: UIBarButtonItem) {
        
        if !diceArray.isEmpty {
            for dice in diceArray{
                dice.removeFromParentNode()
            }
            
        }
    }
    
    //MARK: - ARSCNViewDelegateMethods
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else {return}

        //anchor detects plane (tiles) in scene
        let planeNode = createPlane(withPlaneAnchor: planeAnchor)
        
        node.addChildNode(planeNode)
     

    }
    
    //MARK: - Plane Rendering Methods
    
    func createPlane(withPlaneAnchor planeAnchor: ARPlaneAnchor) -> SCNNode {
        
        //creating a place (2D object)
        let plane = SCNPlane(width: CGFloat(planeAnchor.extent.x), height: CGFloat(planeAnchor.extent.z))
        
        let planeNode = SCNNode()
        
        planeNode.position = SCNVector3(x: planeAnchor.center.x, y: 0, z: planeAnchor.center.z)
        
        //Need to convert the vertical plane to a horizontal plane
        //90 degress clockwise
        planeNode.transform = SCNMatrix4MakeRotation(-Float.pi/2, 1, 0, 0)
        
        let gridMaterial = SCNMaterial()
        
        gridMaterial.diffuse.contents = UIImage(named: "art.scnassets/grid.png")
        
        plane.materials = [gridMaterial]
        
        planeNode.geometry = plane
    
        return planeNode
    }

    
}
