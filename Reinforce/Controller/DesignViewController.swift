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

    var selectedQuote : Quote!
    var lastQuoteSearchString : String?

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        notificationVisualEffectsView.layer.cornerRadius = 10
        notificationVisualEffectsView.clipsToBounds = true

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

    // MARK: - Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "QuoteSearchSegue" {
            let quoteSearchVC = segue.destination as! PaperQuotesViewController
            quoteSearchVC.designViewController = self
        }

    }

    @IBAction func searchQuotesButtonTapped(_ sender: UIButton) {
        let paperQuotesVC = storyboard?.instantiateViewController(withIdentifier: Constants.Identifiers.paperQuotesViewController) as! PaperQuotesViewController
        paperQuotesVC.designViewController = self
        self.present(paperQuotesVC, animated: true)
    }

    @IBAction func editAttachmentButtonTapped(_ sender: UIButton) {
        let alert = UIAlertController(title: "Choose a photo", message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Search Unsplash", style: .default, handler: {_ in
            let unsplashVC = self.storyboard?.instantiateViewController(withIdentifier: Constants.Identifiers.unsplashViewController) as! UnsplashViewController
            self.present(unsplashVC, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in
            self.pickAnImageFrom(.camera)
        }))
        alert.addAction(UIAlertAction(title:"Photo Library", style: .default, handler: {_ in
            self.pickAnImageFrom(.photoLibrary)
        }))

        self.present(alert, animated: true)
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
