//
//  EventDetailViewController.swift
//  Beauty Buisness
//
//  Created by Vasiliy Andreyev on 21.04.2022.
//

import Foundation
import UIKit


class EventDetailViewController: UIViewController {
    
    private enum EventDetailSection: Int, Hashable {
        case main
    }
    
    
    private var eventDetailCollectionView: UICollectionView!
    private var eventDetailDiffableDataSource: UICollectionViewDiffableDataSource<EventDetailSection, Event>!
    private var editBarButtonPressed: Bool = false { didSet { setupNavigationBar() } }

    public var events: [Event]?
    public var selectedEvent: Event?

        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = .myBackgroundColor
        setupNavigationBar()
        setupEventDetailCollectionView()
        setupDataSource()
        createInitialSnapshot()

    }
        
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        showSelectedItem()
    }
    

    public func configureDetail (event: Event, from: [Event]) {
        selectedEvent = event
        events = from
    }
    
   
    
    public func showSelectedItem () {
    
        guard let selectedEvent = selectedEvent,
              let indexPathOfSelectedEvent = eventDetailDiffableDataSource.indexPath(for: selectedEvent) else {
            return
        }
        eventDetailCollectionView.scrollToItem(at: indexPathOfSelectedEvent, at: .centeredHorizontally, animated: false)

    }
    
    private func updateSelectedEventOnScroll (by indexPath: IndexPath) {
        
        let eventAtIndexPath = eventDetailDiffableDataSource.itemIdentifier(for: indexPath)
        selectedEvent = eventAtIndexPath
        
    }
        
    private func setupEventDetailCollectionView () {
        
        eventDetailCollectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        eventDetailCollectionView.layer.cornerRadius = view.frame.width / 20
        view.addSubview(eventDetailCollectionView)
        eventDetailCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            eventDetailCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            eventDetailCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            eventDetailCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            eventDetailCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
        ])
        eventDetailCollectionView.alwaysBounceVertical = false
        eventDetailCollectionView.delegate = self
    }
    
    private func createLayout () -> UICollectionViewCompositionalLayout {
        
        // Item
        let item = NSCollectionLayoutItem(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            )
        )
        // Group
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalHeight(1)
            ),
            subitem: item,
            count: 1
        )
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .paging
        
        
        //MAGIC HAPPENS HERE! The visibleItemsInvalidationHandler closure is triggered EVERY FCKIN TIME the item appears on screen. I loop through each of the current visible items, then I compare the current scrollOffset to the visible item's frame origin, AND IF those are true (and the are only after the next visible item stays still on screen, the title and selected events are changed!
        section.visibleItemsInvalidationHandler = { [weak self] visibleItems, scrollOffset, layoutEnvironment in
            visibleItems.forEach { visItem in
                if scrollOffset == visItem.frame.origin {
                    self?.updateSelectedEventOnScroll(by: visItem.indexPath)
                }
            }
        }
        
        //Return
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func setupDataSource () {
        
        let cellRegistration = UICollectionView.CellRegistration<EventDetailCollectionViewCell, Event> { [weak self] cell, indexPath, event in
    
            cell.configure(event: self?.eventDetailDiffableDataSource.itemIdentifier(for: indexPath))
            
            
        }
        
        eventDetailDiffableDataSource = UICollectionViewDiffableDataSource(collectionView: eventDetailCollectionView) { collectionView, indexPath, event in
            
            guard let section = EventDetailSection.init(rawValue: indexPath.section) else { return nil }
            switch section {
            case .main:
               return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: event)
            }
        }
    }
    
    private func createInitialSnapshot () {
        
        var snapshot = NSDiffableDataSourceSnapshot<EventDetailSection, Event>()
        guard let availiableEvents = events else { return }
        snapshot.appendSections([.main])
        snapshot.appendItems(availiableEvents)
        eventDetailDiffableDataSource.apply(snapshot)
  
    }
    
    private func setupNavigationBar () {
        
        title = "Детализация"
        
        let editBarButton = UIBarButtonItem(title: editBarButtonPressed ? "Готово" : "Изменить", style: editBarButtonPressed ? .done : .plain, target: self, action: #selector(editAction(_:)))
        navigationItem.rightBarButtonItem = editBarButton
        
    }
    
    @objc private func editAction (_ sender: UIAction) {
        editBarButtonPressed = !editBarButtonPressed
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "editButtonPressed"), object: editBarButtonPressed, userInfo: nil)
    }
    
    
    
    
}


extension EventDetailViewController: UICollectionViewDelegate {
    
    
    
}



