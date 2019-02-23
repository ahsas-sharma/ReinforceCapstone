//
//  DesignViewController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 17/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import UIKit
import AVKit

class DesignViewController : UIViewController {

    @IBOutlet weak var notificationVisualEffectsView: UIView!
    @IBOutlet weak var attachmentImageView: UIImageView!
    @IBOutlet weak var titleTextView: UITextView!
    @IBOutlet weak var bodyTextView: UITextView!

    @IBOutlet var actionButtons: [UIButton]!


    var selectedQuote : Quote!
    var lastQuoteSearchString : String?
    let dataController = (UIApplication.shared.delegate as! AppDelegate).dataController

    var reminder: Reminder!

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationVisualEffectsView.layer.cornerRadius = 10
        notificationVisualEffectsView.clipsToBounds = true

        for button in actionButtons {
            button.layer.cornerRadius = 10.0
            button.clipsToBounds = true
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.lightGray.cgColor
        }

        // Add observers for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Set default text
        titleTextView.text = Constants.TextView.defaultTitleText
        bodyTextView.text = Constants.TextView.defaultBodyText
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }


    // MARK: - IBActions

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }


    @IBAction func nextButtonTapped(_ sender: Any) {
        print("Notification title : \(String(describing: titleTextView.text))")
        print("Notification body : \(String(describing: bodyTextView.text))")
        print("Image: \(String(describing: attachmentImageView.image?.description))")

        let newReminder = Reminder(context: dataController.backgroundContext)
        newReminder.title = titleTextView.text
        newReminder.body = bodyTextView.text
        newReminder.image = attachmentImageView.image?.pngData()
        newReminder.createdAt = Date()
        self.reminder = newReminder

        do {
            try dataController.backgroundContext.save()
        } catch {
            fatalError("Error saving background context")
        }

        performSegue(withIdentifier: "NotificationScreenSegue", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NotificationScreenSegue" {
            let notificationVC = segue.destination as! NotificationsTableViewController
            notificationVC.reminder = self.reminder
        }
    }

    @IBAction func searchPaperQuotesButtonTapped(_ sender: UIButton) {
        let paperQuotesVC = storyboard?.instantiateViewController(withIdentifier: Constants.Identifiers.paperQuotesViewController) as! PaperQuotesViewController
        paperQuotesVC.designViewController = self
        self.present(paperQuotesVC, animated: true)
    }

    @IBAction func searchUnsplashButtonTapped(_ sender: UIButton){
        let unsplashVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Identifiers.unsplashNavigationController)
        self.present(unsplashVC!, animated: true)
    }


    @IBAction func takePhotoButtonTapped(_ sender: Any) {
        self.pickAnImageFrom(.camera)
    }

    @IBAction func photoLibraryButtonTapped(_ sender: Any) {
        self.pickAnImageFrom(.photoLibrary)

    }

    /// Presents an imagePickerController based on the source type
    func pickAnImageFrom(_ source: UIImagePickerController.SourceType) {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = true
        imagePicker.setEditing(true, animated: true)
        imagePicker.modalPresentationStyle = .overCurrentContext

        self.present(imagePicker, animated: true)
    }
}

// MARK: - UITextView
extension DesignViewController : UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        switch textView {
        case titleTextView :
            if textView.text == Constants.TextView.defaultTitleText {
                textView.text = ""
            }
        case bodyTextView :
            if textView.text == Constants.TextView.defaultBodyText {
                textView.text = ""
            }
        default: ()
        }

    }

    func textViewDidEndEditing(_ textView: UITextView) {
        print("textViewDidEndEditing")
    }

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

// MARK:- ImagePicker Delegate -

extension DesignViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        print("Picker didFinishPickingMediaWithInfo from source:\(picker.sourceType)")

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        // Set the preview image
        attachmentImageView.image = image

        // print out the image size as a test
        print(image.size)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
