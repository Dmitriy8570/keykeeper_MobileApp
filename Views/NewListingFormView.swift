import SwiftUI

struct NewListingFormView: View {
    @StateObject var viewModel = NewListingViewModel()
    @State private var showingMapPicker = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Об объекте")) {
                    Picker("Тип недвижимости", selection: $viewModel.propertyTypeIndex) {
                        ForEach(0..<viewModel.propertyTypes.count, id: \.self) { i in
                            Text(viewModel.propertyTypes[i]).tag(i)
                        }
                    }
                    TextField("Цена (₽)", text: $viewModel.price)
                        .keyboardType(.numberPad)
                    TextField("Описание", text: $viewModel.description, axis: .vertical)
                        .lineLimit(5)
                }
                Section(header: Text("Адрес")) {
                    TextField("Регион (область)", text: $viewModel.region)
                    TextField("Район", text: $viewModel.district)
                    TextField("Город / Населенный пункт", text: $viewModel.settlement)
                    TextField("Муниципалитет", text: $viewModel.municipalite)
                    TextField("Улица", text: $viewModel.street)
                    TextField("Номер дома", text: $viewModel.houseNumber)
                    Button(action: { showingMapPicker = true }) {
                        if let lat = viewModel.latitude, let lon = viewModel.longitude {
                            Text("Координаты выбраны (\(String(format: "%.4f", lat)), \(String(format: "%.4f", lon)))")
                        } else {
                            Text("Выбрать на карте")
                        }
                    }
                }
                Section(header: Text("Характеристики")) {
                    TextField("Этаж", text: $viewModel.floor)
                        .keyboardType(.numberPad)
                    TextField("Этажность дома", text: $viewModel.totalFloors)
                        .keyboardType(.numberPad)
                    TextField("Количество комнат", text: $viewModel.roomCount)
                        .keyboardType(.numberPad)
                    TextField("Площадь (кв.м.)", text: $viewModel.area)
                        .keyboardType(.decimalPad)
                }
                if let error = viewModel.errorMessage {
                    Text(error).foregroundColor(.red)
                }
                Button("Опубликовать") {
                    Task { await viewModel.publishListing() }
                }
                .disabled(viewModel.isPosting)
            }
            .navigationTitle("Новое объявление")
            .sheet(isPresented: $showingMapPicker) {
                // Представляем MapPickerViewController например,
                // где пользователь может выбрать точку на карте.
                // После выбора устанавливаем viewModel.latitude/longitude
            }
            .alert(isPresented: $viewModel.postSuccess) {
                Alert(title: Text("Объявление опубликовано"),
                      message: Text("Теперь вы можете добавить фотографии."),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
}
