import Foundation
import Supabase

public final class SupabaseManager {
    public static let shared = SupabaseManager()
    
    public let client: SupabaseClient
    
    private init() {
        let supabaseURL = URL(string: "https://zfengirsvsjikrhxrfit.supabase.co")!
        let supabaseKey = "sb_publishable_JVUVGkUrqNY-u-VWL-m4gQ_-i2e8CKG"
        self.client = SupabaseClient(supabaseURL: supabaseURL, supabaseKey: supabaseKey)
    }
}
