//
//  AlgorithmViewController.swift
//  Algorithms
//
//  Created by Roberto Fierro Martinez on 4/22/17.
//  Copyright © 2017 Roberto Fierro Martinez. All rights reserved.
//

import UIKit

protocol AlgorithmDelegate: class {
    func solve()
    func step(shouldStopSolve:Bool)
    func back(shouldStopSolve:Bool)
    func shuffle()
}

class AlgorithmViewController: UIViewController {
    
    weak var delegate:AlgorithmDelegate?

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak private var containerYConstraint: NSLayoutConstraint!
    @IBOutlet weak private var containerXConstraint: NSLayoutConstraint!
    @IBOutlet weak private var containerWidth750Constraint: NSLayoutConstraint!
    @IBOutlet weak private var containerWidth1000Constraint: NSLayoutConstraint!
    @IBOutlet weak private var playButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak private var playButtonYConstraint: NSLayoutConstraint!
    @IBOutlet weak private var playButtonXConstraint: NSLayoutConstraint!
    @IBOutlet weak private var shuffleButtonXConstraint: NSLayoutConstraint!
    @IBOutlet weak private var shuffleButtonYConstraint: NSLayoutConstraint!
    
    private lazy var algorithmController: UIViewController? = {
        
        var viewController:UIViewController?
        switch (self.title!) {
            case "Insertion Sort":
                viewController = InsertSortViewController()
                self.delegate = viewController as! InsertSortViewController
            break
            default:
                break
        }
        
        if let controller = viewController {
            self.add(asChildViewController: controller)
        }
        
        return viewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.add(asChildViewController: self.algorithmController)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.remove(asChildViewController: self.algorithmController)
        self.algorithmController = nil;
        self.delegate = nil;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillLayoutSubviews() {
        
        if UIDevice.current.orientation == .landscapeLeft ||
           UIDevice.current.orientation == .landscapeRight {
            
            self.containerXConstraint = self.containerXConstraint.setMultiplier(multiplier: 0.52)
            self.containerYConstraint = self.containerYConstraint.setMultiplier(multiplier: 1)
            self.containerWidth1000Constraint = self.containerWidth1000Constraint.setMultiplier(multiplier: 0.48)
            self.containerWidth750Constraint = self.containerWidth750Constraint.setMultiplier(multiplier: 0.48)
            
            self.playButtonXConstraint = self.playButtonXConstraint.setMultiplier(multiplier: 1.65)
            self.playButtonYConstraint = self.playButtonYConstraint.setMultiplier(multiplier: 0.20)
            self.playButtonWidthConstraint = self.playButtonWidthConstraint.setMultiplier(multiplier: 0.30)
            
            self.shuffleButtonXConstraint = self.shuffleButtonXConstraint.setMultiplier(multiplier: 1.65)
            self.shuffleButtonYConstraint = self.shuffleButtonYConstraint.setMultiplier(multiplier: 0.86)
        } else {
            self.containerXConstraint = self.containerXConstraint.setMultiplier(multiplier: 1)
            self.containerYConstraint = self.containerYConstraint.setMultiplier(multiplier: 0.65)
            self.containerWidth1000Constraint = self.containerWidth1000Constraint.setMultiplier(multiplier: 0.9)
            self.containerWidth750Constraint = self.containerWidth750Constraint.setMultiplier(multiplier: 0.9)
            
            self.playButtonXConstraint = self.playButtonXConstraint.setMultiplier(multiplier: 1.45)
            self.playButtonYConstraint = self.playButtonYConstraint.setMultiplier(multiplier: 1.65)
            self.playButtonWidthConstraint = self.playButtonWidthConstraint.setMultiplier(multiplier: 0.40)
            
            self.shuffleButtonXConstraint = self.shuffleButtonXConstraint.setMultiplier(multiplier: 0.55)
            self.shuffleButtonYConstraint = self.shuffleButtonYConstraint.setMultiplier(multiplier: 1.84)
        }
        
    }
    
    private func add(asChildViewController viewController: UIViewController?) {
        
        if let controller = viewController {
            
            self.addChildViewController(controller)
            self.containerView.addSubview(controller.view)
            self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[algorithmView]|", options: [], metrics: nil, views: ["algorithmView":controller.view]))
            self.containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[algorithmView]|", options: [], metrics: nil, views: ["algorithmView":controller.view]))
            
            controller.didMove(toParentViewController: self)
        }
        
        
    }
    
    private func remove(asChildViewController viewController: UIViewController?) {

        if let controller = viewController {
            controller.willMove(toParentViewController: nil)
            controller.view.removeFromSuperview()
            controller.removeFromParentViewController()
        }
    }

    @IBAction func playAlgorithm(_ sender: AnyObject) {
        
        self.delegate?.solve()
        
    }
    
    @IBAction func stepByStepAlgorithm(_ sender: AnyObject) {
        self.delegate?.step(shouldStopSolve:true)
    }
    
    @IBAction func stepBackAlgorithm(_ sender: AnyObject) {
        self.delegate?.back(shouldStopSolve: true)
    }
    

}
