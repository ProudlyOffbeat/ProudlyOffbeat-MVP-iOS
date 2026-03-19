//
//  HomeMenuView.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/12/26.
//

import UIKit

final class HomeMenuView: UIView {
    
    //MARK: - Properties
    private var selectedIndex: Int = 0
    private var items: [String] = []
    
    var onSelect: ((Int) -> Void)?
    
    //블러 배경
    private let blurView: UIVisualEffectView = {
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
        blur.layer.cornerRadius = 20
        blur.clipsToBounds = true
        blur.layer.borderWidth = 1
        blur.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        return blur
    }()
    
    private let homeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    init (items: [String], selectedIndex: Int = 0) {
        self.items = items
        self.selectedIndex = selectedIndex
        super.init(frame: .zero)
        
        setupHierarchy()
        setupLayout()
        buildMenuItems()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//MARK: - Private Methods

private extension HomeMenuView {
    
    func setupHierarchy() {
        addSubview(blurView)
        blurView.contentView.addSubview(homeStackView)
    }
    
    func setupLayout() {
        blurView.translatesAutoresizingMaskIntoConstraints = false
        homeStackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            blurView.topAnchor.constraint(equalTo: topAnchor),
            blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
            blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            homeStackView.topAnchor.constraint(equalTo: blurView.contentView.topAnchor, constant: 10),
            homeStackView.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor, constant: 16),
            homeStackView.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor, constant: -16),
            homeStackView.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor, constant: -10),
        ])
    }
    
    func buildMenuItems() {
        //기존 아이템 제거
        homeStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        for(index, title) in items.enumerated() {
            let itemView = createMenuItem(title: title, isSelected: index == selectedIndex, index: index)
            homeStackView.addArrangedSubview(itemView)
        }
    }
    
    func createMenuItem(title: String, isSelected: Bool, index: Int ) -> UIButton {
        var config = UIButton.Configuration.plain()
        config.title = title
        config.titleTextAttributesTransformer = .init { attr in
            var attr = attr
            attr.font = .bodyRegular
            return attr
         }
        config.baseForegroundColor = UIColor(named: "gray10")
        // 선택 안 됐어도 체크마크 자리 유지 (투명 이미지)
        config.image = UIImage(.checkmark)
        
        config.imageColorTransformer = isSelected
            ? .init { _ in UIColor(named: "gray10") ?? .label }
            : .init { _ in .clear }
        config.imagePadding = 8
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 30)
        
        let button = UIButton(configuration: config)
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.addAction(UIAction { [weak self] _ in
            self?.selectedIndex = index
            self?.buildMenuItems()
            self?.onSelect?(index)
        }, for: .touchUpInside)
        return button
    }
}
