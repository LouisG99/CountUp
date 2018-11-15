//
//  ViewController.swift
//  CountUp
//
//  Created by Louis Gouirand on 9/13/18.
//  Copyright © 2018 Louis Gouirand. All rights reserved.
//

import UIKit
import CoreData
import Firebase

// TO DO:
// - figure out firebase thing

// have 2 buttons when first opening the app to decide between local (coredata)
// and cloud dtorage (firebase)


class LoginController: UIViewController {
    
    
    
    override func viewDidLoad() {
        print("Kette")
    }
    
}


/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// MARK: Entry after login
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
class EntryScreenController: UIViewController {
    var appDelegate : AppDelegate?
    var context : NSManagedObjectContext?
    var entity : NSEntityDescription?
    
    let subViewHeight = CGFloat(70.0)
    var count_views = CGFloat(0.0)
    
    @IBOutlet weak var CountersScroll: UIScrollView!
    @IBOutlet weak var CounterStack: UIStackView!
    
    @IBAction func NewCounter(_ sender: Any) {
        NewCounterHelper()
    }
    
    func NewCounterHelper() {
        // adding to Data Core
        let count = Int(count_views)
        let counterName: String
        
        if count==0 {
            counterName = "Counter Example"
        }
        else {
            counterName = "New Counter #" + String(Int(count_views))
        }
        
        let newUser = NSManagedObject(entity: entity!, insertInto: context)
        newUser.setValue(counterName, forKey: "name")
        // init other values to avoid undefined behavior (?)
        newUser.setValue(15, forKey: "limit")
        newUser.setValue(1, forKey: "increment")
        newUser.setValue(0, forKey: "value")
        newUser.setValue(8, forKey: "notif_hour")
        newUser.setValue(0, forKey: "notif_min")
        newUser.setValue("Daily", forKey: "notif_freq")
        
        do {
            try context?.save()
        } catch {
            print("Failed saving")
        }
        
        display_views_helper(name: counterName, index: Int(count_views), limReached: false)
        count_views+=1.0
    }
    
    
    func display_views(start_i: Int) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Counters")
        request.returnsObjectsAsFaults = false
        var nbrElems = 0
        
