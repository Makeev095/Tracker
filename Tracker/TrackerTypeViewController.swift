import UIKit

final class TrackerTypeViewController: UIViewController {

    var onSelectHabit: (() -> Void)?
    var onSelectIrregularEvent: (() -> Void)?

    private let habitButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Привычка", for: .normal)
        button.setTitleColor(UIColor(named: "ypWhite"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "ypBlack")
        button.layer.cornerRadius = 16
        return button
    }()

    private let irregularEventButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Нерегулярное событие", for: .normal)
        button.setTitleColor(UIColor(named: "ypWhite"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = UIColor(named: "ypBlack")
        button.layer.cornerRadius = 16
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "ypWhite") ?? .systemBackground
        navigationItem.title = "Создание трекера"
        navigationItem.largeTitleDisplayMode = .never

        habitButton.addTarget(self, action: #selector(didTapHabit), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(didTapIrregularEvent), for: .touchUpInside)

        view.addSubview(habitButton)
        view.addSubview(irregularEventButton)

        NSLayoutConstraint.activate([
            habitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.heightAnchor.constraint(equalToConstant: 60),

            irregularEventButton.leadingAnchor.constraint(equalTo: habitButton.leadingAnchor),
            irregularEventButton.trailingAnchor.constraint(equalTo: habitButton.trailingAnchor),
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    @objc private func didTapHabit() {
        onSelectHabit?()
    }

    @objc private func didTapIrregularEvent() {
        onSelectIrregularEvent?()
    }
}
