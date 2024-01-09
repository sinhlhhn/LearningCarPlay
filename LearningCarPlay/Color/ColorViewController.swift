//

import UIKit

extension NSNotification.Name {
    static let requestLockState: NSNotification.Name = .init("REQUEST_LOCK_STATE")
    static let lockStateChanged: NSNotification.Name = .init("LOCK_STATE_CHANGED")
    static let newLockStateForCarPlay: NSNotification.Name = .init("NEW_LOCK_STATE_FOR_CAR_PLAY")
    
}

class ColorViewController: UIViewController {

    @IBOutlet weak var colorLabel: UILabel!
    
    var locks: [LockModel] = [
        LockModel(name: "Lock 1", state: .open),
        LockModel(name: "Lock 2", state: .closed),
        LockModel(name: "Lock 3", state: .open)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateLockState), name: .lockStateChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getLockState), name: .requestLockState, object: nil)
    }
    
    @objc private func updateLockState(_ notification: NSNotification) {
        guard let dict = notification.object as? [String: String],
        let lockName = dict["lock_name"] else {
            return
        }
        print(lockName)
        colorLabel.text = lockName
        for lock in locks {
            if lock.name.contains(lockName) {
                lock.toggle()
            }
        }
        // fake request api
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            NotificationCenter.default.post(name: .newLockStateForCarPlay, object: self.locks)
        }
    }
    
    @objc private func getLockState() {
        colorLabel.text = "get lock state"
        // fake request api
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            NotificationCenter.default.post(name: .newLockStateForCarPlay, object: self.locks)
        }
    }
}
