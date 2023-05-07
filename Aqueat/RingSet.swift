//
//  RingSet.swift
//  Aqueat
//
//  Created by Leo Dion on 5/2/23.
//

import SwiftUI

struct RingSet: View {
  @State var value : CGFloat = 110
    var body: some View {
      ZStack{
        
          PercentageRing(ringWidth: 40, percent: value, startColor: .red, endColor: Color(hue: 0.9, saturation: 1.0, brightness: 1.0), overlayView: {
            Image(systemName: "arrow.forward")
          })
          .frame(width: 300, height: 300)
          
        
        
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
//        Stepper("", value: self.$value)
//
//        ActivityRingView(progress: .constant(2.75), width: 210).fixedSize()
//
//          ActivityRingView(progress: .constant(0.75), width: 120).fixedSize()
        
      }
    }
}

struct RingSet_Previews: PreviewProvider {
    static var previews: some View {
        RingSet()
    }
}
