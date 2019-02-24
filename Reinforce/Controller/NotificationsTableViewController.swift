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

    // IBOutlets
    @IBOutlet var dayButtonsCollection: [UIButton]!
    @IBOutlet weak var saveBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var notificationTimeLabel: UILabel!

    // IndexPaths
    let notificationTimeCellIndexPath = IndexPath(row: 0, section: 1)
    let timePickerCellIndexPath = IndexPath(row: 1, section: 1)

    var reminder : Reminder!
    let sectionTitles : [Int: String] = [0:"Notify me on the following days",
                                         1:"At the following time"]

    var isTimePickerVisible : Bool = false
    let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController
    let currentCalendar = Calendar.current


    override func viewDidLoad() {
        super.viewDidLoad()

        print("viewDidLoad \(#file)")
        styleDaysSelectionButtons(dayButtonsCollection)
        updateTimeLabel()

        // TEST NOTIFICATIONS
        let category = UNNotificationCategory(identifier: "notificationIdentifier", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        UNUserNotificationCenter.current().delegate = self


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


    @IBAction func timePickerValueChanged(_ sender: UIDatePicker) {
        updateTimeLabel()
    }


    /// Updates the time label based on timepicker value
    fileprivate func updateTimeLabel() {
        self.notificationTimeLabel.text = timePicker.date.formattedTimeString()
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        reminder.timeString = timePicker.date.formattedTimeString()
        let requests = generateNotificationRequests(forReminder: reminder, withDate: timePicker.date)
        for request in requests {
            UNUserNotificationCenter.current().add(request, withCompletionHandler: {
                error in
                guard error == nil else {
                    print("There was an error while scheduling the notification : \(String(describing: error?.localizedDescription))")
                    return
                }
                print("Added a request with identifier : \(request.identifier)")
            })
        }

        reminder.isActive = true

        do {
            try dataController.backgroundContext.save()
        } catch {
            fatalError("Cannot save background context.")
        }

        self.navigationController?.dismiss(animated: true, completion: nil)
    }

    // MARK: - TableView DataSource and Delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }


    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath == timePickerCellIndexPath {
            if isTimePickerVisible { return 150.0 } else { return 0.0 }
        }
        return tableView.estimatedRowHeight
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == notificationTimeCellIndexPath {
            isTimePickerVisible = !isTimePickerVisible
            tableView.reloadData()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }


    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }



    // MARK: - Helper
    func styleDaysSelectionButtons(_ buttons: [UIButton]) {
        for button in buttons {
            button.setBackgroundColor(color: #colorLiteral(red: 0, green: 0.4784313725, blue: 1, alpha: 1), forState: .selected)
            button.setTitleColor(.white, for: .selected)
        }
    }

    /// Returns an array of UNNotificationRequest objects that can be added directly to UNUserNotificationCenter. Also creates Request CoreData objects that can be used to enable/disable said notifications at a later stage.
    func generateNotificationRequests(forReminder reminder: Reminder, withDate date: Date) -> [UNNotificationRequest] {
        let weekdays = selectedWeekdaysArray()
        let dateComponents = createDateComponentsForNotifications(forWeekdays: weekdays, timePickerDate: date)
        var requests = [UNNotificationRequest]()
        for element in dateComponents {

            let content = createNotificationContent(forReminder: reminder)
            // Create the UNNotificationRequest object and append to returning array
            let trigger = UNCalendarNotificationTrigger(dateMatching: element, repeats: true)
            let uuid = UUID()
            let request = UNNotificationRequest(identifier: uuid.uuidString, content: content, trigger: trigger)
            requests.append(request)
            print("content.attachment url:\(content.attachments[0].url)")
            print("content.attachment identifier:\(content.attachments[0].identifier)")

            // Create request CoreData object
            let notificationRequest = Request(context: dataController.backgroundContext)
            notificationRequest.reminder = reminder
            notificationRequest.identifier = uuid
            notificationRequest.hour = Int16(element.hour!)
            notificationRequest.minute = Int16(element.minute!)
            notificationRequest.weekday = Int16(element.weekday!)
            notificationRequest.attachmentUrl = content.attachments.first?.url
        }

        do {
            try dataController.backgroundContext.save()
        } catch {
            fatalError("Something went terribly wrong while trying to save the backgroundContext.")
        }

        return requests
    }


    /// Returns an array of DateComponents objects based on selected weekdays and time
    func createDateComponentsForNotifications(forWeekdays weekdays: [Int], timePickerDate date: Date) -> [DateComponents] {
        let hour = currentCalendar.component(.hour, from: date)
        let minute = currentCalendar.component(.minute, from: date)
        var dateComponents = [DateComponents]()
        for weekday in weekdays {
            let component = DateComponents(hour: hour, minute: minute, weekday: weekday)
            dateComponents.append(component)
            print("Added component : \(component)")
        }
        return dateComponents
    }

    /// Returns a UNNotificationContent object constructed using the Reminder object
    func createNotificationContent(forReminder reminder: Reminder) -> UNNotificationContent {
        let content = UNMutableNotificationContent()
        // TODO: add checks for optionals
        content.title = reminder.title!
        content.body = reminder.body!
        content.sound = UNNotificationSound.default

        let attachmentUrl = saveImageAndURL(imageName: (UUID().uuidString + ".jpeg"), imageData: reminder.image!)
        var attachment : UNNotificationAttachment!
        do {
            attachment = try UNNotificationAttachment(identifier: "", url: attachmentUrl!, options: [:])
            content.attachments = [attachment]
        } catch {
            print(error)
        }

        return content
    }

    /// Returns an array of weekday integer values based on user selection and updates the current Reminder object's weekdays attribute
    func selectedWeekdaysArray() -> [Int] {
        var days = [Int]()
        var shortDayNames = [String]()
        for (index, button) in dayButtonsCollection.enumerated() {
            button.isSelected ? days.append(index+1) : ()
            button.isSelected ? shortDayNames.append((button.titleLabel?.text)!) : ()
        }
        reminder.weekdays = shortDayNames.joined(separator: ", ")
        return days
    }

    /// Save image to disk and its URL as Reminder object attribute
    func saveImageAndURL(imageName: String, imageData: Data) -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }

        let fileName = imageName
        let fileURL = documentsDirectory.appendingPathComponent(fileName)

        //Checks if file exists, removes it if so.
        if FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                try FileManager.default.removeItem(atPath: fileURL.path)
                print("Removed old image")
            } catch let removeError {
                print("couldn't remove file at path", removeError)
            }

        }

        // TEST PRINT IMAGE SIZE
        let byteCount = imageData.count
        print("Byte count / 1048576 : \(byteCount/1048576) MB")
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useMB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        let string = bcf.string(fromByteCount: Int64(byteCount))
        print("Image Size: \(string)")

        do {
            try imageData.write(to: fileURL)
        } catch let error {
            print("error saving file with error", error)
        }

        // Update reminder object's localUrl attribute
//        reminder.imageLocalURL = fileURL

        print("fileURL: \(fileURL.description)")
        print((loadImageFromDiskWith(fileName: imageName))?.size)

        return fileURL
    }

    // Load image from disk
    func loadImageFromDiskWith(fileName: String) -> UIImage? {

        let documentDirectory = FileManager.SearchPathDirectory.documentDirectory

        let userDomainMask = FileManager.SearchPathDomainMask.userDomainMask
        let paths = NSSearchPathForDirectoriesInDomains(documentDirectory, userDomainMask, true)

        if let dirPath = paths.first {
            let imageUrl = URL(fileURLWithPath: dirPath).appendingPathComponent(fileName)
            let image = UIImage(contentsOfFile: imageUrl.path)
            return image

        }

        return nil
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

    func formattedTimeString() -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "hh:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"

        let dateString = formatter.string(from: self)
        return dateString
    }

}

extension DateComponents {


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


