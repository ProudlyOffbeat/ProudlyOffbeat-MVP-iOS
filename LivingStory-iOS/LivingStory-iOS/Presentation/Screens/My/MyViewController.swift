//
//  MyViewController.swift
//  LivingStory-iOS
//
//  Created by Demian Yoo on 2/9/26.
//

import UIKit

final class MyViewController: UIViewController {

    // MARK: - Properties

    weak var coordinator: AppCoordinator?

    // MARK: - UI Components

    private let radialGlowView = RadialGlowView()

    private let settingsButton: UIButton = {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
        button.setImage(UIImage(.settings)?.withConfiguration(config), for: .normal)
        button.tintColor = UIColor(named: "gray0")
        return button
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupStyle()
        setupHierarchy()
        setupLayout()
    }
}

// MARK: - Private Methods

private extension MyViewController {

    func setupStyle() {
        view.backgroundColor = UIColor(named: "gray100")

        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = StringLiterals.My.title
        navigationController?.navigationBar.largeTitleTextAttributes = [
            .font: UIFont.title1Emphasized
        ]

        let settingsBarButton = UIBarButtonItem(customView: settingsButton)
        navigationItem.rightBarButtonItem = settingsBarButton
    }

    func setupHierarchy() {
        view.addSubview(radialGlowView)
    }

    func setupLayout() {
        radialGlowView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            radialGlowView.widthAnchor.constraint(equalToConstant: 589),
            radialGlowView.heightAnchor.constraint(equalToConstant: 610),
            radialGlowView.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -100),
            radialGlowView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
}