        do {
            let result = try context?.fetch(request)
            var count = 0
            for data in result as! [NSManagedObject] {
                let value = data.value(forKey: "value") as! Int
                let lim = data.value(forKey: "limit") as! Int
                let isReached = value >= lim
                display_views_helper(name: data.value(forKey: "name") as! String, index: count, limReached: isReached)
                count+=1
                nbrElems+=1
            }
            
        } catch {
            print("Failed")
        }
        return nbrElems
    }
    
    func display_views_helper(name: String, index: Int, limReached: Bool) {
        let first_view = CounterStack.subviews[0]
        let label_constr = first_view.subviews[0]
        let button_constr = first_view.subviews[1]
        
        let newView = UIView()
        
        let label = UILabel()
        label.text = name
        label.font = label.font.withSize(17)
        label.translatesAutoresizingMaskIntoConstraints = false
        if limReached {
            label.textColor = .white
        }
        else {
            label.textColor = .black
        }
        
        let see_button = UIButton()
        see_button.translatesAutoresizingMaskIntoConstraints = false
        see_button.setTitle("See", for: .normal)
        see_button.setTitleColor(button_constr.tintColor, for: .normal)
        see_button.titleLabel?.font =  .systemFont(ofSize: 15.0)
        see_button.addTarget(self, action: #selector(self.counterTouched), for: .touchUpInside)
        see_button.tag = index
        if limReached {
            see_button.setTitleColor(.green, for: .normal)
        }
        
        // create constraints
        let leadingLabel = NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: label_constr, attribute: .leading, multiplier: 1, constant: 0)
        let verticalLabel = NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: label_constr, attribute: .centerY, multiplier: 1, constant: subViewHeight * CGFloat(index))
        
        let trailingButton = NSLayoutConstraint(item: see_button, attribute: .leading, relatedBy: .equal, toItem: button_constr, attribute: .leading, multiplier: 1, constant: 0)
        let verticalButton = NSLayoutConstraint(item: see_button, attribute: .centerY, relatedBy: .equal, toItem: button_constr, attribute: .centerY, multiplier: 1, constant: subViewHeight * CGFloat(index))
        
        // add
        newView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        newView.addSubview(label)
        newView.addSubview(see_button)
        
        if limReached {
            newView.backgroundColor = UIColor( red: CGFloat(0/255.0), green: CGFloat(0/255.0), blue: CGFloat(0/255.0), alpha: CGFloat(0.5) )
        }
        else {
            newView.backgroundColor = UIColor( red: CGFloat(235/255.0), green: CGFloat(235/255.0), blue: CGFloat(235/255.0), alpha: CGFloat(1.0) )
        }
        
        // if template
        if (index==0) {
            CounterStack.removeArrangedSubview(CounterStack.subviews[0])
        }
        CounterStack.addArrangedSubview(newView)
        CounterStack.addConstraints([leadingLabel, verticalLabel, trailingButton, verticalButton])
        CounterStack.reloadInputViews()
    }
    
    @objc func counterTouched(sender: UIButton!) {
        // to switch VC essentially need to link to storyboard
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "CounterScreen") as! CounterController
        
        VC.counter_name = getName(index: sender.tag)
        VC.index = sender.tag
        self.present(VC, animated: true, completion: nil)
    }
    
    func getName(index: Int) -> String {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Counters")
        request.returnsObjectsAsFaults = false
        let name: String
        
        do {
            let result = try context?.fetch(request) as! [NSManagedObject]
            name = result[index].value(forKey: "name") as! String
            }
        catch {
            print("Fail in getName")
            name = "Undefined name"
        }
        return name
    }
    
    func countViewsInit() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Counters")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context?.fetch(request) as! [NSManagedObject]
            count_views = CGFloat(result.count)
        } catch {
            print("Catch in countViewsInit()")
            count_views = CGFloat(0.0)
        }
    }
    
    override func viewDidLoad() {
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = appDelegate?.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: "Counters", in: (context ?? nil)!)
        
        // init count_views
        countViewsInit()
        
        let nbrStacks = display_views(start_i: 0)

        if nbrStacks==0 { // if no element saved in CoreData, add default one
            NewCounterHelper()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// MARK: Counter Screen
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
class CounterController: UIViewController, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {
    @IBOutlet weak var CountDisplay: UILabel!
    @IBOutlet weak var CounterTitle: UILabel!
    
    @IBOutlet weak var Stepper: UIStepper!
    
    @IBOutlet weak var modifyButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var IncrementDisplay: UILabel!
    var incrementVal = Int()
    
    @IBAction func StepperOn(_ sender: UIStepper) {
        changeCount(sender)
    }
    
    @IBAction func DeleteCounter() {
        deleteCounterHelper()
    }
    
    @IBAction func modifyPickerView() {
        modifyButton.isHidden = true
        doneButton.isHidden = false
        PickIncrement.isUserInteractionEnabled = true
        PickIncrement.backgroundColor = UIColor.white
    }
    
    @IBAction func donePickerView() {
        incrementVal = PickIncrement.selectedRow(inComponent: 0) + 1
        updateIncrDisplay()
        PickIncrement.isUserInteractionEnabled = false
        PickIncrement.backgroundColor = UIColor(red: CGFloat(0.9), green: CGFloat(0.9), blue: CGFloat(0.9), alpha: 1.0)
        modifyButton.isHidden = false
        doneButton.isHidden = true
    }
    
    @IBOutlet weak var limitField: UITextField!
    
    
    @IBAction func accessSettings() {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "settings screen") as! SettingsController

        VC.index = self.index
        self.present(VC, animated: true, completion: nil)
    }
    
    // Core Data Vars
    var appDelegate : AppDelegate?
    var context : NSManagedObjectContext?
    var entity : NSEntityDescription?
    
    var counter_name: String = "Name not yet defined"
    var index: Int = 0

    
    // update counter value
    func changeCount(_ sender: UIStepper) {
        if let text: String = CountDisplay.text {
            let countVal = Int(text) ?? 0
            
            if Int(sender.value) > countVal {
                CountDisplay.text = String(countVal + incrementVal)
                // sender.value += Double(incrementVal)
                sender.value += Double(incrementVal) - 1 // for auto added increment
            }
            else if (Int(sender.value) < countVal) && (countVal-incrementVal>=0){
                CountDisplay.text = String(countVal - incrementVal)
                sender.value -= (Double(incrementVal) - 1) // same
            }
            else {
                sender.value = 0
                CountDisplay.text = "0"
            }
            // storing changes
            saveData()
        }
        checkCompleted()
    }
    
    
    @IBAction func ResetValue() {
        Stepper.value = 0
        CountDisplay.text = "0"
        // storing changes
        saveData()
        checkCompleted()
    }
    
    @IBOutlet weak var PickIncrement: UIPickerView!
    var pickerData: [String] = [String]()

    @IBOutlet weak var CounterName: UITextField!
    
    override func viewDidLoad() {
        // Core data stuff
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = appDelegate?.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: "Counters", in: (context ?? nil)!)
        
        CounterName.delegate = self
        limitField.delegate = self
        CountDisplay.text = "0"
        incrementVal = 1
        
        // Constructing scroll view
        let incrementLimit = 10
        for i in 1...incrementLimit {
            pickerData.append(String(i))
        }
        PickIncrement.delegate = self
        PickIncrement.dataSource = self
        PickIncrement.isUserInteractionEnabled = false
        PickIncrement.backgroundColor = UIColor(red: CGFloat(0.9), green: CGFloat(0.9), blue: CGFloat(0.9), alpha: 1.0)
        modifyButton.isHidden = false
        doneButton.isHidden = true
        
        // dynamic initialization
        CounterTitle.text = counter_name
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Counters")
        request.returnsObjectsAsFaults = false
        do {
            var result = try context?.fetch(request) as! [NSManagedObject]
            let savedVar = result[index]
            
            Stepper.value = (savedVar.value(forKey: "value") as! Double)
            CounterTitle.text = (savedVar.value(forKey: "name") as! String)
            CountDisplay.text = String(savedVar.value(forKey: "value") as! Int)
            limitField.text = String(savedVar.value(forKey: "limit") as! Int)
            
            let incrFromData = savedVar.value(forKey: "increment") as! Int
            PickIncrement.selectRow(incrFromData-1, inComponent: 0, animated: true)
        }
        catch {
            print("Error while initializing display of couter")
        }
        checkCompleted()
        IncrementDisplay.text = "Increment Value: " + String(incrementVal)
    }
    func checkCompleted() {
        if let textVal: String = CountDisplay.text {
            if let textLim : String = limitField.text {
                let val = Int(textVal) ?? 0
                let lim = Int(textLim) ?? 15
                
                if (val >= lim) {
                    view.backgroundColor = UIColor( red: CGFloat(200/255.0), green: CGFloat(200/255.0), blue: CGFloat(200/255.0), alpha: CGFloat(1.0))
                }
                else {
                    view.backgroundColor = UIColor( red: CGFloat(245/255.0), green: CGFloat(245/255.0), blue: CGFloat(245/255.0), alpha: CGFloat(1.0) )
                }
            }
        }
    }
    
    func checkIsNumeric(str: String) -> Bool {
        let number : Set = ["0","1","2","3","4","5","6","7","8","9"]
        for c in str {
            if !number.contains(String(c)){
                return false
            }
        }
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        let id = textField.accessibilityIdentifier ?? "none"
        
        if (id == "counterLimit") {
            if !checkIsNumeric(str: textField.text ?? "") {
                textField.text = "-1"
            }
            
        }
        else {
            self.CounterTitle.text = self.CounterName.text
            self.CounterName.text = ""
            self.CounterName.textColor = UIColor.gray
        }
        // storing changes
        saveData()
        checkCompleted()
    }

    func saveData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Counters")
        request.returnsObjectsAsFaults = false
        
        do {
            var result = try context?.fetch(request) as! [NSManagedObject]
            let savedVar = result[index]
            savedVar.setValue(CounterTitle.text, forKey: "name")
            savedVar.setValue(incrementVal, forKey: "increment")
            savedVar.setValue(Int(CountDisplay.text ?? "-1"), forKey: "value")
            savedVar.setValue(Int(limitField.text ?? "15"), forKey: "limit")
            result[index] = savedVar
        }
        catch {
            print("Probably indexing problem with saveData in counter screen")
        }
        
        do {
            try context?.save()
        } catch {
            print("Failed saving")
        }
    }
    
    func deleteCounterHelper() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Counters")
        request.returnsObjectsAsFaults = false
        
        do {
            let result = try context?.fetch(request) as! [NSManagedObject]
            
            if index < result.count-1 {
                for i in index...result.count-2 {
                    context?.delete(result[i])
                    context?.insert(result[i+1])
                }
            }
            context?.delete(result[result.count-1])

            try context?.save()
            
            let VC = self.storyboard?.instantiateViewController(withIdentifier: "firstScreen") as! EntryScreenController
            self.present(VC, animated: true, completion: nil)
            
        }
        catch {
            print("Failed to delete")
        }
    }
    
    func updateIncrDisplay() {
        IncrementDisplay.text = "Increment Value: " + String(incrementVal)
        // storing changes
        saveData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // for scroll view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        incrementVal = Int(pickerData[row]) ?? 1
//        updateIncrDisplay()
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRowInComponent row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hides the keyboard.
        textField.resignFirstResponder()
        return true
    }
}

