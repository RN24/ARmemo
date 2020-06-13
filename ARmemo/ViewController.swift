//
//  ViewController.swift
//  ARmemo
//
//  Created by 西岡亮太 on 2020/06/13.
//  Copyright © 2020 西岡亮太. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        //let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        //sceneView.scene = scene
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal]
        configuration.environmentTexturing = .automatic
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
     lazy var memoSaveURL: URL = {
           do {
               return try FileManager.default
                   .url(for: .documentDirectory,
                        in: .userDomainMask,
                        appropriateFor: nil,
                        create: true)
                   .appendingPathComponent("map.arexperience")
           } catch {
               fatalError("Can't get file save URL: \(error.localizedDescription)")
           }
       }()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: sceneView) else {
            return
        }
        guard let hitTest = sceneView.hitTest(location, types: [.existingPlane]).first else {
            return
        }
        
        let memoAnchor = ARAnchor(name: "Memo", transform: hitTest.worldTransform)
        sceneView.session.add(anchor: memoAnchor)
        
    }
    
    //ロードするボタン
    @IBAction func loadButtonTapped(_ sender: Any) {
        do{
            let data = try Data(contentsOf: memoSaveURL)
            let worldMap: ARWorldMap? = try NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
            
            //WorldMapをconfigurationに渡してARSessionを再開する
            guard let map = worldMap else {
                return
            }
            
            setWorldMapToSession(worldMap: map)
        }catch{
            
            
        }
        
        
    }
    
    private func setWorldMapToSession(worldMap: ARWorldMap){
        let configuration = ARWorldTrackingConfiguration()
        configuration.initialWorldMap = worldMap
        sceneView.session.run(configuration)
 
        
    }
    
    //保存するボタン
        @IBAction func SaveButtonTapped(_ sender: Any) {
        sceneView.session.getCurrentWorldMap(completionHandler: { worldMap, error in
            guard let map = worldMap else{
                return
            }
            
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true)
                try data.write(to: self.memoSaveURL)

                
            }catch{
                print(error)
                
            }
            
        })
        
    }
    


    // MARK: - ARSCNViewDelegate
    

    //Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor.name == "Memo" {
            let textGeometry = SCNText(string: "水曜日", extrusionDepth: 1)
            let textNode = SCNNode(geometry: textGeometry)
            textNode.scale = SCNVector3(0.005, 0.005, 0.005)
            
            node.addChildNode(textNode)
            
        }
        
    }

    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}
