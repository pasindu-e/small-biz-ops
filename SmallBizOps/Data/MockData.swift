import Foundation

/// Seed content used once by `FirestoreSeeder` to populate an empty Firestore project.
enum MockData {
    static let products: [Product] = [
        Product(name: "Premium Coffee Beans", sku: "COF-001", stock: 4, minimum: 10, status: .lowStock, category: "Beverages", supplier: "Northline Roasters", unitCost: 12.50, averageDailyUsage: 1.4),
        Product(name: "Paper Cups", sku: "SUP-014", stock: 12, minimum: 20, status: .lowStock, category: "Supplies", supplier: "Cascade Packaging Co.", unitCost: 3.25, averageDailyUsage: 2.6),
        Product(name: "Vanilla Syrup", sku: "ING-022", stock: 28, minimum: 12, status: .inStock, category: "Ingredients", supplier: "Flavorworks Supply", unitCost: 8.10, averageDailyUsage: 0.9),
        Product(name: "Northstar Tote Bag", sku: "MER-008", stock: 42, minimum: 15, status: .inStock, category: "Merchandise", supplier: "Bluecrest Textiles", unitCost: 6.40, averageDailyUsage: 0.5),
    ]

    static let suppliers: [Supplier] = [
        Supplier(
            name: "Northline Roasters",
            category: "Coffee Roaster",
            address: "4210 NE Alberta St, Portland, OR",
            city: "Portland, OR",
            phone: "(503) 555-0131",
            email: "orders@northlineroasters.com",
            leadTimeDays: 3,
            productsSupplied: ["Premium Coffee Beans"],
            latitude: 45.5231,
            longitude: -122.6765
        ),
        Supplier(
            name: "Cascade Packaging Co.",
            category: "Packaging Supplies",
            address: "1830 SE Powell Blvd, Portland, OR",
            city: "Portland, OR",
            phone: "(503) 555-0187",
            email: "sales@cascadepackaging.com",
            leadTimeDays: 5,
            productsSupplied: ["Paper Cups"],
            latitude: 45.5051,
            longitude: -122.6550
        ),
        Supplier(
            name: "Flavorworks Supply",
            category: "Ingredients",
            address: "927 NW Raleigh St, Portland, OR",
            city: "Portland, OR",
            phone: "(503) 555-0164",
            email: "hello@flavorworkssupply.com",
            leadTimeDays: 4,
            productsSupplied: ["Vanilla Syrup"],
            latitude: 45.5300,
            longitude: -122.6970
        ),
        Supplier(
            name: "Bluecrest Textiles",
            category: "Merchandise & Textiles",
            address: "6600 N Interstate Ave, Portland, OR",
            city: "Portland, OR",
            phone: "(503) 555-0142",
            email: "support@bluecresttextiles.com",
            leadTimeDays: 7,
            productsSupplied: ["Northstar Tote Bag"],
            latitude: 45.5670,
            longitude: -122.6800
        ),
    ]

    static let orders: [Order] = [
        Order(
            id: "#ORD-1048",
            customer: "Maya Chen",
            email: "maya@example.com",
            phone: "(415) 555-0142",
            total: 184.50,
            status: .delayed,
            time: "2 days overdue",
            itemsLabel: "6 items",
            lineItems: [
                OrderLineItem(title: "4 × Ceramic Dripper", amount: 116.00),
                OrderLineItem(title: "2 × Coffee Filter Pack", amount: 48.00),
            ],
            shipping: 20.50,
            timeline: [
                OrderStatusStep(title: "Order placed", subtitle: "Jun 14 · 9:24 AM", complete: true),
                OrderStatusStep(title: "Processing", subtitle: "Jun 14 · 2:10 PM", complete: true),
                OrderStatusStep(title: "Shipped", subtitle: "Jun 15 · FedEx 7482 9012", complete: true),
                OrderStatusStep(title: "Delivery update", subtitle: "Expected Jun 16 · Overdue", complete: false),
            ]
        ),
        Order(
            id: "#ORD-1051",
            customer: "Jordan Lee",
            email: "jordan@example.com",
            phone: "(415) 555-0198",
            total: 72.00,
            status: .processing,
            time: "Due today",
            itemsLabel: "3 items",
            lineItems: [
                OrderLineItem(title: "3 × House Blend Bag", amount: 54.00),
                OrderLineItem(title: "1 × Northstar Mug", amount: 18.00),
            ],
            shipping: 0,
            timeline: [
                OrderStatusStep(title: "Order placed", subtitle: "Jun 17 · 11:02 AM", complete: true),
                OrderStatusStep(title: "Processing", subtitle: "Jun 17 · 1:45 PM", complete: true),
                OrderStatusStep(title: "Shipped", subtitle: "Expected Jun 18", complete: false),
                OrderStatusStep(title: "Delivered", subtitle: "Pending", complete: false),
            ]
        ),
        Order(
            id: "#ORD-1052",
            customer: "Sam Rivera",
            email: "sam@example.com",
            phone: "(415) 555-0175",
            total: 128.25,
            status: .pending,
            time: "Due tomorrow",
            itemsLabel: "4 items",
            lineItems: [
                OrderLineItem(title: "2 × Espresso Blend Bag", amount: 68.00),
                OrderLineItem(title: "2 × Northstar Tote Bag", amount: 48.00),
            ],
            shipping: 12.25,
            timeline: [
                OrderStatusStep(title: "Order placed", subtitle: "Jun 18 · 8:10 AM", complete: true),
                OrderStatusStep(title: "Processing", subtitle: "Pending", complete: false),
                OrderStatusStep(title: "Shipped", subtitle: "Pending", complete: false),
                OrderStatusStep(title: "Delivered", subtitle: "Pending", complete: false),
            ]
        ),
    ]

