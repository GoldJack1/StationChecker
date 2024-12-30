import SwiftUI

struct landingPage: View {
    @State private var arrowScale: CGFloat = 0.5 // Initial scale for the arrow image

    var body: some View {
        NavigationStack {
            ZStack {
                Color.yellow
                    .ignoresSafeArea()
                
                VStack(spacing: 40) {
                    Image("arrow") // Replace with your asset name
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .scaleEffect(arrowScale) // Apply scaling effect
                        .onAppear {
                            // Animate scale to normal size
                            withAnimation(.easeInOut(duration: 1.5)) {
                                arrowScale = 1.0
                            }
                        }
                    
                    Text("Welcome to GBR")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.black)
                    
                    NavigationLink(destination: HomePageView()) { // Navigate to Map
                        Text("Get Started")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(30)
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                    }
                    .padding()
                    .navigationBarBackButtonHidden(true)
                }
            }
        }
    }
}

struct LandingPage_Previews: PreviewProvider {
    static var previews: some View {
        landingPage()
    }
}
