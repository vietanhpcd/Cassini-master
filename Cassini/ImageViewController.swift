//
//  ImageViewController.swift
//  Cassini
//
//  Created by Trương Thắng on 4/8/17.
//  Copyright © 2017 Trương Thắng. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
            scrollView.contentSize = imageView.frame.size
            scrollView.addSubview(imageView)
            
            scrollView.maximumZoomScale = 1
            scrollView.minimumZoomScale = 0.03
        }
    }
    var imageURL: URL? {
        didSet {
            image = nil
            if view.window != nil {
                fetchImage()
            }
        }
    }
    
    private func fetchImage() {
        guard let url = imageURL else {return}
        if let img = Cache.cache.object(forKey: url as NSURL) {
            image = img
        } else {
            spinner.startAnimating()
            DispatchQueue.global(qos: .userInitiated).async {
                guard let imagedata = try? Data(contentsOf: url) else {
                    self.spinner.stopAnimating()
                    return}
                DispatchQueue.main.async {
                    self.image = UIImage(data: imagedata)
                    self.spinner.stopAnimating()
                    Cache.cache.setObject(self.image!, forKey: url as NSURL)
                }
            }
        }
    }
    
    var imageView = UIImageView()
    private var image: UIImage? {
        set {
            imageView.image = newValue
            imageView.sizeToFit()
        }
        get {
            return imageView.image
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if image == nil {
            fetchImage()
        }
    }
}

// MARK: - UIScrollViewDelegate

extension ImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
