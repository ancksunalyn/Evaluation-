//
//  ViewController.swift
//  Evaluation+
//  Created by Evelyn on 17-11-24.
//  Copyright © 2017 eleves. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    

    @IBOutlet weak var studentNameText: UITextField!
    @IBOutlet weak var studentsTabView: UITableView!
    
    typealias studentName = String
    typealias course = String
    typealias grade = Double
    
    let studentsObj = UserDefaultsManager()
    var studentGrades: [studentName: [course: grade]]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadStudentDefaults()
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return studentGrades.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: nil)
        cell.textLabel?.text = [studentName](studentGrades.keys)[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let name = [studentName](studentGrades.keys)[indexPath.row]
             studentGrades[name] = nil
             studentsObj.setKey(theValue: studentGrades as AnyObject, theKey: "grades")
             studentsTabView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = [studentName](studentGrades.keys)[indexPath.row]
        studentsObj.setKey(theValue: name as AnyObject, theKey: "selectedStudentName")
        performSegue(withIdentifier: "seg", sender: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        studentNameText.resignFirstResponder()
        return true
    }
    
    func loadStudentDefaults() {
        if studentsObj.doesKeyExist(theKey: "grades") {
            studentGrades = studentsObj.getValue(theKey: "grades") as! [studentName: [course: grade]]
         } else {
            studentGrades = [studentName: [course: grade]]()
         }
    }
    
    @IBAction func addStudent(_ sender: UIButton) {
        if studentNameText.text != "" {
         studentGrades[studentNameText.text!] = [course: grade]()
         studentNameText.text = ""
         studentsObj.setKey(theValue: studentGrades as AnyObject, theKey: "grades")
         studentsTabView.reloadData()
         }
    }
    



}

