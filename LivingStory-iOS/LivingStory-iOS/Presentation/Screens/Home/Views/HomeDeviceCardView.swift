//
//  HomeDeviceCardView.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/11/26.
//

import UIKit

//MARK: - 기기종류
enum HomeDeviceType {
    case light
    case speaker
    
    var homeIcon: UIImage? {
        switch self {
        case .light:
            return UIImage(.lightbulb)
        case .speaker:
            return UIImage(.speaker)
        }
    }
}

final class HomeDeviceCardView: UIView {
    
    private let homeDeviceType: HomeDeviceType
    private var homeDeviceState: Bool = false
    
    private let homeIconBackgroundView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    private let homeIconDeviceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 20)
        return imageView
    }()
    
    private let deviceNameLabel: UILabel = {
        let nameLabel = UILabel()
        nameLabel.font = .subheadlineEmphasized
        return nameLabel
    }()
    
    private let deviceStatusLabel: UILabel = {
        let stateLabel = UILabel()
        stateLabel.font = .footnoteRegular
        return stateLabel
    }()
    
    private let labelStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()
    
    //MARK: - 초기화
    init(deviceType: HomeDeviceType, deviceState: Bool) {
        self.homeDeviceType = deviceType
        self.homeDeviceState = deviceState
        // 코드베이스 + AutoLayout시 .zero
        super.init(frame: .zero)
        
        setupStyle()
        setupHierarchy()
        setupLayout()
        updateAppearance()
    }
    
    //MARK: - Swift 6 이후부터는 UIView class가 스토리보드 명시적으로 사용하기 때문에 스토리보드 사용안한다는 명시적 확인을 해줘야함.
    // -> Storyboard 디코딩용 init인데, 코드 기반 UI라 @available(*, unavailable)로 사용을 막음.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Public Methods

extension HomeDeviceCardView {
    func configure(name: String, status: String, homeDeviceState: Bool) {
        self.homeDeviceState = homeDeviceState
        deviceNameLabel.text = name
        deviceStatusLabel.text = status
        updateAppearance()
    }
}

private extension HomeDeviceCardView {
    
    func setupStyle() {
        layer.cornerRadius = 20
        clipsToBounds = true
    }
    
    func setupHierarchy() {
        addSubview(homeIconBackgroundView)
        homeIconBackgroundView.addSubview(homeIconDeviceImageView)
        
        addSubview(labelStackView)
        labelStackView.addArrangedSubview(deviceNameLabel)
        labelStackView.addArrangedSubview(deviceStatusLabel)
    }
    
    func setupLayout() {
        homeIconBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        homeIconDeviceImageView.translatesAutoresizingMaskIntoConstraints = false
        labelStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // 아이콘 배경 ( 상,좌측 14, 크기 38*30)
            homeIconBackgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 14),
            homeIconBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            homeIconBackgroundView.widthAnchor.constraint(equalToConstant: 38),
            homeIconBackgroundView.heightAnchor.constraint(equalToConstant: 38),
            
            // 아이콘 크기 ( 정중앙 )
            homeIconDeviceImageView.centerXAnchor.constraint(equalTo: homeIconBackgroundView.centerXAnchor),
            homeIconDeviceImageView.centerYAnchor.constraint(equalTo: homeIconBackgroundView.centerYAnchor),
            
            // 라벨 스택뷰
            labelStackView.topAnchor.constraint(equalTo: homeIconBackgroundView.bottomAnchor, constant: 16),
            labelStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
            labelStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
            labelStackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -14)
        ])
    }
    
    func updateAppearance() {
        homeIconDeviceImageView.image = homeDeviceType.homeIcon
        deviceNameLabel.textColor = UIColor(named: "gray10")
        
        if homeDeviceState {
            activateStyle()
        } else {
            inactivateStyle()
        }
    }
    
    func activateStyle() {
        switch homeDeviceType {
        case .light:
            backgroundColor = UIColor(named: "yellow70")
            layer.borderWidth = 1
            layer.borderColor = UIColor(named: "yellow20")? .cgColor
            homeIconBackgroundView.backgroundColor = UIColor(named: "yellow0")
            homeIconDeviceImageView.tintColor = UIColor(named: "gray100")
            
        case .speaker:
            backgroundColor = UIColor(named: "blue30")
            layer.borderWidth = 1
            layer.borderColor = UIColor(named: "blue60")? .cgColor
            homeIconBackgroundView.backgroundColor = UIColor(named: "blue0")
            homeIconDeviceImageView.tintColor = UIColor(named: "gray100")
        }
        deviceNameLabel.textColor = UIColor(named: "gray10")
    }
    
    func inactivateStyle() {
        backgroundColor = UIColor(named: "gray70")
        layer.borderWidth = 0
        layer.borderColor = nil
        homeIconBackgroundView.backgroundColor = UIColor(named: "gray60")
        homeIconDeviceImageView.tintColor = UIColor(named: "gray50")
        deviceStatusLabel.textColor = UIColor(named: "gray40")
    }
}
