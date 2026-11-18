import UIKit

final class TrackersViewController: UIViewController {

    private let emptyImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "EmptyTrackers"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let emptyLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor(named: "ypBlack")
        label.textAlignment = .center
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "ypWhite") ?? .systemBackground
        setupNavigationBar()
        setupEmptyState()
    }

    private func setupNavigationBar() {
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true

        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        addButton.tintColor = UIColor(named: "ypBlack")
        navigationItem.leftBarButtonItem = addButton
    }

    private func setupEmptyState() {
        view.addSubview(emptyImageView)
        view.addSubview(emptyLabel)

        NSLayoutConstraint.activate([
            emptyImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyImageView.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            emptyImageView.widthAnchor.constraint(equalToConstant: 80),
            emptyImageView.heightAnchor.constraint(equalToConstant: 80),

            emptyLabel.topAnchor.constraint(equalTo: emptyImageView.bottomAnchor, constant: 8),
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 16),
            emptyLabel.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -16)
        ])
    }

    @objc private func didTapAddButton() {
        // Реализацию логики выполним в следующих уроках.
    }
}
