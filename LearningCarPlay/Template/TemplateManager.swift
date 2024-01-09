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
        let tabTemplate = CPTabBarTemplate(templates: [listTemplateFromPlaces()])
        carplayInterfaceController?.setRootTemplate(tabTemplate, animated: true, completion: { _, _ in
            //request for the lock
        })
    }
    
    func updateTemplate(state: String) {
        if let root = carplayInterfaceController?.rootTemplate as? CPTabBarTemplate {
            root.updateTemplates([listTemplateFromPlaces(state: state)])
        }
    }
    
    private func listTemplateFromPlaces(state: String = "Processing") -> CPListTemplate {
        let places: [LockData.LockDetail] = LockData.falseQuickOrders
        let storeListTemplate = CPListTemplate(
            title: "Locations",
            sections: [CPListSection(items: places.compactMap({ (place) -> CPListItem in
                let listItem = CPListItem(text: place.name, detailText: state)
                listItem.handler = { item, completion in
                    NotificationCenter.default.post(name: .lockStateChanged, object: ["lock_name": place.name])
                }
                return listItem
            }))])
        
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

class LockData {
    
    static let falseQuickOrders = [
        LockDetail(name: "Lock 1", detail: "This is lock 1"),
        LockDetail(name: "Lock 2", detail: "This is lock 2"),
        LockDetail(name: "Lock 3", detail: "This is lock 3"),
        LockDetail(name: "Lock 4", detail: "This is lock 4")
    ]
    
    // MARK: Orders
    
    class LockDetail {
        var name: String
        var detail: String
        init(name: String, detail: String) {
            self.name = name
            self.detail = detail
        }
    }
}
