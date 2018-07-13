//
//  ImageCropperViewController.swift
//  ImageCropperWithAutoLayoutConstraints
//
//  Created by Kinzang Chhogyal on 13/7/18.
//  Copyright © 2018 Kinzang Chhogyal. All rights reserved.
//

/*
 * This view controller receives an images.
 * The user can zoom and pan, and then crop the image.
 * The cropped image can be accessed by the calling view controller.
 */

import UIKit

// MARK: Protocol
// To be implemented in calling view controller - what happens after cropping finished

protocol ImageCropperViewControllerDelegate {
    func imageDidFinishCropping(imageCropperViewController: ImageCropperViewController)
}

// MARK: Class

class ImageCropperViewController: UIViewController {
    
    // MARK: Properties

    //offsets for centering image
    var xOffset: CGFloat = 0
    var yOffset: CGFloat = 0
    
    //constraints for positioning imageView after zoom
    var imageViewTopAnchorConstraint: NSLayoutConstraint?
    var imageViewLeadingAnchorConstraint: NSLayoutConstraint?
    
    // delegate - the calling view controller
    var delegate: ImageCropperViewControllerDelegate?
    
    //variable to store cropped image
    var croppedImage: UIImage!
    
    //navigaton bar
    let navigationBar : UINavigationBar = {
        let nb = UINavigationBar()
        let nitem = UINavigationItem(title: "Crop")
        nb.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)
        nitem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(cropImageAndExit))
        nb.items = [nitem]
        nb.translatesAutoresizingMaskIntoConstraints = false
        return nb
    }()
    
    //imageView containing image to be cropped - inside scrollView
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    //scrollView for zooming and panning
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.backgroundColor = UIColor.white
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    
    // MARK: Initializers
    
    //intialize with image to be cropped
    init(image: UIImage) {
        //set image in imageView
        self.imageView.image = image
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //assign delegates
        scrollView.delegate = self
        navigationBar.delegate = self
        
        //view background
        self.view.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)
        
        // add subviews
        self.view.addSubview(scrollView)
        self.view.addSubview(navigationBar)
        scrollView.addSubview(imageView) //imaveView in scrollView
        
        
        //layout constraints
        
        navigationBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        navigationBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        navigationBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        navigationBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        scrollView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        scrollView.heightAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
        
        //save imageView Constraints for later use
        
        imageViewLeadingAnchorConstraint = imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        imageViewLeadingAnchorConstraint?.isActive = true
        
        imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        
        imageViewTopAnchorConstraint = imageView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        imageViewTopAnchorConstraint?.isActive = true
        
        imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        //center imageView in scrollView
        centerScrollViewContents()
    }
    
    override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
        
        //set scrollView border
        let scrollViewBorder = CAShapeLayer()
        scrollViewBorder.frame = scrollView.frame
        scrollViewBorder.lineWidth = 1
        scrollViewBorder.lineDashPattern = [20, 5, 10, 5]
        scrollViewBorder.fillColor = UIColor.clear.cgColor
        scrollViewBorder.strokeColor = UIColor.lightGray.cgColor
        scrollViewBorder.path = UIBezierPath(rect: scrollView.bounds).cgPath
        view.layer.addSublayer(scrollViewBorder)
        
        //update zoom scale for scrollView
        updateMinZoomScaleForSize(scrollView.frame.size)
    }
    
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / (imageView.image?.size.width)!
        let heightScale = size.height / (imageView.image?.size.height)!
        let minScale = min(widthScale, heightScale)
        
        //minimum scale is scale that fits image in scrollView
        scrollView.minimumZoomScale = minScale
        
        //current zoomScale
        scrollView.zoomScale = minScale
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //update view constraints - for imageView centering after zoom
    override func updateViewConstraints() {
        imageViewTopAnchorConstraint?.constant = yOffset
        imageViewLeadingAnchorConstraint?.constant = xOffset
        super.updateViewConstraints()
    }
    
    // MARK: Action
    
    //crop image action
    @objc func cropImageAndExit(){
        //save image in scroll view area
        UIGraphicsBeginImageContextWithOptions(scrollView.frame.size, false, UIScreen.main.scale)
        let offset = scrollView.contentOffset
        UIGraphicsGetCurrentContext()?.translateBy(x: -offset.x, y: -offset.y)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //imageView.image = croppedImage
        
        //call imageDidFinishCropping in delegate, i.e. calling view controller
        delegate?.imageDidFinishCropping(imageCropperViewController: self)
        
        //dismiss this view
        dismiss(animated: true, completion: nil)
    }

}

// MARK: Scroll View Delegate

extension ImageCropperViewController: UIScrollViewDelegate {
    
    // during zooming - view to return
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    // after zooming - task to perform
    // in this case, center imageView
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerScrollViewContents()
    }
    
    //center imageView in scrollView
    fileprivate func centerScrollViewContents(){
        yOffset = max(0, (scrollView.bounds.size.height - imageView.frame.height) / 2)
        xOffset = max(0, (scrollView.bounds.size.width - imageView.frame.width) / 2)
        updateViewConstraints() //call updateViewConstraints
    }
    
}

// MARK: Navigation Bar Delegate

extension ImageCropperViewController: UINavigationBarDelegate {
    
}
