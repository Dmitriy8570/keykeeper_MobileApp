import SwiftUI
import MapKit   // для коорд-выбора (упрощённо)

struct NewListingFormView: View {
    @StateObject private var vm = NewListingViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 14) {
                    // --- тип ---
                    Picker("Тип недвижимости", selection: $vm.selectedTypeIndex) {
                        ForEach(vm.propertyTypes.indices, id: \.self) { idx in
                            Text(vm.propertyTypes[idx].name).tag(idx)
                        }
                    }
                    .pickerStyle(.menu)

                    // --- адрес ---
                    Group {
                        TextField("Регион", text: $vm.region)
                        TextField("Муниципалитет", text: $vm.municipalite)
                        TextField("Нас. пункт", text: $vm.settlement)
                        TextField("Район", text: $vm.district)
                        TextField("Улица", text: $vm.street)
                        TextField("Дом", text: $vm.houseNumber)
                    }
                    .textFieldStyle(.roundedBorder)

                    // --- параметры ---
                    Group {
                        TextField("Цена (₽)", text: $vm.price)
                            .keyboardType(.numberPad)
                        TextField("Площадь (м²)", text: $vm.area)
                            .keyboardType(.decimalPad)
                        TextField("Комнат", text: $vm.roomCount)
                            .keyboardType(.numberPad)
                        TextField("Этаж", text: $vm.floor)
                            .keyboardType(.numberPad)
                        TextField("Этажей в доме", text: $vm.totalFloors)
                            .keyboardType(.numberPad)
                    }
                    .textFieldStyle(.roundedBorder)

                    // --- описание ---
                    TextEditor(text: $vm.description)
                        .frame(height: 120)
                        .overlay(RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.secondary.opacity(0.3)))

                    // --- кнопка ---
                    if let err = vm.error {
                        Text(err).foregroundColor(.red)
                    }
                    Button("Опубликовать") {
                        Task { await vm.publish() }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(vm.isPosting)
                }
                .padding()
            }
            .navigationTitle("Новое объявление")
            .task { await vm.loadDictionaries() }

            // переход к загрузке фото
            .navigationDestination(isPresented:
                Binding(get: { vm.newListingId != nil },
                        set: { if !$0 { vm.newListingId = nil } })
            ) {
                if let id = vm.newListingId {
                    UploadPhotosView(listingId: id)
                }
            }
        }
    }
}
