import SwiftUI

struct PropertyCardView: View {
    let property: Property
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .aspectRatio(16/9, contentMode: .fit)
                    .overlay(
                        AsyncImage(url: URL(string: property.images.first ?? "")) { image in
                            image.resizable().scaledToFill()
                        } placeholder: {
                            Image(systemName: "house.fill").foregroundColor(.gray)
                        }
                    )
                    .clipped()
                
                if property.isVerified {
                    Text("VERIFIED")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appAccent)
                        .foregroundColor(.white)
                        .cornerRadius(4)
                        .padding(8)
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("₹\(property.rent)/mo")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    Spacer()
                    Text("\(property.bhk) BHK • \(property.propertyType.displayName)")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                    Text("\(property.location.area), \(property.location.city)")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                Divider()
                
                HStack {
                    Text(property.furnishing.displayName)
                    Spacer()
                    Text(property.allowedTenants.displayName)
                }
                .font(.caption)
                .foregroundColor(.textSecondary)
            }
            .padding()
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}
