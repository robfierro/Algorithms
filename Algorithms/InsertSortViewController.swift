//
//  InsertSortViewController.swift
//  Algorithms
//
//  Created by Roberto Fierro Martinez on 4/24/17.
//  Copyright © 2017 Roberto Fierro Martinez. All rights reserved.
//

import UIKit

class InsertSortViewController: UIViewController, AlgorithmDelegate {

    private let items = 9
    private let spacing = 12
    
    private var list:[UILabel] = [UILabel]()
    private var isSorted:Bool = false
    private var width:CGFloat {
        get {
            let freeSpace = self.view.bounds.width - 20 - CGFloat(self.items+1)*CGFloat(spacing)
            return floor(freeSpace/CGFloat(self.items))
        }
    }
    
    private let stepByStepQueue = DispatchQueue(label: "stepByStepQueue")
    
    private var isSolveStopped:Bool = true
    private var stepIndex:Int = 0
    private var stepSecondaryIndex:Int = 0;
    private var key:UILabel!
    
    enum InsetionSortOperation {
        case grayOutFirstElement
        case moveDown
        case moveLeft
        case moveRight
        case moveUp
    }
    
    private var path:[(element:UILabel, index:Int, operation:InsetionSortOperation)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
    }
    
    func setupView() {
        
        self.view.backgroundColor = UIColor(white: 7, alpha: 3)
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.layer.cornerRadius = 10
        self.view.layer.masksToBounds = true
        for index in 0..<self.items {
            
            let number = Int.randomNonRepeatingNumber(seed: self.items, clean:self.items)
            let label = BottomAlignedLabel()
            label.translatesAutoresizingMaskIntoConstraints = false;
            label.text = String(number+1)
            label.font = UIFont.boldSystemFont(ofSize: 20)
            label.backgroundColor = UIColor.randomNonRepetingColor(clean:self.items)
            label.textColor = label.backgroundColor?.blackOrWhiteContrastingColor()
            label.textAlignment = .center
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
            self.list.append(label)
            self.view.addSubview(label)
            self.addContraintForLabel(label: label, index: index+1)
        }
    }
    
    func multiplier(atIndex index:Int) -> CGFloat {
        
        let xWidthPorcent:CGFloat = width/(self.view.bounds.width - 20)
        let xSpacingPorcent:CGFloat = CGFloat(spacing)/(self.view.bounds.width - 20)
        let xLeadTrailSpace:CGFloat = 20.0/self.view.bounds.width
        return ((xWidthPorcent+xSpacingPorcent)*CGFloat(index)*2) - xLeadTrailSpace
    }
    
