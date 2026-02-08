//
//  LocationSearchService.swift
//  WeatherApp
//
//  Created by Ashish on 01/02/26.
//

import MapKit
import Observation
import Combine

@Observable
class LocationSearchService: NSObject, MKLocalSearchCompleterDelegate {
    var completions: [MKLocalSearchCompletion] = []
    var searchText = "" {
        didSet {
            // Push the new value into our PassthroughSubject
            searchSubject.send(searchText)
        }
    }
    var isNoDataFound:Bool = false

    private let completer = MKLocalSearchCompleter()
    private let searchSubject = PassthroughSubject<String, Never>()
    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        completer.delegate = self
        completer.resultTypes = .address
        completer.pointOfInterestFilter = .excludingAll

        setupSearchDebounce()
    }

    private func setupSearchDebounce() {
        searchSubject
            // Wait for 0.3 seconds of silence before firing
            .debounce(for: .seconds(0.3), scheduler: RunLoop.main)
            // Prevent redundant calls if the text hasn't changed
            .removeDuplicates()
            .sink { [weak self] text in
                self?.isNoDataFound = false
                if text.count < 2 {
                    // CLEAR results when search is removed/cleared
                    self?.completions = []
                } else {
                    // Otherwise, perform the search
                    self?.completer.queryFragment = text
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        // Run on main thread to ensure @Observable updates the UI safely
        DispatchQueue.main.async {[weak self] in
            self?.completions = completer.results
            self?.isNoDataFound = completer.results.count == 0
        }
    }

    func getCoordinate(from completion: MKLocalSearchCompletion, completionHandler: @escaping (Coordinates?) -> Void) {
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)

        search.start { response, error in
            if let error = error {

            } else if let coordinate = response?.mapItems.first?.placemark.coordinate {
                completionHandler(Coordinates(lon: coordinate.longitude, lat: coordinate.latitude))
            } else {

            }

        }
    }
}
