//
//  InsertSortViewController.swift
//  Algorithms
//
//  Created by Roberto Fierro Martinez on 4/24/17.
//  Copyright © 2017 Roberto Fierro Martinez. All rights reserved.
//

import UIKit

class InsertSortViewController: UIViewController, AlgorithmDelegate {

    // MARK: - Enums
    private enum InsetionSortOperation {
        case grayOutFirstElement
        case moveDown
        case moveLeft
        case moveRight
        case moveUp
    }
    
    // MARK: - Configuration Constants
    private let items = 9
    
    // MARK: - UI Constants
    private let spacing = 12
    private let stepByStepQueue = DispatchQueue(label: "stepByStepQueue")
    
    // MARK: - UI Variables
    private var labelColors:Dictionary<String, UIColor> = Dictionary<String, UIColor>()
    private var width:CGFloat {
        get {
            let freeSpace = self.view.bounds.width - 20 - CGFloat(self.items+1)*CGFloat(spacing)
            return floor(freeSpace/CGFloat(self.items))
        }
    }
    
    // MARK: - Model Variables
    private var list:[UILabel] = [UILabel]()
    private var stepIndex:Int = 0
    private var stepSecondaryIndex:Int = 0;
    private var key:UILabel!
    
    private var isSorted:Bool = false
    private var isSolveStopped:Bool = true
    
    private var path:Stack<(element:UILabel, elementIndex:Int, secondaryIndex:Int, primaryIndex:Int, operation:InsetionSortOperation)> = Stack<(element:UILabel, elementIndex:Int, secondaryIndex:Int, primaryIndex:Int, operation:InsetionSortOperation)>()
    
