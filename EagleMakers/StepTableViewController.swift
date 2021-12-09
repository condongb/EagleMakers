//
//  StepTableViewController.swift
//  EagleMakers
//
//  Created by Gage Condon on 12/5/21.
//

import UIKit

class StepTableViewController: UITableViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var stepImageView: UIImageView!
    @IBOutlet weak var addStepBarButton: UIBarButtonItem!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var addPhotoButton: UIButton!
    
    var imagePickerController = UIImagePickerController()
    var step: Step!
    var post: Post!
    var steps: Steps!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setToolbarHidden(true, animated: true)
        
        //hide keyboard if we tap outside of a view
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        imagePickerController.delegate = self
        
        guard post != nil else {
            print("ERROR: Nno spot passed to REviewRTableVieController.swift")
            return
        }
        
        if step == nil {
            step = Step()
        }
        
        if post.documentID != "" {
            updateUserInterface()
            addStepBarButton.hide()
            cancelBarButton.title = "Done"
            addPhotoButton.isHidden = true
            titleTextField.borderStyle = .none
        } else {
            addBordersToEditableObjects()
        }

    }
    
    func addBordersToEditableObjects() {
        titleTextField.addBorder(width: 0.5, radius: 5.0, color: .black)
        descriptionTextView.addBorder(width: 0.5, radius: 5.0, color: .black)
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func updateUserInterface() {
        titleTextField.text = step.title
        descriptionTextView.text = step.text
        let photoURL = URL(string: step.stepImageURL)
        stepImageView.sd_setImage(with: photoURL)
    }
    
    func updateFromUserInterface() {
        step.title = titleTextField.text!
        step.text = descriptionTextView.text!
        step.stepImage = stepImageView.image!
    }
    
    
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func addImageButtonPressed(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (_) in
            self.accessPhotoLibrary()
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (_) in
            self.accessCamera()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cameraAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addStepButtonPressed(_ sender: UIBarButtonItem) {
        updateFromUserInterface()
        step.saveData(post: post) { (success) in
            if success {
                self.leaveViewController()
            } else {
                print("ERROR: Can't unwind segue from Step because of step saving error.")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
}

extension StepTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            stepImageView.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            stepImageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func accessPhotoLibrary() {
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func accessCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePickerController.sourceType = .camera
            present(imagePickerController, animated: true, completion: nil)
        } else {
            showAlert(title: "Camera Not Availible", message: "There is no camera availible on this device.")
        }
    }
}
