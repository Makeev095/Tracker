import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
        setupAppearance()
    }

    private func setupTabs() {
        let trackersViewController = TrackersViewController()
        let trackersNavigationController = UINavigationController(rootViewController: trackersViewController)
        trackersNavigationController.tabBarItem = UITabBarItem(
            title: "Трекеры",
            image: UIImage(systemName: "record.circle.fill"),
            selectedImage: nil
        )

        let statisticsViewController = StatisticsViewController()
        let statisticsNavigationController = UINavigationController(rootViewController: statisticsViewController)
        statisticsNavigationController.tabBarItem = UITabBarItem(
            title: "Статистика",
            image: UIImage(systemName: "hare.fill"),
            selectedImage: nil
        )

        viewControllers = [trackersNavigationController, statisticsNavigationController]
    }

    private func setupAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "ypWhite") ?? .systemBackground
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(named: "ypBlue")
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(named: "ypBlue") ?? .systemBlue
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(named: "ypGray")
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(named: "ypGray") ?? .systemGray
        ]

        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        tabBar.tintColor = UIColor(named: "ypBlue")
        tabBar.unselectedItemTintColor = UIColor(named: "ypGray")
    }
}
