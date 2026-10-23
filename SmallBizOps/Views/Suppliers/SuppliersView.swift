import SwiftUI
import MapKit

struct SuppliersView: View {
    @EnvironmentObject var router: AppRouter
    @EnvironmentObject var store: MockDataStore
    @Environment(\.openURL) private var openURL
    @State private var cameraPosition: MapCameraPosition = .region(
        MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 45.5152, longitude: -122.6784), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    )
    @State private var selectedSupplierID: Supplier.ID?
    @State private var showingAddSupplier = false
    @State private var supplierToEdit: Supplier?
    @State private var supplierToDelete: Supplier?
    @State private var deleteErrorMessage: String?

    private var selectedSupplier: Supplier? {
        store.suppliers.first { $0.id == selectedSupplierID }
    }

    var body: some View {
        VStack(spacing: 0) {
            BackHeader(title: "Suppliers & Map", onBack: { router.go(.settings) }) {
                Button {
                    showingAddSupplier = true
                } label: {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                        .frame(width: 36, height: 36)
                        .background(Color.appNavy)
                        .clipShape(Circle())
                }
                .buttonStyle(.press)
            }
            .padding(.horizontal, 20)

            Map(position: $cameraPosition, selection: $selectedSupplierID) {
                ForEach(store.suppliers) { supplier in
                    Marker(supplier.name, systemImage: "shippingbox.fill", coordinate: supplier.coordinate)
                        .tint(supplier.id == selectedSupplierID ? Color(uiColor: .systemRed) : Color(uiColor: .systemIndigo))
                        .tag(supplier.id)
                }
            }
            .mapStyle(.standard)
            .frame(height: 260)
            .onAppear {
                cameraPosition = .region(Self.region(for: store.suppliers.map(\.coordinate)))
            }
            .onChange(of: store.suppliers) { _, newSuppliers in
                guard selectedSupplierID == nil else { return }
                cameraPosition = .region(Self.region(for: newSuppliers.map(\.coordinate)))
            }
            .onChange(of: selectedSupplierID) { _, newValue in
                guard let supplier = store.suppliers.first(where: { $0.id == newValue }) else { return }
                withAnimation {
                    cameraPosition = .region(
                        MKCoordinateRegion(center: supplier.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
                    )
                }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    if let selectedSupplier {
                        supplierDetailCard(selectedSupplier)
                            .padding(.top, 16)
                    }

                    HStack {
                        Text("All suppliers").font(.appSectionTitle())
                        Spacer()
                        Text("\(store.suppliers.count) suppliers").font(.appCaption()).foregroundColor(.appMuted)
                    }
                    .padding(.top, 22)
                    .padding(.bottom, 10)

                    VStack(spacing: 8) {
                        ForEach(store.suppliers) { supplier in
                            supplierRow(supplier)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .background(Color.appOffWhite)
        .sheet(isPresented: $showingAddSupplier) {
            AddEditSupplierView().environmentObject(store)
        }
        .sheet(item: $supplierToEdit) { supplier in
            AddEditSupplierView(supplierToEdit: supplier).environmentObject(store)
        }
        .alert("Delete Supplier?", isPresented: Binding(get: { supplierToDelete != nil }, set: { if !$0 { supplierToDelete = nil } })) {
            Button("Cancel", role: .cancel) { supplierToDelete = nil }
            Button("Delete", role: .destructive) {
                guard let supplier = supplierToDelete else { return }
                store.deleteSupplier(supplier) { result in
                    if case .failure(let error) = result {
                        deleteErrorMessage = error.localizedDescription
                    } else if selectedSupplierID == supplier.id {
                        selectedSupplierID = nil
                    }
                    supplierToDelete = nil
                }
            }
        } message: {
            Text("This removes \(supplierToDelete?.name ?? "this supplier") permanently.")
        }
        .alert("Couldn't Delete Supplier", isPresented: Binding(get: { deleteErrorMessage != nil }, set: { if !$0 { deleteErrorMessage = nil } })) {
            Button("OK") { deleteErrorMessage = nil }
        } message: {
            Text(deleteErrorMessage ?? "")
        }
    }

    private func supplierRow(_ supplier: Supplier) -> some View {
        let isSelected = supplier.id == selectedSupplierID
        return Button {
            withAnimation { selectedSupplierID = supplier.id }
        } label: {
            HStack(spacing: 11) {
                ZStack {
                    RoundedRectangle(cornerRadius: 11, style: .continuous)
                        .fill(isSelected ? Color.appIce : Color(hex: "EDF1F6"))
                        .frame(width: 38, height: 38)
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 16))
                        .foregroundColor(isSelected ? .appBlue : Color(hex: "56667D"))
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(supplier.name).font(.appRowTitle()).foregroundColor(.primary)
                    Text("\(supplier.category) · \(supplier.city)").font(.appCaption()).foregroundColor(.appMuted)
                }
                Spacer()
                Image(systemName: "chevron.right").font(.system(size: 14)).foregroundColor(.appMuted)
            }
            .padding(12)
        }
        .buttonStyle(.press)
        .appCard(padding: 0)
    }

    private func supplierDetailCard(_ supplier: Supplier) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Color.appIce).frame(width: 46, height: 46)
                    Image(systemName: "building.2.fill").font(.system(size: 19)).foregroundColor(.appBlue)
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(supplier.name).font(.system(size: 16, weight: .bold))
                    Text(supplier.category).font(.appCaption()).foregroundColor(.appMuted)
                }
                Spacer()
                Button {
                    supplierToEdit = supplier
                } label: {
                    Image(systemName: "pencil")
                        .foregroundColor(.appSlate)
                        .frame(width: 34, height: 34)
                        .background(Color(hex: "EEF1F5"))
                        .clipShape(Circle())
                }
                .buttonStyle(.press)
                Button {
                    supplierToDelete = supplier
                } label: {
                    Image(systemName: "trash")
                        .foregroundColor(.appDanger)
                        .frame(width: 34, height: 34)
                        .background(Color(hex: "FBEAEA"))
                        .clipShape(Circle())
                }
                .buttonStyle(.press)
            }

            Divider().background(Color.appLine)

            VStack(alignment: .leading, spacing: 8) {
                infoLine(icon: "mappin.and.ellipse", text: supplier.address)
                infoLine(icon: "phone", text: supplier.phone)
                infoLine(icon: "envelope", text: supplier.email)
                infoLine(icon: "clock", text: "\(supplier.leadTimeDays)-day lead time")
                infoLine(icon: "shippingbox", text: "Supplies " + supplier.productsSupplied.joined(separator: ", "))
            }

            HStack(spacing: 10) {
                Button {
                    openInMaps(supplier)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.triangle.turn.up.right.circle.fill")
                        Text("Get Directions")
                    }
                    .font(.appButton())
                    .frame(maxWidth: .infinity)
                    .frame(minHeight: 44)
                    .foregroundColor(.white)
                    .background(Color.appNavy)
                    .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                }
                .buttonStyle(.press)

                Button {
                    callSupplier(supplier)
                } label: {
                    Image(systemName: "phone.fill")
                        .foregroundColor(.appSlate)
                        .frame(width: 44, height: 44)
                        .background(Color(hex: "EEF1F5"))
                        .clipShape(RoundedRectangle(cornerRadius: 13, style: .continuous))
                }
                .buttonStyle(.press)
            }
        }
        .padding(14)
        .appCard(padding: 0)
    }

    private func infoLine(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 9) {
            Image(systemName: icon).font(.system(size: 12)).foregroundColor(.appMuted).frame(width: 16)
            Text(text).font(.system(size: 12)).foregroundColor(.appSlate)
        }
    }

    private func openInMaps(_ supplier: Supplier) {
        let placemark = MKPlacemark(coordinate: supplier.coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = supplier.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    private func callSupplier(_ supplier: Supplier) {
        let digits = supplier.phone.filter { $0.isNumber }
        guard let url = URL(string: "tel://\(digits)") else { return }
        openURL(url)
    }

    private static func region(for coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 45.5152, longitude: -122.6784), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
        }
        let lats = coordinates.map(\.latitude)
        let lons = coordinates.map(\.longitude)
        let center = CLLocationCoordinate2D(latitude: (lats.min()! + lats.max()!) / 2, longitude: (lons.min()! + lons.max()!) / 2)
        let span = MKCoordinateSpan(
            latitudeDelta: max((lats.max()! - lats.min()!) * 1.8, 0.04),
            longitudeDelta: max((lons.max()! - lons.min()!) * 1.8, 0.04)
        )
        return MKCoordinateRegion(center: center, span: span)
    }
}

#Preview {
    SuppliersView().environmentObject(AppRouter()).environmentObject(MockDataStore())
}
