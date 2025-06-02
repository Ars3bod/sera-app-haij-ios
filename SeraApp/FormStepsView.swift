import SwiftUI

struct FormStepsView: View {
    @ObservedObject var formData: FormDataModel
    @ObservedObject var pdfManager: PDFManager
    @State private var showingSuccess = false
    @State private var showingImagePicker = false
    @State private var showingSourceSelection = false
    @State private var selectedImage: UIImage?
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // شريط التنقل العلوي
                HStack {
                    Button("إغلاق") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.blue)
                    
                    Spacer()
                    
                    Text("تجميع الصور")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    // مساحة فارغة للتوازن
                    Text("إغلاق")
                        .foregroundColor(.clear)
                }
                .padding()
                .background(Color(UIColor.systemGroupedBackground))
                
                Divider()
                
                Spacer()
                
                // محتوى معرض الصور المحدث
                if formData.selectedImages.isEmpty {
                    // عرض زر إضافة كبير عندما لا توجد صور
                    VStack(spacing: 30) {
                        // أيقونة كبيرة
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)
                        
                        // نص توضيحي
                        VStack(spacing: 10) {
                            Text("إضافة الصور")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("(حتى 8 صور)")
                                .font(.body)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        // الزر الكبير
                        Button(action: {
                            showingSourceSelection = true
                        }) {
                            HStack(spacing: 15) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                Text("إضافة صور")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(
                                LinearGradient(
                                    colors: [.blue, .blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(15)
                            .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.horizontal, 40)
                    }
                } else {
                    // عرض معرض الصور الموجودة
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 20) {
                            ForEach(formData.selectedImages.indices, id: \.self) { index in
                                ZStack(alignment: .topTrailing) {
                                    Image(uiImage: formData.selectedImages[index])
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 150, height: 150)
                                        .clipped()
                                        .cornerRadius(12)
                                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                                    
                                    Button(action: {
                                        formData.removeImage(at: index)
                                    }) {
                                        Image(systemName: "xmark.circle.fill")
                                            .font(.title3)
                                            .foregroundColor(.red)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                    }
                                    .offset(x: 8, y: -8)
                                }
                            }
                            
                            // زر إضافة المزيد من الصور (إذا لم نصل للحد الأقصى)
                            if formData.selectedImages.count < 8 {
                                Button(action: {
                                    showingSourceSelection = true
                                }) {
                                    VStack(spacing: 10) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 30))
                                            .foregroundColor(.blue)
                                        
                                        Text("إضافة صورة")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                    }
                                    .frame(width: 150, height: 150)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [5]))
                                    )
                                }
                            }
                        }
                        .padding()
                    }
                }
                
                Spacer()
                
                // أزرار التحكم
                VStack(spacing: 15) {
                    if !formData.selectedImages.isEmpty {
                        if pdfManager.isGenerating {
                            ProgressView("جاري إنشاء PDF...")
                                .padding()
                        }
                        
                        Button(action: {
                            generatePDF()
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
                                    colors: [.green, .green.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                        }
                        .disabled(pdfManager.isGenerating)
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 30)
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .environment(\.layoutDirection, .rightToLeft)
        }
        .sheet(isPresented: $showingSuccess) {
            if let pdfURL = pdfManager.generatedPDFURL {
                PDFSuccessView(pdfURL: pdfURL, pdfManager: pdfManager)
            }
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
            LocalImagePicker(selectedImage: $selectedImage, sourceType: sourceType)
        }
        .onChange(of: selectedImage) { image in
            if let image = image {
                formData.addImage(image)
                selectedImage = nil
            }
        }
    }
    
    private func generatePDF() {
        pdfManager.generateFinalPDF(with: formData) { url in
            if url != nil {
                showingSuccess = true
            }
        }
    }
}

struct LocalImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: LocalImagePicker
        
        init(_ parent: LocalImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.selectedImage = image
            }
            picker.dismiss(animated: true)
        }
    }
} 