//
//  PhotoViewController.swift
//  Notes
//
//  Created by andrey on 2019-07-22.
//  Copyright © 2019 andrey. All rights reserved.
//

import UIKit

class PhotoViewController: UIViewController {

    private let photoView = PhotoView()

    override internal func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    override internal func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        photoView.frame = view.safeAreaLayoutGuide.layoutFrame
    }

    override internal func viewWillAppear(_ animated: Bool) {
        if (self.isMovingToParent) {
            self.tabBarController?.tabBar.isHidden = true
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        if (self.isMovingFromParent) {
            self.tabBarController?.tabBar.isHidden = false
        }
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        photoView.viewWillTransition()
    }

    internal func setCurrentPhoto(index: Int) {
        photoView.pageSelected = index
    }

    private func setupViews() {
        view.backgroundColor = UIColor.black
        view.addSubview(photoView)
    }
}
