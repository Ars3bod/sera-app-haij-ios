import SwiftUI
import UniformTypeIdentifiers

// إضافة notifications للتعامل مع حالات معالجة PDF
extension Notification.Name {
    static let pdfProcessingStarted = Notification.Name("pdfProcessingStarted")
    static let pdfProcessingFinished = Notification.Name("pdfProcessingFinished")
    static let pdfProcessingError = Notification.Name("pdfProcessingError")
}

struct ContentView: View {
    @StateObject private var formData = FormDataModel()
    @StateObject private var pdfManager = PDFManager()
    @State private var selectedService: ServiceType? = nil
    
    enum ServiceType {
        case fillableForm
        case photoService
    }
    
    var body: some View {
        ZStack {
            // خلفية متدرجة
            LinearGradient(
                colors: [
                    Color.blue.opacity(0.1),
                    Color.purple.opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // رأس التطبيق
                    VStack(spacing: 15) {
                        Image(systemName: "building.2")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                            .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                        
                        Text("تطبيق خدمات الكهرباء")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.center)
                        
                        Text("جميع الخدمات متاحة أدناه")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 20)
                    
                    // الخدمات المتاحة
                    VStack(spacing: 20) {
                        // خدمة النموذج القابل للملء (محضر بلاغ انقطاع الخدمة الكهربائية)
                        ServiceSectionView(
                            title: "محضر بلاغ انقطاع الخدمة الكهربائية",
                            description: "إنشاء محضر رسمي لتوثيق انقطاع الخدمة الكهربائية مع جميع التفاصيل والإجراءات المطلوبة",
                            icon: "bolt.fill",
                            color: .orange,
                            isExpanded: selectedService == .fillableForm,
                            onToggle: {
                                withAnimation {
                                    selectedService = selectedService == .fillableForm ? nil : .fillableForm
                                }
                            },
                            content: {
                                FillableFormView(pdfManager: pdfManager)
                            }
                        )
                        
                        // خدمة إضافة الصور لملفات PDF
                        ServiceSectionView(
                            title: "إضافة صور لملف PDF",
                            description: "رفع ملف PDF مخصص وإضافة الصور في الصفحتين الأخيرتين بتنسيق منظم",
                            icon: "photo.fill.on.rectangle.fill",
                            color: .blue,
                            isExpanded: selectedService == .photoService,
                            onToggle: {
                                withAnimation {
                                    selectedService = selectedService == .photoService ? nil : .photoService
                                }
                            },
                            content: {
                                PhotoServiceView(formData: formData, pdfManager: pdfManager)
                            }
                        )
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 50)
                }
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

struct ServiceSectionView<Content: View>: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let isExpanded: Bool
    let onToggle: () -> Void
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(spacing: 0) {
            // رأس الخدمة
            Button(action: onToggle) {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Image(systemName: icon)
                                .font(.system(size: 40))
                                .foregroundColor(color)
                            
                            Text(title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.leading)
                            
                            Text(description)
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.leading)
                                .lineLimit(3)
                        }
                        
                        Spacer()
                        
                        Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(color)
                    }
                    .padding(25)
                }
                .background(
                    RoundedRectangle(cornerRadius: isExpanded ? 20 : 20)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 15, x: 0, y: 8)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
            }
            .buttonStyle(PlainButtonStyle())
            
            // محتوى الخدمة
            if isExpanded {
                VStack {
                    content
                }
                .padding(.top, 10)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
    }
}

struct PhotoServiceView: View {
    @ObservedObject var formData: FormDataModel
    @ObservedObject var pdfManager: PDFManager
    @State private var showingSuccess = false
    @State private var showingImagePicker = false
    @State private var showingSourceSelection = false
    @State private var showingDocumentPicker = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var isProcessingPDF = false
    
