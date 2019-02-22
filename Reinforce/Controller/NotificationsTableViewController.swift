//
//  NotificationsTableViewController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 20/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationsTableViewController : UITableViewController {

    // Controls
    @IBOutlet var dayButtonsCollection: [UIButton]!
    @IBOutlet weak var frequencyControl: UISegmentedControl!
    @IBOutlet weak var intervalStepper: UIStepper!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!

    // Labels
    @IBOutlet weak var summaryLabel: UILabel!
    @IBOutlet weak var onceTimeLabel: UILabel!
    @IBOutlet weak var intervalHoursLabel: UILabel!
    @IBOutlet weak var startTimeLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!

    // Time Settings Cells
    @IBOutlet weak var onceTableViewCell: UITableViewCell!
    @IBOutlet weak var repeatIntervalTableViewCell: UITableViewCell!
    @IBOutlet weak var repeatStartTableViewCell: UITableViewCell!
    @IBOutlet weak var repeatEndTableViewCell: UITableViewCell!
    @IBOutlet weak var datePickerCell: UIView!


    // Time Picker
    @IBOutlet weak var repeatStartTimePicker: UIDatePicker!
    @IBOutlet weak var onceTimePicker: UIDatePicker!

    var reminder : Reminder!
    var isRepeatNotificationSelected : Bool {
        get {
            return self.frequencyControl.selectedSegmentIndex == 1 ? true : false
        }
    }

    let sectionTitles : [Int: String] = [0:"Days",
                                         1:"Number of times per day",
                                         2:"Once a day",
                                         3:"Repeating",
                                         5:"Summary"]
    var isOnceTimerPickerVisible : Bool = false
    var isRepeatStartTimePickerVisible : Bool = false
    var isRepeatEndTimePickerVisible : Bool = false
    let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController


    override func viewDidLoad() {
        super.viewDidLoad()
        styleDaysSelectionButtons(dayButtonsCollection)

        // TEST
        print("Received reminder object : \(reminder)")
        // Tableview adjustments for hiding and showing sections
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect.zero)

        onceTimePicker.locale = Locale.current
        onceTimePicker.timeZone = TimeZone.current

        let date = Date()
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date)
        let ordinal = cal.component(.weekdayOrdinal, from: date)
        print("Days: \(cal.shortWeekdaySymbols)")
        print("Weekday : \(weekday) and WeekdayOrdinal : \(ordinal) and locale : \(String(describing: cal.locale?.description))")
        print("Time: \(date.description)")
        print("Local: \(date.toLocalTime())")

        for (index,button) in dayButtonsCollection.enumerated() {
            print("\(index) : \(button.titleLabel!.text!) ")
        }

        // TEST NOTIFICATIONS
        let category = UNNotificationCategory(identifier: "notificationIdentifier", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        UNUserNotificationCenter.current().delegate = self


    }

    func createSampleNotification(date: Date) {
        // Capture content from reminder object
        let content = UNMutableNotificationContent()
        content.categoryIdentifier = "notificationIdentifier"
        content.title = "Notification Title"
        content.body = "Success is no accident. It is hard work, perseverance, learning, studying, sacrifice and most of all, love of what you are doing or learning to do."
        content.sound = UNNotificationSound.default

        // Create trigger and request
        let components = Calendar.current.dateComponents([.weekday,.hour,.minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components , repeats:true)
        let uuid = UUID()
        let uuidString = uuid.uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)

        // Create core data objects
        let notification = Request(context: dataController.backgroundContext)
        notification.identifier = uuid
        notification.hour = Int16(components.hour!)
        notification.minute = Int16(components.minute!)
        notification.weekday = Int16(components.weekday!)
        notification.reminder = reminder

        do {
            try dataController.backgroundContext.save()
        } catch {
            fatalError("There was a problem saving the background context.")
        }

        // Add notification request
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {
            error in
            print("Request fired.")
        })
    }



    /// Returns an array of UNNotificationRequest objects that can be added directly to UNUserNotificationCenter. Also creates Request CoreData objects that can be used to enable/disable said notifications at a later stage.
    func generateOnceADayNotificationRequests(forReminder reminder: Reminder) -> [UNNotificationRequest] {
        let content = createNotificationContent(forReminder: reminder)
        let weekdays = selectedWeekdaysArray()
        let date = onceTimePicker.date
        let dateComponents = createDateComponentsForOnceNotifications(forWeekdays: weekdays, timePickerDate: date)
        var requests = [UNNotificationRequest]()
        for element in dateComponents {
            // Create the UNNotificationRequest object and append to returning array
            let trigger = UNCalendarNotificationTrigger(dateMatching: element, repeats: true)
            let uuid = UUID()
            let request = UNNotificationRequest(identifier: uuid.uuidString, content: content, trigger: trigger)
            requests.append(request)

            // Create request CoreData object
            let notificationRequest = Request(context: dataController.backgroundContext)
            notificationRequest.reminder = reminder
            notificationRequest.identifier = uuid
            notificationRequest.hour = Int16(element.hour!)
            notificationRequest.minute = Int16(element.minute!)
            notificationRequest.weekday = Int16(element.weekday!)
        }

        do {
            try dataController.backgroundContext.save()
        } catch {
            fatalError("Something went terribly wrong while trying to save the backgroundContext.")
        }

        return requests
    }


    func activateNotifications() {

    }

    // MARK: - IBActions

    @IBAction func testButtonTapped(_ sender: Any) {
        let center = UNUserNotificationCenter.current()

        center.getPendingNotificationRequests(completionHandler: { requests in
            for request in requests {
                print(request.identifier)
                print(request.trigger.debugDescription)
            }
        })
    }

    // Common IBAction to handle selection of days
    @IBAction func toggleDaySelection(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }



    @IBAction func segmentedControlIndexChanged(_ sender: UISegmentedControl) {
        tableView.reloadSections(IndexSet(arrayLiteral: 2,3), with: .automatic)
    }


    @IBAction func saveButtonTapped(_ sender: Any) {
        print("Save button tapped")
        let date = onceTimePicker.date
        createSampleNotification(date: date)
    }
    // MARK: - TableView DataSource and Delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 1
        case 2:
            if frequencyControl.selectedSegmentIndex == 0 {
                if isOnceTimerPickerVisible {
                    return 2
                } else {
                    return 1
                }
            } else {return 0}
        case 3: if frequencyControl.selectedSegmentIndex == 1 { return 3 } else {return 0}
        case 4: return 1
        default: return 0
        }
    }

