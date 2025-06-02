import Foundation
import UIKit
import SwiftUI
import UniformTypeIdentifiers

// نموذج البيانات لحفظ الصور المختارة
class FormDataModel: ObservableObject {
    @Published var selectedImages: [UIImage] = []
    @Published var selectedPDFURL: URL?
    @Published var selectedPDFName: String = ""
    @Published var hasPDFSelected: Bool = false
    @Published var currentStep: Int = 0
    
    let totalSteps = 1  // خطوة واحدة فقط للصور
    
    // ملاحظة: سيتم وضع الصور في مواضع ثابتة في آخر صفحتين:
    // الصفحة قبل الأخيرة: 4 صور في شبكة 2×2 (أعلى يسار، أعلى يمين، أسفل يسار، أسفل يمين)
    // الصفحة الأخيرة: 4 صور في شبكة 2×2 (أعلى يسار، أعلى يمين، أسفل يسار، أسفل يمين)
    // المجموع: 8 صور إجمالاً
    
    func nextStep() {
        if currentStep < totalSteps - 1 {
            currentStep += 1
        }
    }
    
    func previousStep() {
        if currentStep > 0 {
            currentStep -= 1
        }
    }
    
    func addImage(_ image: UIImage) {
        guard selectedImages.count < 8 else { return }
        selectedImages.append(image)
    }
    
    func removeImage(at index: Int) {
        guard index < selectedImages.count else { return }
        selectedImages.remove(at: index)
    }
    
    func clearImages() {
        selectedImages.removeAll()
    }
    
    func setPDFFile(url: URL, name: String) {
        selectedPDFURL = url
        selectedPDFName = name
        hasPDFSelected = true
    }
    
    func clearPDFFile() {
        selectedPDFURL = nil
        selectedPDFName = ""
        hasPDFSelected = false
    }
    
    func resetAll() {
        clearImages()
        clearPDFFile()
        currentStep = 0
    }
} 