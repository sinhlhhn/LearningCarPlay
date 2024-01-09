/*
See LICENSE folder for this sample’s licensing information.

Abstract:
`TemplateManager` manages the CPTemplates that the app displays.
*/

import CarPlay
import Foundation
import os

class TemplateManager: NSObject {

    var carplayInterfaceController: CPInterfaceController?
    
    private var carplayScene: CPTemplateApplicationScene?
    private var sessionConfiguration: CPSessionConfiguration?

    // MARK: CPTemplateApplicationSceneDelegate
    
    /// - Tag: did_connect
    func interfaceControllerDidConnect(_ interfaceController: CPInterfaceController, scene: CPTemplateApplicationScene) {
        MemoryLogger.shared.appendEvent("Connected to CarPlay window.")
        carplayInterfaceController = interfaceController
        carplayScene = scene
        carplayInterfaceController?.delegate = self
        sessionConfiguration = CPSessionConfiguration(delegate: self)
        setRootTemplate()
    }
    
    func interfaceControllerDidDisconnect(_ interfaceController: CPInterfaceController, scene: CPTemplateApplicationScene) {
        MemoryLogger.shared.appendEvent("Disconnected from CarPlay window.")
        carplayInterfaceController = nil
    }
    
    func setRootTemplate() {
        let tabTemplate = CPTabBarTemplate(templates: [listTemplateFromPlaces(locks: [LockModel.defaultLock])])
        carplayInterfaceController?.setRootTemplate(tabTemplate, animated: true, completion: { _, _ in
            //request for the lock
        })
    }
    
    func updateTemplate(locks: [LockModel]) {
        if let root = carplayInterfaceController?.rootTemplate as? CPTabBarTemplate {
            root.updateTemplates([listTemplateFromPlaces(locks: locks)])
        }
    }
    
    private func listTemplateFromPlaces(locks: [LockModel]) -> CPListTemplate {
        let storeListTemplate = CPListTemplate(
            title: "Locks",
            sections: [CPListSection(items: locks.compactMap { (lock) -> CPListItem in
                let listItem = CPListItem(text: lock.name, detailText: lock.state.rawValue, image: UIImage(systemName: lock.image))
                listItem.handler = { item, completion in
                    NotificationCenter.default.post(name: .lockStateChanged, object: ["lock_name": lock.name])
                }
                return listItem
            })])
        
        storeListTemplate.tabTitle = "List"
        storeListTemplate.tabImage = UIImage(systemName: "list.star")!
        return storeListTemplate
    }
}

extension TemplateManager: CPTabBarTemplateDelegate {
    func tabBarTemplate(_ tabBarTemplate: CPTabBarTemplate, didSelect selectedTemplate: CPTemplate) {
        MemoryLogger.shared.appendEvent("Selected Tab: \(selectedTemplate).")
    }
}

extension TemplateManager: CPSessionConfigurationDelegate {
    func sessionConfiguration(_ sessionConfiguration: CPSessionConfiguration,
                              limitedUserInterfacesChanged limitedUserInterfaces: CPLimitableUserInterface) {
        MemoryLogger.shared.appendEvent("Limited UI changed: \(limitedUserInterfaces)")
    }
}

extension TemplateManager: CPInterfaceControllerDelegate {
    func templateWillAppear(_ aTemplate: CPTemplate, animated: Bool) {
        MemoryLogger.shared.appendEvent("Template \(aTemplate.classForCoder) will appear.")
    }

    func templateDidAppear(_ aTemplate: CPTemplate, animated: Bool) {
        MemoryLogger.shared.appendEvent("Template \(aTemplate.classForCoder) did appear.")
    }

    func templateWillDisappear(_ aTemplate: CPTemplate, animated: Bool) {
        MemoryLogger.shared.appendEvent("Template \(aTemplate.classForCoder) will disappear.")
    }

    func templateDidDisappear(_ aTemplate: CPTemplate, animated: Bool) {
        MemoryLogger.shared.appendEvent("Template \(aTemplate.classForCoder) did disappear.")
    }
}

class LockModel {
    let name: String
    var state: LockState
    
    init(name: String, state: LockState) {
        self.name = name
        self.state = state
    }
    
    static let defaultLock = LockModel(name: "Loading lock", state: .processing)
    
    enum LockState: String {
        case open
        case closed
        case processing
    }
    
    func toggle() {
        switch state {
        case .open: state = .closed
        case .closed: state = .open
        case .processing: state = .processing
        }
    }
    
    var image: String {
        switch state {
        case .open: return "door.garage.open"
        case .closed: return "door.garage.closed"
        case .processing: return ""
        }
    }
}
