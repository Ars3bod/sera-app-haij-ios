import Foundation
import UIKit
import PDFKit
import UniformTypeIdentifiers

class PDFManager: ObservableObject {
    @Published var isGenerating = false
    @Published var generatedPDFURL: URL?
    @Published var errorMessage: String?
    @Published var isProcessing = false
    
    // تحميل قالب PDF من المشروع
    func loadPDFTemplate() -> PDFDocument? {
        guard let url = Bundle.main.url(forResource: "template_with_placeholder", withExtension: "pdf"),
              let pdfDocument = PDFDocument(url: url) else {
            errorMessage = "لم يتم العثور على قالب PDF"
            return nil
        }
        return pdfDocument
    }
    
    // إدراج صورة في موضع ثابت في PDF
    func embedImageAtFixedPosition(_ image: UIImage, in pdf: PDFDocument, at rect: CGRect, pageIndex: Int) {
        guard pageIndex < pdf.pageCount,
              let page = pdf.page(at: pageIndex) else { return }
        
        // الحصول على أبعاد الصفحة
        let pageBounds = page.bounds(for: .mediaBox)
        
        // إنشاء PDF context جديد
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pageBounds, nil)
        UIGraphicsBeginPDFPage()
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndPDFContext()
            return
        }
        
        // تطبيق transformation لإصلاح الانقلاب
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0, y: -pageBounds.height)
        
        // رسم الصفحة الأصلية
        page.draw(with: .mediaBox, to: context)
        
        // تحويل الإحداثيات لتصحيح الموضع
        let correctedRect = CGRect(
            x: rect.minX,
            y: pageBounds.height - rect.maxY,
            width: rect.width,
            height: rect.height
        )
        
        // رسم إطار حول الصورة (اختياري)
        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(1.0)
        context.stroke(correctedRect)
        
        // حفظ حالة السياق قبل تطبيق تحويلات على الصورة
        context.saveGState()
        
        // تطبيق تحويل إضافي لإصلاح انقلاب الصورة
        context.translateBy(x: correctedRect.midX, y: correctedRect.midY)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: -correctedRect.width/2, y: -correctedRect.height/2)
        
        // رسم الصورة في الموضع المحدد مع الإحداثيات المصححة
        let imageRect = CGRect(x: 0, y: 0, width: correctedRect.width, height: correctedRect.height)
        image.draw(in: imageRect)
        
        // استعادة حالة السياق
        context.restoreGState()
        
        UIGraphicsEndPDFContext()
        
        // إنشاء PDF document جديد من البيانات
        if let newPDFDocument = PDFDocument(data: pdfData as Data),
           let newPage = newPDFDocument.page(at: 0) {
            pdf.insert(newPage, at: pageIndex)
            pdf.removePage(at: pageIndex + 1)
        }
    }
    
    // تحديد مواضع الصور في آخر صفحتين
    func getImagePositions(for pdf: PDFDocument) -> [(pageIndex: Int, rect: CGRect)] {
        guard pdf.pageCount >= 2 else { return [] }
        
        // الحصول على آخر صفحتين
        let secondLastPageIndex = pdf.pageCount - 2
        let lastPageIndex = pdf.pageCount - 1
        
        guard let secondLastPage = pdf.page(at: secondLastPageIndex),
              let lastPage = pdf.page(at: lastPageIndex) else { return [] }
        
        let secondLastPageBounds = secondLastPage.bounds(for: .mediaBox)
        let lastPageBounds = lastPage.bounds(for: .mediaBox)
        
        // حساب أبعاد الصور (أكبر لتحسين الوضوح)
        let imageWidth: CGFloat = 300   // زيادة من 200 إلى 340
        let imageHeight: CGFloat = 300  // زيادة من 200 إلى 340
        let spaceBetweenImages: CGFloat = 15 // تقليل المسافة من 20 إلى 10
        
        // حساب المواضع للصفحة الثانية من الآخر (الصفحة قبل الأخيرة)
        let leftX_page2 = (secondLastPageBounds.width - (2 * imageWidth + spaceBetweenImages)) / 2
        let rightX_page2 = leftX_page2 + imageWidth + spaceBetweenImages
        
        let centerY_page2 = secondLastPageBounds.height * 0.5
        let topY_page2 = centerY_page2 + (imageHeight / 2) + (spaceBetweenImages / 2)
        let bottomY_page2 = centerY_page2 - (imageHeight / 2) - (spaceBetweenImages / 2)
        
        // حساب المواضع للصفحة الأخيرة
        let leftX_page3 = (lastPageBounds.width - (2 * imageWidth + spaceBetweenImages)) / 2
        let rightX_page3 = leftX_page3 + imageWidth + spaceBetweenImages
        
        let centerY_page3 = lastPageBounds.height * 0.5
        let topY_page3 = centerY_page3 + (imageHeight / 2) + (spaceBetweenImages / 2)
        let bottomY_page3 = centerY_page3 - (imageHeight / 2) - (spaceBetweenImages / 2)
        
        return [
            // الصفحة قبل الأخيرة - 4 صور
            (secondLastPageIndex, CGRect(x: leftX_page2, y: topY_page2, width: imageWidth, height: imageHeight)),      // أعلى يسار
            (secondLastPageIndex, CGRect(x: rightX_page2, y: topY_page2, width: imageWidth, height: imageHeight)),     // أعلى يمين
            (secondLastPageIndex, CGRect(x: leftX_page2, y: bottomY_page2, width: imageWidth, height: imageHeight)),   // أسفل يسار
            (secondLastPageIndex, CGRect(x: rightX_page2, y: bottomY_page2, width: imageWidth, height: imageHeight)),  // أسفل يمين
            
            // الصفحة الأخيرة - 4 صور
            (lastPageIndex, CGRect(x: leftX_page3, y: topY_page3, width: imageWidth, height: imageHeight)),      // أعلى يسار
            (lastPageIndex, CGRect(x: rightX_page3, y: topY_page3, width: imageWidth, height: imageHeight)),     // أعلى يمين
            (lastPageIndex, CGRect(x: leftX_page3, y: bottomY_page3, width: imageWidth, height: imageHeight)),   // أسفل يسار
            (lastPageIndex, CGRect(x: rightX_page3, y: bottomY_page3, width: imageWidth, height: imageHeight))   // أسفل يمين
        ]
    }
    
    // تسطيح PDF لجعله غير قابل للتحرير
    func flattenPDF(_ pdf: PDFDocument) -> PDFDocument? {
        let flattened = PDFDocument()
        
        for i in 0..<pdf.pageCount {
            guard let page = pdf.page(at: i) else { continue }
            
            let bounds = page.bounds(for: .mediaBox)
            
            // إنشاء PDF context جديد لكل صفحة
            let pdfData = NSMutableData()
            UIGraphicsBeginPDFContextToData(pdfData, bounds, nil)
            UIGraphicsBeginPDFPage()
            
            guard let context = UIGraphicsGetCurrentContext() else {
                UIGraphicsEndPDFContext()
                continue
            }
            
            // تطبيق transformation لإصلاح الانقلاب
            context.scaleBy(x: 1.0, y: -1.0)
            context.translateBy(x: 0, y: -bounds.height)
            
            // رسم الصفحة
            page.draw(with: .mediaBox, to: context)
            
            UIGraphicsEndPDFContext()
            
            // إضافة الصفحة الجديدة للمستند المسطح
            if let tempPDF = PDFDocument(data: pdfData as Data),
               let newPage = tempPDF.page(at: 0) {
                flattened.insert(newPage, at: flattened.pageCount)
            }
        }
        
        return flattened
    }
    
    // إنتاج PDF نهائي مع الصور في مواضع ثابتة
    func generateFinalPDF(with formData: FormDataModel, completion: @escaping (URL?) -> Void) {
        guard formData.hasPDFSelected, let sourcePDFURL = formData.selectedPDFURL else {
            errorMessage = "لم يتم اختيار ملف PDF"
            completion(nil)
            return
        }
        
        guard !formData.selectedImages.isEmpty else {
            errorMessage = "لم يتم اختيار أي صور"
            completion(nil)
            return
        }
        
        isGenerating = true
        errorMessage = nil
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let finalPDFURL = try self.createPDFWithCustomTemplate(
                    sourcePDFURL: sourcePDFURL,
                    images: formData.selectedImages
                )
                
                DispatchQueue.main.async {
                    self.isGenerating = false
                    self.generatedPDFURL = finalPDFURL
                    completion(finalPDFURL)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isGenerating = false
                    self.errorMessage = "حدث خطأ أثناء إنشاء PDF: \(error.localizedDescription)"
                    completion(nil)
                }
            }
        }
    }
    
    private func createPDFWithCustomTemplate(sourcePDFURL: URL, images: [UIImage]) throws -> URL {
        print("🔍 [DEBUG] بدء إنشاء PDF مخصص مع الصور")
        print("🔍 [DEBUG] مسار ملف PDF المصدر: \(sourcePDFURL)")
        print("🔍 [DEBUG] عدد الصور المرفقة: \(images.count)")
        
        // إنشاء مسار للملف النهائي
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let outputURL = documentsPath.appendingPathComponent("SERA_PDF_with_Images_\(timestamp).pdf")
        
        print("🔍 [DEBUG] مسار الحفظ النهائي: \(outputURL)")
        
        // قراءة ملف PDF المصدر
        guard let sourcePDFDocument = PDFDocument(url: sourcePDFURL) else {
            print("❌ [ERROR] لا يمكن قراءة ملف PDF المصدر")
            throw PDFError.cannotLoadTemplate
        }
        
        let pageCount = sourcePDFDocument.pageCount
        print("🔍 [DEBUG] عدد صفحات PDF المصدر: \(pageCount)")
        
        guard pageCount >= 2 else {
            print("❌ [ERROR] ملف PDF يحتوي على أقل من صفحتين")
            throw PDFError.insufficientPages
        }
        
        print("✅ [SUCCESS] سيتم إضافة الصور في:")
        print("✅ [SUCCESS] - الصفحة \(pageCount-1) (قبل الأخيرة): الصور 1-4")
        print("✅ [SUCCESS] - الصفحة \(pageCount) (الأخيرة): الصور 5-8")
        
        // إنشاء PDF جديد باستخدام Core Graphics
        UIGraphicsBeginPDFContextToFile(outputURL.path, CGRect.zero, nil)
        
        // نسخ جميع الصفحات من الملف المصدر
        for i in 0..<pageCount {
            if let page = sourcePDFDocument.page(at: i) {
                let pageRect = page.bounds(for: .mediaBox)
                UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
                
                if let context = UIGraphicsGetCurrentContext() {
                    // رسم الصفحة الأصلية أولاً
                    context.translateBy(x: 0, y: pageRect.height)
                    context.scaleBy(x: 1.0, y: -1.0)
                    page.draw(with: .mediaBox, to: context)
                    context.scaleBy(x: 1.0, y: -1.0)
                    context.translateBy(x: 0, y: -pageRect.height)
                    
                    // إضافة الصور في آخر صفحتين فقط
                    if i == pageCount - 2 {
                        // الصفحة قبل الأخيرة - الصور 1-4
                        let firstFourImages = Array(images.prefix(4))
                        print("🔍 [DEBUG] إضافة \(firstFourImages.count) صور في الصفحة قبل الأخيرة")
                        addImagesToPage(context: context, pageRect: pageRect, images: firstFourImages)
                    } else if i == pageCount - 1 {
                        // الصفحة الأخيرة - الصور 5-8 (إن وجدت)
                        if images.count > 4 {
                            let remainingImages = Array(images.suffix(from: 4))
                            print("🔍 [DEBUG] إضافة \(remainingImages.count) صور في الصفحة الأخيرة")
                            addImagesToPage(context: context, pageRect: pageRect, images: remainingImages)
                        } else {
                            print("🔍 [DEBUG] لا توجد صور إضافية للصفحة الأخيرة")
                        }
                    }
                }
            }
        }
        
        UIGraphicsEndPDFContext()
        
        // تطبيق تسطيح PDF للتأكد من أن الملف غير قابل للتحرير
        print("🔄 [FLATTEN] تطبيق تسطيح على PDF مع الصور...")
        
        if let finalPDF = PDFDocument(url: outputURL),
           let flattenedPDF = flattenPDF(finalPDF) {
            
            // إنشاء مسار جديد للملف المُسطح
            let flattenedURL = documentsPath.appendingPathComponent("SERA_PDF_with_Images_Flattened_\(timestamp).pdf")
            if flattenedPDF.write(to: flattenedURL) {
                print("✅ [SUCCESS] تم إنشاء PDF مُسطح بنجاح في: \(flattenedURL)")
                
                // حذف الملف المؤقت
                try? FileManager.default.removeItem(at: outputURL)
                
                return flattenedURL
            }
        }
        
        // في حالة فشل التسطيح، إرجاع الملف الأصلي
        print("⚠️ [WARNING] تم إنشاء PDF بدون تسطيح إضافي")
        print("✅ [SUCCESS] تم إنشاء PDF بنجاح في: \(outputURL)")
        return outputURL
    }
    
    private func addImagesToPage(context: CGContext, pageRect: CGRect, images: [UIImage]) {
        let positions = getImagePositionsForPage(pageRect: pageRect)
        
        for (index, image) in images.enumerated() {
            if index < positions.count {
                image.draw(in: positions[index])
            }
        }
    }
    
    private func getImagePositionsForPage(pageRect: CGRect) -> [CGRect] {
        let imageWidth: CGFloat = 340   // زيادة من 200 إلى 340
        let imageHeight: CGFloat = 340  // زيادة من 200 إلى 340
        let spaceBetweenImages: CGFloat = 10 // تقليل المسافة من 20 إلى 10
        
        // حساب المواضع في شبكة 2×2 - أكثر توسطاً في الصفحة
        let centerY = pageRect.height * 0.5  // وضع الصور في المنتصف (50%)
        let leftX = (pageRect.width - (2 * imageWidth + spaceBetweenImages)) / 2
        let rightX = leftX + imageWidth + spaceBetweenImages
        let topY = centerY + (imageHeight / 2) + (spaceBetweenImages / 2)
        let bottomY = centerY - (imageHeight / 2) - (spaceBetweenImages / 2)
        
        return [
            CGRect(x: leftX, y: topY, width: imageWidth, height: imageHeight),      // أعلى يسار
            CGRect(x: rightX, y: topY, width: imageWidth, height: imageHeight),     // أعلى يمين
            CGRect(x: leftX, y: bottomY, width: imageWidth, height: imageHeight),   // أسفل يسار
            CGRect(x: rightX, y: bottomY, width: imageWidth, height: imageHeight)   // أسفل يمين
        ]
    }
    
    private func addImagesToLastPages(pdf: PDFDocument, images: [UIImage]) throws {
        guard pdf.pageCount >= 2 else {
            throw PDFError.insufficientPages
        }
        
        let secondLastPageIndex = pdf.pageCount - 2
        let lastPageIndex = pdf.pageCount - 1
        
        guard let secondLastPage = pdf.page(at: secondLastPageIndex),
              let lastPage = pdf.page(at: lastPageIndex) else {
            throw PDFError.cannotAccessPages
        }
        
        print("🔍 [DEBUG] إضافة الصور في آخر صفحتين:")
        print("🔍 [DEBUG] - الصفحة \(secondLastPageIndex + 1) (قبل الأخيرة): الصور 1-4")
        print("🔍 [DEBUG] - الصفحة \(lastPageIndex + 1) (الأخيرة): الصور 5-8")
        
        // إضافة الصور للصفحة قبل الأخيرة (4 صور كحد أقصى)
        let firstBatch = Array(images.prefix(4))
        print("🔍 [DEBUG] إضافة \(firstBatch.count) صور في الصفحة قبل الأخيرة")
        try addImagesUsingCoreGraphics(to: secondLastPage, images: firstBatch)
        
        // إضافة الصور المتبقية للصفحة الأخيرة
        if images.count > 4 {
            let secondBatch = Array(images.dropFirst(4).prefix(4))
            print("🔍 [DEBUG] إضافة \(secondBatch.count) صور في الصفحة الأخيرة")
            try addImagesUsingCoreGraphics(to: lastPage, images: secondBatch)
        } else {
            print("🔍 [DEBUG] لا توجد صور إضافية للصفحة الأخيرة")
        }
    }
    
    private func addImagesUsingCoreGraphics(to page: PDFPage, images: [UIImage]) throws {
        let pageRect = page.bounds(for: .mediaBox)
        let positions = getImagePositionsForPage(pageRect: pageRect)
        
        // إنشاء PDF جديد بالصورة المحدثة
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, pageRect, nil)
        UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndPDFContext()
            throw PDFError.imageProcessingFailed
        }
        
        // رسم الصفحة الأصلية أولاً
        context.translateBy(x: 0, y: pageRect.height)
        context.scaleBy(x: 1.0, y: -1.0)
        page.draw(with: .mediaBox, to: context)
        context.scaleBy(x: 1.0, y: -1.0)
        context.translateBy(x: 0, y: -pageRect.height)
        
        // إضافة الصور باستخدام نفس منطق الخدمة المساعدة
        for (index, image) in images.enumerated() {
            if index < positions.count {
                image.draw(in: positions[index])
            }
        }
        
        UIGraphicsEndPDFContext()
        
        // استبدال الصفحة بالصفحة الجديدة التي تحتوي على الصور
        if let newPDFDocument = PDFDocument(data: pdfData as Data),
           let newPage = newPDFDocument.page(at: 0) {
            
            // العثور على فهرس الصفحة في المستند الأصلي
            if let pageIndex = (0..<page.document!.pageCount).first(where: { page.document!.page(at: $0) === page }) {
                page.document!.insert(newPage, at: pageIndex)
                page.document!.removePage(at: pageIndex + 1)
            }
        }
    }
    
    private func addImageToPDFPage(_ page: PDFPage, image: UIImage, at rect: CGRect) throws {
        // هذه الطريقة لم تعد مستخدمة
    }
    
    // مشاركة PDF المُنتج
    func sharePDF(url: URL) -> UIActivityViewController {
        let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = UIView()
        return activityVC
    }
    
    // دالة لإنشاء PDF مع الصور (للخدمة الأولى)
    func createPDFWithImages(formData: FormDataModel, completion: @escaping (URL?) -> Void) {
        generateFinalPDF(with: formData, completion: completion)
    }
    
    // إضافة الدالة الجديدة لملء النموذج
    func generateFilledPDF(with formData: FormFieldsModel, completion: @escaping (URL?) -> Void) {
        DispatchQueue.main.async {
            self.isProcessing = true
            self.errorMessage = nil
        }
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let url = try self.fillPDFTemplate(with: formData)
                
                DispatchQueue.main.async {
                    self.generatedPDFURL = url
                    self.isProcessing = false
                    completion(url)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isProcessing = false
                    completion(nil)
                }
            }
        }
    }
    
    private func fillPDFTemplate(with formData: FormFieldsModel) throws -> URL {
        print("🔍 [DEBUG] بدء ملء النموذج PDF باستخدام القالب فقط")
        
        // فحص القالب أولاً لمعرفة الحقول المتاحة
        inspectPDFTemplate()
        
        // تحميل قالب PDF
        guard let templatePath = Bundle.main.path(forResource: "template_with_placeholder", ofType: "pdf"),
              let templatePDF = PDFDocument(url: URL(fileURLWithPath: templatePath)) else {
            throw PDFError.cannotLoadTemplate
        }
        
        print("🔍 [DEBUG] تم تحميل قالب PDF بنجاح")
        
        // إنشاء نسخة جديدة من PDF
        let outputPDF = PDFDocument()
        
        // نسخ جميع الصفحات
        for pageIndex in 0..<templatePDF.pageCount {
            if let page = templatePDF.page(at: pageIndex) {
                outputPDF.insert(page, at: pageIndex)
            }
        }
        
        // ملء الحقول
        try fillFormFields(in: outputPDF, with: formData)
        
        // إضافة الصور في آخر صفحتين إذا وجدت
        if !formData.selectedImages.isEmpty {
            try addImagesToLastPages(pdf: outputPDF, images: formData.selectedImages)
        }
        
        // تطبيق تسطيح PDF لجعله غير قابل للتحرير
        print("🔄 [FLATTEN] بدء تسطيح PDF لجعله غير قابل للتحرير...")
        guard let flattenedPDF = flattenPDF(outputPDF) else {
            print("⚠️ [WARNING] فشل في تسطيح PDF، سيتم حفظ النسخة الأصلية")
            return try savePDF(outputPDF, filename: "Electrical_Outage_Report")
        }
        
        print("✅ [SUCCESS] تم تسطيح PDF بنجاح")
        
        // حفظ الملف المُسطح
        return try savePDF(flattenedPDF, filename: "Electrical_Outage_Report_Flattened")
    }
    
    private func addEmptyPagesForImages(to pdf: PDFDocument, pageRect: CGRect) {
        // إضافة صفحتين فارغتين للصور
        for _ in 0..<2 {
            let pageData = NSMutableData()
            UIGraphicsBeginPDFContextToData(pageData, pageRect, nil)
            UIGraphicsBeginPDFPageWithInfo(pageRect, nil)
            
            if let context = UIGraphicsGetCurrentContext() {
                context.setFillColor(UIColor.white.cgColor)
                context.fill(pageRect)
            }
            
            UIGraphicsEndPDFContext()
            
            if let newPDF = PDFDocument(data: pageData as Data),
               let page = newPDF.page(at: 0) {
                pdf.insert(page, at: pdf.pageCount)
            }
        }
    }
    
    private func addImagesToPage(_ page: PDFPage, images: [UIImage]) {
        // تم استبدال هذه الدالة بـ addImagesUsingCoreGraphics 
        // التي تستخدم Core Graphics بدلاً من PDFAnnotation
        // لتحقيق نفس منطق الخدمة المساعدة
    }
    
    private func savePDF(_ pdf: PDFDocument, filename: String) throws -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let timestamp = dateFormatter.string(from: Date())
        let outputURL = documentsPath.appendingPathComponent("\(filename)_\(timestamp).pdf")
        
        if pdf.write(to: outputURL) {
            print("✅ [SUCCESS] تم حفظ PDF في: \(outputURL)")
            return outputURL
        } else {
            throw PDFError.cannotSavePDF
        }
    }
    
    private func fillFormFields(in pdf: PDFDocument, with formData: FormFieldsModel) throws {
        print("🔍 [DEBUG] بدء ملء الحقول في القالب")
        print("🎨 [FONT] الخط المحدد: \(formData.selectedFontFamily), الحجم: \(formData.selectedFontSize)")
        print("🎨 [COLOR] اللون المحدد: \(formData.selectedTextColor)")
        
        var fieldsFound = false
        var fieldsFilled = 0
        
        // المرور عبر جميع صفحات PDF
        for pageIndex in 0..<pdf.pageCount {
            guard let page = pdf.page(at: pageIndex) else { continue }
            
            print("🔍 [DEBUG] فحص الصفحة \(pageIndex + 1), عدد الـ annotations: \(page.annotations.count)")
            
            // الحصول على annotations (الحقول) في الصفحة
            for annotation in page.annotations {
                if let fieldName = annotation.fieldName {
                    print("🔍 [DEBUG] العثور على حقل: '\(fieldName)', نوع: \(annotation.type ?? "غير محدد")")
                    fieldsFound = true
                    
                    // الحصول على القيمة مرة واحدة
                    let value = getValueForField(fieldName: fieldName, formData: formData)
                    
                    // ملء الحقول بناءً على نوع الحقل
                    if annotation.widgetFieldType == .text {
                        // استخدام النص العادي فقط - PDF annotations لا تدعم NSAttributedString بشكل مباشر
                        annotation.widgetStringValue = value
                        
                        // محاولة تطبيق خصائص الخط إذا كان ذلك ممكناًK
                        if let font = UIFont(name: formData.selectedFontFamily, size: formData.selectedFontSize) {
                            // تطبيق الخط على annotation إذا كان مدعوماً
                            annotation.font = font
                            print("✅ [FONT] تم تطبيق الخط '\(formData.selectedFontFamily)' على الحقل '\(fieldName)'")
                        } else {
                            print("⚠️ [WARNING] لا يمكن تطبيق الخط '\(formData.selectedFontFamily)' على الحقل '\(fieldName)'")
                        }
                        
                        // محاولة تطبيق اللون إذا كان مدعوماً
                        annotation.color = formData.selectedTextColor
                        print("✅ [COLOR] تم تطبيق اللون على الحقل '\(fieldName)'")
                        
                        if !value.isEmpty {
                            fieldsFilled += 1
                            print("✅ [SUCCESS] تم ملء حقل النص '\(fieldName)' بالقيمة: '\(value)'")
                        }
                        
                    } else if annotation.widgetFieldType == .choice {
                        // للقوائم المنسدلة - نص عادي فقط
                        annotation.widgetStringValue = value
                        if !value.isEmpty {
                            fieldsFilled += 1
                            print("✅ [SUCCESS] تم ملء القائمة '\(fieldName)' بالقيمة: '\(value)'")
                        }
                        
                    } else if annotation.widgetFieldType == .button {
                        // للأزرار/checkboxes
                        if value.lowercased() == "yes" || value == "1" || value == "✓" {
                            annotation.buttonWidgetState = .onState
                            fieldsFilled += 1
                            print("✅ [SUCCESS] تم تفعيل checkbox '\(fieldName)'")
                        } else {
                            annotation.buttonWidgetState = .offState
                            print("📝 [INFO] تم ترك checkbox '\(fieldName)' فارغ")
                        }
                    }
                    
                    if value.isEmpty {
                        print("⚠️ [WARNING] لم يتم العثور على قيمة للحقل '\(fieldName)'")
                    }
                }
            }
        }
        
        print("📊 [DEBUG] إجمالي الحقول الموجودة: \(fieldsFound)")
        print("📊 [DEBUG] إجمالي الحقول المملوءة: \(fieldsFilled)")
        
        if !fieldsFound {
            print("❌ [ERROR] لم يتم العثور على أي حقول قابلة للملء في القالب")
            throw PDFError.cannotAccessPages
        }
        
        if fieldsFilled == 0 {
            print("⚠️ [WARNING] لم يتم ملء أي حقول - تحقق من أسماء الحقول في القالب")
        }
    }
    
    // دالة مساعدة لمطابقة أسماء الحقول مع البيانات
    private func getValueForField(fieldName: String, formData: FormFieldsModel) -> String {
        
        // مطابقة أسماء الحقول الفعلية في القالب مع البيانات - المطابقة المحدثة
        switch fieldName {
        // البيانات الأساسية - المطابقة المحدثة
        case "Text_1": // day - اليوم
            return formData.day
        case "Text_2": // reportTime - الساعة  
            return formData.time
        case "Text_3": // location - الموقع 
            return formData.location
        case "Text_4": // subscriptionNumber - رقم الاشتراك
            return formData.subscriptionNumber
        case "Text_6": // date - التاريخ
            return formData.date
        case "Text_7": // meterCapacity - سعة العداد
            return formData.meterCapacity
        case "Text_8": // currentLoad - الحمل الحالي
            return formData.currentLoad
        case "Text_11": // outageDetails - تفاصيل الانقطاع
            return formData.additionalVerificationDetails
            
        // التوصيات - حقل نص واحد فقط
        case "Text_27": // التوصيات
            return formData.recommendations
            
        // التواقيع - المطابقة المحدثة
        // التوقيع الأول
        case "Text_58": // recommenderSignature_1
            return formData.signatures.count > 0 ? formData.signatures[0].representative : ""
        case "Text_44": // recommenderEntity_1
            return formData.signatures.count > 0 ? formData.signatures[0].organization : ""
            
        // التوقيع الثاني
        case "Text_39": // recommenderSignature_2
            return formData.signatures.count > 1 ? formData.signatures[1].representative : ""
        case "Text_43": // recommenderEntity_2
            return formData.signatures.count > 1 ? formData.signatures[1].organization : ""
            
        // التوقيع الثالث
        case "Text_40": // recommenderSignature_3
            return formData.signatures.count > 2 ? formData.signatures[2].representative : ""
        case "Text_42": // recommenderEntity_3
            return formData.signatures.count > 2 ? formData.signatures[2].organization : ""
            
        // التوقيع الرابع
        case "Text_51": // recommenderSignature_4
            return formData.signatures.count > 3 ? formData.signatures[3].representative : ""
        case "Text_47": // recommenderEntity_4
            return formData.signatures.count > 3 ? formData.signatures[3].organization : ""
            
        // التوقيع الخامس
        case "Text_52": // recommenderSignature_5
            return formData.signatures.count > 4 ? formData.signatures[4].representative : ""
        case "Text_48": // recommenderEntity_5
            return formData.signatures.count > 4 ? formData.signatures[4].organization : ""
            

        // صناديق الاختيار (Checkboxes) - نفس المطابقة السابقة
        case "Checkbox_1": // sourceCompanyKadana - بلاغ من شركة كدانة
            return formData.reportFromKadana ? "Yes" : ""
        case "Checkbox_2": // sourceLicensedOperator - بلاغ من المرخص له
            return formData.reportFromLicensee ? "Yes" : ""
        case "Checkbox_3": // sourceEnergyCenter - بلاغ وارد لمركز منظومة الطاقة
            return formData.reportFromEnergySystemCenter ? "Yes" : ""
        case "Checkbox_4": // sourceCampOperatorCompany - بلاغ من الشركة المشغلة لمخيمات
            return formData.reportFromOperatingCompany ? "Yes" : ""
        case "Checkbox_5": // sourceFieldVisit - انقطاع خلال زيارة ميدانية
            return formData.outageFieldVisit ? "Yes" : ""
        case "Checkbox_6": // sourceControlCenter - رصد في مركز التحكم الخاص بالمرخص له
            return formData.detectedInControlCenter ? "Yes" : ""
        case "Checkbox_7": // sourceMina - مشعر منى
            return formData.reportFromOther ? "Yes" : ""
            
        default:
            print("⚠️ [WARNING] حقل غير معروف: '\(fieldName)'")
            return ""
        }
    }
    
    // دالة لفحص القالب واستخراج أسماء الحقول
    func inspectPDFTemplate() {
        guard let templatePath = Bundle.main.path(forResource: "template_with_placeholder", ofType: "pdf"),
              let templatePDF = PDFDocument(url: URL(fileURLWithPath: templatePath)) else {
            print("❌ [ERROR] لا يمكن تحميل ملف القالب")
            return
        }
        
        print("🔍 [TEMPLATE INSPECTION] بدء فحص ملف القالب")
        print("🔍 [TEMPLATE INSPECTION] عدد الصفحات: \(templatePDF.pageCount)")
        
        var totalAnnotations = 0
        var formFields: [String] = []
        
        // فحص كل صفحة
        for pageIndex in 0..<templatePDF.pageCount {
            guard let page = templatePDF.page(at: pageIndex) else { continue }
            
            print("\n📄 [PAGE \(pageIndex + 1)] فحص الصفحة \(pageIndex + 1)")
            print("📄 [PAGE \(pageIndex + 1)] عدد الـ annotations: \(page.annotations.count)")
            
            // فحص كل annotation في الصفحة
            for (index, annotation) in page.annotations.enumerated() {
                totalAnnotations += 1
                
                print("  🔸 Annotation \(index + 1):")
                print("    - النوع: \(annotation.type ?? "غير محدد")")
                print("    - الموضع: \(annotation.bounds)")
                
                // فحص إذا كان form field
                if let fieldName = annotation.fieldName {
                    print("    - ✅ اسم الحقل: '\(fieldName)'")
                    print("    - نوع الحقل: \(annotation.widgetFieldType.rawValue)")
                    
                    if let currentValue = annotation.widgetStringValue {
                        print("    - القيمة الحالية: '\(currentValue)'")
                    }
                    
                    // إضافة إلى قائمة الحقول
                    formFields.append(fieldName)
                } else {
                    print("    - ❌ ليس form field")
                }
                
                // فحص المحتوى النصي
                if let contents = annotation.contents, !contents.isEmpty {
                    print("    - المحتوى: '\(contents)'")
                }
            }
        }
        
        print("\n📊 [SUMMARY] ملخص فحص القالب:")
        print("📊 إجمالي الـ annotations: \(totalAnnotations)")
        print("📊 إجمالي حقول النماذج: \(formFields.count)")
        
        if !formFields.isEmpty {
            print("\n📝 [FORM FIELDS] قائمة أسماء الحقول الموجودة:")
            for (index, fieldName) in formFields.enumerated() {
                print("  \(index + 1). '\(fieldName)'")
            }
        } else {
            print("\n⚠️ [WARNING] لم يتم العثور على أي form fields في القالب!")
        }
    }
}

enum PDFError: LocalizedError {
    case cannotLoadTemplate
    case insufficientPages
    case cannotAccessPages
    case imageProcessingFailed
    case cannotSavePDF
    
    var errorDescription: String? {
        switch self {
        case .cannotLoadTemplate:
            return "لا يمكن قراءة ملف PDF المحدد. تأكد من أن الملف غير تالف وليس محمي بكلمة مرور."
        case .insufficientPages:
            return "ملف PDF يجب أن يحتوي على صفحتين على الأقل لإضافة الصور في الصفحتين الأخيرتين."
        case .cannotAccessPages:
            return "لا يمكن الوصول إلى صفحات PDF"
        case .imageProcessingFailed:
            return "فشل في معالجة الصورة"
        case .cannotSavePDF:
            return "فشل في حفظ PDF"
        }
    }
} 
