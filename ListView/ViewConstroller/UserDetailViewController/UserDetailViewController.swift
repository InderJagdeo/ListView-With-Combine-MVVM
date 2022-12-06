//
//  UserDetailViewController.swift
//  ListView
//
//  Created by Macbook on 30/11/22.
//

import UIKit
import MapKit
import Combine

class UserDetailViewController: UIViewController {

    // MARK: - Properties
    @IBOutlet private weak var userName: UILabel!
    @IBOutlet private weak var userEmail: UILabel!
    @IBOutlet private weak var userPhone: UILabel!
    @IBOutlet private weak var userWebsite: UILabel!
    @IBOutlet private weak var userCompany: UILabel!
    @IBOutlet private weak var userAddress: UILabel!
    @IBOutlet private weak var mapView: MKMapView!

    private let viewModel: UserDetailViewModel?
    private var subscriptions = Set<AnyCancellable>()

    static var identifier: String {
        return String(describing: self)
    }

    // MARK: - Initializer
    init?(coder: NSCoder, viewModel: UserDetailViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIView Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set navigation item title
        navigationItem.title = "User Detail"

        // Calling user defined methods
        updateView(viewModel)
    }
}

extension UserDetailViewController {
    // MARK: - User Defined Methods
    
    private func updateView(_ viewModel: UserDetailViewModel?) {
        guard let viewModel = viewModel else { return }
        updateUserDetail(viewModel)
        updateUserLocationInMap(with: viewModel.location, and: viewModel.address)
    }

    private func updateUserDetail(_ viewModel: UserDetailViewModel) {
        userName.text = viewModel.name
        userEmail.text = viewModel.email
        userPhone.text = viewModel.phone
        userWebsite.text = viewModel.website
        userCompany.text = viewModel.companyName
        userAddress.text = viewModel.address
    }

    private func updateUserLocationInMap(with location: CLLocation?, and address: String) {
        guard let lat = location?.coordinate.latitude,
              let long = location?.coordinate.longitude else { return }
        let center = CLLocationCoordinate2D(latitude: lat, longitude: long)
        let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))

        let annotation = MKPointAnnotation()
        annotation.coordinate = center
        annotation.title = address

        self.mapView.setRegion(region, animated: true)
        self.mapView.addAnnotation(annotation)
    }
}