    static let initialTasks: [TaskItem] = [
        TaskItem(title: "Confirm coffee bean reorder", relatedTo: "Premium Coffee Beans", time: "10:00 AM", priority: .high),
        TaskItem(title: "Contact Maya about delayed order", relatedTo: "#ORD-1048", time: "12:00 PM", priority: .high),
        TaskItem(title: "Review paper cup stock", relatedTo: "Paper Cups", time: "3:00 PM", priority: .medium),
        TaskItem(title: "Update summer display", relatedTo: "Store operations", time: "5:00 PM", priority: .low),
    ]

    static let todayRun = AgentRun(
        title: "Daily operations prepared",
        dateLabel: "Today",
        timeLabel: "8:42 AM",
        duration: "18 sec",
        findingsCount: 3,
        tasksCount: 3,
        toolCallsCount: 4,
        reviewState: .approved,
        executionTrace: [
            ExecutionStep(kind: "PLAN", title: "Prepared an inventory and order health check", copy: "Prioritized exceptions that could affect today's sales."),
            ExecutionStep(kind: "TOOL CALL", title: "Inventory.readAll()", copy: "Returned 24 product records · 0.8 sec"),
            ExecutionStep(kind: "TOOL CALL", title: "Orders.getOpen()", copy: "Returned 8 open orders · 0.6 sec"),
            ExecutionStep(kind: "RESULT", title: "Identified 3 operational issues", copy: "2 stock risks and 1 delayed customer order."),
            ExecutionStep(kind: "RECOMMEND", title: "Proposed 3 reviewable actions", copy: "No changes were made automatically."),
        ],
        createdAt: Date()
    )

    static let yesterdayRun = AgentRun(
        title: "Daily operations prepared",
        dateLabel: "Yesterday",
        timeLabel: "8:35 AM",
        duration: "14 sec",
        findingsCount: 2,
        tasksCount: 2,
        toolCallsCount: 3,
        reviewState: .reviewed,
        executionTrace: [
            ExecutionStep(kind: "PLAN", title: "Prepared an inventory and order health check", copy: "Focused on stock thresholds and open orders."),
            ExecutionStep(kind: "TOOL CALL", title: "Inventory.readAll()", copy: "Returned 24 product records · 0.7 sec"),
            ExecutionStep(kind: "RESULT", title: "Identified 2 operational issues", copy: "1 stock risk and 1 pending order."),
            ExecutionStep(kind: "RECOMMEND", title: "Proposed 2 reviewable actions", copy: "No changes were made automatically."),
        ],
        createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()
    )

    static let activityEvents: [ActivityEvent] = [
        ActivityEvent(title: "Reorder approved", subtitle: "Paper Cups · 50 units · $175.00", time: "4:16 PM", isApproved: true, createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()),
        ActivityEvent(title: "3 tasks completed", subtitle: "Daily operations tasks", time: "3:40 PM", isApproved: false, createdAt: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date()),
    ]

    static let settingsGroups: [SettingsGroup] = [
        SettingsGroup(title: "BUSINESS", rows: [
            SettingsRow(iconName: "building.2", title: "Business profile", subtitle: "Northstar Goods"),
            SettingsRow(iconName: "map", title: "Suppliers & Map", subtitle: "\(MockData.suppliers.count) suppliers"),
            SettingsRow(iconName: "exclamationmark.triangle", title: "Stock thresholds", subtitle: "2 custom rules"),
            SettingsRow(iconName: "bell", title: "Notifications", subtitle: "Daily brief at 8:30 AM"),
        ]),
        SettingsGroup(title: "DATA & PRIVACY", rows: [
            SettingsRow(iconName: "icloud", title: "Sync status", subtitle: "Synced just now"),
            SettingsRow(iconName: "shield", title: "On-device processing", subtitle: "Private by default"),
            SettingsRow(iconName: "faceid", title: "Face ID", subtitle: "Enabled"),
        ]),
        SettingsGroup(title: "ABOUT", rows: [
            SettingsRow(iconName: "info.circle", title: "About SmallBizOps", subtitle: "Version 1.0"),
            SettingsRow(iconName: "shield", title: "Privacy & security", subtitle: "Learn more"),
        ]),
    ]
}
