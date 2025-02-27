import SwiftUI

struct ConfettiView: View {
    @State private var isAnimating = false
    @ObservedObject private var confettiManager = ConfettiManager.shared
    let colors: [Color] = [.red, .blue, .green, .yellow, .pink, .purple, .orange]
    let confettiCount = 150 // Increased count for more confetti
    
    var body: some View {
        ZStack {
            ForEach(0..<confettiCount, id: \.self) { index in
                ConfettiPiece(
                    color: colors[index % colors.count],
                    position: randomPosition(),
                    angle: randomAngle(),
                    size: randomSize(),
                    shape: randomShape(index: index),
                    isAnimating: $isAnimating,
                    origin: confettiManager.confettiOrigin
                )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
    
    private func randomPosition() -> CGPoint {
        // If we have an origin point, use it as the base for confetti
        if let origin = confettiManager.confettiOrigin {
            // Normalize the origin to 0-1 range
            let normalizedX = origin.x / UIScreen.main.bounds.width
            let normalizedY = origin.y / UIScreen.main.bounds.height
            
            // Create a small random offset around the origin
            return CGPoint(
                x: normalizedX + CGFloat.random(in: -0.05...0.05),
                y: normalizedY + CGFloat.random(in: -0.05...0.05)
            )
        } else {
            // Default behavior - random positions from top of screen
            return CGPoint(
                x: CGFloat.random(in: 0...1),
                y: CGFloat.random(in: -0.1...0.2)
            )
        }
    }
    
    private func randomAngle() -> Double {
        return Double.random(in: 0...360)
    }
    
    private func randomSize() -> CGFloat {
        return CGFloat.random(in: 5...15)
    }
    
    private func randomShape(index: Int) -> ConfettiShape {
        let shapes: [ConfettiShape] = [.rectangle, .circle, .triangle, .star]
        return shapes[index % shapes.count]
    }
}

enum ConfettiShape {
    case rectangle, circle, triangle, star
}

struct ConfettiPiece: View {
    let color: Color
    let position: CGPoint
    let angle: Double
    let size: CGFloat
    let shape: ConfettiShape
    @Binding var isAnimating: Bool
    let origin: CGPoint?
    
    @State private var finalPosition = CGPoint(x: 0, y: 0)
    @State private var rotation = 0.0
    @State private var opacity = 0.0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        confettiShape
            .position(
                x: UIScreen.main.bounds.width * (isAnimating ? finalPosition.x : position.x),
                y: UIScreen.main.bounds.height * (isAnimating ? finalPosition.y : position.y)
            )
            .rotationEffect(.degrees(isAnimating ? rotation : angle))
            .scaleEffect(scale)
            .opacity(opacity)
            .onAppear {
                // Randomize final position - if we have an origin, spread out from there
                if origin != nil {
                    finalPosition = CGPoint(
                        x: CGFloat.random(in: 0...1),
                        y: CGFloat.random(in: 0.7...1.2)
                    )
                } else {
                    finalPosition = CGPoint(
                        x: CGFloat.random(in: 0...1),
                        y: CGFloat.random(in: 0.7...1.2)
                    )
                }
                
                // Randomize rotation
                rotation = Double.random(in: 360...720)
                
                // Animate with delay based on position
                withAnimation(Animation.easeOut(duration: 3)
                    .delay(Double.random(in: 0...0.5))) {
                    opacity = 1.0
                }
                
                // Add a scale animation for more visual interest
                withAnimation(Animation.easeInOut(duration: 2)
                    .delay(Double.random(in: 0...0.5))
                    .repeatForever(autoreverses: true)) {
                    scale = CGFloat.random(in: 0.8...1.2)
                }
                
                // Animate the falling and rotation
                withAnimation(Animation.easeOut(duration: Double.random(in: 2...4))
                    .delay(Double.random(in: 0...0.5))) {
                    // This triggers the position and rotation changes
                    isAnimating = true
                }
                
                // Fade out at the end
                withAnimation(Animation.easeIn(duration: 0.5)
                    .delay(Double.random(in: 2.5...3.5))) {
                    opacity = 0
                }
            }
    }
    
    @ViewBuilder
    private var confettiShape: some View {
        switch shape {
        case .rectangle:
            Rectangle()
                .fill(color)
                .frame(width: size, height: size * 0.3)
        case .circle:
            Circle()
                .fill(color)
                .frame(width: size * 0.7, height: size * 0.7)
        case .triangle:
            Triangle()
                .fill(color)
                .frame(width: size, height: size)
        case .star:
            Star(corners: 5, smoothness: 0.45)
                .fill(color)
                .frame(width: size, height: size)
        }
    }
}

// Custom shapes for more interesting confetti
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

struct Star: Shape {
    let corners: Int
    let smoothness: CGFloat
    
    func path(in rect: CGRect) -> Path {
        guard corners >= 2 else { return Path() }
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * smoothness
        
        let path = Path { path in
            let angleStep = .pi * 2 / Double(corners * 2)
            
            for i in 0..<(corners * 2) {
                let radius = i.isMultiple(of: 2) ? outerRadius : innerRadius
                let angle = Double(i) * angleStep - .pi / 2
                let point = CGPoint(
                    x: center.x + CGFloat(cos(angle)) * radius,
                    y: center.y + CGFloat(sin(angle)) * radius
                )
                
                if i == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
        }
        
        return path
    }
}

#if DEBUG
struct ConfettiView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            ConfettiView()
        }
    }
}
#endif 