    var body: some View {
        VStack(spacing: 20) {
            
            // خطوة 1: اختيار ملف PDF
            VStack(spacing: 15) {
                HStack {
                    Image(systemName: "1.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                    Text("اختر ملف PDF")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                if !formData.hasPDFSelected {
                    Button(action: {
                        showingDocumentPicker = true
                    }) {
                        VStack(spacing: 12) {
                            Image(systemName: "doc.badge.plus")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            Text("اختر ملف PDF من جهازك")
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 100)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(15)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [8]))
                        )
                    }
                } else {
                    HStack {
                        Image(systemName: "doc.fill")
                            .foregroundColor(.green)
                        Text(formData.selectedPDFName)
                            .font(.body)
                            .foregroundColor(.primary)
                        Spacer()
                        Button("تغيير") {
                            showingDocumentPicker = true
                        }
                        .foregroundColor(.blue)
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(10)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(UIColor.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            
            // خطوة 2: إضافة الصور
            if formData.hasPDFSelected {
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "2.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 5) {
                            Text("أضف الصور (حتى 8 صور)")
                                .font(.body)
                                .foregroundColor(.primary)
                                .multilineTextAlignment(.center)
                            
                            Text("ستُضاف الصور في الصفحتين الأخيرتين")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        Spacer()
                    }
                    
                    if formData.selectedImages.isEmpty {
                        Button(action: {
                            showingSourceSelection = true
                        }) {
                            VStack(spacing: 12) {
                                Image(systemName: "photo.badge.plus")
                                    .font(.system(size: 40))
                                    .foregroundColor(.green)
                                
                                Text("أضف صوراً للملف")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 100)
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(15)
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.green, style: StrokeStyle(lineWidth: 2, dash: [8]))
                            )
                        }
                    } else {
                        VStack(spacing: 15) {
                            HStack {
                                Text("الصور المختارة (\(formData.selectedImages.count)/8)")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if formData.selectedImages.count > 0 {
                                    VStack(alignment: .trailing, spacing: 2) {
                                        if formData.selectedImages.count <= 4 {
                                            Text("الصفحة قبل الأخيرة: \(formData.selectedImages.count)")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                            Text("الصفحة الأخيرة: 0")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        } else {
                                            Text("الصفحة قبل الأخيرة: 4")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                            Text("الصفحة الأخيرة: \(formData.selectedImages.count - 4)")
                                                .font(.caption2)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                            }
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                ForEach(formData.selectedImages.indices, id: \.self) { index in
                                    ImageThumbnailView(
                                        image: formData.selectedImages[index],
                                        onDelete: {
                                            formData.removeImage(at: index)
                                        }
                                    )
                                }
                                
                                if formData.selectedImages.count < 8 {
                                    AddImageButton(action: {
                                        showingSourceSelection = true
                                    })
                                }
                            }
                        }
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
            }
            
            // خطوة 3: إنشاء PDF
            if formData.hasPDFSelected && !formData.selectedImages.isEmpty {
                VStack(spacing: 15) {
                    HStack {
                        Image(systemName: "3.circle.fill")
                            .foregroundColor(.purple)
                            .font(.title2)
                        Text("إنشاء PDF النهائي")
                            .font(.headline)
                            .fontWeight(.bold)
                        Spacer()
                    }
                    
                    Button(action: {
                        pdfManager.createPDFWithImages(formData: formData) { url in
                            if url != nil {
                                showingSuccess = true
                            }
                        }
                    }) {
                        HStack {
                            Image(systemName: "doc.fill")
                            Text("إنشاء PDF مع الصور")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [.purple, .purple.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .purple.opacity(0.3), radius: 6, x: 0, y: 3)
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(UIColor.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                )
            }
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker(formData: formData)
        }
        .actionSheet(isPresented: $showingSourceSelection) {
            ActionSheet(
                title: Text("اختر مصدر الصورة"),
                buttons: [
                    .default(Text("الكاميرا")) {
                        sourceType = .camera
                        showingImagePicker = true
                    },
                    .default(Text("معرض الصور")) {
                        sourceType = .photoLibrary
                        showingImagePicker = true
                    },
                    .cancel(Text("إلغاء"))
                ]
            )
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
        }
        .onChange(of: selectedImage) { _, image in
            if let image = image {
                formData.addImage(image)
                selectedImage = nil
            }
        }
        .sheet(isPresented: $showingSuccess) {
            if let pdfURL = pdfManager.generatedPDFURL {
                PDFSuccessView(pdfURL: pdfURL, pdfManager: pdfManager)
            }
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}

struct DocumentPicker: UIViewControllerRepresentable {
    @ObservedObject var formData: FormDataModel
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.pdf])
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: DocumentPicker
        
        init(_ parent: DocumentPicker) {
            self.parent = parent
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .pdfProcessingStarted, object: nil)
            }
            
            let canAccess = url.startAccessingSecurityScopedResource()
            defer {
                url.stopAccessingSecurityScopedResource()
            }
            
            guard canAccess else {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .pdfProcessingFinished, object: nil)
                    NotificationCenter.default.post(name: .pdfProcessingError, object: nil, userInfo: ["message": "لا يمكن الوصول للملف المحدد"])
                }
                return
            }
            
            do {
                let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                let fileName = url.lastPathComponent
                let destinationURL = documentsPath.appendingPathComponent(fileName)
                
                if FileManager.default.fileExists(atPath: destinationURL.path) {
                    try FileManager.default.removeItem(at: destinationURL)
                }
                
                let data = try Data(contentsOf: url)
                try data.write(to: destinationURL)
                
                DispatchQueue.main.async {
                    self.parent.formData.setPDFFile(url: destinationURL, name: fileName)
                    NotificationCenter.default.post(name: .pdfProcessingFinished, object: nil)
                    self.parent.presentationMode.wrappedValue.dismiss()
                }
                
            } catch {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .pdfProcessingFinished, object: nil)
                    NotificationCenter.default.post(name: .pdfProcessingError, object: nil, userInfo: ["message": "فشل في نسخ الملف: \(error.localizedDescription)"])
                    self.parent.presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
}

struct ImageThumbnailView: View {
    let image: UIImage
    let onDelete: () -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 120, height: 120)
                .clipped()
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red)
                    .background(Color.white)
                    .clipShape(Circle())
            }
            .offset(x: 6, y: -6)
        }
    }
}

struct AddImageButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: "plus")
                    .font(.system(size: 25))
                    .foregroundColor(.blue)
                
                Text("إضافة")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .frame(width: 120, height: 120)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5]))
            )
        }
    }
}

struct PDFSuccessView: View {
    let pdfURL: URL
    @ObservedObject var pdfManager: PDFManager
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                
                VStack(spacing: 15) {
                    Text("تم إنشاء PDF بنجاح!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("تم حفظ ملف PDF مع جميع الصور المختارة")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button(action: {
                    showingShareSheet = true
                }) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text("مشاركة PDF")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.blue)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .navigationTitle("تم بنجاح")
            .navigationBarTitleDisplayMode(.inline)
            .environment(\.layoutDirection, .rightToLeft)
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [pdfURL])
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
} 