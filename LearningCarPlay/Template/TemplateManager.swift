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
    
    private func listTemplateFromPlaces() -> CPListTemplate {
        let places: [String] = ["1", "2", "3"]
        let storeListTemplate = CPListTemplate(
            title: "Locations",
            sections: [CPListSection(items: places.compactMap({ (place) -> CPListItem in
                let listItem = CPListItem(text: place, detailText: nil)
                listItem.handler = { [weak self] item, completion in
                    self?.showOrderTemplate()
                    completion()
                }
                return listItem
            }))])
        
        storeListTemplate.tabTitle = "List"
        storeListTemplate.tabImage = UIImage(systemName: "list.star")!
        return storeListTemplate
    }
    
    private func showOrderTemplate() {
        let infoTemplate = CPInformationTemplate(
            title: "Order Options",
            layout: CPInformationTemplateLayout.leading,
            items: FalseHoagieData.falseQuickOrders.compactMap({ (orderItem) -> CPInformationItem in
                return CPInformationItem(title: orderItem.type, detail: orderItem.order.joined(separator: "\n"))
            }),
            actions: [
                CPTextButton(title: "Order Last", textStyle: .confirm, handler: { [weak self] (button) in
                    MemoryLogger.shared.appendEvent("Ordering last .")
                    MemoryLogger.shared.updateColor()
                }),
                CPTextButton(title: "Order Favorite", textStyle: .confirm, handler: { [weak self] (button) in
                    MemoryLogger.shared.appendEvent("Ordering favorite .")
                })
            ])
        
        // Two templates is the maximum for quick-ordering CarPlay apps. The sample validates it here as a reminder.
        if let controller = carplayInterfaceController,
           controller.templates.count < 2 {
            carplayInterfaceController?.pushTemplate(infoTemplate, animated: true) { [weak self] (done, error) in
                self?.handleError(error, prependedMessage: "Error pushing \(infoTemplate.classForCoder)")
            }
        } else {
            carplayInterfaceController?.popToRootTemplate(animated: true) { [weak self] (done, error) in
                if self?.handleError(error, prependedMessage: "Error popping to root template") == false {
                    self?.carplayInterfaceController?.pushTemplate(infoTemplate, animated: true) { (done, error) in
                        self?.handleError(error, prependedMessage: "Error pushing \(infoTemplate.classForCoder)")
                    }
                }
            }
        }
    }
    
    @discardableResult
    func handleError(_ error: Error?, prependedMessage: String) -> Bool {
        if let error = error {
            MemoryLogger.shared.appendEvent("\(prependedMessage): \(error.localizedDescription).")
        }
        return error != nil
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

class FalseHoagieData {
    static let falseData = FalseHoagieData()
    static let falseQuickOrders = [
        HoagieOrder(
            orderItems: [
                "Italian Hoagie * no mayo, no tomato, extra cheese",
                "Large unsweetened Tea"],
            typeOfOrder: "Last Order (on 12/31/2020)"),
        HoagieOrder(
            orderItems: [
                "Veggie Hoagie",
                "Oatmeal cookie"],
            typeOfOrder: "Favorite")
    ]
    
    // MARK: Orders
    
    class HoagieOrder {
        var order: [String]
        var type: String
        init(orderItems: [String], typeOfOrder: String) {
            order = orderItems
            type = typeOfOrder
        }
    }
}
