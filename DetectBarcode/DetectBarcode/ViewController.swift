//
//  ViewController.swift
//  DetectBarcode
//
//  Created by Manish on 21/11/23.
//

import UIKit
import Vision


class ViewController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var inputImage: UIImageView!
    
    private let imagePicker = UIImagePickerController()
    
    private let processQueue = DispatchQueue(label: "process.queue.barcode", qos: .userInitiated)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func onTapSelectImageButton(_ sender: Any) {
        self.imagePicker.delegate = self
        self.present(imagePicker, animated: true)
    }
    
}

private extension ViewController {
    
    func detectBarcode() {
        guard let img = inputImage.image?.pngData() else {
            assertionFailure()
            // handle error
            return
        }
        
        processQueue.async {
            let request = VNDetectBarcodesRequest()
            request.revision = VNDetectBarcodesRequestRevision2 // 3rd revision is failing
            
            #if targetEnvironment(simulator)
            request.usesCPUOnly = true
            #endif
            
            let handler = VNImageRequestHandler(data: img)
            
            do {
                try handler.perform([request])
                
                if let foundBarcodes = request.results?.compactMap({ $0.payloadStringValue }).joined(separator: ", ") {
                    DispatchQueue.main.async {
                        if foundBarcodes.isEmpty {
                            self.resultLabel.text = "Could not recognise"
                        } else {
                            self.resultLabel.text = foundBarcodes
                        }
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.resultLabel.text = "Failed"
                }
                assertionFailure()
            }
        }
        
    }
    
}

// MARK: - Image Picker
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
            let pickedImage = info[.originalImage] as? UIImage
            inputImage.image = pickedImage
            
            detectBarcode()
            
            picker.dismiss(animated: true)
    }
    
}
