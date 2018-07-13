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
protocol ImageCropperViewControllerDelegate {
    func imageDidFinishCropping(imageCropperViewController: ImageCropperViewController)
}

class ImageCropperViewController: UIViewController {

    var xOffset: CGFloat
    var yOffset: CGFloat
    
    var imageViewTopAnchorConstraint: NSLayoutConstraint?
    var imageViewLeadingAnchorConstraint: NSLayoutConstraint?
    
    var delegate: ImageCropperViewControllerDelegate?
    
    var croppedImage: UIImage!
    
    let navigationBar : UINavigationBar = {
        let nb = UINavigationBar()
        let nitem = UINavigationItem(title: "Crop")
        nb.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)
        nitem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(cropImageAndExit))
        
        nb.items = [nitem]
        
        nb.translatesAutoresizingMaskIntoConstraints = false
        return nb
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        //let iv = UIImageView(image: #imageLiteral(resourceName: "cliffs"))
        
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    let scrollView: UIScrollView = {
        let sv = UIScrollView()
        //sv.layer.borderColor = UIColor.white.cgColor
        sv.backgroundColor = UIColor.white
        //sv.layer.borderWidth = 1
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()
    
    
    
    init(image: UIImage) {
        self.imageView.image = image
        self.xOffset = 0
        self.yOffset = 0
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    override func viewDidLoad() {
        print("In View Did Load \(navigationBar.tintColor)")
        
        super.viewDidLoad()
        
        
        
        //scrollview delegate
        scrollView.delegate = self
        navigationBar.delegate = self
        
        //view background
        self.view.backgroundColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)
        //self.view.alpha = 0.9
        
        self.view.addSubview(scrollView)
        self.view.addSubview(navigationBar)
        scrollView.addSubview(imageView)
        
        navigationBar.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
        navigationBar.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        navigationBar.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        navigationBar.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        scrollView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        scrollView.heightAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
                   
        imageViewLeadingAnchorConstraint = imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor)
        imageViewLeadingAnchorConstraint?.isActive = true
        
        imageView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor).isActive = true
        
        imageViewTopAnchorConstraint = imageView.topAnchor.constraint(equalTo: scrollView.topAnchor)
        imageViewTopAnchorConstraint?.isActive = true
        
        imageView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor).isActive = true
        
        
        
        
    }
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        centerSrcollViewContents()
        print("LAYING OUT SUBVIEWS")
    }
    
    
    
    override func viewDidLayoutSubviews() {
        
        print("In View Did Layout Subview")
        
        /********************/
        let scrollViewBorder = CAShapeLayer()
        scrollViewBorder.frame = scrollView.frame
        scrollViewBorder.lineWidth = 1
        scrollViewBorder.lineDashPattern = [20, 5, 10, 5]
        scrollViewBorder.fillColor = UIColor.clear.cgColor
        scrollViewBorder.strokeColor = UIColor.lightGray.cgColor
        scrollViewBorder.path = UIBezierPath(rect: scrollView.bounds).cgPath
        view.layer.addSublayer(scrollViewBorder)
        
        /********************/
        
        super.viewDidLayoutSubviews()
        updateMinZoomScaleForSize(scrollView.frame.size)
    }
    
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        print("In updateMinZoomScaleForSize")
        
        
        let widthScale = size.width / (imageView.image?.size.width)!
        let heightScale = size.height / (imageView.image?.size.height)!
        let minScale = min(widthScale, heightScale)
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func updateViewConstraints() {
        imageViewTopAnchorConstraint?.constant = yOffset
        imageViewLeadingAnchorConstraint?.constant = xOffset
        //        imageView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: -yOffset)
        //        imageView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: -xOffset)
        super.updateViewConstraints()
        print("UPDATING VIE CONSTRAINTS")
        
        //        imageView.frame.origin.y = yOffset
        //
        //        imageView.frame.origin.x = xOffset
    }
    
    @objc func cropImageAndExit(){
        print("dismissing")
        
        /************/
        
        
        UIGraphicsBeginImageContextWithOptions(scrollView.frame.size, false, UIScreen.main.scale)
        let offset = scrollView.contentOffset
        print("offset: \(offset)")
        UIGraphicsGetCurrentContext()?.translateBy(x: -offset.x, y: -offset.y)
        scrollView.layer.render(in: UIGraphicsGetCurrentContext()!)
        croppedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageView.image = croppedImage
        
        /***************/
        delegate?.imageDidFinishCropping(imageCropperViewController: self)
        dismiss(animated: true, completion: nil)
    }

}

extension ImageCropperViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func centerSrcollViewContents(){
        yOffset = max(0, (scrollView.bounds.size.height - imageView.frame.height) / 2)
        
        xOffset = max(0, (scrollView.bounds.size.width - imageView.frame.width) / 2)
        updateViewConstraints()
    }
    
    //
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerSrcollViewContents()
    }
    
}

extension ImageCropperViewController: UINavigationBarDelegate {
    
}
