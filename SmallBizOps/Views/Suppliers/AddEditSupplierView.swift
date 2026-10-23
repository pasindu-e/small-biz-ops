import SwiftUI
import MapKit

struct AddEditSupplierView: View {
    @EnvironmentObject var store: MockDataStore
    @Environment(\.dismiss) private var dismiss

    /// Pass an existing supplier to edit it; leave nil to create a new one.
    let supplierToEdit: Supplier?

    @State private var name: String
    @State private var category: String
    @State private var address: String
    @State private var city: String
    @State private var phone: String
    @State private var email: String
    @State private var leadTimeDays: String
    @State private var productsSupplied: String
    @State private var pinCoordinate: CLLocationCoordinate2D
    @State private var cameraPosition: MapCameraPosition
    @State private var errorMessage: String?
    @State private var isSaving = false

    private static let defaultCoordinate = CLLocationCoordinate2D(latitude: 45.5152, longitude: -122.6784)

    init(supplierToEdit: Supplier? = nil) {
        self.supplierToEdit = supplierToEdit
        _name = State(initialValue: supplierToEdit?.name ?? "")
        _category = State(initialValue: supplierToEdit?.category ?? "")
        _address = State(initialValue: supplierToEdit?.address ?? "")
        _city = State(initialValue: supplierToEdit?.city ?? "")
        _phone = State(initialValue: supplierToEdit?.phone ?? "")
        _email = State(initialValue: supplierToEdit?.email ?? "")
        _leadTimeDays = State(initialValue: supplierToEdit.map { String($0.leadTimeDays) } ?? "")
        _productsSupplied = State(initialValue: supplierToEdit?.productsSupplied.joined(separator: ", ") ?? "")
        let coordinate = supplierToEdit?.coordinate ?? Self.defaultCoordinate
        _pinCoordinate = State(initialValue: coordinate)
        _cameraPosition = State(initialValue: .region(
            MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08))
        ))
    }

    private var isEditing: Bool { supplierToEdit != nil }

    var body: some View {
        NavigationStack {
            Form {
                Section("Supplier") {
                    TextField("Name", text: $name)
                    TextField("Category", text: $category)
                    TextField("Products supplied (comma separated)", text: $productsSupplied)
                }
                Section("Contact") {
                    TextField("Address", text: $address)
                    TextField("City", text: $city)
                    TextField("Phone", text: $phone)
                        .keyboardType(.phonePad)
                    TextField("Email", text: $email)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                }
                Section("Logistics") {
                    TextField("Lead time (days)", text: $leadTimeDays)
                        .keyboardType(.numberPad)
                }
                Section("Map location") {
                    MapReader { proxy in
                        Map(position: $cameraPosition) {
                            Marker("Supplier", coordinate: pinCoordinate)
                                .tint(Color(uiColor: .systemRed))
                        }
                        .mapStyle(.standard)
                        .frame(height: 220)
                        .onTapGesture { screenPoint in
                            guard let coordinate = proxy.convert(screenPoint, from: .local) else { return }
                            pinCoordinate = coordinate
                        }
                    }
                    .listRowInsets(EdgeInsets())
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    Text("Tap the map to drop the pin at the supplier's location.")
                        .font(.system(size: 11))
                        .foregroundColor(.appMuted)

                    HStack {
                        Text("Lat \(pinCoordinate.latitude, specifier: "%.4f"), Lng \(pinCoordinate.longitude, specifier: "%.4f")")
                            .font(.system(size: 11))
                            .foregroundColor(.appMuted)
                        Spacer()
                    }
                }

                if let errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 12))
                        .foregroundColor(.appDanger)
                }
            }
            .navigationTitle(isEditing ? "Edit Supplier" : "Add Supplier")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSaving {
                        ProgressView()
                    } else {
                        Button("Save") { save() }
                    }
                }
            }
            .disabled(isSaving)
        }
    }

    private func save() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            errorMessage = "Enter a supplier name."
            return
        }
        guard let leadTimeValue = Int(leadTimeDays) else {
            errorMessage = "Enter a valid lead time in days."
            return
        }

        let products = productsSupplied
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }

        var supplier = supplierToEdit ?? Supplier(
            name: trimmedName,
            category: "",
            address: "",
            city: "",
            phone: "",
            email: "",
            leadTimeDays: 0,
            productsSupplied: [],
            latitude: 0,
            longitude: 0
        )
        supplier.name = trimmedName
        supplier.category = category.trimmingCharacters(in: .whitespacesAndNewlines)
        supplier.address = address.trimmingCharacters(in: .whitespacesAndNewlines)
        supplier.city = city.trimmingCharacters(in: .whitespacesAndNewlines)
        supplier.phone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        supplier.email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        supplier.leadTimeDays = leadTimeValue
        supplier.productsSupplied = products
        supplier.latitude = pinCoordinate.latitude
        supplier.longitude = pinCoordinate.longitude

        isSaving = true
        let completion: (Result<Void, Error>) -> Void = { result in
            isSaving = false
            switch result {
            case .success:
                dismiss()
            case .failure(let error):
                errorMessage = "Couldn't save: \(error.localizedDescription)"
            }
        }

        if isEditing {
            store.updateSupplier(supplier, completion: completion)
        } else {
            store.addSupplier(supplier, completion: completion)
        }
    }
}

#Preview {
    AddEditSupplierView().environmentObject(MockDataStore())
}
