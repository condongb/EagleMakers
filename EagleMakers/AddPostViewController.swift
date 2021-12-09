//
//  AddPostViewController.swift
//  EagleMakers
//
//  Created by Gage Condon on 12/4/21.
//

import UIKit

class AddPostViewController: UIViewController {
    
    @IBOutlet weak var postTitleTextField: UITextField!
    @IBOutlet weak var mainPostImageView: UIImageView!
    @IBOutlet weak var cancelBarButton: UIBarButtonItem!
    @IBOutlet weak var addPostBarButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var addStepButton: UIButton!
    
    var imagePickerController = UIImagePickerController()
    
    var post: Post!
    var steps: Steps!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide keyboard if we tap outside of a view
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
        tableView.register(PostStepTableViewCell.nib(), forCellReuseIdentifier: PostStepTableViewCell.identifier)
        
        imagePickerController.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        
        if post == nil {
            post = Post()
        } else {
            updateUserInterface()
            addPostBarButton.hide()
            cancelBarButton.title = "Back"
            postTitleTextField.isEnabled = false
            postTitleTextField.borderStyle = .none
            addPhotoButton.isHidden = true
            addStepButton.isHidden = true
            addPostBarButton.title = "Done"
        }
        
        if steps == nil {
            steps = Steps()
        }
        
        print("stepArray in AddPost viewdidload: \(steps.stepArray)")
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setToolbarHidden(true, animated: true)

        if post.documentID != "" {
            steps.loadData(post: post) {
                self.tableView.reloadData()
            }
        }
        
        print("stepArray in AddPost viewwillappear: \(steps.stepArray)")
        self.tableView.reloadData()
    }
    
    func updateUserInterface() {
        postTitleTextField.text = post.title
        let photoURL = URL(string: post.mainPostImageURL)
        mainPostImageView.sd_setImage(with: photoURL)
    }
    
    func updateFromInterface() {
        post.title = postTitleTextField.text!
        post.mainPostImage = mainPostImageView.image!
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        updateFromInterface()
        switch segue.identifier ?? "" {
        case "AddStep":
            let navigationController = segue.destination as! UINavigationController
            let destination = navigationController.viewControllers.first as! StepTableViewController
            destination.post = post
            destination.steps = steps
        case "ShowStep":
            let destination = segue.destination as! StepTableViewController
            let selectedIndexPath = tableView.indexPathForSelectedRow!
            destination.post = post
            destination.steps = steps
            destination.step = steps.stepArray[selectedIndexPath.row]
        default:
            print("Couldn't find a case for segue identifier... this should not have happened!")
        }
    }
    
    @IBAction func unwindToThisView(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? StepTableViewController {
            sourceViewController.updateFromUserInterface()
            sourceViewController.steps.stepArray.append(sourceViewController.step)
            steps = sourceViewController.steps
        }
    }
    
    
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func saveCancelAlert(title: String, message: String, segueIdentifier: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save", style: .default) { (_) in
            self.post.saveData { (success) in
                self.addPostBarButton.title = "Done"
                self.cancelBarButton.hide()
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    
    
    func leaveViewController() {
        let isPresentingInAddMode = presentingViewController is UINavigationController
        if isPresentingInAddMode {
            dismiss(animated: true, completion: nil)
        } else {
            navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func addPhotoButtonPressed(_ sender: UIButton) {
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
    
    
    @IBAction func addPostButtonPressed(_ sender: UIBarButtonItem) {
        updateFromInterface()
        
        post.saveData { (success) in
            if success {
                for step in self.steps.stepArray {
                    step.saveData(post: self.post) { (success) in
                        self.leaveViewController()
                    }
                }
            } else {
                self.oneButtonAlert(title: "Save Failed", message: "For some reason the data would not save to the cloud. ")
            }
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
        leaveViewController()
    }
    
    @IBAction func addStepButtonPressed(_ sender: UIButton) {
        updateFromInterface()
        performSegue(withIdentifier: "AddStep", sender: self)
//        if post.documentID == "" {
//            saveCancelAlert(title: "This Venue Has Not Been Saved", message: "You must save this venue before you can review it.", segueIdentifier: "AddReview")
//        } else {
//            performSegue(withIdentifier: "AddStep", sender: nil)
//        }
    }
    
}

extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            mainPostImageView.image = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            mainPostImageView.image = originalImage
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


extension AddPostViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return steps.stepArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostStepTableViewCell", for: indexPath) as! PostStepTableViewCell
        cell.configure(with: steps.stepArray[indexPath.row])
        cell.stepTitleLabel.text = "Step \(indexPath.row+1): \(steps.stepArray[indexPath.row].title)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowStep", sender: self)
    }
    
    
}
