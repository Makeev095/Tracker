import UIKit

final class StatisticsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "ypWhite") ?? .systemBackground
        navigationItem.title = "Статистика"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
}
