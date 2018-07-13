//
//  ViewController.swift
//  ImageCropperWithAutoLayoutConstraints
//
//  Created by Kinzang Chhogyal on 13/7/18.
//  Copyright © 2018 Kinzang Chhogyal. All rights reserved.
//

/*
* This is the main view controller.
* Afer an image is selected it will launch the ImageCropperViewController.
 */

import UIKit

class ViewController: UIViewController {
    
    // MARK: Properties
    
    //imagePicker
    let picker = UIImagePickerController()
    
    //to launch image picker by tapping image
    let tapGestureRecognizer = UITapGestureRecognizer()
    
    // imageView to show cropped image
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 100
        iv.clipsToBounds = true
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.red.cgColor
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //imagePicker setup
        picker.delegate = self
        picker.sourceType = .photoLibrary
        
        //tapGestureRecogniser setup
        tapGestureRecognizer.addTarget(self, action: #selector(imageTapped))
        
        //add views
        view.addSubview(imageView)
        imageView.addGestureRecognizer(tapGestureRecognizer)
        
        //view layout constraints
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive  = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive  = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor).isActive = true
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Action
    
    //imageView tapped, launch picker
    @objc func imageTapped(_ sender : UITapGestureRecognizer){
        self.present(picker, animated: true, completion: nil)
    }
    
}

// MARK: Extension

/*
* UIImagePickerControllerDelegate, UINavigationControllerDelegate : for imagePicker
*
* ImageCropperViewControllerDelegate: for getting cropped image from ImageCropperViewController
* It is a protocol declared in the ImageCropperViewController.
*/

extension ViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate, ImageCropperViewControllerDelegate {
    
    //if image is picked...
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //save the image that is picked
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        //dismiss image picker
        dismiss(animated: true, completion: nil)
        
        //instantiate ImageCropperViewController
        let imageCropperViewController = ImageCropperViewController(image: image)
        
        //make this view controller the delegate
        imageCropperViewController.delegate = self
        
        //presnet ImageCropperViewController
        self.present(imageCropperViewController, animated: true, completion: nil)
        
    }
    
    // image finished cropping, update image view
    // implemented by this view controller as required by ImageCropperViewControllerDelegate
    func imageDidFinishCropping(imageCropperViewController: ImageCropperViewController) {
        print("HELLO")
        print("Cropped Image  size: \(imageCropperViewController.croppedImage.size)")
        imageView.image = imageCropperViewController.croppedImage
    }


}

