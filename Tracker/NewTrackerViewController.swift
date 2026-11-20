import UIKit

protocol NewTrackerViewControllerDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker)
}

final class NewTrackerViewController: UIViewController {

    private enum Option: Int, CaseIterable {
        case category
        case schedule
    }

    weak var delegate: NewTrackerViewControllerDelegate?

    private let isHabit: Bool
    private var selectedSchedule: Set<WeekDay> = []
    private let defaultEmoji = "🙂"
    private let defaultColor = UIColor(red: 253 / 255, green: 76 / 255, blue: 73 / 255, alpha: 1)

    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = UIColor(named: "ypBackground")
        textField.layer.cornerRadius = 16
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 75))
        textField.rightViewMode = .always
        textField.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        textField.clearButtonMode = .whileEditing
        textField.returnKeyType = .done
        return textField
    }()

    private let optionsTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = UIColor(named: "ypBackground")
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorColor = UIColor(named: "ypGray")
        tableView.isScrollEnabled = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "OptionCell")
        return tableView
    }()

    private var optionsTableHeightConstraint: NSLayoutConstraint?
    private var buttonsBottomConstraint: NSLayoutConstraint?

    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.keyboardDismissMode = .onDrag
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()

    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let buttonsStack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Отменить", for: .normal)
        button.setTitleColor(UIColor(named: "ypRed"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(named: "ypRed")?.cgColor
        return button
    }()

    private let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Создать", for: .normal)
        button.setTitleColor(UIColor(named: "ypWhite"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 16
        return button
    }()

    init(isHabit: Bool) {
        self.isHabit = isHabit
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "ypWhite") ?? .systemBackground
        navigationItem.title = isHabit ? "Новая привычка" : "Новое нерегулярное событие"
        navigationItem.largeTitleDisplayMode = .never

        optionsTableView.dataSource = self
        optionsTableView.delegate = self
        nameTextField.delegate = self
        nameTextField.addTarget(self, action: #selector(didChangeName), for: .editingChanged)
        cancelButton.addTarget(self, action: #selector(didTapCancel), for: .touchUpInside)
        createButton.addTarget(self, action: #selector(didTapCreate), for: .touchUpInside)

        setupLayout()
        updateCreateButtonState()
        registerKeyboardNotifications()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func setupLayout() {
        buttonsStack.addArrangedSubview(cancelButton)
        buttonsStack.addArrangedSubview(createButton)

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(nameTextField)
        contentView.addSubview(optionsTableView)
        view.addSubview(buttonsStack)

        let tableHeight = CGFloat(optionsCount) * 75
        let heightConstraint = optionsTableView.heightAnchor.constraint(equalToConstant: tableHeight)
        optionsTableHeightConstraint = heightConstraint

        let bottomConstraint = buttonsStack.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.bottomAnchor,
            constant: -16
        )
        buttonsBottomConstraint = bottomConstraint

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStack.topAnchor, constant: -16),

            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            nameTextField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            nameTextField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            nameTextField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            nameTextField.heightAnchor.constraint(equalToConstant: 75),

            optionsTableView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 24),
            optionsTableView.leadingAnchor.constraint(equalTo: nameTextField.leadingAnchor),
            optionsTableView.trailingAnchor.constraint(equalTo: nameTextField.trailingAnchor),
            optionsTableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24),
            heightConstraint,

            buttonsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            bottomConstraint,
            buttonsStack.heightAnchor.constraint(equalToConstant: 60)
        ])
    }

    private func registerKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        let keyboardInView = view.convert(frame, from: nil)
        let overlap = max(0, view.bounds.maxY - keyboardInView.minY)
        buttonsBottomConstraint?.constant = overlap > 0 ? -(overlap - view.safeAreaInsets.bottom + 8) : -16
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
        buttonsBottomConstraint?.constant = -16
        UIView.animate(withDuration: duration) {
            self.view.layoutIfNeeded()
        }
    }

    private var optionsCount: Int {
        isHabit ? Option.allCases.count : 1
    }

    private var isNameValid: Bool {
        !(nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    @objc private func didChangeName() {
        updateCreateButtonState()
    }

    @objc private func hideKeyboard() {
        view.endEditing(true)
    }

    @objc private func didTapCancel() {
        presentingViewController?.dismiss(animated: true)
    }

    @objc private func didTapCreate() {
        let name = (nameTextField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard isNameValid else { return }
        if isHabit && selectedSchedule.isEmpty { return }

        let tracker = Tracker(
            id: UUID(),
            name: name,
            color: defaultColor,
            emoji: defaultEmoji,
            schedule: isHabit ? selectedSchedule : []
        )
        delegate?.didCreateTracker(tracker)
        presentingViewController?.dismiss(animated: true)
    }

    private func updateCreateButtonState() {
        let isEnabled = isNameValid && (!isHabit || !selectedSchedule.isEmpty)
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled
            ? UIColor(named: "ypBlack")
            : UIColor(named: "ypGray")
    }

    private func scheduleSubtitle() -> String? {
        guard !selectedSchedule.isEmpty else { return nil }
        if selectedSchedule.count == WeekDay.allCases.count {
            return "Каждый день"
        }
        return WeekDay.allCases
            .filter { selectedSchedule.contains($0) }
            .map(\.shortTitle)
            .joined(separator: ", ")
    }
}

extension NewTrackerViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        optionsCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OptionCell", for: indexPath)
        var content = UIListContentConfiguration.subtitleCell()
        content.textProperties.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        content.textProperties.color = UIColor(named: "ypBlack") ?? .label
        content.secondaryTextProperties.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        content.secondaryTextProperties.color = UIColor(named: "ypGray") ?? .secondaryLabel

        if indexPath.row == Option.category.rawValue {
            content.text = "Категория"
            content.secondaryText = nil
        } else {
            content.text = "Расписание"
            content.secondaryText = scheduleSubtitle()
        }

        cell.contentConfiguration = content
        cell.backgroundColor = UIColor(named: "ypBackground")
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .none
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        75
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard isHabit, indexPath.row == Option.schedule.rawValue else { return }

        let scheduleViewController = ScheduleViewController(selectedDays: selectedSchedule)
        scheduleViewController.delegate = self
        navigationController?.pushViewController(scheduleViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let isFirst = indexPath.row == 0
        let isLast = indexPath.row == optionsCount - 1
        cell.separatorInset = isLast
            ? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
            : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

        var corners: CACornerMask = []
        if isFirst {
            corners.insert(.layerMinXMinYCorner)
            corners.insert(.layerMaxXMinYCorner)
        }
        if isLast {
            corners.insert(.layerMinXMaxYCorner)
            corners.insert(.layerMaxXMaxYCorner)
        }
        cell.layer.cornerRadius = corners.isEmpty ? 0 : 16
        cell.layer.maskedCorners = corners
        cell.layer.masksToBounds = true
    }
}

extension NewTrackerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension NewTrackerViewController: ScheduleViewControllerDelegate {
    func didConfirmSchedule(_ schedule: Set<WeekDay>) {
        selectedSchedule = schedule
        optionsTableView.reloadData()
        updateCreateButtonState()
    }
}
