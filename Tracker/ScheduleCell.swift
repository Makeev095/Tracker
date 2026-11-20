import UIKit

protocol ScheduleCellDelegate: AnyObject {
    func scheduleCell(_ cell: ScheduleCell, didChangeValue isOn: Bool, for day: WeekDay)
}

final class ScheduleCell: UITableViewCell {

    static let reuseIdentifier = "ScheduleCell"

    weak var delegate: ScheduleCellDelegate?
    private var day: WeekDay?

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = UIColor(named: "ypBlack")
        return label
    }()

    private lazy var daySwitch: UISwitch = {
        let daySwitch = UISwitch()
        daySwitch.translatesAutoresizingMaskIntoConstraints = false
        daySwitch.onTintColor = UIColor(named: "ypBlue")
        daySwitch.addTarget(self, action: #selector(didChangeSwitch), for: .valueChanged)
        return daySwitch
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = UIColor(named: "ypBackground")
        contentView.backgroundColor = UIColor(named: "ypBackground")

        contentView.addSubview(titleLabel)
        contentView.addSubview(daySwitch)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),

            daySwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daySwitch.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: daySwitch.leadingAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(day: WeekDay, isOn: Bool) {
        self.day = day
        titleLabel.text = day.title
        daySwitch.isOn = isOn
    }

    @objc private func didChangeSwitch() {
        guard let day else { return }
        delegate?.scheduleCell(self, didChangeValue: daySwitch.isOn, for: day)
    }
}
