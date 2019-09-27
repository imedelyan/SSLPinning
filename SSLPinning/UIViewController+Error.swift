import UIKit

extension UIViewController {
  func presentError(withTitle title: String,
                    message: String,
                    actions: [UIAlertAction] = [UIAlertAction(title: "OK", style: .default)]) {
    let alertController = UIAlertController(title: title,
                                            message: message,
                                            preferredStyle: .alert)
    actions.forEach { action in
      alertController.addAction(action)
    }
    present(alertController, animated: true)
  }
}