/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
// MARK: Settings Screen
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
class SettingsController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    var index: Int = 0
    
    @IBOutlet weak var currentSettings: UILabel!
    @IBOutlet weak var settingsScroll: UIPickerView!
//    var pickerData: [[String]] = []
    var freq = ["Daily", "Weekly", "Monthly"]
    var hour = [String()]
    var min = [String()]
    var pickerData: [[String]] = []
    
    var context : NSManagedObjectContext?
    var entity : NSEntityDescription?
    var appDelegate : AppDelegate?
    
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var modifButton: UIButton!
    
    @IBAction func modifySettings(_ sender: Any) {
        settingsScroll.isUserInteractionEnabled = true
        settingsScroll.backgroundColor = UIColor.white
        doneButton.isEnabled = true
        modifButton.isEnabled = false
    }
    
    @IBAction func doneModifSettings() {
        updateDisplaySet(initialize: false)
        saveData()
        settingsScroll.isUserInteractionEnabled = false
        settingsScroll.backgroundColor = UIColor(red: CGFloat(0.9), green: CGFloat(0.9), blue: CGFloat(0.9), alpha: 1.0)
        doneButton.isEnabled = false
        modifButton.isEnabled = true
    }
    
    override func viewDidLoad() {
        // loading current settings
        appDelegate = UIApplication.shared.delegate as? AppDelegate
        context = appDelegate?.persistentContainer.viewContext
        entity = NSEntityDescription.entity(forEntityName: "Counters", in: (context ?? nil)!)
        
        for i in 0...23 {
            hour.append(String(i))
        }
        for i in 0...59 {
            min.append(String(i))
        }
        pickerData = [freq, hour, min]
        settingsScroll.dataSource = self
        settingsScroll.delegate = self
        
        updateDisplaySet(initialize: true)
        
        // init PickerView state
        settingsScroll.isUserInteractionEnabled = false
        settingsScroll.backgroundColor = UIColor(red: CGFloat(0.9), green: CGFloat(0.9), blue: CGFloat(0.9), alpha: 1.0)
        doneButton.isEnabled = false
    }
    
    @IBAction func backButton() {
        let VC = self.storyboard?.instantiateViewController(withIdentifier: "CounterScreen") as! CounterController
        
        VC.index = self.index
        self.present(VC, animated: true, completion: nil)
    }
    
    func updateDisplaySet(initialize: Bool) {
        var freq : String = "uninit"
        var hour: Int = -1
        var min: Int = -1
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Counters")
        request.returnsObjectsAsFaults = false
        do {
            if initialize {
                do {
                    var result = try context?.fetch(request) as! [NSManagedObject]
                    let savedVar = result[index]
                    
                    freq = savedVar.value(forKey: "notif_freq") as! String
                    hour = savedVar.value(forKey: "notif_hour") as! Int
                    min = (savedVar.value(forKey: "notif_min") as! Int)
                    
                    var indecesFreq = ["Daily": 0, "Weekly": 1, "Monthly": 2]
                    settingsScroll.selectRow(indecesFreq[freq] ?? 0, inComponent: 0, animated: true)
                    settingsScroll.selectRow(hour+1, inComponent: 1, animated: true)
                    settingsScroll.selectRow(min+1, inComponent: 2, animated: true)
                }
                catch {
                    print("Error while initializing display of couter")
                }
            }
            else {
                freq = pickerData[0][settingsScroll.selectedRow(inComponent: 0)]
                hour = Int(pickerData[1][settingsScroll.selectedRow(inComponent: 1)]) ?? -1
                min = Int(pickerData[2][settingsScroll.selectedRow(inComponent: 2)]) ?? -1
                
                if hour == -1 {
                    hour = 0
                    settingsScroll.selectRow(1, inComponent: 1, animated: true)
                }
                if min == -1 {
                    min = 0
                    settingsScroll.selectRow(1, inComponent: 2, animated: true)
                }
            }
            let time = freq + " reminders at " + time_helper(hour: hour, min: min)
            currentSettings.text = time
        }
    }
    
    func time_helper(hour: Int, min: Int) -> String {
        let twelve = (hour != 0 && hour != 12)
        var hr = twelve ? String(hour%12) : String(12)
        var minute = String(min)
        var suffix = "am"
        
        if (hour<10 && hour>0) {
            hr = "0"+hr
        } else if (hour==0) {
            hr = "12"
        }
        if (min < 10) {
            minute = "0"+minute
        }

        if (hour>=12) {
           suffix = "pm"
        }
        return hr+":"+minute+" "+suffix
    }
    
    func saveData() {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Counters")
        request.returnsObjectsAsFaults = false

        do {
            var result = try context?.fetch(request) as! [NSManagedObject]
            
            let notif_freq = pickerData[0][settingsScroll.selectedRow(inComponent: 0)]
            let notif_hour = Int(pickerData[1][settingsScroll.selectedRow(inComponent: 1)])
            let notif_min = Int(pickerData[2][settingsScroll.selectedRow(inComponent: 2)])
            
            result[index].setValue(notif_freq, forKey: "notif_freq")
            result[index].setValue(notif_hour, forKey: "notif_hour")
            result[index].setValue(notif_min, forKey: "notif_min")
        }
        catch {
            print("Probably indexing problem with saveData in counter screen")
        }

        do {
            try context?.save()
        } catch {
            print("Failed saving")
        }
    }
    
    // for scroll view
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData[component].count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
//        saveData()
        return pickerData[component][row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRowInComponent row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
    }
}