    func addContraintForLabel(label:UILabel, index:Int) {
        
        let number = CGFloat(Int(label.text!)!)
        let heightConstant = width + width*(number/2)
        
        let horizontalConstraint = NSLayoutConstraint(item: label, attribute: .centerX, relatedBy: .equal, toItem: self.view, attribute: .centerX, multiplier: multiplier(atIndex: index), constant: 0)
        horizontalConstraint.identifier = "x-\(label.text)"
        let verticalConstraint = NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .centerY, multiplier: 1, constant: 0)
        verticalConstraint.identifier = "y-\(label.text)"
        let widthConstraint = NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: width)
        let heightConstraint = NSLayoutConstraint(item: label, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant:heightConstant)
        self.view.addConstraints([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func moveLabelDown(label:UILabel) {
        
        for contraint in self.view.constraints where (contraint.identifier == "y-\(label.text)") {
            contraint.constant = 150
            self.view.layoutIfNeeded()
        }
    }
    
    func moveLabelUp(label:UILabel) {
        
        for contraint in self.view.constraints where (contraint.identifier == "y-\(label.text)") {
            contraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    func moveLabelLeft(atIndex index:Int, label:UILabel) {
        
        for var contraint in self.view.constraints where (contraint.identifier == "x-\(label.text)") {
            contraint = contraint.setMultiplier(multiplier: self.multiplier(atIndex: index))
            self.view.layoutIfNeeded()
        }
    }
    
    func moveLabelRight(atIndex index:Int, label:UILabel) {
        
        for var contraint in self.view.constraints where (contraint.identifier == "x-\(label.text)") {
            contraint = contraint.setMultiplier(multiplier: self.multiplier(atIndex: index+2))
            self.view.layoutIfNeeded()
        }
    }
    
    func animateLabelDown(label:UILabel, completion:@escaping (Void) -> Void) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: Double(0.5), delay:0.1, options: [.curveEaseInOut], animations: {
                self.moveLabelDown(label: label)
                }, completion: { success in
                    completion()
            })
        }
    }
    
    func animateLabelsLeftToRight(left:(UILabel, Int), right:(UILabel,Int), completion:@escaping (Void) -> Void) {

        DispatchQueue.main.async {
            UIView.animate(withDuration: Double(0.5), delay:0.1, options: [.curveEaseInOut], animations: {
                self.moveLabelLeft(atIndex: left.1, label:left.0)
                self.moveLabelRight(atIndex: right.1, label:right.0)
                }, completion: { success in
                    completion()
            })
        }
    }
    
    func animateLabelUp(label:UILabel, completion:@escaping (Void) -> Void) {
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: Double(0.5), delay:0.2, options: [.curveEaseInOut], animations: {
                self.moveLabelUp(label:label)
                }, completion: { success in
                    label.backgroundColor = .gray
                    label.textColor = .white
                    completion()
            })
        }
    }
    
    func insertionSort(list:[Int]) -> [Int] {
        
        var A = list
        for primaryIndex in 1..<A.count {
            
            let key = A[primaryIndex]
            var secondaryIndex = primaryIndex - 1
            
            while (secondaryIndex >= 0 && key > A[secondaryIndex]) {
                A[secondaryIndex+1] = A[secondaryIndex]
                secondaryIndex-=1
            }
            
            A[secondaryIndex+1] = key
            
        }
        
        return A
    }
    
    func grayOutFirsElementOperation() {
        
        self.stepByStepQueue.sync {
            self.list.first!.backgroundColor = .gray
            self.list.first!.textColor = .white
            self.path.append((self.list.first!, index: 0, operation:.grayOutFirstElement))
        }
    }
    
    func moveDownElement() {
        self.stepByStepQueue.sync {
            self.key = self.list[self.stepIndex]
            self.animateLabelDown(label: self.key) {
                
                if(!self.isSolveStopped) { self.step() }
            }
            self.path.append((self.key, index: self.stepIndex, operation:.moveDown))
            self.stepSecondaryIndex = self.stepIndex-1;
        }
    }
    
    func moveLeftToRightElements() {
        self.stepByStepQueue.sync {
            self.animateLabelsLeftToRight(left: (key, self.stepSecondaryIndex + 1), right: (self.list[self.stepSecondaryIndex], self.stepSecondaryIndex)) {
                
                if(!self.isSolveStopped) { self.step() }
            }
            
            self.path.append((self.key, index: self.stepSecondaryIndex + 1, operation:.moveLeft))
            self.path.append((self.list[self.stepSecondaryIndex], index: self.stepSecondaryIndex, operation:.moveRight))
            self.list[self.stepSecondaryIndex + 1] = self.list[self.stepSecondaryIndex]
            self.stepSecondaryIndex-=1
        }
    }
    
    func moveUpKeyElement(){
        self.stepByStepQueue.sync {
            self.animateLabelUp(label: self.key) {
                
                if(!self.isSolveStopped) { self.step() }
            }
            self.path.append((self.key, index: self.stepSecondaryIndex + 1, operation:.moveUp))
            self.list[self.stepSecondaryIndex + 1] = self.key
            self.stepIndex+=1
        }
    }
    
    public func solve() {
        
        self.isSolveStopped = false
        self.step()
    }
    
    public func step(shouldStopSolve:Bool = false) {
        
        if shouldStopSolve {
            self.isSolveStopped = true
        }
        
        if(self.stepIndex == 0) {
            self.grayOutFirsElementOperation()
            self.stepIndex+=1
        }
        
        guard self.stepIndex < self.list.count else {
            self.isSorted = true;
            self.isSolveStopped = true;
            return
        }
        
        let operation:InsetionSortOperation = (self.path.last?.operation)!
        
        switch (operation) {
            case InsetionSortOperation.grayOutFirstElement:
                
                self.moveDownElement()
                break
            case InsetionSortOperation.moveDown: fallthrough
            case InsetionSortOperation.moveRight:
                if self.stepSecondaryIndex >= 0 && self.list[self.stepSecondaryIndex].textToInt() < self.key.textToInt() {
                    self.moveLeftToRightElements()
                } else {
                    self.moveUpKeyElement()
                }
                break
            case InsetionSortOperation.moveUp:
                
                self.moveDownElement()
                break
            default:
                break
        }
        
    }
    
    public func back() {
        
    }
    
    public func shuffle() {
        
    }

}
