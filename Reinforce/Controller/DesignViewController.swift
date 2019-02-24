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
    // to store view's y origin based on nav bar
    var baseHeight: Float!

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        applyStyleToUIElements()

        // Add observers for keyboard events
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)

        // Set default text
        titleTextView.text = Constants.TextView.defaultTitleText
        bodyTextView.text = Constants.TextView.defaultBodyText

        // Setup blank reminder
        reminder = Reminder(context: dataController.backgroundContext)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - IBActions

    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }


    @IBAction func nextButtonTapped(_ sender: Any) {
        // do what needs to be done
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Constants.Identifiers.notificationScreenSegue {
            let notificationVC = segue.destination as! NotificationsTableViewController
            prepareReminderObject()
            notificationVC.reminder = self.reminder
        }

        if segue.identifier == Constants.Identifiers.unsplashNavigationControllerSegue {
            let unsplashNavVC = segue.destination as! UINavigationController
            if let unsplashVC = unsplashNavVC.topViewController as? UnsplashViewController {
                unsplashVC.designViewController = self
            }
        }
    }

    @IBAction func searchPaperQuotesButtonTapped(_ sender: UIButton) {
        let paperQuotesVC = storyboard?.instantiateViewController(withIdentifier: Constants.Identifiers.paperQuotesViewController) as! PaperQuotesViewController
        paperQuotesVC.designViewController = self
        self.present(paperQuotesVC, animated: true)
    }

    @IBAction func searchUnsplashButtonTapped(_ sender: UIButton){
        // anything?
    }


    @IBAction func takePhotoButtonTapped(_ sender: Any) {
        self.pickAnImageFrom(.camera)
    }

    @IBAction func photoLibraryButtonTapped(_ sender: Any) {
        self.pickAnImageFrom(.photoLibrary)

    }



    // MARK: - Helper

    fileprivate func prepareReminderObject() {
        reminder.title = titleTextView.text
        reminder.body = bodyTextView.text
        reminder.image = attachmentImageView.image?.jpegData(compressionQuality: 0.50)
        reminder.createdAt = Date()
    }

    /// Presents an imagePickerController based on the source type
    fileprivate func pickAnImageFrom(_ source: UIImagePickerController.SourceType) {

        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = true
        imagePicker.setEditing(true, animated: true)
        imagePicker.modalPresentationStyle = .overCurrentContext

        self.present(imagePicker, animated: true)
    }

    /// Performs initial styling of various UI elements
    private func applyStyleToUIElements() {
        notificationVisualEffectsView.layer.cornerRadius = 10
        notificationVisualEffectsView.clipsToBounds = true

        for button in actionButtons {
            button.layer.cornerRadius = 10.0
            button.clipsToBounds = true
            button.layer.borderWidth = 0.5
            button.layer.borderColor = UIColor.lightGray.cgColor
        }
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

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        let navBarHeight = self.navigationController?.navigationBar.frame.height
        let navBarOriginY = self.navigationController?.navigationBar.frame.origin.y
        baseHeight = Float(navBarHeight!) + Float(navBarOriginY!)
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == CGFloat(baseHeight) {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != CGFloat(baseHeight) {
            self.view.frame.origin.y = CGFloat(baseHeight)
        }
    }
}

// MARK:- ImagePicker Delegate -

extension DesignViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
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
