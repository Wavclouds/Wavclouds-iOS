import UIKit
import Turbo
import WebKit

class ViewController: UINavigationController, UITabBarDelegate {
    let tabBar = UITabBar()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create custom tab bar items with SF Symbols
        let itemHome = createCustomTabBarItem(systemName: "house.fill", title: "Home", tag: 0)
        let itemUpload = createCustomTabBarItem(systemName: "tray.and.arrow.up", title: "Upload", tag: 1)
        let itemChat = createCustomTabBarItem(systemName: "ellipsis.message.fill", title: "Chat", tag: 2)
        let itemProfile = createCustomTabBarItem(systemName: "person", title: "Profile", tag: 3)

        // Set the items for the custom tab bar
        tabBar.items = [itemHome, itemUpload, itemChat, itemProfile]
    
        // Calculate the correct Y position
        let tabBarY = self.view.frame.height - tabBar.frame.height - view.safeAreaInsets.bottom
        
        print("View height: \(self.view.frame.height)")
        print("Tab bar height: \(tabBar.frame.height)")
        print("Safe area bottom inset: \(view.safeAreaInsets.bottom)")
        print("Calculated tabBarY: \(tabBarY)")
        // Calculate the adaptive height for the tab bar
        var tabBarHeight: CGFloat = 80.0 // Your default height
        if #available(iOS 11.0, *) {
            tabBarHeight = max(49, view.safeAreaInsets.bottom + tabBar.safeAreaInsets.bottom) // 49 is the standard height for tab bars
        }
        
        // Adjust the height for larger devices
        if UIDevice.current.userInterfaceIdiom == .pad || UIScreen.main.bounds.height > 800 {
            tabBarHeight = max(tabBarHeight, 80.0) // Adjust as needed for larger devices
        }
        print("Tab Bar Height: \(tabBarHeight)")

        // Position and add the custom tab bar to the view
        tabBar.frame = CGRect(x: 0, y: tabBarY - tabBarHeight, width: self.view.frame.width, height: tabBarHeight)
        self.view.addSubview(tabBar)
        
        // Set the initial selected tab
        tabBar.selectedItem = itemHome
    }
    
    func createCustomTabBarItem(systemName: String, title: String, tag: Int) -> UITabBarItem {
        let tabBarItem = UITabBarItem(title: title, image: UIImage(systemName: systemName), tag: tag)
        // You can customize additional properties of the tab bar item here, such as imageInsets, badgeValue, etc.
        return tabBarItem
    }
}
