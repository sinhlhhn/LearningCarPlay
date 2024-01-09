//

import UIKit

class ColorViewController: UIViewController {

    @IBOutlet weak var colorLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

}

extension ColorViewController: ColorDelegate {
    func didUpdateColor() {
//        DispatchQueue.main.as
        colorLabel.text = "\(Int.random(in: 0...1000))"
    }
}