   // MARK: - View Life Cycle and Configuration
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupView()
    }
    
    private func setupView() {
        
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
            self.labelColors.updateValue(label.backgroundColor! , forKey: label.text!)
            label.textAlignment = .center
            label.layer.cornerRadius = 5
            label.layer.masksToBounds = true
            self.list.append(label)
            self.view.addSubview(label)
            self.addContraintForLabel(label: label, index: index+1)
        }
    }
    
    private func multiplier(atIndex index:Int) -> CGFloat {
        
        let xWidthPorcent:CGFloat = width/(self.view.bounds.width - 20)
        let xSpacingPorcent:CGFloat = CGFloat(spacing)/(self.view.bounds.width - 20)
        let xLeadTrailSpace:CGFloat = 20.0/self.view.bounds.width
        return ((xWidthPorcent+xSpacingPorcent)*CGFloat(index)*2) - xLeadTrailSpace
    }
    
    private func addContraintForLabel(label:UILabel, index:Int) {
        
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
    
    // MARK: - Constraints Methods
    private func moveLabelDown(label:UILabel) {
        
        for contraint in self.view.constraints where (contraint.identifier == "y-\(label.text)") {
            contraint.constant = 150
            self.view.layoutIfNeeded()
        }
    }
    
    private func moveLabelUp(label:UILabel) {
        
        for contraint in self.view.constraints where (contraint.identifier == "y-\(label.text)") {
            contraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
    
    private func moveLabelLeft(atIndex index:Int, label:UILabel) {
        
        for var contraint in self.view.constraints where (contraint.identifier == "x-\(label.text)") {
            contraint = contraint.setMultiplier(multiplier: self.multiplier(atIndex: index))
            self.view.layoutIfNeeded()
        }
    }
    
    private func moveLabelRight(atIndex index:Int, label:UILabel) {
        
        for var contraint in self.view.constraints where (contraint.identifier == "x-\(label.text)") {
            contraint = contraint.setMultiplier(multiplier: self.multiplier(atIndex: index+2))
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Animation Methods
    private func animateLabelDown(label:UILabel, completion:@escaping (Void) -> Void) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: Double(0.5), delay:0.1, options: [.curveEaseInOut], animations: {
                self.moveLabelDown(label: label)
                }, completion: { success in
                    completion()
            })
        }
    }
    
    private func animateLabelsLeftToRight(left:(UILabel, Int), right:(UILabel,Int), completion:@escaping (Void) -> Void) {

        DispatchQueue.main.async {
            UIView.animate(withDuration: Double(0.5), delay:0.1, options: [.curveEaseInOut], animations: {
                self.moveLabelLeft(atIndex: left.1, label:left.0)
                self.moveLabelRight(atIndex: right.1, label:right.0)
                }, completion: { success in
                    completion()
            })
        }
    }
    
    private func animateLabelUp(label:UILabel, completion:@escaping (Void) -> Void) {
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: Double(0.5), delay:0.2, options: [.curveEaseInOut], animations: {
                self.moveLabelUp(label:label)
                }, completion: { success in
                    completion()
            })
        }
    }
    
    // MARK: - Step By Step Operations
    private func grayOutFirsElementOperation() {
        
        self.stepByStepQueue.sync {
            self.list.first!.backgroundColor = .gray
            self.list.first!.textColor = .white
            self.path.push((self.list.first!, elementIndex: 0, secondaryIndex:self.stepSecondaryIndex, primaryIndex:self.stepIndex,operation:.grayOutFirstElement))
        }
    }
    
    private func moveDownElement() {
        self.stepByStepQueue.sync {
            
            if let label = self.key {
                label.backgroundColor = .gray
                label.textColor = .white
            }
            self.key = self.list[self.stepIndex]
            self.animateLabelDown(label: self.key) {
                
                if(!self.isSolveStopped) { self.step() }
            }
            self.path.push((self.key, elementIndex: self.stepIndex, secondaryIndex:self.stepSecondaryIndex, primaryIndex:self.stepIndex, operation:.moveDown))
            self.stepSecondaryIndex = self.stepIndex-1;
        }
    }
    
    private func moveLeftToRightElements() {
        self.stepByStepQueue.sync {
            self.animateLabelsLeftToRight(left: (key, self.stepSecondaryIndex + 1), right: (self.list[self.stepSecondaryIndex], self.stepSecondaryIndex)) {
                
                if(!self.isSolveStopped) { self.step() }
            }
            
            self.path.push((self.key, elementIndex: self.stepSecondaryIndex + 1, secondaryIndex:self.stepSecondaryIndex, primaryIndex:self.stepIndex, operation:.moveLeft))
            self.path.push((self.list[self.stepSecondaryIndex], elementIndex: self.stepSecondaryIndex, secondaryIndex:self.stepSecondaryIndex, primaryIndex:self.stepIndex, operation:.moveRight))
            self.list[self.stepSecondaryIndex + 1] = self.list[self.stepSecondaryIndex]
            self.stepSecondaryIndex-=1
        }
    }
    
    private func moveUpKeyElement(){
        self.stepByStepQueue.sync {
            self.animateLabelUp(label: self.key) {
                if(!self.isSolveStopped) { self.step() }
            }
            self.path.push((self.key, elementIndex: self.stepSecondaryIndex + 1, secondaryIndex:self.stepSecondaryIndex, primaryIndex:self.stepIndex, operation:.moveUp))
            self.list[self.stepSecondaryIndex + 1] = self.key
            self.stepIndex+=1
        }
    }
    
    private func inverseMoveUp(element:(element:UILabel, elementIndex:Int, secondaryIndex:Int, primaryIndex:Int, operation:InsetionSortOperation)) {
        self.stepByStepQueue.sync {
            self.key = element.element
            self.key.backgroundColor = self.labelColors[self.key.text!]
            self.key.textColor = self.key.backgroundColor!.blackOrWhiteContrastingColor()
            self.animateLabelDown(label: self.key) { }
            self.stepSecondaryIndex = element.secondaryIndex
            self.stepIndex = element.primaryIndex
        }
    }
    
    private func inverseMoveRightToLeft(right:(element:UILabel, elementIndex:Int, secondaryIndex:Int, primaryIndex:Int, operation:InsetionSortOperation), left:(element:UILabel, elementIndex:Int, secondaryIndex:Int, primaryIndex:Int, operation:InsetionSortOperation)) {
        
        self.stepByStepQueue.sync {
            self.key = left.element
            self.stepSecondaryIndex = right.secondaryIndex
            self.stepIndex = right.primaryIndex
            self.animateLabelsLeftToRight(left: (right.element, left.elementIndex), right: (self.key, right.elementIndex)) {}
            self.list[self.stepSecondaryIndex] = right.element
        }
    }
    
    private func inverseMoveDown(element:(element:UILabel, elementIndex:Int, secondaryIndex:Int, primaryIndex:Int, operation:InsetionSortOperation)) {
        
        self.stepByStepQueue.sync {
            self.key = element.element
            self.stepSecondaryIndex = element.secondaryIndex
            self.stepIndex = element.primaryIndex
            self.animateLabelUp(label: self.key) {}
            self.list[self.stepIndex] = self.key
        }
    }
    
    private func inverseGrayOut(element:(element:UILabel, elementIndex:Int, secondaryIndex:Int, primaryIndex:Int, operation:InsetionSortOperation)) {
        self.stepByStepQueue.sync {
            self.key = element.element
            self.stepSecondaryIndex = element.secondaryIndex
            self.stepIndex = element.primaryIndex
            self.list.first!.backgroundColor = UIColor.generatedColors.first
            self.list.first!.textColor = UIColor.generatedColors.first!.blackOrWhiteContrastingColor()
        }
    }
    
    //MARK: - AlgorithmDelegate Methods
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
            self.key.backgroundColor = .gray
            self.key.textColor = .white
            print(self.list)
            return
        }
        
        let operation:InsetionSortOperation = (self.path.peek()?.operation)!
        
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
    
    public func back(shouldStopSolve:Bool = false) {
        
        self.isSorted = false;
        
        if shouldStopSolve {
            self.isSolveStopped = true
        }
        
        if(self.path.isEmpty) {
            return
        }

        let move = self.path.pop()
        
        switch (move!.operation) {
            case InsetionSortOperation.moveUp:
                self.inverseMoveUp(element: move!)
                break
            case InsetionSortOperation.moveRight:
                let leftMove = self.path.pop()
                self.inverseMoveRightToLeft(right: move!, left: leftMove!)
                break
            case InsetionSortOperation.moveDown:
                self.inverseMoveDown(element: move!)
                break
            case InsetionSortOperation.grayOutFirstElement:
                self.inverseGrayOut(element: move!)
                break
            default:
                break
        }
    }
    
    public func shuffle() {
        
    }
    
    // MARK: - Insertion Sort
    public func insertionSort(list:[Int]) -> [Int] {
        
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


}
