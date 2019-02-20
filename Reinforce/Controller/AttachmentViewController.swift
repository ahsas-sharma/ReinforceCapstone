//
//  AttachmentViewController.swift
//  Reinforce
//
//  Created by Ahsas Sharma on 17/02/19.
//  Copyright © 2019 Ahsas Sharma. All rights reserved.
//

import Foundation

class AttachmentViewController : UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("AttachmentViewController viewDidLoad")
    }


    // MARK: - Helper -

    @IBAction func takePhotoButtonTapped(_ sender: UIButton) {
        pickAnImageFrom(.camera)
    }

    @IBAction func selectFromPhotoLibraryButtonTapped(_ sender: UIButton) {
        pickAnImageFrom(.photoLibrary)
    }

    /// Presents an imagePickerController based on the source type
    func pickAnImageFrom(_ source: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = source
        imagePicker.allowsEditing = true
        imagePicker.setEditing(true, animated: true)
        imagePicker.modalPresentationStyle = .overCurrentContext
    }
}


// MARK:- ImagePicker Delegate -

extension AttachmentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)

        print("Picker didFinishPickingMediaWithInfo from source:\(picker.sourceType)")

        guard let image = info[.editedImage] as? UIImage else {
            print("No image found")
            return
        }

        // print out the image size as a test
        print(image.size)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

}
