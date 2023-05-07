//
//  ContentView.swift
//  Aqueat
//
//  Created by Leo Dion on 4/19/23.
//

import SwiftUI

extension Double {
    func toRadians() -> Double {
        return self * Double.pi / 180
    }
    func toCGFloat() -> CGFloat {
        return CGFloat(self)
    }
}

// https://liquidcoder.com/swiftui-ring-animation/
struct RingShape: Shape {
    // Helper function to convert percent values to angles in degrees
    static func percentToAngle(percent: Double, startAngle: Double) -> Double {
        (percent / 100 * 360) + startAngle
    }
    private var percent: Double
    private var startAngle: Double
    private let drawnClockwise: Bool
    
    // This allows animations to run smoothly for percent values
    var animatableData: Double {
        get {
            return percent
        }
        set {
            percent = newValue
        }
    }
    
    init(percent: Double = 100, startAngle: Double = -90, drawnClockwise: Bool = false) {
        self.percent = percent
        self.startAngle = startAngle
        self.drawnClockwise = drawnClockwise
    }
    
    // This draws a simple arc from the start angle to the end angle
    func path(in rect: CGRect) -> Path {
        let width = rect.width
        let height = rect.height
        let radius = min(width, height) / 2
        let center = CGPoint(x: width / 2, y: height / 2)
        let endAngle = Angle(degrees: RingShape.percentToAngle(percent: self.percent, startAngle: self.startAngle))
        return Path { path in
            path.addArc(center: center, radius: radius, startAngle: Angle(degrees: startAngle), endAngle: endAngle, clockwise: drawnClockwise)
        }
    }
}

struct PercentageRing: View {
    
  private static let ShadowColor: Color = Color.black.opacity(0.5)
    private static let ShadowRadius: CGFloat = 5
    private static let ShadowOffsetMultiplier: CGFloat = ShadowRadius + 2
    
    private let ringWidth: CGFloat
  private let percent : Double
  @State private var currentValue: Double = 0.0
    private let backgroundColor: Color
    private let foregroundColors: [Color]
    private let startAngle: Double = -90
  private let overlayView : () -> any View
    
    private var gradientStartAngle: Double {
        self.currentValue >= 100 ? relativePercentageAngle - 360 : startAngle
    }
    private var absolutePercentageAngle: Double {
        RingShape.percentToAngle(percent: self.currentValue, startAngle: 0)
    }
    private var relativePercentageAngle: Double {
        // Take into account the startAngle
        absolutePercentageAngle + startAngle
    }
    private var firstGradientColor: Color {
        self.foregroundColors.first ?? .black
    }
    private var lastGradientColor: Color {
        self.foregroundColors.last ?? .black
    }
    private var ringGradient: AngularGradient {
        AngularGradient(
            gradient: Gradient(colors: self.foregroundColors),
            center: .center,
            startAngle: Angle(degrees: self.gradientStartAngle),
            endAngle: Angle(degrees: relativePercentageAngle)
        )
    }
  init(ringWidth: CGFloat, percent: Double, startColor: Color, endColor: Color, overlayView: @escaping () -> any View) {
    self.init(ringWidth: ringWidth, percent: percent, backgroundColor: startColor.opacity(0.2), foregroundColors: [startColor, endColor], overlayView: overlayView)
  }
    
  init(ringWidth: CGFloat, percent: Double, backgroundColor: Color, foregroundColors: [Color], overlayView: @escaping () -> any View) {
        self.ringWidth = ringWidth
        self.percent = percent
        self.backgroundColor = backgroundColor
        self.foregroundColors = foregroundColors
    self.overlayView = overlayView
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
              AnyView(overlayView()).offset(y: -geometry.size.height / 2).zIndex(100)
                // Background for the ring
                RingShape()
                    .stroke(style: StrokeStyle(lineWidth: self.ringWidth))
                    
                // Foreground
                RingShape(percent: self.currentValue, startAngle: self.startAngle)
                    .stroke(style: StrokeStyle(lineWidth: self.ringWidth, lineCap: .round))
                    .fill(self.ringGradient)
                // End of ring with drop shadow
                //if self.getShowShadow(frame: geometry.size) {
                    Circle()
                        .fill(self.lastGradientColor)
                        .frame(width: self.ringWidth, height: self.ringWidth, alignment: .center)
                        .position(x: geometry.size.width / 2,
                                y: 0)
                        .shadow(color: PercentageRing.ShadowColor,
                                radius: PercentageRing.ShadowRadius,
                                x: 5,
                                y: 0)
                        .mask(Rectangle()
//                          .frame(width: self.ringWidth / 4, height: self.ringWidth, alignment: .trailing)
                          .offset(x: 3 * self.ringWidth, y: -self.ringWidth)
                        )
                        .rotationEffect(.init(degrees: currentValue / 100 * 360))
                        
                //}
            }
        }
        // Padding to ensure that the entire ring fits within the view size allocated
        .padding(self.ringWidth / 2)
        .animation(.easeInOut(duration: 1.0), value: currentValue)
        .onAppear{
          self.currentValue = percent
        }
    }
    
    private func getEndCircleLocation(frame: CGSize) -> (CGFloat, CGFloat) {
        // Get angle of the end circle with respect to the start angle
        let angleOfEndInRadians: Double = relativePercentageAngle.toRadians()
        let offsetRadius = min(frame.width, frame.height) / 2
        let location = (offsetRadius * cos(angleOfEndInRadians).toCGFloat(), offsetRadius * sin(angleOfEndInRadians).toCGFloat())
        print(location)
      return location
    }
    
    private func getEndCircleShadowOffset() -> (CGFloat, CGFloat) {
        let angleForOffset = absolutePercentageAngle + (self.startAngle + 90)
        let angleForOffsetInRadians = angleForOffset.toRadians()
        let relativeXOffset = cos(angleForOffsetInRadians)
        let relativeYOffset = sin(angleForOffsetInRadians)
        let xOffset = relativeXOffset.toCGFloat() * PercentageRing.ShadowOffsetMultiplier
        let yOffset = relativeYOffset.toCGFloat() * PercentageRing.ShadowOffsetMultiplier
        return (xOffset, yOffset)
    }
    
    private func getShowShadow(frame: CGSize) -> Bool {
        let circleRadius = min(frame.width, frame.height) / 2
        let remainingAngleInRadians = (360 - absolutePercentageAngle).toRadians().toCGFloat()
        if self.currentValue >= 100 {
            return true
        } else if circleRadius * remainingAngleInRadians <= self.ringWidth {
            return true
        }
        return false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
      ZStack{
        PercentageRing(ringWidth: 40, percent: 125, startColor: .red, endColor: Color(hue: 0.9, saturation: 1.0, brightness: 1.0), overlayView: {
            Image(systemName: "arrow.forward")
          })
          .frame(width: 300, height: 300)
          .animation(.default, value: 100)
          
//
//
//        PercentageRing(ringWidth: 40, percent: 125, startColor: .red, endColor: Color(hue: 0.9, saturation: 1.0, brightness: 1.0), overlayView: {
//          Image(systemName: "arrow.forward")
//        }).frame(width: 215, height: 215)
//
//
//
//        PercentageRing(ringWidth: 40, percent: 125, startColor: .red, endColor: Color(hue: 0.9, saturation: 1.0, brightness: 1.0), overlayView: {
//          Image(systemName: "arrow.forward")
//        }).frame(width: 130, height: 130)
//
//        ActivityRingView(progress: .constant(2.75), width: 210).fixedSize()
//
//          ActivityRingView(progress: .constant(0.75), width: 120).fixedSize()
        
      }
    }
}
