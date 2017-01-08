//
//  AssetListTableViewCell.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import UIKit

class AssetListTableViewCell: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = "AssetListTableViewCellIdentifier"
    
    @IBOutlet weak var assetNameLabel: UILabel!
    
    @IBOutlet weak var downloadStateLabel: UILabel!
    
    @IBOutlet weak var downloadProgressView: UIProgressView!
    
    weak var delegate: AssetListTableViewCellDelegate?
    
    var asset: Asset? {
        didSet {
            if let asset = asset {
                let downloadState = StreamPersistenceManager.sharedManager.downloadState(for: asset)
                
                switch downloadState {
                case .downloaded:
                    downloadProgressView.isHidden = true
                    
                case .downloading:
                    
                    downloadProgressView.isHidden = false
                    
                case .notDownloaded:
                    break
                }
                
                assetNameLabel.text = asset.name
                downloadStateLabel.text = downloadState.rawValue
                
                let notificationCenter = NotificationCenter.default
                notificationCenter.addObserver(self, selector: #selector(handleAssetDownloadStateChangedNotification(_:)), name: AssetDownloadStateChangedNotification, object: nil)
                notificationCenter.addObserver(self, selector: #selector(handleAssetDownloadProgressNotification(_:)), name: AssetDownloadProgressNotification, object: nil)
            }
            else {
                downloadProgressView.isHidden = false
                assetNameLabel.text = ""
                downloadStateLabel.text = ""
            }
        }
    }
    
    // MARK: Notification handling
    
    func handleAssetDownloadStateChangedNotification(_ notification: Notification) {
        guard let assetStreamName = notification.userInfo![Asset.Keys.name] as? String,
            let downloadStateRawValue = notification.userInfo![Asset.Keys.downloadState] as? String,
            let downloadState = Asset.DownloadState(rawValue: downloadStateRawValue),
            let asset = asset
            , asset.name == assetStreamName else { return }
        
        DispatchQueue.main.async {
            switch downloadState {
            case .downloading:
                self.downloadProgressView.isHidden = false
                
                if let downloadSelection = notification.userInfo?[Asset.Keys.downloadSelectionDisplayName] as? String {
                    self.downloadStateLabel.text = "\(downloadState): \(downloadSelection)"
                    return
                }
                
            case .downloaded, .notDownloaded:
                self.downloadProgressView.isHidden = true
            }
            
            self.delegate?.assetListTableViewCell(self, downloadStateDidChange: downloadState)
        }
    }
    
    func handleAssetDownloadProgressNotification(_ notification: NSNotification) {
        guard let assetStreamName = notification.userInfo![Asset.Keys.name] as? String, let asset = asset , asset.name == assetStreamName else { return }
        guard let progress = notification.userInfo![Asset.Keys.percentDownloaded] as? Double else { return }
        
        self.downloadProgressView.setProgress(Float(progress), animated: true)
    }
}

protocol AssetListTableViewCellDelegate: class {
    
    func assetListTableViewCell(_ cell: AssetListTableViewCell, downloadStateDidChange newState: Asset.DownloadState)
}