//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return UITableView.automaticDimension
//    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 2 {
            if frequencyControl.selectedSegmentIndex == 0 {return 20} else {return 0.1}
        } else if section == 3 {
            if frequencyControl.selectedSegmentIndex == 1 {return 20} else {return 0.1}
        } else { return 20 }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 2 {
            if frequencyControl.selectedSegmentIndex == 0 {return sectionTitles[section]} else {return nil}
        } else if section == 3 {
            if frequencyControl.selectedSegmentIndex == 1 {return sectionTitles[section]} else {return nil}
        } else { return sectionTitles[section] }
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 2 {
            if frequencyControl.selectedSegmentIndex == 0 {return 20} else {return 0.1}
        } else if section == 3 {
            if frequencyControl.selectedSegmentIndex == 1 {return 30} else {return 0.1}
        } else { return 20 }
    }

    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 3 && frequencyControl.selectedSegmentIndex == 1 { return "You will receieve notifications within these hours only."} else {return nil}
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch frequencyControl.selectedSegmentIndex {
        case 0:
            if indexPath == IndexPath(row: 0, section: 2) {
                isOnceTimerPickerVisible = !isOnceTimerPickerVisible
                print("Set isOnceTimePickerVisible to :\(isOnceTimerPickerVisible)")
                tableView.reloadData()
                print("Number of rows in section 2: \(tableView.numberOfRows(inSection: 2))")
            }
        case 1:
            tableView.beginUpdates()
            tableView.endUpdates()

        default: ()
        }
    }

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        print("DeSelected cell : \(indexPath)")
        tableView.beginUpdates()
        tableView.endUpdates()
    }

    // MARK: - DatePicker

    @IBAction func onceTimePickerValueChanged(_ sender: UIDatePicker) {
        print(sender.date.debugDescription)
        print(sender.locale.debugDescription)
        print(sender.calendar.debugDescription)
        print(sender.timeZone.debugDescription)
        print(sender.date.toLocalTime())
    }


    // MARK: - Helper
    func styleDaysSelectionButtons(_ buttons: [UIButton]) {
        for button in buttons {
            button.setBackgroundColor(color: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), forState: .selected)
            button.setTitleColor(.white, for: .selected)
        }
    }

    /// Returns an array of DateComponents objects based on selected weekdays and time
    func createDateComponentsForOnceNotifications(forWeekdays weekdays: [Int], timePickerDate date: Date) -> [DateComponents] {
        let hour = Calendar.current.component(.hour, from: date)
        let minute = Calendar.current.component(.minute, from: date)
        var dateComponents = [DateComponents]()
        for weekday in weekdays {
            let component = DateComponents(hour: hour, minute: minute, weekday: weekday)
            dateComponents.append(component)
        }
        return dateComponents
    }

    /// Returns a UNNotificationContent object constructed using the Reminder object
    func createNotificationContent(forReminder: Reminder) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        // TODO: add checks for optionals
        content.title = reminder.title!
        content.body = reminder.body!
        // TODO: add attachment check
        return content
    }

    // TEST - Update summary label test
    func updateSummaryLabel() {
        var selectedDays = [String]()
        for (index,button) in dayButtonsCollection.enumerated() {
            if button.isSelected {
                selectedDays.append("\(index+1), \(button.titleLabel!.text!)")
            }
        }
        let displayString = selectedDays.joined(separator: ", ")
        UIView.animate(withDuration: 0.1, animations: {
            self.summaryLabel.text = displayString
        })
    }

    /// Returns an array of weekday integer values based on user selection
    func selectedWeekdaysArray() -> [Int] {
        var days = [Int]()
        for (index, button) in dayButtonsCollection.enumerated() {
            button.isSelected ? days.append(index+1) : ()
        }
        return days
    }
}


extension Date {
    var localDateDescription: String {
        return description(with: NSLocale.current)
    }

    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

}


// HANDLE NOTIFICATION ACTIONS
extension NotificationsTableViewController : UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Received response")
        print(response)
        let userInfo = response.notification.request.content.userInfo
        switch response.actionIdentifier {
        case "OPEN_URL":
            print("Open URL action tapped for address:\(String(describing: userInfo["url"]))")
            break
        default:()
        }
    }
}


