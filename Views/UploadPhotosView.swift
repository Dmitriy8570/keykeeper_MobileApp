import SwiftUI

struct UploadPhotosView: View {
    @StateObject private var vm: UploadPhotosViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingPicker = false

    init(listingId: Int) {
        _vm = StateObject(wrappedValue: UploadPhotosViewModel(listingId: listingId))
    }

    var body: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [.init(.adaptive(minimum: 100), spacing: 10)]) {
                    ForEach(vm.selected.indices, id: \.self) { idx in
                        Image(uiImage: vm.selected[idx])
                            .resizable().scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipped()
                            .cornerRadius(8)
                            .overlay(alignment: .topTrailing) {
                                Button {
                                    vm.selected.remove(at: idx)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.white)
                                        .shadow(radius: 2)
                                }
                            }
                    }
                }
                .padding()
            }

            if let err = vm.error {
                Text(err).foregroundColor(.red)
            }

            HStack {
                Button("Выбрать фото") { showingPicker = true }
                    .buttonStyle(.bordered)

                Spacer()

                Button("Загрузить") {
                    Task { await vm.upload() }
                }
                .buttonStyle(.borderedProminent)
                .disabled(vm.selected.isEmpty || vm.isUploading)
            }
            .padding()
        }
        .navigationTitle("Фото к объявлению")
        .sheet(isPresented: $showingPicker) {
            PhotoPicker(maxCount: 10) { imgs in
                vm.selected.append(contentsOf: imgs)
            }
        }
        .overlay {
            if vm.isUploading {
                ZStack {
                    Color.black.opacity(0.2).ignoresSafeArea()
                    ProgressView("Загрузка…")
                        .padding().background(.thinMaterial)
                        .cornerRadius(12)
                }
            }
        }
        .alert("Фотографии загружены!", isPresented: $vm.done) {
            Button("Ок") { dismiss() }
        }
    }
}
