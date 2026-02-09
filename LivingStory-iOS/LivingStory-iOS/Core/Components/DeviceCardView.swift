//
//  DeviceCard.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

// MARK: - Device Type Enum

enum DeviceType {
    case light
    case speaker
}

// MARK: - DeviceCard
final class DeviceCardView: UIView {
    
    // MARK: - Properties
    private let deviceType: DeviceType
    private var devicePower: Bool
    
    // MARK: - UI Components
    private let iconBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = .subheadlineEmphasized
        return label
    }()
    
    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .footnoteRegular
        return label
    }()
    
    // MARK: - 초기화
    init(deviceType: DeviceType, devicePower: Bool = false) {
        self.deviceType = deviceType
        self.devicePower = devicePower
        super.init(frame: .zero)
        setupStyle()
        setupHierarchy()
        setupLayout()
        updateAppearance()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Public Methods
extension DeviceCardView {
    func configure(name: String, status: String, devicePower: Bool) {
        self.devicePower = devicePower
        nameLabel.text = name
        statusLabel.text = status
        updateAppearance()
    }
}


// MARK: - Private Methods

private extension DeviceCardView {
    
    func setupStyle() {
        layer.cornerRadius = 20
        clipsToBounds = true
    }
    
    func setupHierarchy() {
        addSubview(iconBackgroundView)
        iconBackgroundView.addSubview(iconImageView)
        addSubview(nameLabel)
        addSubview(statusLabel)
    }
    
    func setupLayout() {
        iconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 아이콘 배경 (상단 14, 좌측 14, 40x40)
            iconBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            iconBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            iconBackgroundView.widthAnchor.constraint(equalToConstant: 40),
            iconBackgroundView.heightAnchor.constraint(equalToConstant: 40),
            
            // 아이콘 이미지 (원형 안 센터)
            iconImageView.centerXAnchor.constraint(equalTo: iconBackgroundView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconBackgroundView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),
            
            // 기기 이름 (아이콘 아래 16pt)
            nameLabel.topAnchor.constraint(equalTo: iconBackgroundView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            
            // 상태 텍스트 (이름 아래 4pt, 하단 14pt)
            statusLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 2),
            statusLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            statusLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            statusLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -14)
        ])
    }
    
    func updateAppearance() {
        switch (deviceType, devicePower) {
        case (.light, true):
            backgroundColor = UIColor(named: "yellow70")
            layer.borderWidth = 1
            layer.borderColor = UIColor(named: "yellow20")?.cgColor
            iconBackgroundView.backgroundColor = UIColor(named: "yellow0")
            iconImageView.image = UIImage(.lightbulb)
            iconImageView.tintColor = UIColor(named: "gray100")
            nameLabel.textColor = UIColor(named: "gray10")
            statusLabel.textColor = UIColor(named: "gray10")
            
        case (.light, false):
            backgroundColor = UIColor(named: "gray70")
            iconBackgroundView.backgroundColor = UIColor(named: "gray60")
            iconImageView.image = UIImage(.lightbulb)
            iconImageView.tintColor = UIColor(named: "gray50")
            nameLabel.textColor = UIColor(named: "gray10")
            statusLabel.textColor = UIColor(named: "gray40")
            
        case (.speaker, true):
            backgroundColor = UIColor(named: "blue30")
            layer.borderWidth = 1
            layer.borderColor = UIColor(named: "blue60")?.cgColor
            iconBackgroundView.backgroundColor = UIColor(named: "blue0")
            iconImageView.image = UIImage(.speaker)
            iconImageView.tintColor = .white
            nameLabel.textColor = UIColor(named: "gray10")
            statusLabel.textColor = UIColor(named: "gray10")
            
        case (.speaker, false):
            backgroundColor = UIColor(named: "gray70")
            iconBackgroundView.backgroundColor = UIColor(named: "gray60")
            iconImageView.image = UIImage(.speaker)
            iconImageView.tintColor = UIColor(named: "gray40")
            nameLabel.textColor = UIColor(named: "gray10")
            statusLabel.textColor = UIColor(named: "gray40")
        }
    }
}
