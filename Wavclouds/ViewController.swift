import UIKit

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
        
        // Position and add the custom tab bar to the view
        tabBar.frame = CGRect(x: 0, y: self.view.frame.height - 75, width: self.view.frame.width, height: 49)
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
