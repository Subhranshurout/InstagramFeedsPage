//
//  PageViewController.swift
//  InstagramFeedsPage
//
//  Created by Yudiz-subhranshu on 23/10/23.
//

import UIKit

class PageViewController: UIPageViewController {
    var viewControllersList: [UIViewController] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc4 = storyboard.instantiateViewController(withIdentifier: "CameraVC") as? CameraVC {
            viewControllersList.append(vc4)
        }
        if let vc3 = storyboard.instantiateViewController(withIdentifier: "InstagramFeedsVC") as? InstagramFeedsVC {
            viewControllersList.append(vc3)
        }
        delegate = self
        dataSource = self
        setViewControllers([viewControllersList[1]], direction: .forward, animated: true, completion: nil)
    }
}

// MARK: - UIPageViewControllerDataSource

extension PageViewController : UIPageViewControllerDelegate, UIPageViewControllerDataSource {

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewControllersList.firstIndex(of: viewController), currentIndex > 0 else {
            return nil
        }
        return viewControllersList[currentIndex - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentIndex = viewControllersList.firstIndex(of: viewController), currentIndex < viewControllersList.count - 1 else {
            return nil
        }
        return viewControllersList[currentIndex + 1]
    }
}
