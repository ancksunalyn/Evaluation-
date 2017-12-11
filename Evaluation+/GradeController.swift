//
//  GradeController.swift
//  Evaluation+
//  Created by Evelyn on 17-11-24.
//  Copyright © 2017 eleves. All rights reserved.
//

import UIKit

class GradeController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var courseGradeTabView: UITableView!
    @IBOutlet weak var selectedStudentNameLb: UILabel!
    @IBOutlet weak var courseNameTxt: UITextField!
    @IBOutlet weak var courseGradeTxt: UITextField!
    @IBOutlet weak var averageGradeLb: UILabel!
    @IBOutlet weak var eraseAllBt: UIButton!
    
    typealias studentName = String
    typealias course = String
    typealias grade = Double
    
    let studentsObj = UserDefaultsManager()
    var studentGrades: [studentName: [course: grade]]!
    var arrOfCourses: [course]!
    var arrOfGrades: [grade]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedStudentNameLb.text = studentsObj.getValue(theKey: "selectedStudentName") as? String
        loadStudentDefaults()
        fillUpArrays()
        if arrOfCourses.count == 0 {
            averageGradeLb.text = "No grades"
            eraseAllBt.alpha = 0.5
        } else {
            averageGradeLb.text = calculateLastGrades(grades: arrOfGrades) {$0 * 100 / $1}
        }
    }
    
    func fillUpArrays () {
        let name = selectedStudentNameLb.text
        let coursesAndGrades = studentGrades[name!] // il retourne la valeur de la cle
        arrOfCourses = [course](coursesAndGrades!.keys)
        arrOfGrades = [grade](coursesAndGrades!.values)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrOfCourses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = courseGradeTabView.dequeueReusableCell(withIdentifier: "proto")!
        if let aCourse = cell.viewWithTag(100) as! UILabel! {
            aCourse.text = arrOfCourses[indexPath.row]
        }
        if let aGrade = cell.viewWithTag(101) as! UILabel! {
            aGrade.text = String(arrOfGrades[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let name = selectedStudentNameLb.text!
            var coursesGrades = studentGrades[name]!
            let toDelete = [course](coursesGrades.keys)[indexPath.row]
            coursesGrades[toDelete] = nil
            studentGrades[name] = coursesGrades
            studentsObj.setKey(theValue: studentGrades as AnyObject, theKey: "grades")
            fillUpArrays()
            courseGradeTabView.deleteRows(at: [indexPath as IndexPath], with: UITableViewRowAnimation.automatic)
            if arrOfCourses.count == 0 {
                averageGradeLb.text = "No grades"
                eraseAllBt.alpha = 0.5
            } else {
                averageGradeLb.text = calculateLastGrades(grades: arrOfGrades) {$0 * 100 / $1}
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        courseNameTxt.resignFirstResponder()
        courseGradeTxt.resignFirstResponder()
        return true
    }
    
    func loadStudentDefaults() {
        if studentsObj.doesKeyExist(theKey: "grades") {
            studentGrades = studentsObj.getValue(theKey: "grades") as! [studentName: [course: grade]]
        } else {
            studentGrades = [studentName: [course: grade]]()
        }
    }
    
    @IBAction func addCourseAndGrades (_ sender: UIButton) {
        let name = selectedStudentNameLb.text!
        var studentCourses = studentGrades[name]!
        studentCourses[courseNameTxt.text!] = Double(courseGradeTxt.text!)
        studentGrades[name] = studentCourses
        studentsObj.setKey(theValue: studentGrades as AnyObject, theKey: "grades")
        fillUpArrays()
        courseGradeTabView.reloadData()
        courseNameTxt.text = ""
        courseGradeTxt.text = ""
        if arrOfCourses.count == 0 {
            averageGradeLb.text = "No grades"
        } else {
            averageGradeLb.text = calculateLastGrades(grades: arrOfGrades) {$0 * 100 / $1}
            eraseAllBt.alpha = 1.0
        }
    }
    
    func calculateLastGrades (grades: [Double], ruleOf3: (_ total: Double, _ totalForAll: Double) -> Double) -> String {
        let sumOfNotes = grades.reduce(0, +)
        let totalForAllGrades = Double(grades.count * 100)
        let proportionalNote = ruleOf3(sumOfNotes, totalForAllGrades)
        return String(format: "Total of session: %0.1f/%0.1f or %0.1f/100", sumOfNotes, totalForAllGrades, proportionalNote)
    }
    
    @IBAction func resetAll(_ sender: UIButton) {
        if sender.alpha == 0.5 {
            return
        } else {
            let alertController = UIAlertController(title: "Message", message: "Do you really wanna erase it all?", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                UIAlertAction in
                let student = self.selectedStudentNameLb.text!
                self.studentGrades[student] = [course: grade]()
                self.studentsObj.setKey(theValue: self.studentGrades as AnyObject, theKey: "grades")
                self.fillUpArrays()
                self.courseGradeTabView.reloadData()
                self.averageGradeLb.text = "No grades"
                self.eraseAllBt.alpha = 0.5
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
            }
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}


