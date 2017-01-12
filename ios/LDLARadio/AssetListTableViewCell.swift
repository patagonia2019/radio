//
//  AssetListTableViewCell.swift
//  LDLARadio
//
//  Created by Javier Fuchs on 1/6/17.
//  Copyright © 2017 Mobile Patagonia. All rights reserved.
//

import UIKit
import AlamofireImage

class AssetListTableViewCell: UITableViewCell {
    // MARK: Properties
    
    static let reuseIdentifier = "AssetListTableViewCellIdentifier"
    
    @IBOutlet weak var assetNameLabel: UILabel!
    
    @IBOutlet weak var assetImageView: UIImageView!
    
    @IBOutlet weak var downloadStateLabel: UILabel!
    
    @IBOutlet weak var downloadProgressView: UIProgressView!
    
    weak var delegate: AssetListTableViewCellDelegate?
    
    var station: Station? {
        didSet {
            if let station = station {
                guard let urlString = station.url,
                    let url = URL(string: urlString) else { return }
                
                assetImageView.af_setImage(withURL: url)
            }
        }
    }
    
    var stream: Stream? {
        didSet {
            if let stream = stream {
                let downloadState = StreamPersistenceManager.sharedManager.downloadState(for: stream)
                
                switch downloadState {
                case .downloaded:
                    downloadProgressView.isHidden = true
                    
                case .downloading:
                    
                    downloadProgressView.isHidden = false
                    
                case .notDownloaded:
                    break
                }
                
                assetNameLabel.text = stream.name
                downloadStateLabel.text = downloadState.rawValue
                
                let notificationCenter = NotificationCenter.default
                notificationCenter.addObserver(self, selector: #selector(handleStreamDownloadStateChangedNotification(_:)), name: StreamDownloadStateChangedNotification, object: nil)
                notificationCenter.addObserver(self, selector: #selector(handleAssetDownloadProgressNotification(_:)), name: StreamDownloadProgressNotification, object: nil)
            }
            else {
                downloadProgressView.isHidden = false
                assetNameLabel.text = ""
                downloadStateLabel.text = ""
            }
        }
    }
    
    // MARK: Notification handling
    
    func handleStreamDownloadStateChangedNotification(_ notification: Notification) {
        guard let assetStreamName = notification.userInfo![Stream.Keys.name] as? String,
            let downloadStateRawValue = notification.userInfo![Stream.Keys.downloadState] as? String,
            let downloadState = Stream.DownloadState(rawValue: downloadStateRawValue),
            let asset = stream, asset.name == assetStreamName else { return }
        
        DispatchQueue.main.async {
            switch downloadState {
            case .downloading:
                self.downloadProgressView.isHidden = false
                
                if let downloadSelection = notification.userInfo?[Stream.Keys.downloadSelectionDisplayName] as? String {
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
        guard let assetStreamName = notification.userInfo![Stream.Keys.name] as? String, let asset = stream , asset.name == assetStreamName else { return }
        guard let progress = notification.userInfo![Stream.Keys.percentDownloaded] as? Double else { return }
        
        self.downloadProgressView.setProgress(Float(progress), animated: true)
    }
}

protocol AssetListTableViewCellDelegate: class {
    
    func assetListTableViewCell(_ cell: AssetListTableViewCell, downloadStateDidChange newState: Stream.DownloadState)
}
