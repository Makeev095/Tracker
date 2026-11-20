import UIKit

final class OnboardingViewController: UIPageViewController {

    private enum StorageKey {
        static let isCompleted = "isOnboardingCompleted"
    }

    static var shouldShow: Bool {
        !UserDefaults.standard.bool(forKey: StorageKey.isCompleted)
    }

    private lazy var pages: [UIViewController] = [
        OnboardingPageViewController(
            imageName: "OnboardingBlue",
            title: "Отслеживайте только то, что хотите"
        ),
        OnboardingPageViewController(
            imageName: "OnboardingRed",
            title: "Даже если нечего отслеживать"
        )
    ]

    private let pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.currentPageIndicatorTintColor = UIColor(named: "ypBlack")
        pageControl.pageIndicatorTintColor = UIColor(named: "ypBlack")?.withAlphaComponent(0.3)
        pageControl.numberOfPages = 2
        return pageControl
    }()

    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Вот это технологии", for: .normal)
        button.setTitleColor(UIColor(named: "ypWhite"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "ypBlack")
        button.layer.cornerRadius = 16
        return button
    }()

    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: false)
        }

        actionButton.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        view.addSubview(pageControl)
        view.addSubview(actionButton)

        NSLayoutConstraint.activate([
            actionButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            actionButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            actionButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            actionButton.heightAnchor.constraint(equalToConstant: 60),

            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pageControl.bottomAnchor.constraint(equalTo: actionButton.topAnchor, constant: -24)
        ])
    }

    @objc private func didTapAction() {
        UserDefaults.standard.set(true, forKey: StorageKey.isCompleted)
        guard let window = view.window else { return }
        window.rootViewController = TabBarController()
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: nil)
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index > 0 else { return nil }
        return pages[index - 1]
    }

    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController
    ) -> UIViewController? {
        guard let index = pages.firstIndex(of: viewController), index < pages.count - 1 else { return nil }
        return pages[index + 1]
    }
}

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        didFinishAnimating finished: Bool,
        previousViewControllers: [UIViewController],
        transitionCompleted completed: Bool
    ) {
        guard let current = pageViewController.viewControllers?.first,
              let index = pages.firstIndex(of: current) else { return }
        pageControl.currentPage = index
    }
}
