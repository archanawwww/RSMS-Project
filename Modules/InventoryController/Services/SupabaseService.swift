import Foundation
import Supabase

final class SupabaseService {
    
    static let shared = SupabaseService()
    
    let client: SupabaseClient
    
    private init() {
        
        
        
        client = SupabaseClient(
            supabaseURL: URL(string: "https://zfengirsvsjikrhxrfit.supabase.co")!,
            supabaseKey: "sb_publishable_JVUVGkUrqNY-u-VWL-m4gQ_-i2e8CKG",
            options: SupabaseClientOptions(
                auth: SupabaseClientOptions.AuthOptions(
                    // Opt-in to correct session-emission behavior (supabase-swift PR #822).
                    // Ensures the locally stored session is always emitted regardless of expiry.
                    // Check session.isExpired in the listener if your flow depends on valid sessions.
                    emitLocalSessionAsInitialSession: true
                )
                
            )
        )
        
    }
    
    
}
