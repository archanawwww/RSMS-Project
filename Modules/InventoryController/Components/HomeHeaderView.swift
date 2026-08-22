import SwiftUI

struct HomeHeaderView: View {
    let userName: String

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        default: return "Good evening"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            // Greeting line — subheadline weight, secondary color
           

            // Large title — the dominant element
            Text("Home")
                .font(.system(size: 34, weight: .bold))
                .foregroundColor(.primary)
                .padding(.top, 2)
            
            Text("\(greeting), \(userName)")
                .font(.system(size: 17))
                .foregroundColor(.secondary)

            .font(.system(size: 13))
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

