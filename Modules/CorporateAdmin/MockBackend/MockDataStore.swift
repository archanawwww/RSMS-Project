import Foundation

/// Legacy mock data store. Product catalog data now comes from Supabase.
public struct MockDataStore {

    public static var categories: [Category] {
        []
    }

    public static var productMasterRecords: [ProductMasterRecord] {
        []
    }
}
