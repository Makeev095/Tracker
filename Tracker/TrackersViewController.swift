import UIKit

final class TrackersViewController: UIViewController {

    private let defaultCategoryTitle = "Важное"

    private var categories: [TrackerCategory] = [
        TrackerCategory(title: "Важное", trackers: [])
    ]
    private var completedTrackers: [TrackerRecord] = []
    private var completedTrackerIDs: Set<UUID> = []
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate = Date()

    private lazy var datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "ru_RU")
        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        return datePicker
    }()

    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.reuseIdentifier)
        collectionView.register(
            TrackerCategoryHeader.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: TrackerCategoryHeader.reuseIdentifier
        )
        return collectionView
    }()

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
        setupCollectionView()
        setupEmptyState()
        reloadVisibleCategories()
    }

    private func setupNavigationBar() {
        navigationItem.title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always

        let addButton = UIBarButtonItem(
            image: UIImage(systemName: "plus"),
            style: .plain,
            target: self,
            action: #selector(didTapAddButton)
        )
        addButton.tintColor = UIColor(named: "ypBlack")
        navigationItem.leftBarButtonItem = addButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: datePicker)
    }

    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
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
        let typeViewController = TrackerTypeViewController()
        typeViewController.onSelectHabit = { [weak self] in
            self?.showNewTracker(isHabit: true)
        }
        typeViewController.onSelectIrregularEvent = { [weak self] in
            self?.showNewTracker(isHabit: false)
        }

        let navigationController = UINavigationController(rootViewController: typeViewController)
        present(navigationController, animated: true)
    }

    private func showNewTracker(isHabit: Bool) {
        let newTrackerViewController = NewTrackerViewController(isHabit: isHabit)
        newTrackerViewController.delegate = self
        let navigation = (presentedViewController as? UINavigationController)
            ?? (navigationController?.presentedViewController as? UINavigationController)
        navigation?.pushViewController(newTrackerViewController, animated: true)
    }

    @objc private func dateChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        reloadVisibleCategories()
    }

    private func reloadVisibleCategories() {
        let weekday = WeekDay.from(date: currentDate)
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                tracker.schedule.isEmpty || tracker.schedule.contains(weekday)
            }
            guard !trackers.isEmpty else { return nil }
            return TrackerCategory(title: category.title, trackers: trackers)
        }

        reloadCompletedIDs()

        let isEmpty = visibleCategories.isEmpty
        emptyImageView.isHidden = !isEmpty
        emptyLabel.isHidden = !isEmpty
        collectionView.isHidden = isEmpty
        collectionView.reloadData()
    }

    private func reloadCompletedIDs() {
        completedTrackerIDs = Set(
            completedTrackers
                .filter { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                .map(\.trackerId)
        )
    }

    private func addTracker(_ tracker: Tracker) {
        if let index = categories.firstIndex(where: { $0.title == defaultCategoryTitle }) {
            let category = categories[index]
            let updatedCategory = TrackerCategory(
                title: category.title,
                trackers: category.trackers + [tracker]
            )
            categories = categories.enumerated().map { $0.offset == index ? updatedCategory : $0.element }
        } else {
            categories = categories + [TrackerCategory(title: defaultCategoryTitle, trackers: [tracker])]
        }
        reloadVisibleCategories()
    }

    private func completedDays(for trackerId: UUID) -> Int {
        completedTrackers.filter { $0.trackerId == trackerId }.count
    }

    private func isFutureDate(_ date: Date) -> Bool {
        Calendar.current.startOfDay(for: date) > Calendar.current.startOfDay(for: Date())
    }
}

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        visibleCategories.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleCategories[section].trackers.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: TrackerCell.reuseIdentifier,
            for: indexPath
        ) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        cell.configure(
            tracker: tracker,
            completedDays: completedDays(for: tracker.id),
            isCompleted: completedTrackerIDs.contains(tracker.id)
        )
        cell.delegate = self
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: TrackerCategoryHeader.reuseIdentifier,
                for: indexPath
              ) as? TrackerCategoryHeader else {
            return UICollectionReusableView()
        }
        header.configure(title: visibleCategories[indexPath.section].title)
        return header
    }
}

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.bounds.width - 16 * 2 - 9
        return CGSize(width: floor(availableWidth / 2), height: 148)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(top: 0, left: 16, bottom: 16, right: 16)
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        9
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        0
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: 46)
    }
}

extension TrackersViewController: TrackerCellDelegate {
    func trackerCellDidTapComplete(_ cell: TrackerCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        guard !isFutureDate(currentDate) else { return }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        if completedTrackerIDs.contains(tracker.id) {
            completedTrackers = completedTrackers.filter { record in
                !(record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: currentDate))
            }
            completedTrackerIDs.remove(tracker.id)
        } else {
            completedTrackers = completedTrackers + [TrackerRecord(trackerId: tracker.id, date: currentDate)]
            completedTrackerIDs.insert(tracker.id)
        }
        cell.updateCompletion(
            completedDays: completedDays(for: tracker.id),
            isCompleted: completedTrackerIDs.contains(tracker.id)
        )
    }
}

extension TrackersViewController: NewTrackerViewControllerDelegate {
    func didCreateTracker(_ tracker: Tracker) {
        addTracker(tracker)
    }
}
